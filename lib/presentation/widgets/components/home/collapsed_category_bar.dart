import 'package:flutter/material.dart';
import '../../../../core/constants/tattoo_categories.dart';

/// Compact category indicator shown when the category header is collapsed.
class CollapsedCategoryBar extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback onFilterTap;

  const CollapsedCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Categoria:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  TattooCategories.iconFor(selectedCategory),
                  color: primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  selectedCategory,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_drop_down, color: primary, size: 16),
              ],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onFilterTap,
            icon: const Icon(Icons.filter_list, size: 16),
            label: const Text('Filtrar'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
