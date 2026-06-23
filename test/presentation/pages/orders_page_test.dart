import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/auth_user.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:gotattoo/domain/entities/order.dart';
import 'package:gotattoo/domain/entities/user_role.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_state.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_cubit.dart';
import 'package:gotattoo/presentation/pages/user/orders_page.dart';

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

  final order = Order(
    id: '1',
    userId: 'u1',
    items: const [CartItem(product: tProduct, quantity: 2)],
    total: 2400,
    createdAt: DateTime(2026, 6, 1),
  );

  setUp(() {
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(status: AuthStatus.authenticated, user: user),
    );
  });

  Future<void> pumpOrders(WidgetTester tester, OrdersCubit orders) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<OrdersCubit>.value(value: orders),
        ],
        child: const MaterialApp(home: OrdersPage()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the empty state when there are no orders', (tester) async {
    final orders = OrdersCubit(repository: InMemoryOrderRepository());
    await pumpOrders(tester, orders);
    expect(find.text('Você ainda não fez pedidos'), findsOneWidget);
  });

  testWidgets('lists the signed-in user orders', (tester) async {
    final orders = OrdersCubit(repository: InMemoryOrderRepository([order]));
    await pumpOrders(tester, orders);

    expect(find.textContaining('2x Dragão Oriental'), findsOneWidget);
    expect(find.textContaining('2400.00'), findsOneWidget);
  });
}
