import 'package:flutter/material.dart';

/// Extension pour convertir une chaîne hexadécimale en Color.
///
/// Supporte les formats :
/// - `#FF5733` (avec #)
/// - `FF5733` (sans #)
/// - `#F53` (format court avec #)
/// - `F53` (format court sans #)
///
/// Exemple d'utilisation :
/// ```dart
/// final color = '#FF5733'.toColor();
/// final colorWithFallback = hexString?.toColor(fallback: Colors.grey);
/// ```
extension ColorExtension on String {
  /// Convertit une chaîne hexadécimale en [Color].
  ///
  /// [fallback] est retourné si la conversion échoue.
  Color toColor({Color fallback = Colors.grey}) {
    try {
      String hex = replaceAll('#', '').trim();

      // Support format court (ex: F53 → FF5533)
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }

      // Ajouter l'alpha si absent
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// Vérifie si la chaîne est un code couleur hexadécimal valide.
  bool get isValidHexColor {
    final hex = replaceAll('#', '').trim();
    if (hex.length != 3 && hex.length != 6) return false;
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hex);
  }
}

/// Extension nullable pour les chaînes optionnelles.
extension NullableColorExtension on String? {
  /// Convertit une chaîne hexadécimale nullable en [Color].
  ///
  /// Retourne [fallback] si la chaîne est null ou invalide.
  Color toColor({Color fallback = Colors.grey}) {
    if (this == null) return fallback;
    return this!.toColor(fallback: fallback);
  }
}

/// Utilitaires pour manipuler les couleurs.
class ColorUtils {
  ColorUtils._();

  /// Crée une couleur à partir d'une chaîne hexadécimale.
  ///
  /// Préférer l'extension [ColorExtension.toColor] pour plus de lisibilité.
  static Color fromHex(String? hex, {Color fallback = Colors.grey}) {
    return hex.toColor(fallback: fallback);
  }

  /// Retourne une couleur de texte contrastée (noir ou blanc)
  /// en fonction de la luminosité de [backgroundColor].
  static Color contrastingTextColor(Color backgroundColor) {
    // Calcul de la luminance relative (formule W3C)
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Éclaircit une couleur d'un certain pourcentage (0.0 à 1.0).
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'amount doit être entre 0 et 1');
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Assombrit une couleur d'un certain pourcentage (0.0 à 1.0).
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'amount doit être entre 0 et 1');
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Convertit une [Color] en chaîne hexadécimale (sans #).
  static String toHex(Color color, {bool includeAlpha = false}) {
    if (includeAlpha) {
      return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    }
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }
}
