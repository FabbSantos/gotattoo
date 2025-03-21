import 'package:dartz/dartz.dart';
import '../entities/artist.dart';
import '../../core/error/failures.dart';

abstract class ArtistRepository {
  Future<Either<Failure, List<Artist>>> getArtists();
  Future<Either<Failure, Artist>> getArtist(String id);
}
