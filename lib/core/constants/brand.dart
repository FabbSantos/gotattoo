import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GoTattoo brand identity.
abstract class Brand {
  static const String name = 'GoTattoo';
  static const String tagline = 'Encontre o seu tatuador ideal';

  /// Transparent square logo (the red "G" tattoo-machine mark).
  static const String logoAsset = 'assets/brand/logo.png';

  /// Vermelho GoTattoo.
  static const Color red = Color(0xFFE31C2C);

  /// Preto GoTattoo (splash / dark surfaces).
  static const Color black = Color(0xFF1C1C1C);

  /// Poppins — a clean, modern geometric sans used for the wordmark and big
  /// headings. Body text stays on the default sans for readability.
  static TextStyle wordmark(TextStyle base) =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w700);

  /// Applies Poppins across the whole [TextTheme] for a cohesive, modern feel.
  static TextTheme display(TextTheme base) =>
      GoogleFonts.poppinsTextTheme(base);
}
