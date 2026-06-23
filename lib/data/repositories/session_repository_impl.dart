import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/payout_account.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SharedPreferences prefs;

  static const _payoutKey = 'payout_account';

  SessionRepositoryImpl({required this.prefs});

  @override
  Future<PayoutAccount?> getPayoutAccount() async {
    final raw = prefs.getString(_payoutKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return PayoutAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePayoutAccount(PayoutAccount account) async {
    await prefs.setString(_payoutKey, jsonEncode(account.toJson()));
  }
}
