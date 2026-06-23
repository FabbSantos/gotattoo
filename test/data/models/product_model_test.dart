import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/models/product_model.dart';
import 'package:gotattoo/domain/entities/product.dart';

import '../../helpers/fixtures.dart';

void main() {
  const tModel = ProductModel(
    id: '1',
    name: 'Dragão Oriental',
    description: 'Tatuagem de dragão tradicional japonês.',
    price: 1200.00,
    imageUrl: 'https://example.com/dragon.png',
    stock: 5,
    category: 'Old School',
    artistId: '3',
  );

  test('is a subclass of Product entity', () {
    expect(tModel, isA<Product>());
  });

  test('fromJson parses a valid map', () {
    final result = ProductModel.fromJson(tProductJson);
    expect(result, tModel);
  });

  test('fromJson coerces int price to double', () {
    final json = Map<String, dynamic>.from(tProductJson)..['price'] = 1200;
    final result = ProductModel.fromJson(json);
    expect(result.price, 1200.0);
    expect(result.price, isA<double>());
  });

  test('fromEntity copies every field', () {
    final result = ProductModel.fromEntity(tProduct);
    expect(result, tModel);
  });

  test('toJson round-trips back into an equal model', () {
    final json = tModel.toJson();
    expect(ProductModel.fromJson(json), tModel);
  });
}
