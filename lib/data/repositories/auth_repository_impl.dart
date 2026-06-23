import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

/// Local mock authentication backed by [SharedPreferences]. Stores a map of
/// registered users keyed by e-mail plus the current session's e-mail.
///
/// Passwords are stored in plain text — acceptable only because this is a
/// local demo with no backend. Real auth is on the roadmap.
class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences prefs;

  static const _usersKey = 'auth_users';
  static const _currentKey = 'auth_current_email';

  AuthRepositoryImpl({required this.prefs});

  Map<String, dynamic> _readUsers() {
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeUsers(Map<String, dynamic> users) async {
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Seeds the mock catalog artists as real, log-in-able accounts so the artist
  /// experience can be tested. Each account's id matches the artist id used in
  /// the products' `artistId`, so their tattoos and sales line up.
  /// Demo password for all: `gotattoo`.
  static const _seededFlag = 'auth_seeded_artists';
  static const demoPassword = 'gotattoo';

  static const _demoArtists = [
    ['1', 'João Silva', 'joao@gotattoo.com'],
    ['2', 'Ana Costa', 'ana@gotattoo.com'],
    ['3', 'Pedro Matos', 'pedro@gotattoo.com'],
    ['4', 'Carla Dias', 'carla@gotattoo.com'],
    ['5', 'Lucas Reis', 'lucas@gotattoo.com'],
  ];

  Future<void> seedDemoArtistsIfEmpty() async {
    if (prefs.getBool(_seededFlag) ?? false) return;
    final users = _readUsers();
    for (final a in _demoArtists) {
      final user = AuthUser(
        id: a[0],
        name: a[1],
        email: a[2],
        role: UserRole.artist,
      );
      users[a[2]] = {'password': demoPassword, 'user': user.toJson()};
    }
    await _writeUsers(users);
    await prefs.setBool(_seededFlag, true);
  }

  @override
  Future<AuthUser?> currentUser() async {
    final email = prefs.getString(_currentKey);
    if (email == null) return null;
    final users = _readUsers();
    final record = users[email] as Map<String, dynamic>?;
    if (record == null) return null;
    return AuthUser.fromJson(record['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final key = email.trim().toLowerCase();
    final users = _readUsers();
    if (users.containsKey(key)) {
      throw const AuthException('Esse e-mail já está cadastrado.');
    }
    final user = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: key,
      role: role,
    );
    users[key] = {'password': password, 'user': user.toJson()};
    await _writeUsers(users);
    await prefs.setString(_currentKey, key);
    return user;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    final users = _readUsers();
    final record = users[key] as Map<String, dynamic>?;
    if (record == null || record['password'] != password) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    await prefs.setString(_currentKey, key);
    return AuthUser.fromJson(record['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthUser> updateProfile({
    String? name,
    String? nickname,
    String? avatarPath,
    double? latitude,
    double? longitude,
  }) async {
    final email = prefs.getString(_currentKey);
    final users = _readUsers();
    final record = email == null ? null : users[email] as Map<String, dynamic>?;
    if (email == null || record == null) {
      throw const AuthException('Nenhum usuário logado.');
    }
    final current = AuthUser.fromJson(record['user'] as Map<String, dynamic>);
    final updated = current.copyWith(
      name: name,
      nickname: nickname,
      avatarPath: avatarPath,
      latitude: latitude,
      longitude: longitude,
    );
    users[email] = {'password': record['password'], 'user': updated.toJson()};
    await _writeUsers(users);
    return updated;
  }

  @override
  Future<void> logout() async {
    await prefs.remove(_currentKey);
  }
}
