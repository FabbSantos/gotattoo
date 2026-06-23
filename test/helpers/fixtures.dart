import 'package:gotattoo/domain/entities/artist.dart';
import 'package:gotattoo/domain/entities/product.dart';

const tProduct = Product(
  id: '1',
  name: 'Dragão Oriental',
  description: 'Tatuagem de dragão tradicional japonês.',
  price: 1200.00,
  imageUrl: 'https://example.com/dragon.png',
  stock: 5,
  category: 'Old School',
  artistId: '3',
);

const tProductMinimalist = Product(
  id: '8',
  name: 'Linhas Minimalistas',
  description: 'Design minimalista.',
  price: 350.00,
  imageUrl: 'https://example.com/lines.png',
  stock: 15,
  category: 'Minimalista',
  artistId: '5',
);

const tArtist = Artist(
  id: '1',
  name: 'João Silva',
  specialty: 'Realista',
  rating: 4.8,
  imageUrl: 'https://example.com/joao.png',
);

final tProductJson = <String, dynamic>{
  'id': '1',
  'name': 'Dragão Oriental',
  'description': 'Tatuagem de dragão tradicional japonês.',
  'price': 1200.00,
  'imageUrl': 'https://example.com/dragon.png',
  'stock': 5,
  'category': 'Old School',
  'artistId': '3',
};

final tArtistJson = <String, dynamic>{
  'id': '1',
  'name': 'João Silva',
  'specialty': 'Realista',
  'rating': 4.8,
  'imageUrl': 'https://example.com/joao.png',
};
