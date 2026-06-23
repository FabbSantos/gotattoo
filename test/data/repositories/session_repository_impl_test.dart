import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/repositories/session_repository_impl.dart';
import 'package:gotattoo/domain/entities/payout_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SessionRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = SessionRepositoryImpl(prefs: prefs);
  });

  test('returns null when no payout account is stored', () async {
    expect(await repository.getPayoutAccount(), isNull);
  });

  test('persists and reads back the payout account', () async {
    const account = PayoutAccount(provider: 'PayPal', identifier: 'a@b.com');
    await repository.savePayoutAccount(account);
    expect(await repository.getPayoutAccount(), account);
  });
}
