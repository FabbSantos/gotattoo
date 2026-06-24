import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../domain/entities/artist.dart';
import '../../../domain/repositories/artist_repository.dart';
import 'artist_profile_page.dart';

/// Owner-only: review and approve/reject people who asked to be tattoo artists.
class PendingArtistsPage extends StatefulWidget {
  const PendingArtistsPage({super.key});

  @override
  State<PendingArtistsPage> createState() => _PendingArtistsPageState();
}

class _PendingArtistsPageState extends State<PendingArtistsPage> {
  List<Artist>? _items;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<ArtistRepository>().getPendingArtists();
    if (!mounted) return;
    setState(() => _items = res.fold((_) => <Artist>[], (a) => a));
  }

  Future<void> _decide(Artist a, {required bool approve}) async {
    setState(() => _busyId = a.id);
    final repo = sl<ArtistRepository>();
    final res = await (approve
        ? repo.approveArtist(a.id)
        : repo.rejectArtist(a.id));
    if (!mounted) return;
    setState(() => _busyId = null);
    res.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${f.message}')),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve
                ? '${a.name} aprovado como tatuador!'
                : 'Pedido de ${a.name} recusado.'),
          ),
        );
        setState(() => _items?.removeWhere((x) => x.id == a.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de tatuador')),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.inbox_outlined,
                          size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Nenhum pedido pendente.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _card(items[i]),
                  ),
                ),
    );
  }

  Widget _card(Artist a) {
    final busy = _busyId == a.id;
    final image = avatarImage(a.imageUrl);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 26,
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                backgroundImage: image,
                child: image == null ? const Icon(Icons.person) : null,
              ),
              title: Text(
                a.name.isEmpty ? 'Sem nome' : a.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                a.region.isEmpty ? 'Quer ser tatuador' : a.region,
              ),
              trailing: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistProfilePage(artistId: a.id),
                  ),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Ver'),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _decide(a, approve: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : () => _decide(a, approve: true),
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Aprovar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
