import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum OrderStatus {
  pending('En attente', AppColors.statusPending, Icons.schedule),
  validated('Validée', AppColors.statusValidated, Icons.check_circle_outline),
  fabrication('En fabrication', AppColors.statusFabrication, Icons.precision_manufacturing),
  shipped('En expédition', AppColors.statusShipped, Icons.local_shipping_outlined),
  delivered('Livrée', AppColors.statusDelivered, Icons.task_alt),
  cancelled('Annulée', AppColors.statusCancelled, Icons.cancel_outlined);

  final String label;
  final Color color;
  final IconData icon;
  const OrderStatus(this.label, this.color, this.icon);
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class OrderModel {
  final String id;
  final String reference;
  final DateTime date;
  final OrderStatus status;
  final List<OrderItem> items;
  final double deliveryFee;
  final String deliveryAddress;

  const OrderModel({
    required this.id,
    required this.reference,
    required this.date,
    required this.status,
    required this.items,
    required this.deliveryFee,
    required this.deliveryAddress,
  });

  double get subTotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subTotal + deliveryFee;
}

class OrderMockData {
  static final List<OrderModel> orders = [
    OrderModel(
      id: '1',
      reference: 'CMD-2026-0042',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: OrderStatus.pending,
      deliveryFee: 15000,
      deliveryAddress: 'Chantier Cocody Riviera Palmeraie, Abidjan',
      items: const [
        OrderItem(productId: 'bp20_std', productName: 'Brique Pleine 20cm Standard', quantity: 2000, unitPrice: 250),
        OrderItem(productId: 'ciment', productName: 'Ciment Bélier 42.5', quantity: 50, unitPrice: 4800),
      ],
    ),
    OrderModel(
      id: '2',
      reference: 'CMD-2026-0041',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.fabrication,
      deliveryFee: 25000,
      deliveryAddress: 'Zone Industrielle Yopougon, Abidjan',
      items: const [
        OrderItem(productId: 'hf_16', productName: 'Hourdis Français 16cm', quantity: 500, unitPrice: 400),
      ],
    ),
    OrderModel(
      id: '3',
      reference: 'CMD-2026-0038',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.shipped,
      deliveryFee: 10000,
      deliveryAddress: 'Marcory Résidentiel, Abidjan',
      items: const [
        OrderItem(productId: 'bc15_std', productName: 'Brique Creuse 15cm', quantity: 1000, unitPrice: 180),
      ],
    ),
    OrderModel(
      id: '4',
      reference: 'CMD-2026-0030',
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: OrderStatus.delivered,
      deliveryFee: 20000,
      deliveryAddress: 'Bingerville, Cité des cadres',
      items: const [
        OrderItem(productId: 'bp15_std', productName: 'Brique Pleine 15cm', quantity: 3000, unitPrice: 200),
        OrderItem(productId: 'sable', productName: 'Sable de construction', quantity: 2, unitPrice: 35000),
      ],
    ),
    OrderModel(
      id: '5',
      reference: 'CMD-2026-0028',
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: OrderStatus.cancelled,
      deliveryFee: 0,
      deliveryAddress: 'Plateau, Rue du Commerce',
      items: const [
        OrderItem(productId: 'bp20_std', productName: 'Brique Pleine 20cm', quantity: 500, unitPrice: 250),
      ],
    ),
  ];
}
