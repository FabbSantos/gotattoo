import 'package:equatable/equatable.dart';

import '../../../domain/entities/booking.dart';

class BookingsState extends Equatable {
  final bool loading;
  final List<Booking> bookings;

  const BookingsState({this.loading = false, this.bookings = const []});

  BookingsState copyWith({bool? loading, List<Booking>? bookings}) {
    return BookingsState(
      loading: loading ?? this.loading,
      bookings: bookings ?? this.bookings,
    );
  }

  @override
  List<Object?> get props => [loading, bookings];
}
