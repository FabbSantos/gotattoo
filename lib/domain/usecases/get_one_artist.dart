import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/artist.dart';
import '../repositories/artist_repository.dart';

class GetOneArtist {
  final ArtistRepository repository;

  GetOneArtist(this.repository);

  Future<Either<Failure, Artist>> call(String id) async {
    return await repository.getArtist(id);
  }
}
