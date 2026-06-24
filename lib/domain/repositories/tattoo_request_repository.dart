import '../entities/request_comment.dart';
import '../entities/tattoo_request.dart';

abstract class TattooRequestRepository {
  /// The public feed, newest first.
  Future<List<TattooRequest>> feed();

  /// Publish a new request; returns the saved row.
  Future<TattooRequest> create(TattooRequest request);

  /// Update a request the current user authored; returns the saved row.
  Future<TattooRequest> updateRequest(TattooRequest request);

  /// Delete a request the current user authored.
  Future<void> deleteRequest(String id);

  /// Comments on [requestId], oldest first.
  Future<List<RequestComment>> comments(String requestId);

  /// Add a comment; returns the saved row.
  Future<RequestComment> addComment(RequestComment comment);

  /// Report content for manual review ([targetType] = 'request' | 'comment').
  Future<void> report(String targetType, String targetId, String reason);

  /// Like ([like] = true) or unlike a request for the current user.
  Future<void> toggleLike(String requestId, bool like);
}
