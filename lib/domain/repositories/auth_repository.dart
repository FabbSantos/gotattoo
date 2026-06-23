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
  });

  Future<AuthUser> login({required String email, required String password});

  /// Updates the current user's editable profile fields and returns the result.
  Future<AuthUser> updateProfile({
    String? name,
    String? nickname,
    String? avatarPath,
    double? latitude,
    double? longitude,
  });

  Future<void> logout();
}
