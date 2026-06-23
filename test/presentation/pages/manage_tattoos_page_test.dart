import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/di/injection_container.dart';
import 'package:gotattoo/domain/entities/auth_user.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_state.dart';
import 'package:gotattoo/presentation/bloc/product/product_bloc.dart';
import 'package:gotattoo/presentation/bloc/product/product_event.dart';
import 'package:gotattoo/presentation/bloc/product/product_state.dart';
import 'package:gotattoo/presentation/pages/artist/manage_tattoos_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_network_image.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockProductBloc productBloc;
  late MockAuthCubit authCubit;

  const artist = AuthUser(
    id: '3',
    name: 'Pedro',
    email: 'pedro@x.com',
    role: UserRole.artist,
  );

  setUpAll(() => registerFallbackValue(const DeleteProductEvent('1')));

  setUp(() async {
    productBloc = MockProductBloc();
    authCubit = MockAuthCubit();
    await sl.reset();
    sl.registerFactory<ProductBloc>(() => productBloc);
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      initialState: ProductsLoaded([tProduct], selectedCategory: 'Todas'),
    );
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(
        status: AuthStatus.authenticated,
        user: artist,
      ),
    );
  });

  tearDown(() async => sl.reset());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(home: ManageTattoosPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('lists the artist tattoos', (tester) async {
    await mockNetworkImages(() async {
      await pumpPage(tester);
      expect(find.text('Dragão Oriental'), findsOneWidget);
    });
  });

  testWidgets('confirming delete dispatches DeleteProductEvent', (
    tester,
  ) async {
    await mockNetworkImages(() async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover'));
      await tester.pump();
    });

    verify(() => productBloc.add(const DeleteProductEvent('1'))).called(1);
  });
}
