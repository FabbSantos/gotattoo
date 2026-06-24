import 'package:equatable/equatable.dart';

import 'booking_status.dart';

/// A tattoo appointment: a client books a [productId] with an [artistId] for a
/// [scheduledAt] date/time. Money is held in (simulated) escrow until the
/// appointment is completed (artist paid) or cancelled/rejected (client refunded).
class Booking extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String artistId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final DateTime scheduledAt;
  final int durationHours;
  final BookingStatus status;
  final DateTime createdAt;

  /// Real Stripe-driven payment state: none | saved | paid | refunded | failed.
  final String paymentStatus;

  const Booking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.artistId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    this.durationHours = 2,
    this.paymentStatus = 'none',
  });

  /// Whether the card was actually charged (money held on the platform).
  bool get isPaid => paymentStatus == 'paid';
  bool get isRefunded => paymentStatus == 'refunded';
  bool get paymentFailed => paymentStatus == 'failed';

  Booking copyWith({BookingStatus? status, String? paymentStatus}) => Booking(
    id: id,
    clientId: clientId,
    clientName: clientName,
    artistId: artistId,
    productId: productId,
    productName: productName,
    productImageUrl: productImageUrl,
    price: price,
    scheduledAt: scheduledAt,
    durationHours: durationHours,
    status: status ?? this.status,
    createdAt: createdAt,
    paymentStatus: paymentStatus ?? this.paymentStatus,
  );

  @override
  List<Object?> get props => [
    id,
    clientId,
    clientName,
    artistId,
    productId,
    productName,
    productImageUrl,
    price,
    scheduledAt,
    durationHours,
    status,
    createdAt,
    paymentStatus,
  ];
}
