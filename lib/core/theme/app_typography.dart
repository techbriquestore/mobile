import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle headlineLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle headlineMedium = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle headlineSmall = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF666666));
  static const TextStyle priceLarge = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFFFF8C00));
  static const TextStyle priceMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFFF8C00));

  static TextTheme get textTheme => const TextTheme(
    headlineLarge: headlineLarge, headlineMedium: headlineMedium,
    headlineSmall: headlineSmall, bodyLarge: bodyLarge,
    bodyMedium: bodyMedium, bodySmall: bodySmall, labelLarge: button,
  );
}
