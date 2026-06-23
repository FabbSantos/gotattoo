import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final SharedPreferences prefs;

  static const _key = 'cart_items';

  CartRepositoryImpl({required this.prefs});

  @override
  Future<List<CartItem>> load() async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => e as Map<String, dynamic>)
          .map(
            (e) => CartItem(
              product: ProductModel.fromJson(
                e['product'] as Map<String, dynamic>,
              ),
              quantity: (e['quantity'] as num).toInt(),
            ),
          )
          .toList();
    } catch (_) {
      // Corrupted payload — start from an empty cart rather than crashing.
      return [];
    }
  }

  @override
  Future<void> save(List<CartItem> items) async {
    final payload = items
        .map(
          (item) => {
            'product': ProductModel.fromEntity(item.product).toJson(),
            'quantity': item.quantity,
          },
        )
        .toList();
    await prefs.setString(_key, jsonEncode(payload));
  }
}
