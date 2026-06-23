import 'package:flutter/material.dart';

/// Single source of truth for tattoo categories and their icons, shared by the
/// home filters, pickers and the product bloc.
abstract class TattooCategories {
  static const String all = 'Todas';

  static const List<String> values = [
    all,
    'Old School',
    'New School',
    'Tribal',
    'Realista',
    'Geométrica',
    'Blackwork',
    'Aquarela',
    'Minimalista',
  ];

  static IconData iconFor(String category) {
    switch (category) {
      case all:
        return Icons.apps;
      case 'Old School':
        return Icons.anchor;
      case 'New School':
        return Icons.palette;
      case 'Tribal':
        return Icons.architecture;
      case 'Realista':
        return Icons.face;
      case 'Geométrica':
        return Icons.shape_line;
      case 'Blackwork':
        return Icons.texture;
      case 'Aquarela':
        return Icons.water_drop;
      case 'Minimalista':
        return Icons.minimize;
      case 'Lettering':
        return Icons.text_fields;
      case 'Fineline':
        return Icons.gesture;
      case 'Floral':
        return Icons.local_florist;
      case 'Flash':
        return Icons.bolt;
      case 'Pontilhismo':
        return Icons.blur_on;
      case 'Oriental':
        return Icons.brush;
      case 'Pet':
        return Icons.pets;
      case 'Outros':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }
}
