import '../../../domain/entities/artist.dart';

abstract class ArtistEvent {}

class GetArtistsEvent extends ArtistEvent {}

class GetArtistEvent extends ArtistEvent {
  final String id;
  GetArtistEvent(this.id);
}

class AddArtistEvent extends ArtistEvent {
  final Artist artist;
  AddArtistEvent(this.artist);
}

class UpdateArtistEvent extends ArtistEvent {
  final Artist artist;
  UpdateArtistEvent(this.artist);
}

class DeleteArtistEvent extends ArtistEvent {
  final String id;
  DeleteArtistEvent(this.id);
}
