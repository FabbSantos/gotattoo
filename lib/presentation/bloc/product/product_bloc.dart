import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cache/cache_store.dart';
import '../../../core/usecases/usecase.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/add_product.dart';
import '../../../domain/usecases/delete_product.dart';
import '../../../domain/usecases/get_product.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/usecases/update_product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final GetProduct getProduct;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  /// Optional snapshot cache for instant catalog load (null in tests).
  final CacheStore? cache;
  static const String _catalogKey = 'cache_catalog';

  /// Cached full catalog, so filtering doesn't refetch.
  List<Product> _allProducts = const [];
  String _category = ProductBlocDefaults.allCategories;
  String? _artistId;
  String _query = '';

  ProductBloc({
    required this.getProducts,
    required this.getProduct,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
    this.cache,
  }) : super(const ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<FilterProductsByCategoryEvent>(_onFilterByCategory);
    on<FilterProductsByArtistEvent>(_onFilterByArtist);
    on<SearchProductsEvent>(_onSearch);
    on<GetProductEvent>(_onGetProduct);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  /// Applies the current category, artist and search filters to the catalog.
  List<Product> _applyFilters() {
    final q = _query.trim().toLowerCase();
    return _allProducts.where((p) {
      final matchesCategory = _category == ProductBlocDefaults.allCategories ||
          p.category == _category;
      final matchesArtist = _artistId == null || p.artistId == _artistId;
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return matchesCategory && matchesArtist && matchesQuery;
    }).toList();
  }

  ProductsLoaded _loaded() => ProductsLoaded(
    _applyFilters(),
    selectedCategory: _category,
    selectedArtistId: _artistId,
    query: _query,
  );

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    _category = event.category;
    _artistId = event.artistId;
    _query = '';

    // Cache-then-network: show the last catalog instantly, then refresh.
    final cached = cache?.readList(_catalogKey);
    if (cached != null && cached.isNotEmpty) {
      _allProducts = cached.map((m) => ProductModel.fromJson(m)).toList();
      emit(_loaded());
    } else {
      emit(const ProductsLoading());
    }

    final result = await getProducts(const NoParams());
    result.fold(
      (failure) {
        // Keep showing the cache if we have it; only surface the error if not.
        if (cached == null) emit(ProductError(failure.message));
      },
      (products) {
        _allProducts = products;
        emit(_loaded());
        cache?.writeList(
          _catalogKey,
          products.map((p) => ProductModel.fromEntity(p).toJson()).toList(),
        );
      },
    );
  }

  void _onFilterByCategory(
    FilterProductsByCategoryEvent event,
    Emitter<ProductState> emit,
  ) {
    _category = event.category;
    emit(_loaded());
  }

  void _onFilterByArtist(
    FilterProductsByArtistEvent event,
    Emitter<ProductState> emit,
  ) {
    _artistId = event.artistId;
    emit(_loaded());
  }

  void _onSearch(SearchProductsEvent event, Emitter<ProductState> emit) {
    _query = event.query;
    emit(_loaded());
  }

  Future<void> _onGetProduct(
    GetProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductsLoading());
    final result = await getProduct(IdParams(event.id));
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductLoaded(product)),
    );
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductsLoading());
    final result = await addProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductActionSuccess()),
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductsLoading());
    final result = await updateProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductActionSuccess()),
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductsLoading());
    final result = await deleteProduct(IdParams(event.id));
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductActionSuccess()),
    );
  }
}
