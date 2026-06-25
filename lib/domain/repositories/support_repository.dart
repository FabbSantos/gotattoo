import '../entities/support_message.dart';

/// In-app support: a per-user message thread the owner can answer.
abstract class SupportRepository {
  /// Live messages for a thread (the user's own, or any thread for the owner).
  Stream<List<SupportMessage>> watch(String threadUserId);

  /// Post a message. [asOwner] true when the owner is replying.
  Future<void> send({
    required String threadUserId,
    required String body,
    required bool asOwner,
  });

  /// Owner inbox: latest message per thread.
  Future<List<SupportThread>> threads();
}
