import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';

class SupabaseSupportRepository implements SupportRepository {
  final SupabaseClient client;

  SupabaseSupportRepository(this.client);

  SupportMessage _toMsg(Map<String, dynamic> r) => SupportMessage(
        id: r['id'] as String,
        threadUserId: r['thread_user_id'] as String,
        authorId: r['author_id'] as String,
        fromOwner: r['from_owner'] as bool? ?? false,
        body: r['body'] as String? ?? '',
        createdAt: DateTime.parse(r['created_at'] as String),
      );

  @override
  Stream<List<SupportMessage>> watch(String threadUserId) {
    return client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('thread_user_id', threadUserId)
        .order('created_at')
        .map((rows) => rows.map(_toMsg).toList());
  }

  @override
  Future<void> send({
    required String threadUserId,
    required String body,
    required bool asOwner,
  }) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    await client.from('support_messages').insert({
      'thread_user_id': threadUserId,
      'author_id': uid,
      'from_owner': asOwner,
      'body': body,
    });
  }

  @override
  Future<List<SupportThread>> threads() async {
    final rows = await client
        .from('support_threads')
        .select()
        .order('last_at', ascending: false);
    return rows
        .map((r) => SupportThread(
              userId: r['user_id'] as String,
              userName: (r['user_name'] as String?)?.isNotEmpty == true
                  ? r['user_name'] as String
                  : 'Usuário',
              userAvatar: r['user_avatar'] as String?,
              lastBody: (r['last_body'] as String?) ?? '',
              lastFromOwner: r['last_from_owner'] as bool? ?? false,
              lastAt: DateTime.parse(r['last_at'] as String),
            ))
        .toList();
  }
}
