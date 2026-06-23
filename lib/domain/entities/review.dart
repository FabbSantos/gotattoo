import 'package:equatable/equatable.dart';

/// A client's feedback for an artist after a completed appointment.
class Review extends Equatable {
  final String id;
  final String artistId;
  final String clientId;
  final String clientName;
  final int rating; // 1–5
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.artistId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    artistId,
    clientId,
    clientName,
    rating,
    comment,
    createdAt,
  ];
}
