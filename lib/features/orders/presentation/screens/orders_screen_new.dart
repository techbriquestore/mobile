import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

enum OrderStatusFilter {
  active('En cours', AppColors.info, Icons.hourglass_top),
  completed('Terminée', AppColors.success, Icons.check_circle),
  cancelled('Annulée', AppColors.error, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const OrderStatusFilter(this.label, this.color, this.icon);
}

class MockOrder {
  final String id, reference, productName;
  final double totalAmount, paidAmount;
  final int totalInstallments, paidInstallments;
  final OrderStatusFilter status;
  final DateTime nextDueDate;

  const MockOrder({
    required this.id,
    required this.reference,
    required this.productName,
    required this.totalAmount,
    required this.paidAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.status,
    required this.nextDueDate,
  });

  double get progress => paidAmount / totalAmount;
}

final mockOrders = [
  MockOrder(
    id: '1',
    reference: 'CMD-2026-0012',
    productName: 'Brique Pleine 20cm (5000 unités)',
    totalAmount: 1250000,
    paidAmount: 500000,
    totalInstallments: 4,
    paidInstallments: 2,
    status: OrderStatusFilter.active,
    nextDueDate: DateTime.now().add(const Duration(days: 15)),
  ),
  MockOrder(
    id: '2',
    reference: 'CMD-2026-0008',
    productName: 'Hourdis Français 16cm (2000 unités)',
    totalAmount: 800000,
    paidAmount: 800000,
    totalInstallments: 3,
    paidInstallments: 3,
    status: OrderStatusFilter.completed,
    nextDueDate: DateTime.now(),
  ),
  MockOrder(
    id: '3',
    reference: 'CMD-2026-0005',
    productName: 'Brique Creuse 12cm (3000 unités)',
    totalAmount: 480000,
    paidAmount: 120000,
    totalInstallments: 4,
    paidInstallments: 1,
    status: OrderStatusFilter.cancelled,
    nextDueDate: DateTime.now(),
  ),
];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatusFilter? _filter;

  List<MockOrder> get _filtered {
    if (_filter == null) return mockOrders;
    return mockOrders.where((o) => o.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Mes Commandes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => context.push('/orders/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filter Chips ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _Chip(
                    label: 'Toutes',
                    selected: _filter == null,
                    color: AppColors.primary,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  ...OrderStatusFilter.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(
                      label: s.label,
                      selected: _filter == s,
                      color: s.color,
                      onTap: () => setState(() => _filter = s),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // ─── Orders List ───
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune commande',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final order = orders[i];
                      return GestureDetector(
                        onTap: () => context.push('/orders/${order.id}'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reference + Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order.reference,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: order.status.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(order.status.icon, size: 14, color: order.status.color),
                                        const SizedBox(width: 4),
                                        Text(
                                          order.status.label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: order.status.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Product name
                              Text(
                                order.productName,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 14),

                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: order.progress,
                                  backgroundColor: Colors.grey.shade200,
                                  color: order.status.color,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Installments + Amount
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.paidInstallments}/${order.totalInstallments} échéances',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${order.paidAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' / ${order.totalAmount.toStringAsFixed(0)} F',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
