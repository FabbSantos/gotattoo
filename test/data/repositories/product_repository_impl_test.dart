import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/exceptions.dart';
import 'package:gotattoo/core/error/failures.dart';
import 'package:gotattoo/data/models/product_model.dart';
import 'package:gotattoo/data/repositories/product_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late ProductRepositoryImpl repository;
  late MockProductLocalDataSource dataSource;

  final tModel = ProductModel.fromEntity(tProduct);

  setUpAll(() => registerFallbackValue(tModel));

  setUp(() {
    dataSource = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(localDataSource: dataSource);
  });

  group('getProducts', () {
    test('returns Right(list) when the datasource succeeds', () async {
      when(() => dataSource.getProducts()).thenAnswer((_) async => [tModel]);

      final result = await repository.getProducts();

      result.fold(
        (_) => fail('expected products'),
        (products) => expect(products, [tModel]),
      );
    });

    test('returns Left(ServerFailure) on a generic exception', () async {
      when(() => dataSource.getProducts()).thenThrow(Exception('boom'));

      final result = await repository.getProducts();

      expect(result, isA<Left>());
      result.fold((f) => expect(f, isA<ServerFailure>()), (_) {});
    });

    test('returns Left(ServerFailure) on a ServerException', () async {
      when(() => dataSource.getProducts())
          .thenThrow(const ServerException('falhou'));

      final result = await repository.getProducts();

      result.fold(
        (f) => expect(f, const ServerFailure('falhou')),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('getProduct', () {
    test('returns Right(product) on success', () async {
      when(() => dataSource.getProduct(any())).thenAnswer((_) async => tModel);

      final result = await repository.getProduct('1');

      result.fold(
        (_) => fail('expected a product'),
        (product) => expect(product, tModel),
      );
    });

    test('maps NotFoundException to NotFoundFailure', () async {
      when(() => dataSource.getProduct(any()))
          .thenThrow(const NotFoundException('não achou'));

      final result = await repository.getProduct('x');

      result.fold(
        (f) => expect(f, const NotFoundFailure('não achou')),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('write operations', () {
    test('addProduct forwards a ProductModel and returns Right', () async {
      when(() => dataSource.addProduct(any())).thenAnswer((_) async {});

      final result = await repository.addProduct(tProduct);

      expect(result, const Right(null));
      verify(() => dataSource.addProduct(tModel)).called(1);
    });

    test('updateProduct maps NotFoundException to NotFoundFailure', () async {
      when(() => dataSource.updateProduct(any()))
          .thenThrow(const NotFoundException());

      final result = await repository.updateProduct(tProduct);

      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('deleteProduct returns Right on success', () async {
      when(() => dataSource.deleteProduct(any())).thenAnswer((_) async {});

      final result = await repository.deleteProduct('1');

      expect(result, const Right(null));
    });
  });
}
