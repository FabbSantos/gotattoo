import 'package:dartz/dartz.dart';
import '../entities/artist.dart';
import '../../core/error/failures.dart';

abstract class ArtistRepository {
  Future<Either<Failure, List<Artist>>> getArtists();
  Future<Either<Failure, Artist>> getArtist(String id);

  /// Profiles awaiting the owner's approval to become artists.
  Future<Either<Failure, List<Artist>>> getPendingArtists();

  /// Owner action: approve a pending artist (sets role = artist).
  Future<Either<Failure, void>> approveArtist(String id);

  /// Owner action: reject a pending artist.
  Future<Either<Failure, void>> rejectArtist(String id);
}
