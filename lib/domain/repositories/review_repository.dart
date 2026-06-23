import '../entities/review.dart';

abstract class ReviewRepository {
  /// Reviews for [artistId], most recent first.
  Future<List<Review>> forArtist(String artistId);

  Future<void> add(Review review);
}
