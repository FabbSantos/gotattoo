import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/data/repositories/local_review_repository.dart';
import 'package:gotattoo/domain/entities/review.dart';
import 'package:gotattoo/presentation/bloc/review/reviews_cubit.dart';

Review _review(String id, {int rating = 5}) => Review(
  id: id,
  artistId: 'a1',
  clientId: 'c1',
  clientName: 'Fab',
  rating: rating,
  comment: 'Top',
  createdAt: DateTime(2026, 6, 1),
);

void main() {
  test('average is 0 with no reviews', () {
    expect(const ReviewsState().average, 0);
  });

  test('average computes across reviews', () {
    final state = ReviewsState(reviews: [_review('1', rating: 5), _review('2', rating: 3)]);
    expect(state.average, 4);
  });

  blocTest<ReviewsCubit, ReviewsState>(
    'load fetches the artist reviews',
    build: () => ReviewsCubit(
      repository: LocalReviewRepository()..add(_review('1')),
    ),
    act: (cubit) => cubit.load('a1'),
    expect: () => [
      const ReviewsState(loading: true),
      isA<ReviewsState>().having((s) => s.reviews.length, 'count', 1),
    ],
  );

  blocTest<ReviewsCubit, ReviewsState>(
    'add posts a review and reloads',
    build: () => ReviewsCubit(repository: LocalReviewRepository()),
    act: (cubit) async {
      await cubit.load('a1');
      await cubit.add(_review('1'));
    },
    // load(loading, empty) + reload(loading); assert the final loaded state.
    skip: 3,
    expect: () => [
      isA<ReviewsState>().having((s) => s.reviews.single.id, 'id', '1'),
    ],
  );
}
