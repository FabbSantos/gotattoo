import 'package:equatable/equatable.dart';

/// A 1:1 chat thread between a client and an artist, as seen by the current
/// user (so [otherId]/[otherName] are always the *other* party).
class Conversation extends Equatable {
  final String id;
  final String otherId;
  final String otherName;
  final String? otherAvatar;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unread;

  /// True when the current user is the artist and the other party (a client)
  /// has an open booking — surfaced first in the list.
  final bool isPriority;

  const Conversation({
    required this.id,
    required this.otherId,
    required this.otherName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.otherAvatar,
    this.unread = 0,
    this.isPriority = false,
  });

  @override
  List<Object?> get props =>
      [id, otherId, otherName, otherAvatar, lastMessage, lastMessageAt, unread, isPriority];
}
