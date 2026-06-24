import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/stripe_config.dart';

/// A card saved on the client's Stripe customer.
class SavedCard {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory SavedCard.fromJson(Map<String, dynamic> j) => SavedCard(
        id: j['id'] as String,
        brand: j['brand'] as String? ?? 'card',
        last4: j['last4'] as String? ?? '????',
        expMonth: (j['exp_month'] as num?)?.toInt() ?? 0,
        expYear: (j['exp_year'] as num?)?.toInt() ?? 0,
      );
}

/// Stripe payments (Phase 1): collect/save a card at booking time, then charge
/// off-session when the artist approves, and refund on cancel/reject.
///
/// Fully guarded: when Stripe isn't configured (no publishable key) every method
/// is a harmless no-op, so the app keeps the simulated-escrow flow and builds
/// without any Stripe setup.
class PaymentService {
  bool get isConfigured => StripeConfig.isConfigured;

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> init() async {
    if (!isConfigured) return;
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Presents the Payment Sheet to save a card (SetupIntent — no charge).
  /// Returns true if the customer added a card, false if cancelled/unconfigured.
  Future<bool> collectCard() async {
    if (!isConfigured) return false;
    final res = await _client.functions.invoke('stripe-setup-intent');
    final data = (res.data as Map).cast<String, dynamic>();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'GoTattoo',
        customerId: data['customer'] as String,
        customerEphemeralKeySecret: data['ephemeralKey'] as String,
        setupIntentClientSecret: data['setupIntent'] as String,
      ),
    );
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException {
      return false; // user dismissed the sheet
    }
  }

  /// Charges the saved card for [bookingId] (server-side, off-session) and
  /// confirms the booking. Returns true on success. No-op success when Stripe
  /// isn't configured (caller falls back to the simulated flow).
  Future<bool> chargeBooking(String bookingId) async {
    if (!isConfigured) return true;
    final res = await _client.functions.invoke(
      'stripe-charge-booking',
      body: {'booking_id': bookingId},
    );
    final data = res.data;
    return data is Map && data['ok'] == true;
  }

  /// The client's saved cards.
  Future<List<SavedCard>> listCards() async {
    if (!isConfigured) return const [];
    final res = await _client.functions.invoke('stripe-payment-methods');
    final cards = (res.data?['cards'] as List?) ?? const [];
    return cards
        .map((c) => SavedCard.fromJson((c as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Removes a saved card.
  Future<void> removeCard(String paymentMethodId) async {
    if (!isConfigured) return;
    await _client.functions.invoke(
      'stripe-payment-methods',
      body: {'action': 'detach', 'payment_method_id': paymentMethodId},
    );
  }

  /// Refunds a charged booking (server-side). No-op when unconfigured.
  Future<void> refundBooking(String bookingId) async {
    if (!isConfigured) return;
    await _client.functions.invoke(
      'stripe-refund-booking',
      body: {'booking_id': bookingId},
    );
  }
}
