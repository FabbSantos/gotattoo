import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/request_comment.dart';
import '../../domain/entities/tattoo_request.dart';
import '../../domain/repositories/tattoo_request_repository.dart';

class SupabaseTattooRequestRepository implements TattooRequestRepository {
  final SupabaseClient client;

  SupabaseTattooRequestRepository(this.client);

  /// Ids the given user has blocked (their content is hidden from the feed).
  Future<Set<String>> _blockedIds(String uid) async {
    final rows = await client
        .from('user_blocks')
        .select('blocked_id')
        .eq('blocker_id', uid);
    return rows.map((r) => r['blocked_id'] as String).toSet();
  }

  TattooRequest _toRequest(Map<String, dynamic> r) => TattooRequest(
        id: r['id'] as String,
        authorId: r['author_id'] as String,
        authorName: r['author_name'] as String? ?? '',
        authorAvatar: r['author_avatar'] as String?,
        title: r['title'] as String? ?? '',
        description: r['description'] as String? ?? '',
        imageUrl: r['image_url'] as String?,
        placement: r['placement'] as String?,
        budget: (r['budget'] as num?)?.toDouble(),
        status: r['status'] as String? ?? 'open',
        authorIsArtist: r['author_is_artist'] as bool? ?? false,
        authorIsOwner: r['author_is_owner'] as bool? ?? false,
        sensitive: r['sensitive'] as bool? ?? false,
        likeCount: (r['like_count'] as num?)?.toInt() ?? 0,
        commentCount: (r['comment_count'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(r['created_at'] as String),
      );

  RequestComment _toComment(Map<String, dynamic> r) => RequestComment(
        id: r['id'] as String,
        requestId: r['request_id'] as String,
        authorId: r['author_id'] as String,
        authorName: r['author_name'] as String? ?? '',
        authorAvatar: r['author_avatar'] as String?,
        body: r['body'] as String? ?? '',
        authorIsArtist: r['author_is_artist'] as bool? ?? false,
        authorIsOwner: r['author_is_owner'] as bool? ?? false,
        createdAt: DateTime.parse(r['created_at'] as String),
      );

  @override
  Future<List<TattooRequest>> feed() async {
    final rows = await client
        .from('tattoo_requests')
        .select()
        .order('created_at', ascending: false);
    var list = rows.map((r) => _toRequest(r)).toList();

    // Mark which ones the current user has liked.
    final uid = client.auth.currentUser?.id;
    if (uid == null || list.isEmpty) return list;

    // Hide posts from blocked users.
    final blocked = await _blockedIds(uid);
    if (blocked.isNotEmpty) {
      list = list.where((r) => !blocked.contains(r.authorId)).toList();
    }
    if (list.isEmpty) return list;

    final likes = await client
        .from('request_likes')
        .select('request_id')
        .eq('user_id', uid);
    final liked = (likes as List)
        .map((l) => (l as Map)['request_id'] as String)
        .toSet();
    return [
      for (final r in list)
        liked.contains(r.id) ? r.copyWith(likedByMe: true) : r,
    ];
  }

  @override
  Future<void> toggleLike(String requestId, bool like) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    if (like) {
      await client.from('request_likes').upsert({
        'request_id': requestId,
        'user_id': uid,
      });
    } else {
      await client
          .from('request_likes')
          .delete()
          .eq('request_id', requestId)
          .eq('user_id', uid);
    }
  }

  @override
  Future<TattooRequest> create(TattooRequest request) async {
    final row = await client
        .from('tattoo_requests')
        .insert({
          'author_id': request.authorId,
          'author_name': request.authorName,
          'author_avatar': request.authorAvatar,
          'title': request.title,
          'description': request.description,
          'image_url': request.imageUrl,
          'placement': request.placement,
          'budget': request.budget,
          'sensitive': request.sensitive,
        })
        .select()
        .single();
    return _toRequest(row);
  }

  @override
  Future<TattooRequest> updateRequest(TattooRequest request) async {
    final row = await client
        .from('tattoo_requests')
        .update({
          'title': request.title,
          'description': request.description,
          'image_url': request.imageUrl,
          'placement': request.placement,
          'budget': request.budget,
          'sensitive': request.sensitive,
        })
        .eq('id', request.id)
        .select()
        .single();
    return _toRequest(row);
  }

  @override
  Future<void> deleteRequest(String id) async {
    await client.from('tattoo_requests').delete().eq('id', id);
  }

  @override
  Future<List<RequestComment>> comments(String requestId) async {
    final rows = await client
        .from('tattoo_request_comments')
        .select()
        .eq('request_id', requestId)
        .order('created_at', ascending: true);
    var list = rows.map((r) => _toComment(r)).toList();
    // Hide comments from blocked users.
    final uid = client.auth.currentUser?.id;
    if (uid != null && list.isNotEmpty) {
      final blocked = await _blockedIds(uid);
      if (blocked.isNotEmpty) {
        list = list.where((c) => !blocked.contains(c.authorId)).toList();
      }
    }
    return list;
  }

  @override
  Future<RequestComment> addComment(RequestComment comment) async {
    final row = await client
        .from('tattoo_request_comments')
        .insert({
          'request_id': comment.requestId,
          'author_id': comment.authorId,
          'author_name': comment.authorName,
          'author_avatar': comment.authorAvatar,
          'body': comment.body,
        })
        .select()
        .single();
    return _toComment(row);
  }

  @override
  Future<void> report(String targetType, String targetId, String reason) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    await client.from('reports').insert({
      'reporter_id': uid,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
    });
  }
}
