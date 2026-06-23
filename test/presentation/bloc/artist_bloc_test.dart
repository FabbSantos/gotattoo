import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/error/failures.dart';
import 'package:gotattoo/core/usecases/usecase.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_bloc.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_event.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockGetArtists getArtists;
  late MockGetOneArtist getOneArtist;

  ArtistBloc build() =>
      ArtistBloc(getArtists: getArtists, getOneArtist: getOneArtist);

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const IdParams('1'));
  });

  setUp(() {
    getArtists = MockGetArtists();
    getOneArtist = MockGetOneArtist();
  });

  test('initial state is ArtistInitial', () {
    expect(build().state, const ArtistInitial());
  });

  blocTest<ArtistBloc, ArtistState>(
    'GetArtistsEvent emits [Loading, Loaded] on success',
    setUp: () => when(() => getArtists(any()))
        .thenAnswer((_) async => const Right([tArtist])),
    build: build,
    act: (bloc) => bloc.add(const GetArtistsEvent()),
    expect: () => [
      const ArtistsLoading(),
      const ArtistsLoaded([tArtist]),
    ],
  );

  blocTest<ArtistBloc, ArtistState>(
    'GetArtistsEvent emits [Loading, Error] on failure',
    setUp: () => when(() => getArtists(any()))
        .thenAnswer((_) async => const Left(ServerFailure('falhou'))),
    build: build,
    act: (bloc) => bloc.add(const GetArtistsEvent()),
    expect: () => [const ArtistsLoading(), const ArtistError('falhou')],
  );

  blocTest<ArtistBloc, ArtistState>(
    'GetArtistEvent emits [Loading, ArtistLoaded] on success',
    setUp: () => when(() => getOneArtist(any()))
        .thenAnswer((_) async => const Right(tArtist)),
    build: build,
    act: (bloc) => bloc.add(const GetArtistEvent('1')),
    expect: () => [const ArtistsLoading(), const ArtistLoaded(tArtist)],
  );
}
