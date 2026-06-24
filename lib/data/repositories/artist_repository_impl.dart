import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/artist.dart';
import '../../domain/repositories/artist_repository.dart';
import '../datasources/artist_local_data_source.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistDataSource localDataSource;

  ArtistRepositoryImpl({required this.localDataSource});

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
  Future<Either<Failure, List<Artist>>> getArtists() {
    return _guard(() => localDataSource.getArtists());
  }

  @override
  Future<Either<Failure, Artist>> getArtist(String id) {
    return _guard(() => localDataSource.getArtist(id));
  }

  @override
  Future<Either<Failure, List<Artist>>> getPendingArtists() async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> approveArtist(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> rejectArtist(String id) async =>
      const Right(null);
}
