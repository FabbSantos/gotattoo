import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final ProductRepository repository;

  ProductBloc({required this.getProducts, required this.repository})
    : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductEvent>(_onGetProduct);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await getProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onGetProduct(
    GetProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await repository.getProduct(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductLoaded(product)),
    );
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await repository.addProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(ProductActionSuccess()),
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await repository.updateProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(ProductActionSuccess()),
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await repository.deleteProduct(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(ProductActionSuccess()),
    );
  }
}
