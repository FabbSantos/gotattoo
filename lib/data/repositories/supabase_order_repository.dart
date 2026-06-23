import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient client;

  SupabaseOrderRepository(this.client);

  CartItem _toItem(Map<String, dynamic> i) => CartItem(
    product: Product(
      id: (i['product_id'] as String?) ?? '',
      name: i['product_name'] as String? ?? '',
      description: '',
      price: (i['unit_price'] as num?)?.toDouble() ?? 0,
      imageUrl: i['product_image_url'] as String? ?? '',
      stock: 0,
      category: '',
      artistId: i['artist_id'] as String? ?? '',
    ),
    quantity: (i['quantity'] as num?)?.toInt() ?? 1,
  );

  Order _toOrder(Map<String, dynamic> r) {
    // Buyer queries nest items as `order_items`; the sales RPC nests as `items`.
    final rawItems = (r['order_items'] ?? r['items']) as List<dynamic>? ?? [];
    return Order(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      total: (r['total'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(r['created_at'] as String),
      items: rawItems
          .map((i) => _toItem(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<List<Order>> ordersFor(String userId) async {
    final rows = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map((r) => _toOrder(r)).toList();
  }

  @override
  Future<List<Order>> salesFor(String artistId) async {
    final res = await client.rpc(
      'sales_for_artist',
      params: {'p_artist_id': artistId},
    );
    final list = (res as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((r) => _toOrder(r)).toList();
  }

  @override
  Future<void> placeOrder(Order order) async {
    final inserted = await client
        .from('orders')
        .insert({'user_id': order.userId, 'total': order.total})
        .select()
        .single();
    final orderId = inserted['id'] as String;

    final items = order.items
        .map(
          (it) => {
            'order_id': orderId,
            'product_id': it.product.id,
            'product_name': it.product.name,
            'product_image_url': it.product.imageUrl,
            'artist_id': it.product.artistId,
            'unit_price': it.product.effectivePrice,
            'quantity': it.quantity,
          },
        )
        .toList();
    if (items.isNotEmpty) {
      await client.from('order_items').insert(items);
    }
  }
}
