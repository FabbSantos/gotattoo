import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/cache_store.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/repositories/chat_repository.dart';

class ConversationsState extends Equatable {
  final bool loading;
  final List<Conversation> items;

  const ConversationsState({this.loading = false, this.items = const []});

  int get totalUnread => items.fold(0, (sum, c) => sum + c.unread);

  ConversationsState copyWith({bool? loading, List<Conversation>? items}) =>
      ConversationsState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [loading, items];
}

/// App-level: the current user's conversation list and the total unread count
/// for the home "Mensagens" badge.
class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRepository repository;
  final CacheStore? cache;
  String? _userId;

  ConversationsCubit({required this.repository, this.cache})
      : super(const ConversationsState());

  String _key(String userId) => 'cache_conversations_$userId';

  Future<void> start(String userId) async {
    _userId = userId;
    // Show the last snapshot instantly, then refresh from the network.
    final cached = cache?.readList(_key(userId));
    if (cached != null) {
      emit(ConversationsState(items: cached.map(_fromCache).toList()));
    }
    await refresh();
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    if (state.items.isEmpty) emit(state.copyWith(loading: true));
    final items = await repository.conversations();
    emit(ConversationsState(items: items));
    cache?.writeList(_key(userId), items.map(_toCache).toList());
  }

  void stop() {
    _userId = null;
    emit(const ConversationsState());
  }
}

Map<String, dynamic> _toCache(Conversation c) => {
      'id': c.id,
      'other_id': c.otherId,
      'other_name': c.otherName,
      'other_avatar': c.otherAvatar,
      'last_message': c.lastMessage,
      'last_message_at': c.lastMessageAt.toIso8601String(),
      'unread': c.unread,
      'is_priority': c.isPriority,
    };

Conversation _fromCache(Map<String, dynamic> m) => Conversation(
      id: m['id'] as String,
      otherId: m['other_id'] as String? ?? '',
      otherName: m['other_name'] as String? ?? 'Usuário',
      otherAvatar: m['other_avatar'] as String?,
      lastMessage: m['last_message'] as String? ?? '',
      lastMessageAt: DateTime.parse(m['last_message_at'] as String),
      unread: (m['unread'] as num?)?.toInt() ?? 0,
      isPriority: m['is_priority'] as bool? ?? false,
    );
