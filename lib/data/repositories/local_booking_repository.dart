import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';

/// In-memory bookings for offline mode (not persisted — real use is Supabase).
class LocalBookingRepository implements BookingRepository {
  final List<Booking> _bookings = [];

  @override
  Future<void> create(Booking booking) async => _bookings.add(booking);

  @override
  Future<List<Booking>> forClient(String clientId) async {
    final list = _bookings.where((b) => b.clientId == clientId).toList();
    list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return list;
  }

  @override
  Future<List<Booking>> forArtist(String artistId) async {
    final list = _bookings.where((b) => b.artistId == artistId).toList();
    list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return list;
  }

  @override
  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i == -1) return;
    _bookings[i] = _bookings[i].copyWith(status: status);
  }

  @override
  Future<Set<int>> occupiedHours(String artistId, DateTime day) async {
    final occupied = <int>{};
    for (final b in _bookings) {
      if (b.artistId != artistId || !b.status.isOpen) continue;
      final s = b.scheduledAt;
      if (s.year != day.year || s.month != day.month || s.day != day.day) {
        continue;
      }
      for (var h = s.hour; h < s.hour + b.durationHours; h++) {
        occupied.add(h);
      }
    }
    return occupied;
  }
}
