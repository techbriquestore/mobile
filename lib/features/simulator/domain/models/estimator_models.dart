import 'package:flutter/material.dart';

/// Dimensions d'une brique en cm.
class BrickDimensions {
  final double length; // l (cm)
  final double height; // h (cm)
  final double thickness; // e (cm)
  const BrickDimensions({required this.length, required this.height, required this.thickness});
}

/// Produit du catalogue (brique / parpaing / hourdis).
class BrickProduct {
  final String id;
  final String name;
  final String category;
  final BrickDimensions dim;
  final double unitPrice; // FCFA / unité
  final double bulkPrice; // FCFA / millier
  final String usage;
  final double joint; // épaisseur joint cm
  final List<String> auto; // tags d'usage automatique

  const BrickProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.dim,
    required this.unitPrice,
    required this.bulkPrice,
    required this.usage,
    required this.joint,
    required this.auto,
  });
}

/// Type de projet sélectionnable à l'étape 1.
class ProjectType {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  const ProjectType({required this.id, required this.label, required this.icon, required this.description});
}

/// Pièce prédéfinie (salon, chambre, etc.).
class RoomPreset {
  final String id;
  final String name;
  final IconData icon;
  final double defLength;
  final double defWidth;
  final double defHeight;
  final int openings;
  final String type; // 'int' ou 'ext'
  const RoomPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.defLength,
    required this.defWidth,
    required this.defHeight,
    required this.openings,
    required this.type,
  });
}

/// Pièce ajoutée par l'utilisateur dans le simulateur.
class RoomItem {
  final String uid;
  final String presetId;
  String name;
  final IconData icon;
  double length;
  double width;
  double height;
  int openings;
  final String type;
  int qty;

  RoomItem({
    required this.uid,
    required this.presetId,
    required this.name,
    required this.icon,
    required this.length,
    required this.width,
    required this.height,
    required this.openings,
    required this.type,
    this.qty = 1,
  });
}

/// Une ligne du devis estimatif final.
class EstimateLine {
  final String key;
  final String label;
  final BrickProduct brick;
  final int qty;
  final double surface;
  const EstimateLine({
    required this.key,
    required this.label,
    required this.brick,
    required this.qty,
    required this.surface,
  });
}
