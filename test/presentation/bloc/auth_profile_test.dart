import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/repositories/auth_repository_impl.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = AuthRepositoryImpl(prefs: prefs);
  });

  test('updateProfile persists nickname and avatar for the current user', () async {
    await repository.signUp(
      name: 'Fab',
      email: 'fab@x.com',
      password: '1234',
      role: UserRole.client,
    );

    final updated = await repository.updateProfile(
      nickname: 'fabz',
      avatarPath: '/img/a.png',
    );

    expect(updated.nickname, 'fabz');
    expect(updated.avatarPath, '/img/a.png');
    expect(updated.displayName, 'fabz');
    expect((await repository.currentUser())?.nickname, 'fabz');
  });

  blocTest<AuthCubit, AuthState>(
    'AuthCubit.updateProfile emits the updated user',
    setUp: () async {
      await repository.signUp(
        name: 'Fab',
        email: 'fab@x.com',
        password: '1234',
        role: UserRole.client,
      );
    },
    build: () => AuthCubit(repository: repository),
    act: (cubit) => cubit.updateProfile(name: 'Fabrício', nickname: 'fabz'),
    expect: () => [
      isA<AuthState>()
          .having((s) => s.user?.name, 'name', 'Fabrício')
          .having((s) => s.user?.nickname, 'nickname', 'fabz')
          .having((s) => s.status, 'status', AuthStatus.authenticated),
    ],
  );
}
