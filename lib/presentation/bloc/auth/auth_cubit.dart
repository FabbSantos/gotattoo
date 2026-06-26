import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/exceptions.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(const AuthState());

  /// Resolves the initial auth status on app start.
  Future<void> checkAuth() async {
    final user = await repository.currentUser();
    emit(
      AuthState(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(submitting: true, error: null));
    try {
      final user = await repository.login(email: email, password: password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(submitting: true, error: null));
    try {
      final user = await repository.signInWithGoogle();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? portfolio,
    String? instagram,
  }) async {
    emit(state.copyWith(submitting: true, error: null));
    try {
      final user = await repository.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
        portfolio: portfolio,
        instagram: instagram,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? nickname,
    String? avatarPath,
    double? latitude,
    double? longitude,
    String? portfolio,
    String? instagram,
  }) async {
    final user = await repository.updateProfile(
      name: name,
      nickname: nickname,
      avatarPath: avatarPath,
      latitude: latitude,
      longitude: longitude,
      portfolio: portfolio,
      instagram: instagram,
    );
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  /// Re-fetch the signed-in user (e.g. after the owner approves an artist, so
  /// the new 'artist' role takes effect without a re-login).
  Future<void> refresh() async {
    if (state.status != AuthStatus.authenticated) return;
    final user = await repository.currentUser();
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    }
  }

  /// Ask (or re-ask) to become an artist, then refresh so the UI updates.
  Future<void> requestArtist(String portfolio) async {
    await repository.requestArtist(portfolio);
    await refresh();
  }

  Future<void> logout() async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
