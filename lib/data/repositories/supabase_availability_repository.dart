import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/entities/artist_availability.dart';
import '../../domain/repositories/availability_repository.dart';

class SupabaseAvailabilityRepository implements AvailabilityRepository {
  final SupabaseClient client;

  SupabaseAvailabilityRepository(this.client);

  @override
  Future<ArtistAvailability> get(String artistId) async {
    final row = await client
        .from('artist_availability')
        .select()
        .eq('artist_id', artistId)
        .maybeSingle();
    if (row == null) return ArtistAvailability(artistId: artistId);
    return ArtistAvailability(
      artistId: artistId,
      weekdays: ((row['weekdays'] as List?) ?? const [1, 2, 3, 4, 5])
          .map((e) => (e as num).toInt())
          .toSet(),
      startHour: (row['start_hour'] as num?)?.toInt() ?? 9,
      endHour: (row['end_hour'] as num?)?.toInt() ?? 18,
    );
  }

  @override
  Future<void> save(ArtistAvailability a) async {
    await client.from('artist_availability').upsert({
      'artist_id': a.artistId,
      'weekdays': a.weekdays.toList()..sort(),
      'start_hour': a.startHour,
      'end_hour': a.endHour,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
