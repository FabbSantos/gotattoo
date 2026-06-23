import 'package:equatable/equatable.dart';
import '../../../domain/entities/artist.dart';

abstract class ArtistState extends Equatable {
  const ArtistState();

  @override
  List<Object?> get props => [];
}

class ArtistInitial extends ArtistState {
  const ArtistInitial();
}

class ArtistsLoading extends ArtistState {
  const ArtistsLoading();
}

class ArtistsLoaded extends ArtistState {
  final List<Artist> artists;

  const ArtistsLoaded(this.artists);

  @override
  List<Object?> get props => [artists];
}

class ArtistLoaded extends ArtistState {
  final Artist artist;

  const ArtistLoaded(this.artist);

  @override
  List<Object?> get props => [artist];
}

class ArtistError extends ArtistState {
  final String message;

  const ArtistError(this.message);

  @override
  List<Object?> get props => [message];
}
