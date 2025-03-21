import '../models/artist_model.dart';

abstract class ArtistDataSource {
  Future<List<ArtistModel>> getArtists();
  Future<ArtistModel> getArtist(String id);
}

class ArtistLocalDataSourceImpl implements ArtistDataSource {
  // Lista de tatuadores fictícios
  final List<Map<String, dynamic>> _artistsData = [
    {
      'id': '1',
      'name': 'João Silva',
      'specialty': 'Realista',
      'rating': 4.8,
      'imageUrl':
          'https://images.unsplash.com/photo-1597223557154-721c1cecc4b0?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': '2',
      'name': 'Ana Costa',
      'specialty': 'Aquarela',
      'rating': 4.9,
      'imageUrl':
          'https://images.unsplash.com/photo-1614583225154-5fcdda07019e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': '3',
      'name': 'Pedro Matos',
      'specialty': 'Old School',
      'rating': 4.7,
      'imageUrl':
          'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': '4',
      'name': 'Carla Dias',
      'specialty': 'Blackwork',
      'rating': 4.6,
      'imageUrl':
          'https://images.unsplash.com/photo-1542458580-9d880e2a6bdd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': '5',
      'name': 'Lucas Reis',
      'specialty': 'Geométrica',
      'rating': 4.5,
      'imageUrl':
          'https://images.unsplash.com/photo-1591190895404-20b87628ce5c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  Future<List<ArtistModel>> getArtists() async {
    // Simular um atraso de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Converter os dados para modelos
    return _artistsData.map((json) => ArtistModel.fromJson(json)).toList();
  }

  @override
  Future<ArtistModel> getArtist(String id) async {
    // Simular um atraso de rede
    await Future.delayed(const Duration(milliseconds: 300));

    // Buscar o artista pelo ID
    final artistData = _artistsData.firstWhere(
      (artist) => artist['id'] == id,
      orElse: () => throw Exception('Artista não encontrado'),
    );

    return ArtistModel.fromJson(artistData);
  }
}
