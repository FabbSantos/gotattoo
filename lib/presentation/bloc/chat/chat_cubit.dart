import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/cache_store.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';

class ChatState extends Equatable {
  final bool loading;
  final List<ChatMessage> messages;

  const ChatState({this.loading = false, this.messages = const []});

  ChatState copyWith({bool? loading, List<ChatMessage>? messages}) => ChatState(
        loading: loading ?? this.loading,
        messages: messages ?? this.messages,
      );

  @override
  List<Object?> get props => [loading, messages];
}

/// Drives a single open conversation: loads history, streams new messages in
/// realtime, and sends. One instance per opened [conversationId].
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final String conversationId;
  final String userId;
  final CacheStore? cache;

  StreamSubscription? _sub;

  ChatCubit({
    required this.repository,
    required this.conversationId,
    required this.userId,
    this.cache,
  }) : super(const ChatState(loading: true));

  String get _key => 'cache_messages_$conversationId';

  Future<void> load() async {
    // Show cached history instantly, then refresh from the network.
    final cached = cache?.readList(_key);
    if (cached != null) {
      emit(ChatState(messages: cached.map(_fromCache).toList()));
    }

    final msgs = await repository.messages(conversationId);
    emit(ChatState(messages: msgs));
    _persist();
    await repository.markRead(conversationId, userId);

    _sub?.cancel();
    _sub = repository.streamMessages(conversationId).listen((m) {
      if (state.messages.any((x) => x.id == m.id)) return; // de-dupe own echo
      emit(state.copyWith(messages: [...state.messages, m]));
      _persist();
      if (m.senderId != userId) {
        repository.markRead(conversationId, userId);
      }
    });
  }

  Future<void> send(String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final msg = await repository.send(conversationId, userId, text);
    if (msg.id.isNotEmpty && !state.messages.any((x) => x.id == msg.id)) {
      emit(state.copyWith(messages: [...state.messages, msg]));
      _persist();
    }
  }

  /// Persist the most recent slice of the thread for instant reopen.
  void _persist() {
    if (cache == null) return;
    const limit = 100;
    final msgs = state.messages;
    final slice = msgs.length > limit ? msgs.sublist(msgs.length - limit) : msgs;
    cache!.writeList(_key, slice.map(_toCache).toList());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

Map<String, dynamic> _toCache(ChatMessage m) => {
      'id': m.id,
      'conversation_id': m.conversationId,
      'sender_id': m.senderId,
      'body': m.body,
      'read': m.read,
      'created_at': m.createdAt.toIso8601String(),
    };

ChatMessage _fromCache(Map<String, dynamic> m) => ChatMessage(
      id: m['id'] as String,
      conversationId: m['conversation_id'] as String,
      senderId: m['sender_id'] as String,
      body: m['body'] as String? ?? '',
      read: m['read'] as bool? ?? false,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
