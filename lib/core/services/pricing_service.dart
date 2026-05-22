import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service de calcul des prix et paiements échelonnés.
///
/// Centralise toute la logique métier liée aux prix pour garantir
/// la cohérence entre les différents écrans et avec le backend.
///
/// **Constantes métier** :
/// - Frais de livraison : GRATUIT (inclus dans le prix des briques)
/// - Acompte : 15% du total
/// - Frais de gestion : 2% si durée > 6 mois
/// - Paiements : 2 par mois
class PricingService {
  PricingService._();

  // ═══════════════════════════════════════════════════════════════
  // CONSTANTES MÉTIER
  // ═══════════════════════════════════════════════════════════════

  /// Frais de livraison standard en FCFA.
  /// NOTE: Livraison GRATUITE - les frais sont inclus dans le prix des briques.
  static const double deliveryFeeStandard = 0;

  /// Taux de l'acompte initial (15%).
  static const double depositRate = 0.15;

  /// Taux des frais de gestion pour les paiements longs (2%).
  static const double managementFeeRate = 0.02;

  /// Seuil en mois au-delà duquel les frais de gestion s'appliquent.
  static const int managementFeeThresholdMonths = 6;

  /// Nombre de paiements par mois.
  static const int paymentsPerMonth = 2;

  /// Durée minimale en mois pour le paiement échelonné.
  static const int minInstallmentMonths = 3;

  /// Durée maximale en mois pour le paiement échelonné.
  static const int maxInstallmentMonths = 12;

  /// Durées disponibles pour le paiement échelonné.
  static const List<int> availableMonths = [3, 4, 5, 6, 8, 10, 12];

  // ═══════════════════════════════════════════════════════════════
  // CALCULS DE BASE
  // ═══════════════════════════════════════════════════════════════

  /// Calcule le total avec frais de livraison.
  ///
  /// [subtotal] : Sous-total des articles (sans livraison).
  /// [deliveryFee] : Frais de livraison (par défaut : standard).
  static double calculateTotal(
    double subtotal, {
    double deliveryFee = deliveryFeeStandard,
  }) {
    return subtotal + deliveryFee;
  }

  /// Calcule le montant de l'acompte (15% du total).
  ///
  /// L'acompte est arrondi à l'entier supérieur.
  static double calculateDeposit(double total) {
    return (total * depositRate).roundToDouble();
  }

  /// Calcule le nombre total de paiements.
  ///
  /// [months] : Durée en mois.
  static int calculateTotalPayments(int months) {
    return months * paymentsPerMonth;
  }

  /// Calcule le montant de chaque échéance.
  ///
  /// [total] : Montant total de la commande.
  /// [deposit] : Montant de l'acompte déjà payé.
  /// [totalPayments] : Nombre total d'échéances.
  ///
  /// Note : Le montant est arrondi à l'entier inférieur pour éviter
  /// de dépasser le total. La dernière échéance peut être légèrement
  /// différente pour compenser l'arrondi.
  static double calculateInstallmentAmount(
    double total,
    double deposit,
    int totalPayments,
  ) {
    if (totalPayments <= 0) return 0;
    final remaining = total - deposit;
    return (remaining / totalPayments).floorToDouble();
  }

  /// Calcule les frais de gestion (2% si > 6 mois).
  ///
  /// [total] : Montant total de la commande.
  /// [months] : Durée en mois.
  static double calculateManagementFee(double total, int months) {
    if (months <= managementFeeThresholdMonths) return 0;
    return (total * managementFeeRate).roundToDouble();
  }

  /// Vérifie si des frais de gestion s'appliquent.
  static bool hasManagementFee(int months) {
    return months > managementFeeThresholdMonths;
  }

  /// Calcule le grand total (total + frais de gestion).
  static double calculateGrandTotal(double total, int months) {
    return total + calculateManagementFee(total, months);
  }

  // ═══════════════════════════════════════════════════════════════
  // CALCUL COMPLET D'UN PLAN DE PAIEMENT
  // ═══════════════════════════════════════════════════════════════

