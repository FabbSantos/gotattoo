import 'package:equatable/equatable.dart';

import '../../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  bool get isEmpty => items.isEmpty;

  /// Total number of units across all lines.
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price across all lines.
  double get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
