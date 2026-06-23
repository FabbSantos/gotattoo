import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/exceptions.dart';
import 'package:gotattoo/domain/entities/auth_user.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  const user = AuthUser(
    id: '1',
    name: 'Fab',
    email: 'fab@x.com',
    role: UserRole.client,
  );

  setUpAll(() => registerFallbackValue(UserRole.client));
  setUp(() => repository = MockAuthRepository());

  group('checkAuth', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when a user is stored',
      setUp: () =>
          when(() => repository.currentUser()).thenAnswer((_) async => user),
      build: () => AuthCubit(repository: repository),
      act: (cubit) => cubit.checkAuth(),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated, user: user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated when no user is stored',
      setUp: () =>
          when(() => repository.currentUser()).thenAnswer((_) async => null),
      build: () => AuthCubit(repository: repository),
      act: (cubit) => cubit.checkAuth(),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated on success',
      setUp: () => when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user),
      build: () => AuthCubit(repository: repository),
      act: (cubit) => cubit.login(email: 'fab@x.com', password: '1234'),
      expect: () => [
        const AuthState(submitting: true),
        const AuthState(status: AuthStatus.authenticated, user: user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits an error on bad credentials',
      setUp: () => when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('E-mail ou senha inválidos.')),
      build: () => AuthCubit(repository: repository),
      act: (cubit) => cubit.login(email: 'fab@x.com', password: 'x'),
      expect: () => [
        const AuthState(submitting: true),
        const AuthState(error: 'E-mail ou senha inválidos.'),
      ],
    );
  });

  blocTest<AuthCubit, AuthState>(
    'logout emits unauthenticated',
    setUp: () => when(() => repository.logout()).thenAnswer((_) async {}),
    build: () => AuthCubit(repository: repository),
    act: (cubit) => cubit.logout(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );
}
