import '../../domain/entities/request_comment.dart';
import '../../domain/entities/tattoo_request.dart';
import '../../domain/repositories/tattoo_request_repository.dart';

/// Offline/test stub: no backend, so the feed is empty.
class LocalTattooRequestRepository implements TattooRequestRepository {
  @override
  Future<List<TattooRequest>> feed() async => const [];

  @override
  Future<TattooRequest> create(TattooRequest request) async => request;

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
