import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/request_comment.dart';
import 'package:gotattoo/domain/entities/tattoo_request.dart';
import 'package:gotattoo/domain/repositories/tattoo_request_repository.dart';
import 'package:gotattoo/presentation/bloc/feed/tattoo_feed_cubit.dart';

TattooRequest _req(String id, String title) => TattooRequest(
      id: id,
      authorId: 'u1',
      authorName: 'Fab',
      title: title,
      description: '',
      createdAt: DateTime(2026, 1, 1),
    );

class FakeRequestRepo implements TattooRequestRepository {
  final List<TattooRequest> initial;
  int seq = 0;
  FakeRequestRepo(this.initial);

  @override
  Future<List<TattooRequest>> feed() async => initial;

  @override
  Future<TattooRequest> create(TattooRequest request) async {
    return _req('new-${seq++}', request.title);
  }

  @override
  Future<TattooRequest> updateRequest(TattooRequest request) async => request;

  @override
  Future<void> deleteRequest(String id) async {}

  @override
  Future<List<RequestComment>> comments(String requestId) async => const [];

  @override
  Future<RequestComment> addComment(RequestComment comment) async => comment;

  @override
  Future<void> report(String targetType, String targetId, String reason) async {}

  @override
  Future<void> toggleLike(String requestId, bool like) async {}
}

void main() {
  test('load fills the feed', () async {
    final cubit = TattooFeedCubit(repository: FakeRequestRepo([_req('1', 'Leão')]));
    await cubit.load();
    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.loading, isFalse);
    await cubit.close();
  });

  test('create prepends the new request', () async {
    final cubit = TattooFeedCubit(repository: FakeRequestRepo([_req('1', 'Leão')]));
    await cubit.load();
    await cubit.create(_req('', 'Rosa'));
    expect(cubit.state.items.first.title, 'Rosa');
    expect(cubit.state.items, hasLength(2));
    await cubit.close();
  });
}
