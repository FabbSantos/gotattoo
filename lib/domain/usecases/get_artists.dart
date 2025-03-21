import 'package:dartz/dartz.dart';
import 'package:gotattoo/domain/usecases/get_products.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/artist.dart';
import '../repositories/artist_repository.dart';

class GetArtists implements UseCase<List<Artist>, NoParams> {
  final ArtistRepository repository;

  GetArtists(this.repository);

  @override
  Future<Either<Failure, List<Artist>>> call(NoParams params) async {
    return await repository.getArtists();
  }
}
