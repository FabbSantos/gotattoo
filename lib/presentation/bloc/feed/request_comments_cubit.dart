import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/request_comment.dart';
import '../../../domain/repositories/tattoo_request_repository.dart';

class RequestCommentsState extends Equatable {
  final bool loading;
  final List<RequestComment> items;

  const RequestCommentsState({this.loading = true, this.items = const []});

  RequestCommentsState copyWith({bool? loading, List<RequestComment>? items}) =>
      RequestCommentsState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [loading, items];
}

class RequestCommentsCubit extends Cubit<RequestCommentsState> {
  final TattooRequestRepository repository;
  final String requestId;

  RequestCommentsCubit({required this.repository, required this.requestId})
      : super(const RequestCommentsState());

  Future<void> load() async {
    emit(RequestCommentsState(
      loading: false,
      items: await repository.comments(requestId),
    ));
  }

  Future<void> add(RequestComment comment) async {
    final saved = await repository.addComment(comment);
    emit(state.copyWith(items: [...state.items, saved]));
  }
}
