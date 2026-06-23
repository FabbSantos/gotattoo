import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/di/injection_container.dart';
import 'package:gotattoo/core/utils/credential_store.dart';
import 'package:gotattoo/domain/entities/auth_user.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/pages/auth/login_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late AuthCubit authCubit;

  setUp(() async {
    repository = MockAuthRepository();
    authCubit = AuthCubit(repository: repository);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await sl.reset();
    sl.registerLazySingleton(() => CredentialStore(prefs));
  });

  tearDown(() async => sl.reset());

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('does not call login when fields are empty', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('calls login with the entered credentials', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AuthUser(
        id: '1',
        name: 'Fab',
        email: 'fab@x.com',
        role: UserRole.client,
      ),
    );

    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'fab@x.com');
    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    verify(
      () => repository.login(email: 'fab@x.com', password: '1234'),
    ).called(1);
  });
}
