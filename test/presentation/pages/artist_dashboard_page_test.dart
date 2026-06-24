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
import 'package:gotattoo/presentation/bloc/product/product_state.dart';
import 'package:gotattoo/presentation/bloc/session/session_cubit.dart';
import 'package:gotattoo/presentation/pages/artist/artist_dashboard_page.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockProductBloc productBloc;
  late MockAuthCubit authCubit;
  late SessionCubit session;

  setUp(() async {
    productBloc = MockProductBloc();
    authCubit = MockAuthCubit();
    session = SessionCubit(repository: InMemorySessionRepository());
    await sl.reset();
    sl.registerFactory<ProductBloc>(() => productBloc);
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(
        status: AuthStatus.authenticated,
        user: AuthUser(
          id: '3',
          name: 'Pedro',
          email: 'pedro@x.com',
          role: UserRole.artist,
        ),
      ),
    );
  });

  tearDown(() async => sl.reset());

  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: session),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: const MaterialApp(home: ArtistDashboardPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the gross estimated revenue (artist keeps 100%)', (
    tester,
  ) async {
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      // 1200 + 350 = 1550 gross; no platform fee in the P2P model.
      initialState: ProductsLoaded(
        const [tProduct, tProductMinimalist],
        selectedCategory: 'Todas',
      ),
    );

    await pumpDashboard(tester);

    expect(find.text('Faturamento estimado'), findsOneWidget);
    expect(find.textContaining('1550.00'), findsOneWidget);
    expect(find.textContaining('2 tatuagens'), findsOneWidget);
    expect(find.textContaining('100%'), findsOneWidget);
  });
}
