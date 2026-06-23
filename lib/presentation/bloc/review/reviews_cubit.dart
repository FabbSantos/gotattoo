import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/review.dart';
import '../../../domain/repositories/review_repository.dart';

class ReviewsState extends Equatable {
  final bool loading;
  final List<Review> reviews;

  const ReviewsState({this.loading = false, this.reviews = const []});

  double get average => reviews.isEmpty
      ? 0
      : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

  ReviewsState copyWith({bool? loading, List<Review>? reviews}) => ReviewsState(
    loading: loading ?? this.loading,
    reviews: reviews ?? this.reviews,
  );

  @override
  List<Object?> get props => [loading, reviews];
}

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewRepository repository;
  String? _artistId;

  ReviewsCubit({required this.repository}) : super(const ReviewsState());

  Future<void> load(String artistId) async {
    _artistId = artistId;
    emit(state.copyWith(loading: true));
    emit(ReviewsState(reviews: await repository.forArtist(artistId)));
  }

  Future<void> add(Review review) async {
    await repository.add(review);
    if (_artistId != null) await load(_artistId!);
  }
}
