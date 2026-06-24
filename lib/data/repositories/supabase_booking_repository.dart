import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';

class SupabaseBookingRepository implements BookingRepository {
  final SupabaseClient client;

  SupabaseBookingRepository(this.client);

  Booking _toBooking(Map<String, dynamic> r) => Booking(
    id: r['id'] as String,
    clientId: r['client_id'] as String,
    clientName: r['client_name'] as String? ?? '',
    artistId: r['artist_id'] as String,
    productId: r['product_id'] as String? ?? '',
    productName: r['product_name'] as String? ?? '',
    productImageUrl: r['product_image_url'] as String? ?? '',
    price: (r['price'] as num?)?.toDouble() ?? 0,
    scheduledAt: DateTime.parse(r['scheduled_at'] as String),
    durationHours: (r['duration_hours'] as num?)?.toInt() ?? 2,
    status: BookingStatus.fromName(r['status'] as String?),
    createdAt: DateTime.parse(r['created_at'] as String),
    paymentStatus: r['payment_status'] as String? ?? 'none',
  );

  @override
  Future<void> create(Booking b) async {
    await client.from('bookings').insert({
      'client_id': b.clientId,
      'client_name': b.clientName,
      'artist_id': b.artistId,
      'product_id': b.productId,
      'product_name': b.productName,
      'product_image_url': b.productImageUrl,
      'price': b.price,
      'scheduled_at': b.scheduledAt.toIso8601String(),
      'duration_hours': b.durationHours,
      'status': b.status.name,
    });
  }

  @override
  Future<List<Booking>> forClient(String clientId) async {
    final rows = await client
        .from('bookings')
        .select()
        .eq('client_id', clientId)
        .order('scheduled_at', ascending: false);
    return rows.map((r) => _toBooking(r)).toList();
  }

  @override
  Future<List<Booking>> forArtist(String artistId) async {
    final rows = await client
        .from('bookings')
        .select()
        .eq('artist_id', artistId)
        .order('scheduled_at', ascending: false);
    return rows.map((r) => _toBooking(r)).toList();
  }

  @override
  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await client
        .from('bookings')
        .update({'status': status.name})
        .eq('id', bookingId);
  }

  @override
  Future<Set<int>> occupiedHours(String artistId, DateTime day) async {
    final dayStr =
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    final res = await client.rpc(
      'occupied_hours',
      params: {'p_artist_id': artistId, 'p_day': dayStr},
    );
    if (res == null) return {};
    return (res as List).map((e) => (e as num).toInt()).toSet();
  }
}

