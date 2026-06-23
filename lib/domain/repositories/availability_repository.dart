import '../entities/artist_availability.dart';

abstract class AvailabilityRepository {
  /// The artist's availability (defaults to weekdays 9h–18h if none saved).
  Future<ArtistAvailability> get(String artistId);

  Future<void> save(ArtistAvailability availability);
}
