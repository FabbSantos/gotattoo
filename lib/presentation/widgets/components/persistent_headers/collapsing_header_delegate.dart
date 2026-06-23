import 'dart:math';
import 'package:flutter/material.dart';

/// A pinned sliver header that cross-fades between an [expandedWidget] (shown at
/// the top) and a compact [collapsedWidget] (shown while scrolled).
///
/// Only the widget that is mostly visible receives touches (via [IgnorePointer]),
/// which fixes the previous behaviour where both layers captured taps mid-scroll.
class CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget expandedWidget;
  final Widget collapsedWidget;
  final double expandedHeight;
  final double collapsedHeight;

  CollapsingHeaderDelegate({
    required this.expandedWidget,
    required this.collapsedWidget,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final range = (expandedHeight - collapsedHeight).clamp(1.0, double.infinity);
    final progress = (shrinkOffset / range).clamp(0.0, 1.0);

    // Sharp hand-off so the two layers never overlap as live, half-faded UIs.
    final expandedOpacity = (1 - progress / 0.5).clamp(0.0, 1.0);
    final collapsedOpacity = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
    final showingCollapsed = progress >= 0.5;
    final elevation = 4.0 * progress;

    return Container(
      height: max(collapsedHeight, expandedHeight - shrinkOffset),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06 * progress),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: showingCollapsed,
            child: Opacity(opacity: expandedOpacity, child: expandedWidget),
          ),
          IgnorePointer(
            ignoring: !showingCollapsed,
            child: Opacity(opacity: collapsedOpacity, child: collapsedWidget),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant CollapsingHeaderDelegate oldDelegate) {
    // Rebuild whenever a new delegate is supplied — the expanded/collapsed
    // widgets change when the selected category/artist changes.
    return true;
  }
}
