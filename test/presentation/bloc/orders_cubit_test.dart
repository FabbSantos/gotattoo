import 'package:bloc_test/bloc_test.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:gotattoo/domain/entities/order.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_cubit.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_state.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  final order = Order(
    id: '1',
    userId: 'u1',
    items: const [CartItem(product: tProduct, quantity: 1)],
    total: tProduct.price,
    createdAt: DateTime(2026, 1, 1),
  );

  blocTest<OrdersCubit, OrdersState>(
    'load fetches the user orders',
    build: () => OrdersCubit(repository: InMemoryOrderRepository([order])),
    act: (cubit) => cubit.load('u1'),
    expect: () => [
      const OrdersState(loading: true),
      OrdersState(orders: [order]),
    ],
  );

  blocTest<OrdersCubit, OrdersState>(
    'place stores the order and reloads the history',
    build: () => OrdersCubit(repository: InMemoryOrderRepository()),
    act: (cubit) => cubit.place(order),
    expect: () => [
      OrdersState(orders: [order]),
    ],
  );
}
