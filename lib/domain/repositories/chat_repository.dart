import '../entities/chat_message.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  /// The current user's conversations (priority first, then most recent).
  Future<List<Conversation>> conversations();

  /// Find or create the current (client) user's thread with [artistId].
  Future<String> openWithArtist(String artistId);

  /// Messages in [conversationId], oldest first.
  Future<List<ChatMessage>> messages(String conversationId);

  /// Send [body] from [senderId] into [conversationId]; returns the saved row.
  Future<ChatMessage> send(String conversationId, String senderId, String body);

  /// Mark the other party's messages in [conversationId] as read.
  Future<void> markRead(String conversationId, String userId);

  /// Emits new messages inserted into [conversationId] in realtime.
  Stream<ChatMessage> streamMessages(String conversationId);
}
