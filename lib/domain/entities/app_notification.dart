import 'package:equatable/equatable.dart';

/// A notification delivered to a user about a booking lifecycle event
/// (requested, approved, awaiting confirmation, completed, etc.).
class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? bookingId;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.bookingId,
    this.read = false,
  });

  /// Whether this event is for the artist side (vs. the client side), used to
  /// route a tap to the right bookings screen.
  bool get isForArtist =>
      type == 'booking_requested' || type == 'booking_completed';

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        bookingId: bookingId,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [id, userId, type, title, body, bookingId, read, createdAt];
}
