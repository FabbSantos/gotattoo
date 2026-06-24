import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_status.dart';
import '../../../domain/repositories/booking_repository.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final BookingRepository repository;

  String? _clientId;
  String? _artistId;

  BookingsCubit({required this.repository}) : super(const BookingsState());

  Future<void> loadForClient(String clientId) async {
    _clientId = clientId;
    _artistId = null;
    emit(state.copyWith(loading: true));
    emit(BookingsState(bookings: await repository.forClient(clientId)));
  }

  Future<void> loadForArtist(String artistId) async {
    _artistId = artistId;
    _clientId = null;
    emit(state.copyWith(loading: true));
    emit(BookingsState(bookings: await repository.forArtist(artistId)));
  }

  Future<void> create(Booking booking) => repository.create(booking);

  Future<Set<int>> occupiedHours(String artistId, DateTime day) =>
      repository.occupiedHours(artistId, day);

  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await repository.updateStatus(bookingId, status);
    await reload();
  }

  /// Re-run the last load (e.g. after a server-side charge changed a booking).
  Future<void> reload() async {
    if (_clientId != null) {
      await loadForClient(_clientId!);
    } else if (_artistId != null) {
      await loadForArtist(_artistId!);
    }
  }
}
