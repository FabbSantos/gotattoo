import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/artist.dart';
import '../repositories/artist_repository.dart';

class GetOneArtist implements UseCase<Artist, IdParams> {
  final ArtistRepository repository;

  GetOneArtist(this.repository);

  @override
  Future<Either<Failure, Artist>> call(IdParams params) {
    return repository.getArtist(params.id);
  }
}
