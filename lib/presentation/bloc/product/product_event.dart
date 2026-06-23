import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the full catalog, optionally pre-filtered by [category] and/or
/// [artistId] (loading + filtering atomically, avoiding a fetch/filter race).
class GetProductsEvent extends ProductEvent {
  final String category;
  final String? artistId;

  const GetProductsEvent({
    this.category = ProductBlocDefaults.allCategories,
    this.artistId,
  });

  @override
  List<Object?> get props => [category, artistId];
}

/// Filters the already-loaded catalog by category, without refetching.
class FilterProductsByCategoryEvent extends ProductEvent {
  final String category;

  const FilterProductsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filters the already-loaded catalog by artist ([artistId] == null clears it).
class FilterProductsByArtistEvent extends ProductEvent {
  final String? artistId;

  const FilterProductsByArtistEvent(this.artistId);

  @override
  List<Object?> get props => [artistId];
}

/// Free-text search over the cached catalog (name/description/category).
class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class GetProductEvent extends ProductEvent {
  final String id;

  const GetProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddProductEvent extends ProductEvent {
  final Product product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String id;

  const DeleteProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Shared constants for product filtering.
abstract class ProductBlocDefaults {
  static const String allCategories = 'Todas';
}
