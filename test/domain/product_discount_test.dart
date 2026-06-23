import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:gotattoo/domain/entities/product.dart';

const _base = Product(
  id: '1',
  name: 'X',
  description: 'd',
  price: 1000,
  imageUrl: 'https://e.com/x.png',
  stock: 1,
  category: 'Tribal',
  artistId: '1',
);

void main() {
  test('no discount: effectivePrice equals price', () {
    expect(_base.hasDiscount, isFalse);
    expect(_base.effectivePrice, 1000);
  });

  test('discount reduces the effective price', () {
    const p = Product(
      id: '1',
      name: 'X',
      description: 'd',
      price: 1000,
      imageUrl: 'https://e.com/x.png',
      stock: 1,
      category: 'Tribal',
      artistId: '1',
      discountPercent: 20,
    );
    expect(p.hasDiscount, isTrue);
    expect(p.effectivePrice, 800);
  });

  test('cart subtotal uses the discounted price', () {
    const p = Product(
      id: '1',
      name: 'X',
      description: 'd',
      price: 1000,
      imageUrl: 'https://e.com/x.png',
      stock: 1,
      category: 'Tribal',
      artistId: '1',
      discountPercent: 10,
    );
    const item = CartItem(product: p, quantity: 2);
    expect(item.subtotal, 1800); // 900 * 2
  });
}
