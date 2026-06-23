import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/exceptions.dart';
import 'package:gotattoo/core/error/failures.dart';
import 'package:gotattoo/data/models/artist_model.dart';
import 'package:gotattoo/data/repositories/artist_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late ArtistRepositoryImpl repository;
  late MockArtistDataSource dataSource;

  final tModel = ArtistModel.fromEntity(tArtist);

  setUp(() {
    dataSource = MockArtistDataSource();
    repository = ArtistRepositoryImpl(localDataSource: dataSource);
  });

  test('getArtists returns Right(list) on success', () async {
    when(() => dataSource.getArtists()).thenAnswer((_) async => [tModel]);

    final result = await repository.getArtists();

    result.fold(
      (_) => fail('expected artists'),
      (artists) => expect(artists, [tModel]),
    );
  });

  test('getArtists returns Left(ServerFailure) on generic exception', () async {
    when(() => dataSource.getArtists()).thenThrow(Exception('boom'));

    final result = await repository.getArtists();

    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('expected a failure'),
    );
  });

  test('getArtist maps NotFoundException to NotFoundFailure', () async {
    when(() => dataSource.getArtist(any()))
        .thenThrow(const NotFoundException());

    final result = await repository.getArtist('x');

    result.fold(
      (f) => expect(f, isA<NotFoundFailure>()),
      (_) => fail('expected a failure'),
    );
  });
}
