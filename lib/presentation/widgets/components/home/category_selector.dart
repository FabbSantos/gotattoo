import 'package:flutter/material.dart';
import '../../../../core/constants/tattoo_categories.dart';

/// Horizontal, expanded list of category chips shown in the pinned header.
class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // No section title (it's self-explanatory) — keeps the header compact.
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category == selectedCategory;
        final primary = Theme.of(context).primaryColor;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(category),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primary : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.18),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    TattooCategories.iconFor(category),
                    color: isSelected ? primary : Colors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
