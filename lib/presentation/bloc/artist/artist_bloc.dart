import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cache/cache_store.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/artist.dart';
import '../../../domain/usecases/get_artists.dart';
import '../../../domain/usecases/get_one_artist.dart';
import 'artist_event.dart';
import 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final GetArtists getArtists;
  final GetOneArtist getOneArtist;

  /// Optional snapshot cache for instant artist load (null in tests).
  final CacheStore? cache;
  static const String _artistsKey = 'cache_artists';

  ArtistBloc({required this.getArtists, required this.getOneArtist, this.cache})
    : super(const ArtistInitial()) {
    on<GetArtistsEvent>(_onGetArtists);
    on<GetArtistEvent>(_onGetArtist);
  }

  Future<void> _onGetArtists(
    GetArtistsEvent event,
    Emitter<ArtistState> emit,
  ) async {
    // Cache-then-network: show the last list instantly, then refresh.
    final cached = cache?.readList(_artistsKey);
    if (cached != null && cached.isNotEmpty) {
      emit(ArtistsLoaded(cached.map(_artistFromCache).toList()));
    } else {
      emit(const ArtistsLoading());
    }

    final result = await getArtists(const NoParams());
    result.fold(
      (failure) {
        if (cached == null) emit(ArtistError(failure.message));
      },
      (artists) {
        emit(ArtistsLoaded(artists));
        cache?.writeList(_artistsKey, artists.map(_artistToCache).toList());
      },
    );
  }

  Future<void> _onGetArtist(
    GetArtistEvent event,
    Emitter<ArtistState> emit,
  ) async {
    emit(const ArtistsLoading());
    final result = await getOneArtist(IdParams(event.id));
    result.fold(
      (failure) => emit(ArtistError(failure.message)),
      (artist) => emit(ArtistLoaded(artist)),
    );
  }
}

Map<String, dynamic> _artistToCache(Artist a) => {
      'id': a.id,
      'name': a.name,
      'specialty': a.specialty,
      'rating': a.rating,
      'imageUrl': a.imageUrl,
      'region': a.region,
      'latitude': a.latitude,
      'longitude': a.longitude,
      'featured': a.featured,
    };

Artist _artistFromCache(Map<String, dynamic> m) => Artist(
      id: m['id'] as String,
      name: m['name'] as String? ?? '',
      specialty: m['specialty'] as String? ?? '',
      rating: (m['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: m['imageUrl'] as String? ?? '',
      region: m['region'] as String? ?? '',
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      featured: m['featured'] as bool? ?? false,
    );
