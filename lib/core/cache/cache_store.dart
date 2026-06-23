import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Tiny JSON snapshot cache on top of [SharedPreferences].
///
/// Used for "cache-then-network": a screen reads the last snapshot instantly
/// (offline-friendly), then refreshes from the backend and rewrites it.
class CacheStore {
  final SharedPreferences prefs;

  CacheStore(this.prefs);

  /// Read a cached list of rows, or null if absent/corrupt.
  List<Map<String, dynamic>>? readList(String key) {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> rows) =>
      prefs.setString(key, jsonEncode(rows));

  Future<void> remove(String key) => prefs.remove(key);
}
