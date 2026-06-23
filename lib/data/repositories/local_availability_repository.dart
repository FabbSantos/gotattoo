import '../../domain/entities/artist_availability.dart';
import '../../domain/repositories/availability_repository.dart';

/// In-memory availability for offline mode (not persisted).
class LocalAvailabilityRepository implements AvailabilityRepository {
  final Map<String, ArtistAvailability> _store = {};

  @override
  Future<ArtistAvailability> get(String artistId) async =>
      _store[artistId] ?? ArtistAvailability(artistId: artistId);

  @override
  Future<void> save(ArtistAvailability availability) async =>
      _store[availability.artistId] = availability;
}
