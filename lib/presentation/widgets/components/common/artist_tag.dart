import 'package:flutter/material.dart';

/// Small "Tatuador" badge to identify verified artists in the social feed.
class ArtistTag extends StatelessWidget {
  const ArtistTag({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.brush, size: 10, color: primary),
          const SizedBox(width: 3),
          Text(
            'Tatuador',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}
