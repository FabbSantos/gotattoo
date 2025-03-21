import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_artists.dart';
import '../../../domain/usecases/get_one_artist.dart';
import '../../../domain/repositories/artist_repository.dart';
import '../../../domain/usecases/get_products.dart';
import 'artist_event.dart';
import 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final GetArtists getArtists;
  final GetOneArtist getOneArtist;
  final ArtistRepository repository;

  ArtistBloc({
    required this.getArtists,
    required this.getOneArtist,
    required this.repository,
  }) : super(ArtistInitial()) {
    on<GetArtistsEvent>(_onGetArtists);
    on<GetArtistEvent>(_onGetArtist);
    // Os handlers a seguir seriam implementados em um sistema completo
    // Deixei comentados pois não implementamos as operações no repositório
    // on<AddArtistEvent>(_onAddArtist);
    // on<UpdateArtistEvent>(_onUpdateArtist);
    // on<DeleteArtistEvent>(_onDeleteArtist);
  }

  Future<void> _onGetArtists(
    GetArtistsEvent event,
    Emitter<ArtistState> emit,
  ) async {
    emit(ArtistsLoading());
    final result = await getArtists(NoParams());
    result.fold(
      (failure) => emit(ArtistError(failure.message)),
      (artists) => emit(ArtistsLoaded(artists)),
    );
  }

  Future<void> _onGetArtist(
    GetArtistEvent event,
    Emitter<ArtistState> emit,
  ) async {
    emit(ArtistsLoading());
    final result = await getOneArtist(event.id);
    result.fold(
      (failure) => emit(ArtistError(failure.message)),
      (artist) => emit(ArtistLoaded(artist)),
    );
  }

  // Métodos para as operações futuras (adicionar, atualizar, remover)
  /*
  Future<void> _onAddArtist(
    AddArtistEvent event,
    Emitter<ArtistState> emit,
  ) async {
    // Implementação futura
  }

  Future<void> _onUpdateArtist(
    UpdateArtistEvent event,
    Emitter<ArtistState> emit,
  ) async {
    // Implementação futura
  }

  Future<void> _onDeleteArtist(
    DeleteArtistEvent event,
    Emitter<ArtistState> emit,
  ) async {
    // Implementação futura
  }
  */
}
