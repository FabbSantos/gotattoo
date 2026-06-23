import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.stock,
    required super.category,
    required super.artistId,
    super.discountPercent,
    super.durationHours,
  });

  /// Builds a model from a domain entity, so repositories don't have to copy
  /// every field by hand when persisting.
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      stock: product.stock,
      category: product.category,
      artistId: product.artistId,
      discountPercent: product.discountPercent,
      durationHours: product.durationHours,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      stock: (json['stock'] as num).toInt(),
      category: json['category'] as String,
      artistId: json['artistId'] as String,
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
      durationHours: (json['durationHours'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
      'artistId': artistId,
      'discountPercent': discountPercent,
      'durationHours': durationHours,
    };
  }
}
