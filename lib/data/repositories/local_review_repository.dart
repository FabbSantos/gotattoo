import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

/// In-memory reviews for offline mode (not persisted).
class LocalReviewRepository implements ReviewRepository {
  final List<Review> _reviews = [];

  @override
  Future<List<Review>> forArtist(String artistId) async {
    final list = _reviews.where((r) => r.artistId == artistId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> add(Review review) async => _reviews.add(review);
}
