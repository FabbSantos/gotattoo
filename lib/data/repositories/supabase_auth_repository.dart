import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/config/google_auth_config.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth backed by Supabase Auth + the `profiles` table + the `avatars` storage
/// bucket. Implements the same [AuthRepository] contract as the local mock, so
/// the rest of the app is unchanged.
class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient client;

  SupabaseAuthRepository(this.client);

  Future<AuthUser> _toUser(sb.User user) async {
    final profile = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    final map = profile ?? const {};
    return AuthUser(
      id: user.id,
      name: (map['name'] as String?) ?? '',
      email: user.email ?? '',
      role: UserRole.fromName(map['role'] as String?),
      nickname: map['nickname'] as String?,
      avatarPath: map['avatar_url'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isOwner: map['is_owner'] as bool? ?? false,
      artistStatus: map['artist_status'] as String? ?? 'none',
      portfolio: map['portfolio'] as String? ?? '',
      instagram: map['instagram'] as String? ?? '',
      rejectReason: map['reject_reason'] as String? ?? '',
    );
  }

  @override
  Future<AuthUser?> currentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return _toUser(user);
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? portfolio,
    String? instagram,
  }) async {
    try {
      final res = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'role': role.name,
          if (portfolio != null) 'portfolio': portfolio,
          if (instagram != null) 'instagram': instagram,
        },
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException('Não foi possível criar a conta.');
      }
      // Read the profile the trigger created: artists join as pending clients.
      return _toUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException('E-mail ou senha inválidos.');
      }
      return _toUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: GoogleAuthConfig.webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Login cancelado.');
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (idToken == null) {
        throw const AuthException('Não foi possível autenticar com o Google.');
      }
      final res = await client.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException('Falha no login com o Google.');
      }
      return _toUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<AuthUser> updateProfile({
    String? name,
    String? nickname,
    String? avatarPath,
    double? latitude,
    double? longitude,
    String? portfolio,
    String? instagram,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Nenhum usuário logado.');
    }

    String? avatarUrl;
    final isLocalFile = avatarPath != null &&
        avatarPath.isNotEmpty &&
        !avatarPath.startsWith('http');
    if (isLocalFile) {
      final objectPath = '${user.id}/avatar.jpg';
      await client.storage.from('avatars').upload(
            objectPath,
            File(avatarPath),
            fileOptions: const sb.FileOptions(upsert: true),
          );
      avatarUrl = client.storage.from('avatars').getPublicUrl(objectPath);
      // Cache-bust so the new image shows immediately.
      avatarUrl = '$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      avatarUrl = avatarPath;
    }

    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (portfolio != null) 'portfolio': portfolio,
      if (instagram != null) 'instagram': instagram,
    };
    if (updates.isNotEmpty) {
      await client.from('profiles').update(updates).eq('id', user.id);
    }
    return _toUser(user);
  }

  @override
  Future<void> requestArtist(String portfolio) async {
    await client.rpc('request_artist', params: {'p_portfolio': portfolio});
  }

  @override
  Future<void> deleteAccount() async {
    await client.rpc('delete_my_account');
    await client.auth.signOut();
  }

  @override
  Future<void> logout() => client.auth.signOut();
}
