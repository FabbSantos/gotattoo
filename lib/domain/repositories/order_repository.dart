import '../entities/order.dart';

/// Persists placed orders and reads a user's order history.
abstract class OrderRepository {
  /// Orders placed by [userId] (as a buyer), most recent first.
  Future<List<Order>> ordersFor(String userId);

  /// Orders that contain at least one tattoo by [artistId] (the artist's
  /// sales), most recent first.
  Future<List<Order>> salesFor(String artistId);

  Future<void> placeOrder(Order order);
}
