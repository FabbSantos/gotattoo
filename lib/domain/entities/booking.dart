import 'package:equatable/equatable.dart';

import 'booking_status.dart';

/// A tattoo appointment: a client books a [productId] with an [artistId] for a
/// [scheduledAt] date/time. Money is held in (simulated) escrow until the
/// appointment is completed (artist paid) or cancelled/rejected (client refunded).
class Booking extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String artistId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final DateTime scheduledAt;
  final int durationHours;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.artistId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    this.durationHours = 2,
  });

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id,
    clientId: clientId,
    clientName: clientName,
    artistId: artistId,
    productId: productId,
    productName: productName,
    productImageUrl: productImageUrl,
    price: price,
    scheduledAt: scheduledAt,
    durationHours: durationHours,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    clientId,
    clientName,
    artistId,
    productId,
    productName,
    productImageUrl,
    price,
    scheduledAt,
    durationHours,
    status,
    createdAt,
  ];
}
