import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/error/failures.dart';
import '../../domain/entities/artist.dart';
import '../../domain/repositories/artist_repository.dart';

/// Artists are profiles with `role = 'artist'`.
class SupabaseArtistRepository implements ArtistRepository {
  final SupabaseClient client;

  SupabaseArtistRepository(this.client);

  Artist _toArtist(Map<String, dynamic> r) => Artist(
    id: r['id'] as String,
    name: r['name'] as String? ?? '',
    specialty: r['specialty'] as String? ?? '',
    rating: (r['rating'] as num?)?.toDouble() ?? 0,
    imageUrl: r['avatar_url'] as String? ?? '',
    region: r['region'] as String? ?? '',
    latitude: (r['latitude'] as num?)?.toDouble(),
    longitude: (r['longitude'] as num?)?.toDouble(),
    featured: r['featured'] as bool? ?? false,
  );

  @override
  Future<Either<Failure, List<Artist>>> getArtists() async {
    try {
      final rows = await client
          .from('profiles')
          .select()
          .eq('role', 'artist')
          .order('featured', ascending: false)
          .order('rating', ascending: false);
      return Right(rows.map((r) => _toArtist(r)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Artist>> getArtist(String id) async {
    try {
      final row = await client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) return const Left(NotFoundFailure('Tatuador não encontrado.'));
      return Right(_toArtist(row));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
