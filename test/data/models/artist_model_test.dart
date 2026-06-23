import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/models/artist_model.dart';
import 'package:gotattoo/domain/entities/artist.dart';

import '../../helpers/fixtures.dart';

void main() {
  const tModel = ArtistModel(
    id: '1',
    name: 'João Silva',
    specialty: 'Realista',
    rating: 4.8,
    imageUrl: 'https://example.com/joao.png',
  );

  test('is a subclass of Artist entity', () {
    expect(tModel, isA<Artist>());
  });

  test('fromJson parses a valid map', () {
    expect(ArtistModel.fromJson(tArtistJson), tModel);
  });

  test('fromJson coerces int rating to double', () {
    final json = Map<String, dynamic>.from(tArtistJson)..['rating'] = 5;
    expect(ArtistModel.fromJson(json).rating, 5.0);
  });

  test('fromEntity copies every field', () {
    expect(ArtistModel.fromEntity(tArtist), tModel);
  });

  test('toJson round-trips back into an equal model', () {
    expect(ArtistModel.fromJson(tModel.toJson()), tModel);
  });
}
