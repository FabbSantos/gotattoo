import 'package:equatable/equatable.dart';

/// One message in a user's support thread.
class SupportMessage extends Equatable {
  final String id;
  final String threadUserId;
  final String authorId;
  final bool fromOwner;
  final String body;
  final DateTime createdAt;

  const SupportMessage({
    required this.id,
    required this.threadUserId,
    required this.authorId,
    required this.fromOwner,
    required this.body,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, threadUserId, authorId, fromOwner, body, createdAt];
}

/// A thread summary for the owner's support inbox (latest message per user).
class SupportThread extends Equatable {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String lastBody;
  final bool lastFromOwner;
  final DateTime lastAt;

  const SupportThread({
    required this.userId,
    required this.userName,
    required this.lastBody,
    required this.lastFromOwner,
    required this.lastAt,
    this.userAvatar,
  });

  @override
  List<Object?> get props =>
      [userId, userName, userAvatar, lastBody, lastFromOwner, lastAt];
}
