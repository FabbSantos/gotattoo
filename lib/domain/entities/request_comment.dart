import 'package:equatable/equatable.dart';

/// A comment on a [TattooRequest] — usually an artist showing interest.
class RequestComment extends Equatable {
  final String id;
  final String requestId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String body;
  final bool authorIsArtist;
  final bool authorIsOwner;
  final DateTime createdAt;

  const RequestComment({
    required this.id,
    required this.requestId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.authorAvatar,
    this.authorIsArtist = false,
    this.authorIsOwner = false,
  });

  @override
  List<Object?> get props => [
        id,
        requestId,
        authorId,
        authorName,
        authorAvatar,
        body,
        authorIsArtist,
        authorIsOwner,
        createdAt,
      ];
}
