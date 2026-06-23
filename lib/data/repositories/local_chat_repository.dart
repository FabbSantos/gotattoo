import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

/// Offline/test stub: no backend, so there are no conversations or messages.
class LocalChatRepository implements ChatRepository {
  @override
  Future<List<Conversation>> conversations() async => const [];

  @override
  Future<String> openWithArtist(String artistId) async => '';

  @override
  Future<List<ChatMessage>> messages(String conversationId) async => const [];

  @override
  Future<ChatMessage> send(
    String conversationId,
    String senderId,
    String body,
  ) async =>
      ChatMessage(
        id: '',
        conversationId: conversationId,
        senderId: senderId,
        body: body,
        createdAt: DateTime.now(),
      );

  @override
  Future<void> markRead(String conversationId, String userId) async {}

  @override
  Stream<ChatMessage> streamMessages(String conversationId) =>
      const Stream.empty();
}
