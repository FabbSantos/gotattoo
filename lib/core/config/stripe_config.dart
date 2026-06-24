/// Stripe configuration, supplied at build time via --dart-define.
///
/// When [publishableKey] is empty the app builds and runs normally with the
/// (simulated) escrow flow; payments stay dormant until the key is provided.
abstract class StripeConfig {
  static const String publishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool get isConfigured => publishableKey.isNotEmpty;
}
