// ─── Modèle produit catalogue BRIQUES.STORE ──────────────────────────────────
class BrickProduct {
  final String id;
  final String name;
  final String categoryId;
  final String subCategoryId;
  final String reference;
  final double pricePerUnit;
  final String unit;
  final bool inStock;
  final int stockQty;
  final String description;
  final Map<String, String> specs; // dimensions, poids, etc.

  const BrickProduct({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subCategoryId,
    required this.reference,
    required this.pricePerUnit,
    required this.unit,
    required this.inStock,
    required this.stockQty,
    required this.description,
    this.specs = const {},
  });
}

// ─── Mock data BRIQUES.STORE ──────────────────────────────────────────────────
class BrickProductMock {
  BrickProductMock._();

  static const List<BrickProduct> all = [
    // ── Briques Pleines 20 ──
    BrickProduct(
      id: 'bp20_std',
      name: 'Brique Pleine 20cm Standard',
      categoryId: 'briques_pleines',
      subCategoryId: 'bp_20',
      reference: 'BP-20-STD',
      pricePerUnit: 250,
      unit: 'unité',
      inStock: true,
      stockQty: 9000,
      description: 'Brique pleine 20cm de haute densité, idéale pour les murs porteurs et les fondations.',
      specs: {
        'Dimensions': '20 × 10 × 6 cm',
        'Poids': '2.8 kg',
        'Résistance': '≥ 15 MPa',
        'Usage': 'Murs porteurs, fondations',
      },
    ),
    BrickProduct(
      id: 'bp20_hr',
      name: 'Brique Pleine 20cm Haute Résistance',
      categoryId: 'briques_pleines',
      subCategoryId: 'bp_20',
      reference: 'BP-20-HR',
      pricePerUnit: 320,
      unit: 'unité',
      inStock: true,
      stockQty: 4500,
      description: 'Brique pleine 20cm renforcée pour charges lourdes et zones sismiques.',
      specs: {
        'Dimensions': '20 × 10 × 6 cm',
        'Poids': '3.1 kg',
        'Résistance': '≥ 25 MPa',
        'Usage': 'Structures porteuses, piliers',
      },
    ),

    // ── Briques Pleines 15 ──
    BrickProduct(
      id: 'bp15_std',
      name: 'Brique Pleine 15cm Standard',
      categoryId: 'briques_pleines',
      subCategoryId: 'bp_15',
      reference: 'BP-15-STD',
      pricePerUnit: 200,
      unit: 'unité',
      inStock: true,
      stockQty: 6200,
      description: 'Brique pleine 15cm polyvalente pour murs de façade et clôtures.',
      specs: {
        'Dimensions': '15 × 10 × 6 cm',
        'Poids': '2.1 kg',
        'Résistance': '≥ 15 MPa',
        'Usage': 'Façades, clôtures, murs',
      },
    ),

    // ── Briques Creuses 15 ──
    BrickProduct(
      id: 'bc15_std',
      name: 'Brique Creuse 15cm Standard',
      categoryId: 'briques_creuses',
      subCategoryId: 'bc_15',
      reference: 'BC-15-STD',
      pricePerUnit: 180,
      unit: 'unité',
      inStock: true,
      stockQty: 3200,
      description: 'Brique creuse 15cm pour cloisons épaisses avec bonnes propriétés d\'isolation.',
      specs: {
        'Dimensions': '15 × 10 × 20 cm',
        'Poids': '2.4 kg',
        'Alvéoles': '2',
        'Usage': 'Cloisons épaisses, murs extérieurs',
      },
    ),

    // ── Briques Creuses 12 ──
    BrickProduct(
      id: 'bc12_std',
      name: 'Brique Creuse 12cm Standard',
      categoryId: 'briques_creuses',
      subCategoryId: 'bc_12',
      reference: 'BC-12-STD',
      pricePerUnit: 160,
      unit: 'unité',
      inStock: true,
      stockQty: 5800,
      description: 'Brique creuse 12cm, le format le plus utilisé pour les cloisons intérieures.',
      specs: {
        'Dimensions': '12 × 10 × 20 cm',
        'Poids': '2.0 kg',
        'Alvéoles': '2',
        'Usage': 'Cloisons intérieures standard',
      },
    ),

    // ── Briques Creuses 10 ──
    BrickProduct(
      id: 'bc10_std',
      name: 'Brique Creuse 10cm Légère',
      categoryId: 'briques_creuses',
      subCategoryId: 'bc_10',
      reference: 'BC-10-STD',
      pricePerUnit: 140,
      unit: 'unité',
      inStock: false,
      stockQty: 0,
      description: 'Brique creuse 10cm ultra-légère pour cloisons de séparation non portantes.',
      specs: {
        'Dimensions': '10 × 10 × 20 cm',
        'Poids': '1.6 kg',
        'Alvéoles': '2',
        'Usage': 'Cloisons légères, séparations',
      },
    ),

    // ── Hourdis Français ──
    BrickProduct(
      id: 'hf_16',
      name: 'Hourdis Français 16cm',
      categoryId: 'hourdis',
      subCategoryId: 'hourdis_fr',
      reference: 'HF-16',
      pricePerUnit: 400,
      unit: 'unité',
      inStock: true,
      stockQty: 2100,
      description: 'Hourdis type français 16cm pour planchers traditionnels, compatible poutrelles standard.',
      specs: {
        'Dimensions': '16 × 20 × 50 cm',
        'Poids': '7.5 kg',
        'Portée max': '5 m',
        'Usage': 'Planchers, dalles',
      },
    ),
    BrickProduct(
      id: 'hf_20',
      name: 'Hourdis Français 20cm',
      categoryId: 'hourdis',
      subCategoryId: 'hourdis_fr',
      reference: 'HF-20',
      pricePerUnit: 480,
      unit: 'unité',
      inStock: true,
      stockQty: 1400,
      description: 'Hourdis type français 20cm pour grandes portées et charges importantes.',
      specs: {
        'Dimensions': '20 × 20 × 50 cm',
        'Poids': '9.2 kg',
        'Portée max': '7 m',
        'Usage': 'Planchers grandes portées',
      },
    ),

    // ── Hourdis Américain ──
    BrickProduct(
      id: 'ha_std',
      name: 'Hourdis Américain Standard',
      categoryId: 'hourdis',
      subCategoryId: 'hourdis_us',
      reference: 'HA-STD',
      pricePerUnit: 450,
      unit: 'unité',
      inStock: true,
      stockQty: 880,
      description: 'Hourdis type américain grand format, idéal pour les planchers modernes.',
      specs: {
        'Dimensions': '20 × 25 × 60 cm',
        'Poids': '11.0 kg',
        'Portée max': '8 m',
        'Usage': 'Planchers modernes, grandes surfaces',
      },
    ),
  ];

  /// Produits filtrés par catégorie
  static List<BrickProduct> byCategory(String categoryId) =>
      all.where((p) => p.categoryId == categoryId).toList();

  /// Produits filtrés par sous-catégorie
  static List<BrickProduct> bySubCategory(String subId) =>
      all.where((p) => p.subCategoryId == subId).toList();

  /// Recherche par nom ou référence
  static List<BrickProduct> search(String query) {
    final q = query.toLowerCase();
    return all.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.reference.toLowerCase().contains(q) ||
      p.description.toLowerCase().contains(q),
    ).toList();
  }
}
