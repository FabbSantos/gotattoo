import 'package:equatable/equatable.dart';

/// A tattoo idea a user wants done, posted to the public feed for artists to
/// comment on and reach out about.
class TattooRequest extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String description;
  final String? imageUrl;
  final String? placement;
  final double? budget;
  final String status; // open | closed
  final bool authorIsArtist;
  final bool sensitive;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final DateTime createdAt;

  const TattooRequest({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.createdAt,
    this.authorAvatar,
    this.imageUrl,
    this.placement,
    this.budget,
    this.status = 'open',
    this.authorIsArtist = false,
    this.sensitive = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
  });

  TattooRequest copyWith({int? likeCount, bool? likedByMe}) => TattooRequest(
        id: id,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        title: title,
        description: description,
        imageUrl: imageUrl,
        placement: placement,
        budget: budget,
        status: status,
        authorIsArtist: authorIsArtist,
        sensitive: sensitive,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount,
        likedByMe: likedByMe ?? this.likedByMe,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        authorAvatar,
        title,
        description,
        imageUrl,
        placement,
        budget,
        status,
        authorIsArtist,
        sensitive,
        likeCount,
        commentCount,
        likedByMe,
        createdAt,
      ];
}
