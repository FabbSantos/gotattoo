import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductsLoading extends ProductState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductState {
  /// Products visible after applying [selectedCategory] and [selectedArtistId].
  final List<Product> products;
  final String selectedCategory;
  final String? selectedArtistId;
  final String query;

  const ProductsLoaded(
    this.products, {
    required this.selectedCategory,
    this.selectedArtistId,
    this.query = '',
  });

  @override
  List<Object?> get props => [
    products,
    selectedCategory,
    selectedArtistId,
    query,
  ];
}

class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductActionSuccess extends ProductState {
  const ProductActionSuccess();
}
