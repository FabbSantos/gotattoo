import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final SupabaseClient client;

  SupabaseReviewRepository(this.client);

  Review _toReview(Map<String, dynamic> r) => Review(
    id: r['id'] as String,
    artistId: r['artist_id'] as String,
    clientId: r['client_id'] as String,
    clientName: r['client_name'] as String? ?? '',
    rating: (r['rating'] as num?)?.toInt() ?? 0,
    comment: r['comment'] as String? ?? '',
    createdAt: DateTime.parse(r['created_at'] as String),
  );

  @override
  Future<List<Review>> forArtist(String artistId) async {
    final rows = await client
        .from('reviews')
        .select()
        .eq('artist_id', artistId)
        .order('created_at', ascending: false);
    return rows.map((r) => _toReview(r)).toList();
  }

  @override
  Future<void> add(Review review) async {
    await client.from('reviews').insert({
      'artist_id': review.artistId,
      'client_id': review.clientId,
      'client_name': review.clientName,
      'rating': review.rating,
      'comment': review.comment,
    });
  }
}
