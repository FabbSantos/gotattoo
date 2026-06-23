import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/exceptions.dart';
import 'package:gotattoo/data/repositories/auth_repository_impl.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = AuthRepositoryImpl(prefs: prefs);
  });

  Future<dynamic> signUpSample() => repository.signUp(
    name: 'Fab',
    email: 'fab@x.com',
    password: '1234',
    role: UserRole.artist,
  );

  test('currentUser is null before any sign-up', () async {
    expect(await repository.currentUser(), isNull);
  });

  test('signUp creates the user and logs them in', () async {
    final user = await signUpSample();
    expect(user.email, 'fab@x.com');
    expect(user.role, UserRole.artist);
    expect((await repository.currentUser())?.email, 'fab@x.com');
  });

  test('signUp with a duplicate e-mail throws AuthException', () async {
    await signUpSample();
    expect(signUpSample(), throwsA(isA<AuthException>()));
  });

  test('login succeeds with the right password', () async {
    await signUpSample();
    await repository.logout();
    final user = await repository.login(email: 'fab@x.com', password: '1234');
    expect(user.email, 'fab@x.com');
  });

  test('login throws AuthException on wrong credentials', () async {
    await signUpSample();
    expect(
      repository.login(email: 'fab@x.com', password: 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });

  test('logout clears the current user', () async {
    await signUpSample();
    await repository.logout();
    expect(await repository.currentUser(), isNull);
  });
}
