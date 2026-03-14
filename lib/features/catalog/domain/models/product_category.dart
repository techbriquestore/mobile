import 'package:flutter/material.dart';

// ─── Sous-catégorie ───────────────────────────────────────────────────────────
class ProductSubCategory {
  final String id;
  final String label;
  final String description;

  const ProductSubCategory({
    required this.id,
    required this.label,
    required this.description,
  });
}

// ─── Catégorie principale ─────────────────────────────────────────────────────
class ProductCategory {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<ProductSubCategory> subCategories;

  const ProductCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.subCategories,
  });
}

// ─── Données des catégories BRIQUES.STORE ─────────────────────────────────────
class BriqueCategories {
  BriqueCategories._();

  static const ProductCategory briquePleine = ProductCategory(
    id: 'briques_pleines',
    label: 'Briques Pleines',
    description: 'Résistantes et compactes, idéales pour les murs porteurs',
    icon: Icons.view_in_ar_rounded,
    color: Color(0xFFE65100),
    bgColor: Color(0xFFFFF3E0),
    subCategories: [
      ProductSubCategory(
        id: 'bp_20',
        label: '20 Pleine',
        description: 'Brique pleine 20cm — Format standard',
      ),
      ProductSubCategory(
        id: 'bp_15',
        label: '15 Pleine',
        description: 'Brique pleine 15cm — Format intermédiaire',
      ),
    ],
  );

  static const ProductCategory briqueCreuse = ProductCategory(
    id: 'briques_creuses',
    label: 'Briques Creuses',
    description: 'Légères et isolantes, parfaites pour les cloisons',
    icon: Icons.widgets_rounded,
    color: Color(0xFF1565C0),
    bgColor: Color(0xFFE3F2FD),
    subCategories: [
      ProductSubCategory(
        id: 'bc_15',
        label: '15 Creux',
        description: 'Brique creuse 15cm — Cloisons épaisses',
      ),
      ProductSubCategory(
        id: 'bc_12',
        label: '12 Creux',
        description: 'Brique creuse 12cm — Cloisons standard',
      ),
      ProductSubCategory(
        id: 'bc_10',
        label: '10 Creux',
        description: 'Brique creuse 10cm — Cloisons légères',
      ),
    ],
  );

  static const ProductCategory hourdis = ProductCategory(
    id: 'hourdis',
    label: 'Hourdis',
    description: 'Éléments de plancher en béton pour dalles et planchers',
    icon: Icons.layers_rounded,
    color: Color(0xFF2E7D32),
    bgColor: Color(0xFFE8F5E9),
    subCategories: [
      ProductSubCategory(
        id: 'hourdis_fr',
        label: 'Français',
        description: 'Hourdis type français — Standard local',
      ),
      ProductSubCategory(
        id: 'hourdis_us',
        label: 'Américain',
        description: 'Hourdis type américain — Grand format',
      ),
    ],
  );

  // Liste complète des catégories
  static const List<ProductCategory> all = [
    briquePleine,
    briqueCreuse,
    hourdis,
  ];

  // Retrouver une catégorie par ID
  static ProductCategory? findById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Retrouver une sous-catégorie par ID
  static ProductSubCategory? findSubById(String subId) {
    for (final cat in all) {
      try {
        return cat.subCategories.firstWhere((s) => s.id == subId);
      } catch (_) {}
    }
    return null;
  }
}
