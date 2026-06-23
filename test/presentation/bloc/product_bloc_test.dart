import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/failures.dart';
import 'package:gotattoo/core/usecases/usecase.dart';
import 'package:gotattoo/presentation/bloc/product/product_bloc.dart';
import 'package:gotattoo/presentation/bloc/product/product_event.dart';
import 'package:gotattoo/presentation/bloc/product/product_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockGetProducts getProducts;
  late MockGetProduct getProduct;
  late MockAddProduct addProduct;
  late MockUpdateProduct updateProduct;
  late MockDeleteProduct deleteProduct;

  final catalog = [tProduct, tProductMinimalist];

  ProductBloc build() => ProductBloc(
    getProducts: getProducts,
    getProduct: getProduct,
    addProduct: addProduct,
    updateProduct: updateProduct,
    deleteProduct: deleteProduct,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const IdParams('1'));
    registerFallbackValue(tProduct);
  });

  setUp(() {
    getProducts = MockGetProducts();
    getProduct = MockGetProduct();
    addProduct = MockAddProduct();
    updateProduct = MockUpdateProduct();
    deleteProduct = MockDeleteProduct();
  });

  test('initial state is ProductInitial', () {
    expect(build().state, const ProductInitial());
  });

  group('GetProductsEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [Loading, Loaded(all)] when the use case succeeds',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc.add(const GetProductsEvent()),
      expect: () => [
        const ProductsLoading(),
        ProductsLoaded(catalog, selectedCategory: 'Todas'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [Loading, Error] when the use case fails',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => const Left(ServerFailure('erro'))),
      build: build,
      act: (bloc) => bloc.add(const GetProductsEvent()),
      expect: () => [
        const ProductsLoading(),
        const ProductError('erro'),
      ],
    );
  });

  group('FilterProductsByCategoryEvent', () {
    blocTest<ProductBloc, ProductState>(
      'filters the cached catalog without refetching',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc
        ..add(const GetProductsEvent())
        ..add(const FilterProductsByCategoryEvent('Minimalista')),
      skip: 2, // skip Loading + initial Loaded(all)
      expect: () => [
        ProductsLoaded([tProductMinimalist], selectedCategory: 'Minimalista'),
      ],
      verify: (_) => verify(() => getProducts(any())).called(1),
    );

    blocTest<ProductBloc, ProductState>(
      'restores the full list when switching back to "Todas"',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc
        ..add(const GetProductsEvent())
        ..add(const FilterProductsByCategoryEvent('Minimalista'))
        ..add(const FilterProductsByCategoryEvent('Todas')),
      skip: 3, // Loading, Loaded(all), Loaded(minimalista)
      expect: () => [ProductsLoaded(catalog, selectedCategory: 'Todas')],
    );
  });

  blocTest<ProductBloc, ProductState>(
    'GetProductsEvent(artistId) loads pre-filtered to that artist',
    setUp: () => when(() => getProducts(any()))
        .thenAnswer((_) async => Right(catalog)),
    build: build,
    act: (bloc) => bloc.add(const GetProductsEvent(artistId: '3')),
    expect: () => [
      const ProductsLoading(),
      ProductsLoaded(
        [tProduct], // tProduct.artistId == '3'
        selectedCategory: 'Todas',
        selectedArtistId: '3',
      ),
    ],
  );

  group('FilterProductsByArtistEvent', () {
    blocTest<ProductBloc, ProductState>(
      'keeps only products from the selected artist',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc
        ..add(const GetProductsEvent())
        ..add(const FilterProductsByArtistEvent('3')),
      skip: 2,
      expect: () => [
        ProductsLoaded(
          [tProduct], // tProduct.artistId == '3'
          selectedCategory: 'Todas',
          selectedArtistId: '3',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'combines category and artist filters',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc
        ..add(const GetProductsEvent())
        ..add(const FilterProductsByArtistEvent('3'))
        ..add(const FilterProductsByCategoryEvent('Minimalista')),
      skip: 3,
      expect: () => [
        // artist 3 has no Minimalista product -> empty
        const ProductsLoaded(
          [],
          selectedCategory: 'Minimalista',
          selectedArtistId: '3',
        ),
      ],
    );
  });

  group('SearchProductsEvent', () {
    blocTest<ProductBloc, ProductState>(
      'keeps only products matching the query (name/description/category)',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc
        ..add(const GetProductsEvent())
        ..add(const SearchProductsEvent('minimal')),
      skip: 2,
      expect: () => [
        ProductsLoaded(
          [tProductMinimalist], // matches "Linhas Minimalistas" / "Minimalista"
          selectedCategory: 'Todas',
          query: 'minimal',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'empty query returns the whole catalog',
      setUp: () => when(() => getProducts(any()))
          .thenAnswer((_) async => Right(catalog)),
      build: build,
      act: (bloc) => bloc
        ..add(const GetProductsEvent())
        ..add(const SearchProductsEvent('dragão'))
        ..add(const SearchProductsEvent('')),
      skip: 3,
      expect: () => [ProductsLoaded(catalog, selectedCategory: 'Todas')],
    );
  });

  group('GetProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [Loading, ProductLoaded] on success',
      setUp: () => when(() => getProduct(any()))
          .thenAnswer((_) async => const Right(tProduct)),
      build: build,
      act: (bloc) => bloc.add(const GetProductEvent('1')),
      expect: () => [const ProductsLoading(), const ProductLoaded(tProduct)],
    );
  });

  group('write events', () {
    blocTest<ProductBloc, ProductState>(
      'AddProductEvent emits [Loading, ActionSuccess]',
      setUp: () => when(() => addProduct(any()))
          .thenAnswer((_) async => const Right(null)),
      build: build,
      act: (bloc) => bloc.add(const AddProductEvent(tProduct)),
      expect: () => [const ProductsLoading(), const ProductActionSuccess()],
    );

    blocTest<ProductBloc, ProductState>(
      'DeleteProductEvent emits [Loading, Error] on failure',
      setUp: () => when(() => deleteProduct(any()))
          .thenAnswer((_) async => const Left(NotFoundFailure('x'))),
      build: build,
      act: (bloc) => bloc.add(const DeleteProductEvent('1')),
      expect: () => [const ProductsLoading(), const ProductError('x')],
    );
  });
}
