import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient client;

  SupabaseProductRepository(this.client);

  Product _toProduct(Map<String, dynamic> r) => Product(
    id: r['id'] as String,
    name: r['name'] as String? ?? '',
    description: r['description'] as String? ?? '',
    price: (r['price'] as num?)?.toDouble() ?? 0,
    imageUrl: r['image_url'] as String? ?? '',
    stock: (r['stock'] as num?)?.toInt() ?? 0,
    category: r['category'] as String? ?? '',
    artistId: r['artist_id'] as String? ?? '',
    discountPercent: (r['discount_percent'] as num?)?.toInt() ?? 0,
    durationHours: (r['duration_hours'] as num?)?.toInt() ?? 2,
  );

  /// Row for insert/update — `id` is omitted so the DB generates it on insert.
  Map<String, dynamic> _toRow(Product p) => {
    'name': p.name,
    'description': p.description,
    'price': p.price,
    'image_url': p.imageUrl,
    'stock': p.stock,
    'category': p.category,
    'artist_id': p.artistId,
    'discount_percent': p.discountPercent,
    'duration_hours': p.durationHours,
  };

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final rows = await client
          .from('products')
          .select()
          .order('created_at');
      return Right(rows.map((r) => _toProduct(r)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final row = await client
          .from('products')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) return const Left(NotFoundFailure('Tatuagem não encontrada.'));
      return Right(_toProduct(row));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      await client.from('products').insert(_toRow(product));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      await client.from('products').update(_toRow(product)).eq('id', product.id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await client.from('products').delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
