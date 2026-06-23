import 'package:equatable/equatable.dart';

import 'cart_item.dart';

/// A placed order: a snapshot of the cart at checkout time, tied to a buyer.
class Order extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  @override
  List<Object?> get props => [id, userId, items, total, createdAt];
}
