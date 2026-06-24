import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/tattoo_request.dart';
import '../../../domain/repositories/tattoo_request_repository.dart';

class TattooFeedState extends Equatable {
  final bool loading;
  final List<TattooRequest> items;

  const TattooFeedState({this.loading = false, this.items = const []});

  TattooFeedState copyWith({bool? loading, List<TattooRequest>? items}) =>
      TattooFeedState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [loading, items];
}

class TattooFeedCubit extends Cubit<TattooFeedState> {
  final TattooRequestRepository repository;

  TattooFeedCubit({required this.repository})
      : super(const TattooFeedState(loading: true));

  Future<void> load() async {
    if (state.items.isEmpty) emit(state.copyWith(loading: true));
    emit(TattooFeedState(items: await repository.feed()));
  }

  Future<TattooRequest> create(TattooRequest request) async {
    final saved = await repository.create(request);
    emit(TattooFeedState(items: [saved, ...state.items]));
    return saved;
  }

  /// Optimistically flip the like on [id], then persist.
  Future<void> toggleLike(String id) async {
    var nowLiked = false;
    final items = state.items.map((r) {
      if (r.id != id) return r;
      nowLiked = !r.likedByMe;
      return r.copyWith(
        likedByMe: nowLiked,
        likeCount: (r.likeCount + (nowLiked ? 1 : -1)).clamp(0, 1 << 30),
      );
    }).toList();
    emit(state.copyWith(items: items));
    try {
      await repository.toggleLike(id, nowLiked);
    } catch (_) {
      // Best-effort: a refresh will reconcile if it failed.
    }
  }
}
