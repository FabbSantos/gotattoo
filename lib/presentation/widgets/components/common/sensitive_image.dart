import 'dart:ui';

import 'package:flutter/material.dart';

/// Shows [url], blurred behind a "toque para ver" veil when [sensitive] is true
/// (tap reveals it). Non-sensitive images render normally.
class SensitiveImage extends StatefulWidget {
  final String url;
  final bool sensitive;
  final double height;

  const SensitiveImage({
    super.key,
    required this.url,
    this.sensitive = false,
    this.height = 200,
  });

  @override
  State<SensitiveImage> createState() => _SensitiveImageState();
}

class _SensitiveImageState extends State<SensitiveImage> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        widget.url,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );

    if (!widget.sensitive || _revealed) return image;

    return GestureDetector(
      onTap: () => setState(() => _revealed = true),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ImageFiltered blurs the image directly — reliable inside lists,
            // unlike BackdropFilter.
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: image,
            ),
            Container(
              height: widget.height,
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.30),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off, color: Colors.white, size: 30),
                  SizedBox(height: 8),
                  Text(
                    'Conteúdo sensível',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Toque para ver',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
