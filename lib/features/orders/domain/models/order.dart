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

