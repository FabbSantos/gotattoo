import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/product_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final SharedPreferences prefs;

  static const _key = 'orders';

  OrderRepositoryImpl({required this.prefs});

  List<Order> _readAll() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => _orderFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<Order> orders) async {
    final payload = orders.map(_orderToJson).toList();
    await prefs.setString(_key, jsonEncode(payload));
  }

  @override
  Future<List<Order>> ordersFor(String userId) async {
    final all = _readAll().where((o) => o.userId == userId).toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<List<Order>> salesFor(String artistId) async {
    final all = _readAll()
        .where((o) => o.items.any((i) => i.product.artistId == artistId))
        .toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<void> placeOrder(Order order) async {
    final all = _readAll()..add(order);
    await _writeAll(all);
  }

  Map<String, dynamic> _orderToJson(Order order) => {
    'id': order.id,
    'userId': order.userId,
    'total': order.total,
    'createdAt': order.createdAt.toIso8601String(),
    'items': order.items
        .map(
          (item) => {
            'product': ProductModel.fromEntity(item.product).toJson(),
            'quantity': item.quantity,
          },
        )
        .toList(),
  };

  Order _orderFromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['userId'] as String,
    total: (json['total'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    items: (json['items'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (e) => CartItem(
            product: ProductModel.fromJson(e['product'] as Map<String, dynamic>),
            quantity: (e['quantity'] as num).toInt(),
          ),
        )
        .toList(),
  );
}
