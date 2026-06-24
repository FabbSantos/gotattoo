import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../core/utils/url_opener.dart';
import '../../../domain/entities/artist.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/repositories/artist_repository.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/review/reviews_cubit.dart';
import '../../widgets/components/common/owner_tag.dart';
import '../../widgets/components/review/review_dialog.dart';
import '../../widgets/components/review/star_rating.dart';
import '../chat/chat_page.dart';
import '../user/product_detail_page.dart';

/// Public artist profile: info + client reviews, with a quick "Avaliar" action.
///
/// Open it with a preloaded [artist] (e.g. from the picker) or by [artistId]
/// (the artist is fetched).
class ArtistProfilePage extends StatelessWidget {
  final Artist? artist;
  final String artistId;

  const ArtistProfilePage({super.key, this.artist, required this.artistId});

  Future<Artist?> _fetch() async {
    final res = await sl<ArtistRepository>().getArtist(artistId);
    return res.fold((_) => null, (a) => a);
  }

  @override
  Widget build(BuildContext context) {
    if (artist != null) {
      return BlocProvider(
        create: (_) => sl<ReviewsCubit>()..load(artistId),
        child: _ProfileView(artist: artist!),
      );
    }
    return FutureBuilder<Artist?>(
      future: _fetch(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Tatuador não encontrado')),
          );
        }
        return BlocProvider(
          create: (_) => sl<ReviewsCubit>()..load(artistId),
          child: _ProfileView(artist: snap.data!),
        );
      },
    );
  }
}

class _ProfileView extends StatelessWidget {
  final Artist artist;

  const _ProfileView({required this.artist});

  Future<void> _openChat(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final id = await sl<ChatRepository>().openWithArtist(artist.id);
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(conversationId: id, title: artist.name),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a conversa.')),
      );
    }
  }

  void _review(BuildContext context) {
    final reviews = context.read<ReviewsCubit>();
    final user = context.read<AuthCubit>().state.user;
    showReviewDialog(
      context,
      onSubmit: (rating, comment) {
        reviews.add(
          Review(
            id: '',
            artistId: artist.id,
            clientId: user?.id ?? '',
            clientName: user?.displayName ?? '',
            rating: rating,
            comment: comment,
            createdAt: DateTime.now(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação enviada! Obrigado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artist.name),
        actions: [
          if (context.read<AuthCubit>().state.user?.id != artist.id)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Conversar',
              onPressed: () => _openChat(context),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _review(context),
        icon: const Icon(Icons.star),
        label: const Text('Avaliar'),
      ),
      body: BlocBuilder<ReviewsCubit, ReviewsState>(
        builder: (context, state) {
          // Live rating: average of loaded reviews if any, else the stored one.
          final liveRating =
              state.reviews.isNotEmpty ? state.average : artist.rating;
          final ratingLabel = state.reviews.isEmpty && !artist.isRated
              ? 'Novo'
              : liveRating.toStringAsFixed(1);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    backgroundImage: avatarImage(artist.imageUrl),
                    child: avatarImage(artist.imageUrl) == null
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                artist.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (artist.isOwner) ...[
                              const SizedBox(width: 8),
                              const OwnerTag(),
                            ],
                          ],
                        ),
                        Text(
                          '${artist.specialty}'
                          '${artist.region.isNotEmpty ? ' · ${artist.region}' : ''}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StarRating(rating: liveRating),
                            const SizedBox(width: 6),
                            Text(
                              ratingLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '  (${state.reviews.length})',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (artist.portfolio.isNotEmpty) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => openUrl(artist.portfolio),
                  child: Row(
                    children: [
                      Icon(Icons.link,
                          size: 18, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          artist.portfolio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 32),
              const Text(
                'Tatuagens deste artista',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _ArtistTattoos(artistId: artist.id),
              const Divider(height: 32),
              const Text(
                'Avaliações',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (state.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhuma avaliação ainda. Seja o primeiro!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                ...state.reviews.map((r) => _ReviewTile(review: r)),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

/// Horizontal strip of the artist's tattoos (products), loaded once.
class _ArtistTattoos extends StatefulWidget {
  final String artistId;

  const _ArtistTattoos({required this.artistId});

  @override
  State<_ArtistTattoos> createState() => _ArtistTattoosState();
}

class _ArtistTattoosState extends State<_ArtistTattoos> {
  List<Product>? _items;

  @override
  void initState() {
    super.initState();
    try {
      sl<ProductRepository>().getProducts().then((res) {
        if (!mounted) return;
        setState(() {
          _items = res.fold(
            (_) => <Product>[],
            (all) => all.where((p) => p.artistId == widget.artistId).toList(),
          );
        });
      }).catchError((_) {
        if (mounted) setState(() => _items = <Product>[]);
      });
    } catch (_) {
      _items = <Product>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items == null) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhuma tatuagem publicada ainda.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = items[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(productId: p.id),
              ),
            ),
            child: SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      p.imageUrl,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      cacheWidth: 360,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'R\$ ${p.effectivePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final d = review.createdAt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.clientName.isEmpty ? 'Cliente' : review.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              StarRating(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.comment),
          ],
          const SizedBox(height: 4),
          Text(
            '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
