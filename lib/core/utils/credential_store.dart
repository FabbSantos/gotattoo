import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the login email/password on the device so they can be pre-filled.
///
/// Note: passwords are stored in plain shared_preferences — fine for a demo,
/// but production should use `flutter_secure_storage` (roadmap).
class CredentialStore {
  final SharedPreferences prefs;

  static const _flagKey = 'remember_me';
  static const _emailKey = 'remember_email';
  static const _passwordKey = 'remember_password';

  CredentialStore(this.prefs);

  bool get rememberMe => prefs.getBool(_flagKey) ?? false;
  String get email => prefs.getString(_emailKey) ?? '';
  String get password => prefs.getString(_passwordKey) ?? '';

  Future<void> save(String email, String password) async {
    await prefs.setBool(_flagKey, true);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  Future<void> clear() async {
    await prefs.remove(_flagKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}
