import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  /// Runs [action] and maps any datasource exception to a domain [Failure],
  /// so callers never see raw exception details.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts() {
    return _guard(() => localDataSource.getProducts());
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) {
    return _guard(() => localDataSource.getProduct(id));
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) {
    return _guard(
      () => localDataSource.addProduct(ProductModel.fromEntity(product)),
    );
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) {
    return _guard(
      () => localDataSource.updateProduct(ProductModel.fromEntity(product)),
    );
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) {
    return _guard(() => localDataSource.deleteProduct(id));
  }
}
