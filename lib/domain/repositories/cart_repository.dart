import '../entities/cart_item.dart';

/// Persists the shopping cart so it survives app restarts.
abstract class CartRepository {
  Future<List<CartItem>> load();
  Future<void> save(List<CartItem> items);
}
