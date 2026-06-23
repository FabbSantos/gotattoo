import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/failures.dart';
import 'package:gotattoo/core/usecases/usecase.dart';
import 'package:gotattoo/domain/entities/artist.dart';
import 'package:gotattoo/domain/usecases/get_artists.dart';
import 'package:gotattoo/domain/usecases/get_one_artist.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockArtistRepository repository;

  setUp(() => repository = MockArtistRepository());

  test('GetArtists delegates to repository.getArtists', () async {
    when(() => repository.getArtists())
        .thenAnswer((_) async => const Right([tArtist]));

    final result = await GetArtists(repository)(const NoParams());

    expect(result, const Right<Failure, List<Artist>>([tArtist]));
    verify(() => repository.getArtists()).called(1);
  });

  test('GetOneArtist forwards the id', () async {
    when(() => repository.getArtist(any()))
        .thenAnswer((_) async => const Right(tArtist));

    final result = await GetOneArtist(repository)(const IdParams('1'));

    expect(result, const Right<Failure, Artist>(tArtist));
    verify(() => repository.getArtist('1')).called(1);
  });

  test('GetOneArtist propagates failures', () async {
    when(() => repository.getArtist(any()))
        .thenAnswer((_) async => const Left(NotFoundFailure()));

    final result = await GetOneArtist(repository)(const IdParams('x'));

    expect(result, const Left<Failure, Artist>(NotFoundFailure()));
  });
}
