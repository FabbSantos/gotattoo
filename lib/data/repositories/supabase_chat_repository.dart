import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient client;

  SupabaseChatRepository(this.client);

  ChatMessage _toMessage(Map<String, dynamic> r) => ChatMessage(
        id: r['id'] as String,
        conversationId: r['conversation_id'] as String,
        senderId: r['sender_id'] as String,
        body: r['body'] as String? ?? '',
        read: r['read'] as bool? ?? false,
        createdAt: DateTime.parse(r['created_at'] as String),
      );

  @override
  Future<List<Conversation>> conversations() async {
    final rows = await client.rpc('conversation_list') as List;
    return rows.map((r) {
      final m = r as Map<String, dynamic>;
      return Conversation(
        id: m['id'] as String,
        otherId: m['other_id'] as String? ?? '',
        otherName: m['other_name'] as String? ?? 'Usuário',
        otherAvatar: m['other_avatar'] as String?,
        lastMessage: m['last_message'] as String? ?? '',
        lastMessageAt: DateTime.parse(m['last_message_at'] as String),
        unread: (m['unread'] as num?)?.toInt() ?? 0,
        isPriority: m['is_priority'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<String> openWithArtist(String artistId) async {
    final res = await client.rpc(
      'get_or_create_conversation',
      params: {'p_artist_id': artistId},
    );
    return res as String;
  }

  @override
  Future<String> openWithClient(String clientId) async {
    final res = await client.rpc(
      'get_or_create_conversation_as_artist',
      params: {'p_client_id': clientId},
    );
    return res as String;
  }

  @override
  Future<List<ChatMessage>> messages(String conversationId) async {
    final rows = await client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return rows.map((r) => _toMessage(r)).toList();
  }

  @override
  Future<ChatMessage> send(
    String conversationId,
    String senderId,
    String body,
  ) async {
    final row = await client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'body': body,
        })
        .select()
        .single();
    return _toMessage(row);
  }

  @override
  Future<void> markRead(String conversationId, String userId) async {
    await client
        .from('messages')
        .update({'read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('read', false);
  }

  @override
  Stream<ChatMessage> streamMessages(String conversationId) {
    final controller = StreamController<ChatMessage>();
    final channel = client.channel('messages:$conversationId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) => controller.add(_toMessage(payload.newRecord)),
        )
        .subscribe();

    controller.onCancel = () => client.removeChannel(channel);
    return controller.stream;
  }
}
