import '../entities/payout_account.dart';

/// Persists the artist's payout account.
abstract class SessionRepository {
  Future<PayoutAccount?> getPayoutAccount();
  Future<void> savePayoutAccount(PayoutAccount account);
}
