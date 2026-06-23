import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/repositories/local_booking_repository.dart';
import 'package:gotattoo/domain/entities/booking.dart';
import 'package:gotattoo/domain/entities/booking_status.dart';
import 'package:gotattoo/presentation/bloc/booking/bookings_cubit.dart';
import 'package:gotattoo/presentation/bloc/booking/bookings_state.dart';

Booking _booking(String id, {BookingStatus status = BookingStatus.pending}) =>
    Booking(
      id: id,
      clientId: 'c1',
      clientName: 'Fab',
      artistId: 'a1',
      productId: 'p1',
      productName: 'Dragão',
      productImageUrl: '',
      price: 1000,
      scheduledAt: DateTime(2026, 6, 20, 14),
      status: status,
      createdAt: DateTime(2026, 6, 1),
    );

void main() {
  test('occupiedHours expands a booking by its duration', () async {
    final repo = LocalBookingRepository();
    await repo.create(
      Booking(
        id: '1',
        clientId: 'c1',
        clientName: 'Fab',
        artistId: 'a1',
        productId: 'p1',
        productName: 'Dragão',
        productImageUrl: '',
        price: 1000,
        scheduledAt: DateTime(2026, 6, 20, 14),
        durationHours: 3,
        status: BookingStatus.confirmed,
        createdAt: DateTime(2026, 6, 1),
      ),
    );
    // 14h + 3h occupies 14, 15, 16.
    expect(await repo.occupiedHours('a1', DateTime(2026, 6, 20)), {14, 15, 16});
    // Other day / other artist are free.
    expect(await repo.occupiedHours('a1', DateTime(2026, 6, 21)), isEmpty);
    expect(await repo.occupiedHours('a2', DateTime(2026, 6, 20)), isEmpty);
  });

  test('mutual completion: artist marks finished, client confirms', () {
    expect(BookingStatus.confirmed.isOpen, isTrue);
    expect(BookingStatus.awaitingConfirmation.paymentLabel, 'Pagamento retido');
    expect(BookingStatus.completed.paymentLabel, 'Pago ao tatuador');
    expect(BookingStatus.cancelled.paymentLabel, 'Reembolsado');
    expect(BookingStatus.awaitingConfirmation.isCancellable, isFalse);
  });

  blocTest<BookingsCubit, BookingsState>(
    'loadForArtist lists the artist bookings',
    build: () => BookingsCubit(
      repository: LocalBookingRepository()..create(_booking('1')),
    ),
    act: (cubit) => cubit.loadForArtist('a1'),
    expect: () => [
      const BookingsState(loading: true),
      isA<BookingsState>().having((s) => s.bookings.length, 'count', 1),
    ],
  );

  blocTest<BookingsCubit, BookingsState>(
    'updateStatus changes the booking and reloads',
    build: () => BookingsCubit(
      repository: LocalBookingRepository()..create(_booking('1')),
    ),
    act: (cubit) async {
      await cubit.loadForArtist('a1');
      await cubit.updateStatus('1', BookingStatus.confirmed);
    },
    // Skip: load(loading, loaded-pending) + reload(loading); assert the result.
    skip: 3,
    expect: () => [
      isA<BookingsState>().having(
        (s) => s.bookings.single.status,
        'status',
        BookingStatus.confirmed,
      ),
    ],
  );
}
