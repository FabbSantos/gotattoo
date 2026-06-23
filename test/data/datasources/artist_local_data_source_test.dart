import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/exceptions.dart';
import 'package:gotattoo/data/datasources/artist_local_data_source.dart';
import 'package:gotattoo/data/models/artist_model.dart';

void main() {
  late ArtistLocalDataSourceImpl dataSource;

  setUp(() => dataSource = ArtistLocalDataSourceImpl());

  test('getArtists returns the seeded list', () async {
    final artists = await dataSource.getArtists();
    expect(artists, isNotEmpty);
    expect(artists.first, isA<ArtistModel>());
  });

  test('getArtist returns the artist when the id exists', () async {
    final artist = await dataSource.getArtist('1');
    expect(artist.id, '1');
  });

  test('getArtist throws NotFoundException when the id is unknown', () {
    expect(
      () => dataSource.getArtist('nope'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
