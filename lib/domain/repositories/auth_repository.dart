import '../entities/auth_user.dart';
import '../entities/user_role.dart';

/// Authentication boundary. Implementations throw [AuthException] on failure.
abstract class AuthRepository {
  /// The currently logged-in user, or null if none.
  Future<AuthUser?> currentUser();

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? portfolio,
    String? instagram,
  });

  Future<AuthUser> login({required String email, required String password});

  /// Sign in with Google (native flow → Supabase ID-token exchange).
  Future<AuthUser> signInWithGoogle();

  /// Updates the current user's editable profile fields and returns the result.
  Future<AuthUser> updateProfile({
    String? name,
    String? nickname,
    String? avatarPath,
    double? latitude,
    double? longitude,
    String? portfolio,
    String? instagram,
  });

  /// Ask (or re-ask) to become an artist: sets status to pending, saves the
  /// portfolio link and notifies the owner.
  Future<void> requestArtist(String portfolio);

  /// Permanently delete the current user's account and all their data.
  Future<void> deleteAccount();

  Future<void> logout();
}
