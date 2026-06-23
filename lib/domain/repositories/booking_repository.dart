import '../entities/booking.dart';
import '../entities/booking_status.dart';

abstract class BookingRepository {
  Future<void> create(Booking booking);

  /// Bookings the user made as a client, most recent first.
  Future<List<Booking>> forClient(String clientId);

  /// Bookings addressed to the artist, most recent first.
  Future<List<Booking>> forArtist(String artistId);

  Future<void> updateStatus(String bookingId, BookingStatus status);

  /// Hours already occupied (by open bookings) for [artistId] on [day],
  /// each open booking expanded by its duration. Used to block overlaps.
  Future<Set<int>> occupiedHours(String artistId, DateTime day);
}
