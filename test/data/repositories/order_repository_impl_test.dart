import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/repositories/order_repository_impl.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:gotattoo/domain/entities/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fixtures.dart';

void main() {
  late OrderRepositoryImpl repository;

  Order order(String id, String userId, DateTime when) => Order(
    id: id,
    userId: userId,
    items: const [CartItem(product: tProduct, quantity: 1)],
    total: tProduct.price,
    createdAt: when,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = OrderRepositoryImpl(prefs: prefs);
  });

  test('ordersFor returns empty initially', () async {
    expect(await repository.ordersFor('u1'), isEmpty);
  });

  test('placeOrder persists and ordersFor returns it', () async {
    await repository.placeOrder(order('1', 'u1', DateTime(2026, 1, 1)));
    final orders = await repository.ordersFor('u1');
    expect(orders.length, 1);
    expect(orders.first.id, '1');
    expect(orders.first.items.first.product.id, tProduct.id);
  });

  test('ordersFor filters by user', () async {
    await repository.placeOrder(order('1', 'u1', DateTime(2026, 1, 1)));
    await repository.placeOrder(order('2', 'u2', DateTime(2026, 1, 2)));
    expect((await repository.ordersFor('u1')).length, 1);
    expect((await repository.ordersFor('u2')).single.id, '2');
  });

  test('ordersFor returns most recent first', () async {
    await repository.placeOrder(order('old', 'u1', DateTime(2026, 1, 1)));
    await repository.placeOrder(order('new', 'u1', DateTime(2026, 6, 1)));
    final orders = await repository.ordersFor('u1');
    expect(orders.map((o) => o.id).toList(), ['new', 'old']);
  });
}
