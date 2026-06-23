import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/exceptions.dart';
import 'package:gotattoo/data/datasources/product_local_data_source.dart';
import 'package:gotattoo/data/models/product_model.dart';

void main() {
  late ProductLocalDataSourceImpl dataSource;

  setUp(() => dataSource = ProductLocalDataSourceImpl());

  group('getProducts', () {
    test('returns the seeded catalog', () async {
      final products = await dataSource.getProducts();
      expect(products, isNotEmpty);
      expect(products.first, isA<ProductModel>());
    });
  });

  group('getProduct', () {
    test('returns the product when the id exists', () async {
      final product = await dataSource.getProduct('1');
      expect(product.id, '1');
    });

    test('throws NotFoundException when the id is unknown', () {
      expect(
        () => dataSource.getProduct('does-not-exist'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('addProduct', () {
    test('appends a new product to the catalog', () async {
      final before = (await dataSource.getProducts()).length;
      const newProduct = ProductModel(
        id: '999',
        name: 'Nova',
        description: 'desc',
        price: 10,
        imageUrl: 'https://example.com/x.png',
        stock: 1,
        category: 'Tribal',
        artistId: '1',
      );

      await dataSource.addProduct(newProduct);

      final after = await dataSource.getProducts();
      expect(after.length, before + 1);
      expect(after.any((p) => p.id == '999'), isTrue);
    });
  });

  group('updateProduct', () {
    test('replaces an existing product', () async {
      const updated = ProductModel(
        id: '1',
        name: 'Renomeado',
        description: 'desc',
        price: 1,
        imageUrl: 'https://example.com/x.png',
        stock: 1,
        category: 'Tribal',
        artistId: '1',
      );

      await dataSource.updateProduct(updated);

      expect((await dataSource.getProduct('1')).name, 'Renomeado');
    });

    test('throws NotFoundException for an unknown product', () {
      const ghost = ProductModel(
        id: 'ghost',
        name: 'x',
        description: 'x',
        price: 1,
        imageUrl: 'https://example.com/x.png',
        stock: 1,
        category: 'Tribal',
        artistId: '1',
      );
      expect(
        () => dataSource.updateProduct(ghost),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deleteProduct', () {
    test('removes the product from the catalog', () async {
      await dataSource.deleteProduct('1');
      expect(
        () => dataSource.getProduct('1'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
