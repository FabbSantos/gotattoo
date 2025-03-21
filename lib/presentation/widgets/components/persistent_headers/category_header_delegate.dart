import 'dart:math';
import 'package:flutter/material.dart';

class CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget expandedWidget;
  final Widget collapsedWidget;
  final double expandedHeight;
  final double collapsedHeight;

  CategoryHeaderDelegate({
    required this.expandedWidget,
    required this.collapsedWidget,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calcular a porcentagem de progresso da animação usando uma curva suave
    final maxScrollExtent = expandedHeight - collapsedHeight;
    final visibleMainHeight = expandedHeight - shrinkOffset;

    // Use Curves para suavizar a transição
    final progress = Curves.easeOutCubic.transform(
      min(1.0, shrinkOffset / maxScrollExtent),
    );

    // Cores que mudam gradualmente com base no progresso
    final backgroundColor = Color.lerp(
      Theme.of(context).scaffoldBackgroundColor,
      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
      progress,
    );

    // Sombra que intensifica conforme o scroll
    final elevation = lerpDouble(0.0, 4.0, progress) ?? 0.0;

    return Container(
      height: max(collapsedHeight, visibleMainHeight),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05 + 0.05 * progress),
            blurRadius: elevation * 2,
            spreadRadius: elevation / 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Widget expandido com animação de saída
          Positioned.fill(
            child: Opacity(
              opacity: 1.0 - progress,
              child: Transform.translate(
                offset: Offset(
                  0,
                  -20 * progress,
                ), // Desliza suavemente para cima
                child: Transform.scale(
                  scale:
                      lerpDouble(1.0, 0.9, progress) ??
                      1.0, // Encolhe suavemente
                  child: expandedWidget,
                ),
              ),
            ),
          ),

          // Widget colapsado com animação de entrada
          Positioned.fill(
            child: Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(
                  0,
                  10 * (1.0 - progress),
                ), // Desliza suavemente para baixo
                child: Transform.scale(
                  scale:
                      lerpDouble(1.1, 1.0, progress) ??
                      1.0, // Cresce suavemente
                  child: collapsedWidget,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função auxiliar para interpolar valores double
  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
