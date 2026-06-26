import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/blocked_user.dart';
import '../../domain/repositories/block_repository.dart';

class SupabaseBlockRepository implements BlockRepository {
  final SupabaseClient client;

  SupabaseBlockRepository(this.client);

  @override
  Future<Set<String>> blockedIds() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return {};
    final rows = await client
        .from('user_blocks')
        .select('blocked_id')
        .eq('blocker_id', uid);
    return rows.map((r) => r['blocked_id'] as String).toSet();
  }

  @override
  Future<void> block(String userId) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null || userId == uid) return;
    await client.from('user_blocks').upsert({
      'blocker_id': uid,
      'blocked_id': userId,
    });
  }

  @override
  Future<void> unblock(String userId) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    await client
        .from('user_blocks')
        .delete()
        .eq('blocker_id', uid)
        .eq('blocked_id', userId);
  }

  @override
  Future<List<BlockedUser>> blockedUsers() async {
    final ids = await blockedIds();
    if (ids.isEmpty) return [];
    final rows = await client
        .from('profiles')
        .select('id, name, avatar_url')
        .inFilter('id', ids.toList());
    return rows
        .map((r) => BlockedUser(
              id: r['id'] as String,
              name: (r['name'] as String?)?.isNotEmpty == true
                  ? r['name'] as String
                  : 'Usuário',
              avatar: r['avatar_url'] as String?,
            ))
        .toList();
  }
}
