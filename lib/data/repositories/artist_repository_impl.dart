import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/artist.dart';
import '../../domain/repositories/artist_repository.dart';
import '../datasources/artist_local_data_source.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistDataSource localDataSource;

  ArtistRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Artist>>> getArtists() async {
    try {
      final artists = await localDataSource.getArtists();
      return Right(artists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Artist>> getArtist(String id) async {
    try {
      final artist = await localDataSource.getArtist(id);
      return Right(artist);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
