import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;

  /// Id of the artist who designed this tattoo. Links a product to an [Artist].
  final String artistId;

  /// Discount the artist applies to this tattoo, 0–100 (%). The customer pays
  /// [effectivePrice]; the platform fee is computed on what they actually pay.
  final int discountPercent;

  /// How long the session takes, in hours. Used to block overlapping bookings.
  final int durationHours;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.artistId,
    this.discountPercent = 0,
    this.durationHours = 2,
  });

  bool get hasDiscount => discountPercent > 0;

  /// Price the customer actually pays, after the artist's discount.
  double get effectivePrice => price * (1 - discountPercent / 100);

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    stock,
    category,
    artistId,
    discountPercent,
    durationHours,
  ];
}
