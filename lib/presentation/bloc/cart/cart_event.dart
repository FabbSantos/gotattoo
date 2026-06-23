import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Adds [quantity] units of [product] to the cart (merging if already present).
class AddToCart extends CartEvent {
  final Product product;
  final int quantity;

  const AddToCart(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class IncrementCartItem extends CartEvent {
  final String productId;

  const IncrementCartItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

class DecrementCartItem extends CartEvent {
  final String productId;

  const DecrementCartItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

/// Loads the persisted cart from storage (dispatched on app start).
class LoadCart extends CartEvent {
  const LoadCart();
}