  /// Calcule un plan de paiement complet.
  ///
  /// Retourne un [PaymentPlan] avec tous les détails du paiement échelonné.
  static PaymentPlan calculatePaymentPlan({
    required double subtotal,
    required int months,
    double deliveryFee = deliveryFeeStandard,
  }) {
    final total = calculateTotal(subtotal, deliveryFee: deliveryFee);
    final deposit = calculateDeposit(total);
    final totalPayments = calculateTotalPayments(months);
    final installmentAmount = calculateInstallmentAmount(total, deposit, totalPayments);
    final managementFee = calculateManagementFee(total, months);
    final grandTotal = total + managementFee;

    // Calcul du montant de la dernière échéance (ajustement pour l'arrondi)
    final regularInstallmentsTotal = installmentAmount * (totalPayments - 1);
    final lastInstallment = grandTotal - deposit - regularInstallmentsTotal;

    return PaymentPlan(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      deposit: deposit,
      months: months,
      totalPayments: totalPayments,
      installmentAmount: installmentAmount,
      lastInstallmentAmount: lastInstallment,
      managementFee: managementFee,
      grandTotal: grandTotal,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════

  /// Vérifie si une durée est valide pour le paiement échelonné.
  static bool isValidDuration(int months) {
    return availableMonths.contains(months);
  }

  /// Retourne la durée par défaut (3 mois).
  static int get defaultDuration => minInstallmentMonths;
}

/// Représente un plan de paiement complet.
///
/// Contient tous les détails calculés pour un paiement échelonné.
class PaymentPlan {
  /// Sous-total des articles (sans livraison).
  final double subtotal;

  /// Frais de livraison.
  final double deliveryFee;

  /// Total (sous-total + livraison).
  final double total;

  /// Montant de l'acompte (15% du total).
  final double deposit;

  /// Durée en mois.
  final int months;

  /// Nombre total de paiements (mois × 2).
  final int totalPayments;

  /// Montant de chaque échéance régulière.
  final double installmentAmount;

  /// Montant de la dernière échéance (peut différer pour l'arrondi).
  final double lastInstallmentAmount;

  /// Frais de gestion (2% si > 6 mois).
  final double managementFee;

  /// Grand total (total + frais de gestion).
  final double grandTotal;

  const PaymentPlan({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deposit,
    required this.months,
    required this.totalPayments,
    required this.installmentAmount,
    required this.lastInstallmentAmount,
    required this.managementFee,
    required this.grandTotal,
  });

  /// Montant restant après l'acompte.
  double get remainingAfterDeposit => grandTotal - deposit;

  /// Vérifie si des frais de gestion s'appliquent.
  bool get hasManagementFee => managementFee > 0;

  /// Nombre d'échéances régulières (hors dernière).
  int get regularPaymentsCount => totalPayments - 1;

  @override
  String toString() {
    return 'PaymentPlan('
        'subtotal: $subtotal, '
        'total: $total, '
        'deposit: $deposit, '
        'months: $months, '
        'installment: $installmentAmount, '
        'grandTotal: $grandTotal)';
  }
}

/// Provider Riverpod pour le service de pricing.
///
/// Permet d'accéder aux constantes et méthodes de calcul via Riverpod.
final pricingServiceProvider = Provider<PricingService>((ref) {
  // Retourne une instance singleton (toutes les méthodes sont statiques)
  throw UnimplementedError(
    'PricingService utilise des méthodes statiques. '
    'Utilisez PricingService.calculatePaymentPlan() directement.',
  );
});

/// Provider pour calculer un plan de paiement.
///
/// Exemple d'utilisation :
/// ```dart
/// final plan = ref.watch(paymentPlanProvider((subtotal: 100000, months: 6)));
/// ```
final paymentPlanProvider = Provider.family<PaymentPlan, ({double subtotal, int months})>(
  (ref, params) {
    return PricingService.calculatePaymentPlan(
      subtotal: params.subtotal,
      months: params.months,
    );
  },
);
