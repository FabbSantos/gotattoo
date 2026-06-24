import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/avatar_image.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/repositories/artist_repository.dart';

class ProductContent extends StatelessWidget {
  final Product product;
  final int quantity;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onBook;
  final VoidCallback onViewArtist;

  const ProductContent({
    super.key,
    required this.product,
    required this.quantity,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.onDecrement,
    required this.onIncrement,
    required this.onBook,
    required this.onViewArtist,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bookmark,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Disponível',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Preço - Agora entre o título/tags e a descrição
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sell,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'R\$ ${product.effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 10),
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Descrição',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),
              _ArtistByline(artistId: product.artistId, onTap: onViewArtist),

              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Disponível:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.stock} unidades',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  const Text(
                    'Quantidade:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                quantity > 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(11),
                              bottomLeft: Radius.circular(11),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: quantity > 1 ? Colors.white : Colors.grey,
                              size: 18,
                            ),
                            onPressed: quantity > 1 ? onDecrement : null,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                quantity < product.stock
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(11),
                              bottomRight: Radius.circular(11),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              color:
                                  quantity < product.stock
                                      ? Colors.white
                                      : Colors.grey,
                              size: 18,
                            ),
                            onPressed:
                                quantity < product.stock ? onIncrement : null,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onBook();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 8,
                    shadowColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'AGENDAR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Feito por [tatuador]" row that loads the artist once and opens the profile
/// on tap.
class _ArtistByline extends StatefulWidget {
  final String artistId;
  final VoidCallback onTap;

  const _ArtistByline({required this.artistId, required this.onTap});

  @override
  State<_ArtistByline> createState() => _ArtistBylineState();
}

class _ArtistBylineState extends State<_ArtistByline> {
  Artist? _artist;

  @override
  void initState() {
    super.initState();
    try {
      sl<ArtistRepository>().getArtist(widget.artistId).then((res) {
        if (!mounted) return;
        setState(() => _artist = res.fold((_) => null, (a) => a));
      }).catchError((_) {});
    } catch (_) {
      // DI not available (e.g. widget tests) — show the generic fallback.
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final name = _artist?.name ?? 'Tatuador';
    final image = avatarImage(_artist?.imageUrl);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: primary.withValues(alpha: 0.1),
              backgroundImage: image,
              child: image == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feito por',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Ver perfil',
              style: TextStyle(
                  fontSize: 13,
                  color: primary,
                  fontWeight: FontWeight.w600),
            ),
            Icon(Icons.chevron_right, color: primary),
          ],
        ),
      ),
    );
  }
}
