import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/auth_user.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_state.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_bloc.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_event.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_cubit.dart';
import 'package:gotattoo/presentation/pages/user/payment_page.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockAuthCubit authCubit;

  const user = AuthUser(
    id: 'u1',
    name: 'Fab',
    email: 'fab@x.com',
    role: UserRole.client,
  );

  setUp(() {
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(status: AuthStatus.authenticated, user: user),
    );
  });

  testWidgets('paying records the order and clears the cart', (tester) async {
    final cart = CartBloc(repository: InMemoryCartRepository())
      ..add(const AddToCart(tProduct));
    final orders = OrdersCubit(repository: InMemoryOrderRepository());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CartBloc>.value(value: cart),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<OrdersCubit>.value(value: orders),
        ],
        child: const MaterialApp(home: PaymentPage(total: 1200)),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('PAGAR'));
    // Let the simulated processing delay (1500ms) resolve.
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.text('Pagamento aprovado!'), findsOneWidget);
    expect(cart.state.isEmpty, isTrue);
    expect(orders.state.orders.length, 1);
    expect(orders.state.orders.first.userId, 'u1');
  });
}
