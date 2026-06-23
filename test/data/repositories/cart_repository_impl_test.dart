import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/repositories/cart_repository_impl.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fixtures.dart';

void main() {
  late SharedPreferences prefs;
  late CartRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = CartRepositoryImpl(prefs: prefs);
  });

  test('load returns an empty list when nothing is stored', () async {
    expect(await repository.load(), isEmpty);
  });

  test('save then load round-trips the cart', () async {
    const items = [
      CartItem(product: tProduct, quantity: 2),
      CartItem(product: tProductMinimalist, quantity: 1),
    ];

    await repository.save(items);
    final loaded = await repository.load();

    // Loaded products are ProductModel, so compare on stable fields rather
    // than identity (Equatable distinguishes Product vs ProductModel).
    expect(loaded.length, 2);
    expect(loaded[0].product.id, tProduct.id);
    expect(loaded[0].product.price, tProduct.price);
    expect(loaded[0].quantity, 2);
    expect(loaded[1].product.id, tProductMinimalist.id);
    expect(loaded[1].quantity, 1);
  });

  test('load returns empty on corrupted payload', () async {
    SharedPreferences.setMockInitialValues({'cart_items': 'not-json'});
    prefs = await SharedPreferences.getInstance();
    repository = CartRepositoryImpl(prefs: prefs);

    expect(await repository.load(), isEmpty);
  });
}
