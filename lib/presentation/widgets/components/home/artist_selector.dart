import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/location_service.dart';
import '../../../../domain/entities/artist.dart';
import '../../../bloc/artist/artist_bloc.dart';
import '../../../bloc/artist/artist_state.dart';

/// Max distance (km) for the "nearby" filter when a client location is set.
const double _nearbyRadiusKm = 60;

/// Horizontal, expanded list of artist avatars shown in the pinned header.
class ArtistSelector extends StatelessWidget {
  final String? selectedArtistId;
  final ValueChanged<String?> onSelected;

  /// Client coordinates; when set, artists are filtered/sorted by distance.
  final double? clientLat;
  final double? clientLng;

  const ArtistSelector({
    super.key,
    required this.selectedArtistId,
    required this.onSelected,
    this.clientLat,
    this.clientLng,
  });

  bool get _hasLocation => clientLat != null && clientLng != null;

  double? _distanceTo(Artist a) {
    if (!_hasLocation || !a.hasLocation) return null;
    return LocationService.distanceKm(
      clientLat!,
      clientLng!,
      a.latitude!,
      a.longitude!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              _hasLocation ? 'Tatuadores por perto' : 'Tatuadores',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ArtistBloc, ArtistState>(
              builder: (context, state) {
                if (state is ArtistsLoading) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (state is ArtistsLoaded) {
                  var artists = state.artists.toList();
                  if (_hasLocation) {
                    artists = artists
                        .where((a) =>
                            a.hasLocation &&
                            _distanceTo(a)! <= _nearbyRadiusKm)
                        .toList()
                      // Featured first, then nearest.
                      ..sort((a, b) {
                        if (a.featured != b.featured) {
                          return a.featured ? -1 : 1;
                        }
                        return _distanceTo(a)!.compareTo(_distanceTo(b)!);
                      });
                  }
                  if (artists.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum tatuador por perto',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artists.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      final isSelected = artist.id == selectedArtistId;
                      final primary = Theme.of(context).primaryColor;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onSelected(isSelected ? null : artist.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 72,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    height: 58,
                                    width: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? primary
                                                : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: NetworkImage(
                                        artist.imageUrl,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  if (artist.featured)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.amber,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                artist.name.split(' ').first,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: isSelected ? primary : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    artist.ratingLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (_distanceTo(artist) != null)
                                Text(
                                  '${_distanceTo(artist)!.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ArtistError) {
                  return Center(
                    child: Text(
                      'Erro: ${state.message}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Nenhum artista encontrado',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
