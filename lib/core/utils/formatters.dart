import 'package:intl/intl.dart';

/// Utilitaires de formatage pour l'application BRIQUES.STORE.
///
/// Centralise tous les formatages pour garantir la cohérence
/// dans toute l'application.
class Formatters {
  Formatters._();

  // ─────────────────────────────────────────────────────────────
  // PRIX ET MONTANTS
  // ─────────────────────────────────────────────────────────────

  static final _priceFormatter = NumberFormat('#,###', 'fr_FR');

  /// Formate un montant en FCFA avec séparateur de milliers.
  ///
  /// Exemple : `priceFCFA(15000)` → `"15 000 FCFA"`
  static String priceFCFA(num amount) {
    return '${_priceFormatter.format(amount)} FCFA';
  }

  /// Formate un montant sans devise (juste le nombre formaté).
  ///
  /// Exemple : `priceCompact(15000)` → `"15 000"`
  static String priceCompact(num amount) {
    return _priceFormatter.format(amount);
  }

  /// Formate un montant avec devise personnalisée.
  ///
  /// Exemple : `price(15000, currency: '€')` → `"15 000 €"`
  static String price(num amount, {String currency = 'FCFA'}) {
    return '${_priceFormatter.format(amount)} $currency';
  }

  // ─────────────────────────────────────────────────────────────
  // TÉLÉPHONE
  // ─────────────────────────────────────────────────────────────

  /// Formate un numéro de téléphone camerounais (10 chiffres).
  ///
  /// Exemple : `phoneNumber('690123456')` → `"69 01 23 45 6"` (9 chiffres)
  /// Exemple : `phoneNumber('6901234567')` → `"69 01 23 45 67"` (10 chiffres)
  static String phoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 9) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8)}';
    }
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    return phone; // Retourner tel quel si format inconnu
  }

  // ─────────────────────────────────────────────────────────────
  // DATES
  // ─────────────────────────────────────────────────────────────

  /// Date complète en français.
  ///
  /// Exemple : `date(DateTime.now())` → `"20 mai 2026"`
  static String date(DateTime dt) => DateFormat('d MMMM yyyy', 'fr_FR').format(dt);

  /// Date courte.
  ///
  /// Exemple : `dateShort(DateTime.now())` → `"20/05/2026"`
  static String dateShort(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);

  /// Date et heure complètes.
  ///
  /// Exemple : `dateTime(DateTime.now())` → `"20 mai 2026 à 14h30"`
  static String dateTime(DateTime dt) => DateFormat("d MMMM yyyy 'à' HH'h'mm", 'fr_FR').format(dt);

  /// Date relative (aujourd'hui, hier, etc.).
  ///
  /// Exemple : `dateRelative(DateTime.now())` → `"Aujourd'hui"`
  static String dateRelative(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    if (diff == -1) return 'Demain';
    if (diff > 1 && diff <= 7) return 'Il y a $diff jours';
    if (diff < -1 && diff >= -7) return 'Dans ${-diff} jours';
    return date(dt);
  }

  // ─────────────────────────────────────────────────────────────
  // NOMBRES ET POURCENTAGES
  // ─────────────────────────────────────────────────────────────

  /// Formate un pourcentage.
  ///
  /// Exemple : `percentage(0.15)` → `"15%"`
  static String percentage(double value) => '${(value * 100).toStringAsFixed(0)}%';

  /// Formate une quantité avec séparateur de milliers.
  ///
  /// Exemple : `quantity(1500)` → `"1 500"`
  static String quantity(int qty) => _priceFormatter.format(qty);

  /// Formate un nombre décimal.
  ///
  /// Exemple : `decimal(3.5, decimals: 1)` → `"3,5"`
  static String decimal(double value, {int decimals = 2}) {
    return NumberFormat.decimalPattern('fr_FR').format(
      double.parse(value.toStringAsFixed(decimals)),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TEXTE
  // ─────────────────────────────────────────────────────────────

  /// Tronque un texte avec ellipsis.
  ///
  /// Exemple : `truncate('Hello World', 5)` → `"Hello..."`
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalise la première lettre.
  ///
  /// Exemple : `capitalize('hello')` → `"Hello"`
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Formate un nom complet (prénom + nom).
  ///
  /// Exemple : `fullName('jean', 'DUPONT')` → `"Jean Dupont"`
  static String fullName(String firstName, String lastName) {
    return '${capitalize(firstName)} ${capitalize(lastName)}';
  }
}

/// Extension pour faciliter le formatage des nombres.
extension NumFormatExtension on num {
  /// Formate en prix FCFA.
  String get asFCFA => Formatters.priceFCFA(this);

  /// Formate en prix compact (sans devise).
  String get asCompactPrice => Formatters.priceCompact(this);
}

/// Extension pour faciliter le formatage des dates.
extension DateTimeFormatExtension on DateTime {
  /// Formate en date complète française.
  String get formatted => Formatters.date(this);

  /// Formate en date courte.
  String get formattedShort => Formatters.dateShort(this);

  /// Formate en date et heure.
  String get formattedDateTime => Formatters.dateTime(this);

  /// Formate en date relative.
  String get formattedRelative => Formatters.dateRelative(this);
}
