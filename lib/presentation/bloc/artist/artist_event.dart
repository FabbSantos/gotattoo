import 'package:equatable/equatable.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();

  @override
  List<Object?> get props => [];
}

class GetArtistsEvent extends ArtistEvent {
  const GetArtistsEvent();
}

class GetArtistEvent extends ArtistEvent {
  final String id;

  const GetArtistEvent(this.id);

  @override
  List<Object?> get props => [id];
}
