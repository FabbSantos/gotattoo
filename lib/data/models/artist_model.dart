import '../../domain/entities/artist.dart';

class ArtistModel extends Artist {
  ArtistModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.rating,
    required super.imageUrl,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      rating: json['rating'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}
