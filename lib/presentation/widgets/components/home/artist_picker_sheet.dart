import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/avatar_image.dart';
import '../../../bloc/artist/artist_bloc.dart';
import '../../../bloc/artist/artist_state.dart';
import '../../../pages/artist/artist_profile_page.dart';

/// Bottom sheet that lets the user pick an artist (or clear the selection).
class ArtistPickerSheet {
  static Future<void> show(
    BuildContext context, {
    required String? selectedArtistId,
    required ValueChanged<String?> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Selecione um tatuador',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              BlocBuilder<ArtistBloc, ArtistState>(
                builder: (context, state) {
                  if (state is! ArtistsLoaded) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final primary = Theme.of(context).primaryColor;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.artists.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = selectedArtistId == null;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.person_off,
                                color: Colors.grey,
                              ),
                            ),
                            title: const Text('Nenhum'),
                            trailing:
                                isSelected
                                    ? Icon(Icons.check, color: primary)
                                    : null,
                            onTap: () {
                              onSelected(null);
                              Navigator.pop(sheetContext);
                            },
                          );
                        }

                        final artist = state.artists[index - 1];
                        final isSelected = artist.id == selectedArtistId;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: avatarImage(artist.imageUrl),
                          ),
                          title: Text(artist.name),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 13),
                              const SizedBox(width: 2),
                              Text(
                                  '${artist.ratingLabel}  ·  ${artist.specialty}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Icon(Icons.check, color: primary),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                tooltip: 'Ver perfil e avaliações',
                                onPressed: () => Navigator.push(
                                  sheetContext,
                                  MaterialPageRoute(
                                    builder: (_) => ArtistProfilePage(
                                    artist: artist,
                                    artistId: artist.id,
                                  ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            onSelected(artist.id);
                            Navigator.pop(sheetContext);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
