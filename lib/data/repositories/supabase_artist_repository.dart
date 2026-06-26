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
    isOwner: r['is_owner'] as bool? ?? false,
    portfolio: r['portfolio'] as String? ?? '',
    instagram: r['instagram'] as String? ?? '',
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

  @override
  Future<Either<Failure, List<Artist>>> getPendingArtists() async {
    try {
      final rows = await client
          .from('profiles')
          .select()
          .eq('artist_status', 'pending')
          .order('created_at', ascending: false);
      return Right(rows.map((r) => _toArtist(r)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveArtist(String id) async {
    try {
      await client.rpc('approve_artist', params: {'p_id': id});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectArtist(String id, String reason) async {
    try {
      await client.rpc('reject_artist', params: {
        'p_id': id,
        'p_reason': reason,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
