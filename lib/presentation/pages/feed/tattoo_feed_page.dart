import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show AdSize;

import '../../../core/di/injection_container.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../domain/entities/tattoo_request.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/feed/tattoo_feed_cubit.dart';
import '../../widgets/components/common/artist_tag.dart';
import '../../widgets/components/common/feed_banner_ad.dart';
import '../../widgets/components/common/owner_tag.dart';
import '../../widgets/components/common/sensitive_image.dart';
import 'create_request_page.dart';
import 'request_detail_page.dart';

/// Public "mural de ideias": tattoo requests anyone can post and artists engage.
class TattooFeedPage extends StatelessWidget {
  const TattooFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TattooFeedCubit>()..load(),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView();

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
  bool _mineOnly = false;

  Future<void> _refresh() => context.read<TattooFeedCubit>().load();

  Future<void> _create() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRequestPage()),
    );
    if (mounted) _refresh();
  }

  Future<void> _open(TattooRequest r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RequestDetailPage(request: r)),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mural de ideias')),
      bottomNavigationBar: const FeedBannerAd(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Publicar ideia'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Todos')),
                ButtonSegment(value: true, label: Text('Meus posts')),
              ],
              selected: {_mineOnly},
              onSelectionChanged: (s) => setState(() => _mineOnly = s.first),
              showSelectedIcon: false,
            ),
          ),
          Expanded(child: _list()),
        ],
      ),
    );
  }

  Widget _list() {
    final userId = context.read<AuthCubit>().state.user?.id;
    return BlocBuilder<TattooFeedCubit, TattooFeedState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = _mineOnly
              ? state.items.where((r) => r.authorId == userId).toList()
              : state.items;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 56, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma ideia ainda.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Publique a tattoo que você quer fazer — os tatuadores chamam.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }
          // Intersperse a card-sized ad every few posts. `null` marks an ad.
          const adEvery = 6;
          final entries = <dynamic>[];
          for (var i = 0; i < items.length; i++) {
            entries.add(items[i]);
            if ((i + 1) % adEvery == 0 && i != items.length - 1) {
              entries.add(null);
            }
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final entry = entries[i];
                if (entry == null) {
                  return const Center(
                    child: FeedBannerAd(size: AdSize.mediumRectangle),
                  );
                }
                return _RequestCard(
                  request: entry,
                  onTap: () => _open(entry),
                  onLike: () =>
                      context.read<TattooFeedCubit>().toggleLike(entry.id),
                );
              },
            ),
          );
        },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TattooRequest request;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _RequestCard({
    required this.request,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row (Facebook-style header).
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatarImage(request.authorAvatar),
                    child: avatarImage(request.authorAvatar) == null
                        ? const Icon(Icons.person, size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                request.authorName.isEmpty
                                    ? 'alguém'
                                    : request.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ),
                            if (request.authorIsOwner) ...[
                              const SizedBox(width: 6),
                              const OwnerTag(),
                            ],
                            if (request.authorIsArtist) ...[
                              const SizedBox(width: 6),
                              const ArtistTag(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (request.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  request.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                ),
              ],
              if (request.imageUrl != null && request.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 10),
                SensitiveImage(
                  url: request.imageUrl!,
                  sensitive: request.sensitive,
                  height: 180,
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (request.placement != null &&
                      request.placement!.isNotEmpty)
                    _chip(Icons.place_outlined, request.placement!, primary),
                  if (request.budget != null)
                    _chip(
                      Icons.attach_money,
                      'até R\$ ${request.budget!.toStringAsFixed(0)}',
                      primary,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onLike,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            request.likedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: request.likedByMe
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text('${request.likeCount}',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.mode_comment_outlined,
                      size: 17, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${request.commentCount}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      );
}
