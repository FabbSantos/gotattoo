import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String imageUrl;

  /// Region/neighborhood label the artist works in (display only).
  final String region;

  /// Geographic location, used by the distance-based "nearby" filter.
  final double? latitude;
  final double? longitude;

  /// Promoted artist ("Destaque") — sorted first and badged in the UI.
  final bool featured;

  const Artist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.imageUrl,
    this.region = '',
    this.latitude,
    this.longitude,
    this.featured = false,
  });

  bool get isRated => rating > 0;

  /// "Novo" until the artist has real reviews, otherwise the average score.
  String get ratingLabel => isRated ? rating.toStringAsFixed(1) : 'Novo';

  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    id,
    name,
    specialty,
    rating,
    imageUrl,
    region,
    latitude,
    longitude,
    featured,
  ];
}
