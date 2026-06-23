import 'package:equatable/equatable.dart';

/// Where an artist gets paid. A PayPal-style stand-in until real payment
/// onboarding (Stripe Connect / PayPal) lands — see ROADMAP.md.
class PayoutAccount extends Equatable {
  /// e.g. 'PayPal'.
  final String provider;

  /// e.g. the PayPal email / account identifier.
  final String identifier;

  const PayoutAccount({required this.provider, required this.identifier});

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'identifier': identifier,
  };

  factory PayoutAccount.fromJson(Map<String, dynamic> json) {
    return PayoutAccount(
      provider: json['provider'] as String,
      identifier: json['identifier'] as String,
    );
  }

  @override
  List<Object?> get props => [provider, identifier];
}
