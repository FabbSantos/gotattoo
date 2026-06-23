import 'package:flutter/material.dart';
import '../../../../core/constants/tattoo_categories.dart';

/// Bottom sheet that lets the user pick a tattoo category.
class CategoryPickerSheet {
  static Future<void> show(
    BuildContext context, {
    required String selectedCategory,
    required List<String> categories,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Selecione uma categoria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;
                    final primary = Theme.of(context).primaryColor;

                    return ListTile(
                      leading: Icon(
                        TattooCategories.iconFor(category),
                        color: isSelected ? primary : Colors.grey,
                      ),
                      title: Text(category),
                      trailing:
                          isSelected
                              ? Icon(Icons.check, color: primary)
                              : null,
                      onTap: () {
                        onSelected(category);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
