import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum OrderStatus {
  pendingValidation('En attente', AppColors.statusPending, Icons.schedule, 'PENDING_VALIDATION'),
  validated('Validée', AppColors.statusValidated, Icons.check_circle_outline, 'VALIDATED'),
  inPreparation('En fabrication', AppColors.statusFabrication, Icons.precision_manufacturing, 'IN_PREPARATION'),
  shipped('En expédition', AppColors.statusShipped, Icons.local_shipping_outlined, 'SHIPPED'),
  delivered('Livrée', AppColors.statusDelivered, Icons.task_alt, 'DELIVERED'),
  cancelled('Annulée', AppColors.statusCancelled, Icons.cancel_outlined, 'CANCELLED'),
  returned('Retournée', AppColors.statusCancelled, Icons.undo, 'RETURNED');

  final String label;
  final Color color;
  final IconData icon;
  final String backendValue;
  const OrderStatus(this.label, this.color, this.icon, this.backendValue);

  static OrderStatus fromBackend(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.backendValue == value,
      orElse: () => OrderStatus.pendingValidation,
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productReference;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productReference,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return OrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: product?['name'] as String? ?? 'Produit',
      productReference: product?['reference'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class OrderPayment {
  final String id;
  final double amount;
  final String status; // PENDING, COMPLETED, FAILED
  final String method; // ORANGE_MONEY, MTN_MONEY, etc.
  final DateTime? paidAt;
  final DateTime createdAt;
  final int installmentNumber;

  const OrderPayment({
    required this.id,
    required this.amount,
    required this.status,
    required this.method,
    this.paidAt,
    required this.createdAt,
    required this.installmentNumber,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      method: json['method'] as String? ?? 'ORANGE_MONEY',
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      installmentNumber: json['installmentNumber'] as int? ?? 1,
    );
  }
  
  bool get isPaid => status == 'COMPLETED';
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryMode;
  final String? deliveryNotes;
  final int? paymentDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final List<OrderItem> items;
  final List<OrderPayment> payments;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryMode,
    this.deliveryNotes,
    this.paymentDuration,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.items,
    this.payments = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      userId: json['userId'] as String,
      status: OrderStatus.fromBackend(json['status'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryMode: json['deliveryMode'] as String? ?? 'STANDARD',
      deliveryNotes: json['deliveryNotes'] as String?,
      paymentDuration: json['paymentDuration'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'] as String) : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => OrderPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Compat getters
  String get reference => orderNumber;
  DateTime get date => createdAt;
  double get total => totalAmount;
  
  // Payment helpers
  double get totalPaid => payments.where((p) => p.isPaid).fold(0.0, (sum, p) => sum + p.amount);
  double get remainingAmount => totalAmount - totalPaid;
  double get paymentProgress => totalAmount > 0 ? totalPaid / totalAmount : 0;
  int get paidInstallments => payments.where((p) => p.isPaid).length;
}

class OrdersPage {
  final List<OrderModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const OrdersPage({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory OrdersPage.fromJson(Map<String, dynamic> json) => OrdersPage(
        data: (json['data'] as List<dynamic>)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
      );
}

