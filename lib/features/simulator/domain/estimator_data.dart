import 'package:flutter/material.dart';
import 'models/estimator_models.dart';

const List<ProjectType> kProjectTypes = [
  ProjectType(id: 'maison', label: 'Maison', icon: Icons.home_rounded, description: 'Construction complète pièce par pièce'),
  ProjectType(id: 'cloture', label: 'Clôture', icon: Icons.fence_rounded, description: 'Mur de clôture autour d\'un terrain'),
  ProjectType(id: 'dalle', label: 'Dalle / Plancher', icon: Icons.layers_rounded, description: 'Plancher avec hourdis'),
  ProjectType(id: 'autre', label: 'Autre projet', icon: Icons.architecture_rounded, description: 'Extension, rénovation, bâtiment...'),
];

const List<RoomPreset> kRoomPresets = [
  RoomPreset(id: 'salon', name: 'Salon', icon: Icons.weekend_rounded, defLength: 5, defWidth: 4, defHeight: 3, openings: 2, type: 'int'),
  RoomPreset(id: 'chambre', name: 'Chambre', icon: Icons.bed_rounded, defLength: 4, defWidth: 3.5, defHeight: 3, openings: 2, type: 'int'),
  RoomPreset(id: 'cuisine', name: 'Cuisine', icon: Icons.kitchen_rounded, defLength: 3.5, defWidth: 3, defHeight: 3, openings: 2, type: 'int'),
  RoomPreset(id: 'sdb', name: 'Salle de bain', icon: Icons.shower_rounded, defLength: 2.5, defWidth: 2, defHeight: 3, openings: 1, type: 'int'),
  RoomPreset(id: 'wc', name: 'Toilettes', icon: Icons.wc_rounded, defLength: 1.5, defWidth: 1.2, defHeight: 3, openings: 1, type: 'int'),
  RoomPreset(id: 'couloir', name: 'Couloir', icon: Icons.linear_scale_rounded, defLength: 4, defWidth: 1.2, defHeight: 3, openings: 2, type: 'int'),
  RoomPreset(id: 'garage', name: 'Garage', icon: Icons.garage_rounded, defLength: 6, defWidth: 3, defHeight: 3, openings: 1, type: 'ext'),
  RoomPreset(id: 'terrasse', name: 'Terrasse couverte', icon: Icons.deck_rounded, defLength: 4, defWidth: 3, defHeight: 3, openings: 0, type: 'ext'),
  RoomPreset(id: 'custom', name: 'Pièce personnalisée', icon: Icons.edit_rounded, defLength: 0, defWidth: 0, defHeight: 3, openings: 0, type: 'int'),
];

/// Calculs métier (extraits du JSX)
class EstimatorMath {
  /// Briques par m² selon dimensions et joint.
  static double bricksPerSquareMeter(BrickProduct brick) {
    final bL = (brick.dim.length + brick.joint) / 100;
    final bH = (brick.dim.height + brick.joint) / 100;
    return 1 / (bL * bH);
  }

  /// Calcul prix : tranches de 1000 au prix de gros + reste à l'unité.
  static double computePrice(int qty, BrickProduct brick) {
    final m = qty ~/ 1000;
    final r = qty % 1000;
    return m * brick.bulkPrice + r * brick.unitPrice;
  }

  /// Suggère une brique selon l'usage (tag) depuis le catalogue runtime.
  static BrickProduct suggestBrick(String usage, List<BrickProduct> catalogue) {
    if (catalogue.isEmpty) {
      return const BrickProduct(
        id: '_fallback',
        name: 'Brique standard',
        category: '',
        dim: BrickDimensions(length: 40, height: 20, thickness: 15),
        unitPrice: 75,
        bulkPrice: 70000,
        usage: '',
        joint: 1.5,
        auto: [],
      );
    }
    return catalogue.firstWhere(
      (b) => b.auto.contains(usage),
      orElse: () => catalogue.first,
    );
  }
}
