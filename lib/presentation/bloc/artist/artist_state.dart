import '../../../domain/entities/artist.dart';

abstract class ArtistState {}

class ArtistInitial extends ArtistState {}

class ArtistsLoading extends ArtistState {}

class ArtistsLoaded extends ArtistState {
  final List<Artist> artists;
  ArtistsLoaded(this.artists);
}

class ArtistLoaded extends ArtistState {
  final Artist artist;
  ArtistLoaded(this.artist);
}

class ArtistError extends ArtistState {
  final String message;
  ArtistError(this.message);
}

class ArtistActionSuccess extends ArtistState {}
