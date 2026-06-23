import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/artist/artist_bloc.dart';
import '../../../bloc/artist/artist_state.dart';

/// Compact artist indicator shown when the artist header is collapsed.
class CollapsedArtistBar extends StatelessWidget {
  final String? selectedArtistId;
  final VoidCallback onChooseTap;

  const CollapsedArtistBar({
    super.key,
    required this.selectedArtistId,
    required this.onChooseTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        String artistName = 'Nenhum';
        Widget artistAvatar = CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 16,
          child: const Icon(Icons.person, size: 16, color: Colors.grey),
        );

        final hasSelection = selectedArtistId != null;

        if (state is ArtistsLoaded && hasSelection) {
          final match = state.artists
              .where((artist) => artist.id == selectedArtistId);
          if (match.isNotEmpty) {
            final selectedArtist = match.first;
            artistName = selectedArtist.name.split(' ').first;
            artistAvatar = CircleAvatar(
              backgroundImage: NetworkImage(selectedArtist.imageUrl),
              radius: 16,
            );
          }
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Tatuador:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      hasSelection
                          ? primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasSelection ? primary : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    artistAvatar,
                    const SizedBox(width: 6),
                    Text(
                      artistName,
                      style: TextStyle(
                        color: hasSelection ? primary : Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_drop_down,
                      color: hasSelection ? primary : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onChooseTap,
                icon: const Icon(Icons.people, size: 16),
                label: const Text('Escolher'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
