import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/failures.dart';
import 'package:gotattoo/core/usecases/usecase.dart';
import 'package:gotattoo/domain/entities/product.dart';
import 'package:gotattoo/domain/usecases/add_product.dart';
import 'package:gotattoo/domain/usecases/delete_product.dart';
import 'package:gotattoo/domain/usecases/get_product.dart';
import 'package:gotattoo/domain/usecases/get_products.dart';
import 'package:gotattoo/domain/usecases/update_product.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockProductRepository repository;

  setUpAll(() => registerFallbackValue(tProduct));
  setUp(() => repository = MockProductRepository());

  test('GetProducts delegates to repository.getProducts', () async {
    when(() => repository.getProducts())
        .thenAnswer((_) async => const Right([tProduct]));

    final result = await GetProducts(repository)(const NoParams());

    expect(result, const Right<Failure, List<Product>>([tProduct]));
    verify(() => repository.getProducts()).called(1);
  });

  test('GetProduct forwards the id', () async {
    when(() => repository.getProduct(any()))
        .thenAnswer((_) async => const Right(tProduct));

    final result = await GetProduct(repository)(const IdParams('1'));

    expect(result, const Right<Failure, Product>(tProduct));
    verify(() => repository.getProduct('1')).called(1);
  });

  test('GetProduct propagates failures', () async {
    when(() => repository.getProduct(any()))
        .thenAnswer((_) async => const Left(NotFoundFailure()));

    final result = await GetProduct(repository)(const IdParams('x'));

    expect(result, const Left<Failure, Product>(NotFoundFailure()));
  });

  test('AddProduct forwards the product', () async {
    when(() => repository.addProduct(any()))
        .thenAnswer((_) async => const Right(null));

    await AddProduct(repository)(tProduct);

    verify(() => repository.addProduct(tProduct)).called(1);
  });

  test('UpdateProduct forwards the product', () async {
    when(() => repository.updateProduct(any()))
        .thenAnswer((_) async => const Right(null));

    await UpdateProduct(repository)(tProduct);

    verify(() => repository.updateProduct(tProduct)).called(1);
  });

  test('DeleteProduct forwards the id', () async {
    when(() => repository.deleteProduct(any()))
        .thenAnswer((_) async => const Right(null));

    await DeleteProduct(repository)(const IdParams('1'));

    verify(() => repository.deleteProduct('1')).called(1);
  });
}
