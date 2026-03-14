import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

enum _PreorderStatus {
  active('En cours', AppColors.info, Icons.hourglass_top),
  completed('Terminée', AppColors.success, Icons.check_circle),
  cancelled('Annulée', AppColors.error, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const _PreorderStatus(this.label, this.color, this.icon);
}

class _MockPreorder {
  final String id, reference, productName;
  final double totalAmount, paidAmount;
  final int totalInstallments, paidInstallments;
  final _PreorderStatus status;
  final DateTime nextDueDate;

  const _MockPreorder({
    required this.id, required this.reference, required this.productName,
    required this.totalAmount, required this.paidAmount,
    required this.totalInstallments, required this.paidInstallments,
    required this.status, required this.nextDueDate,
  });

  double get progress => paidAmount / totalAmount;
}

final _mockPreorders = [
  _MockPreorder(id: '1', reference: 'PRE-2026-0012', productName: 'Brique Pleine 20cm (5000 unités)', totalAmount: 1250000, paidAmount: 500000, totalInstallments: 4, paidInstallments: 2, status: _PreorderStatus.active, nextDueDate: DateTime.now().add(const Duration(days: 15))),
  _MockPreorder(id: '2', reference: 'PRE-2026-0008', productName: 'Hourdis Français 16cm (2000 unités)', totalAmount: 800000, paidAmount: 800000, totalInstallments: 3, paidInstallments: 3, status: _PreorderStatus.completed, nextDueDate: DateTime.now()),
  _MockPreorder(id: '3', reference: 'PRE-2026-0005', productName: 'Brique Creuse 12cm (3000 unités)', totalAmount: 480000, paidAmount: 120000, totalInstallments: 4, paidInstallments: 1, status: _PreorderStatus.cancelled, nextDueDate: DateTime.now()),
];

class PreordersScreen extends StatefulWidget {
  const PreordersScreen({super.key});

  @override
  State<PreordersScreen> createState() => _PreordersScreenState();
}

class _PreordersScreenState extends State<PreordersScreen> {
  _PreorderStatus? _filter;

  List<_MockPreorder> get _filtered {
    if (_filter == null) return _mockPreorders;
    return _mockPreorders.where((p) => p.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final preorders = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes Pré-commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), onPressed: () => context.push('/preorders/create')),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _Chip(label: 'Toutes', selected: _filter == null, color: AppColors.primary, onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  ..._PreorderStatus.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(label: s.label, selected: _filter == s, color: s.color, onTap: () => setState(() => _filter = s)),
                  )),
                ],
              ),
            ),
          ),
          Expanded(
            child: preorders.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Aucune pré-commande', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: preorders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = preorders[i];
                      return GestureDetector(
                        onTap: () => context.push('/preorders/${p.id}'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p.reference, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: p.status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(p.status.icon, size: 14, color: p.status.color),
                                      const SizedBox(width: 4),
                                      Text(p.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.status.color)),
                                    ]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(p.productName, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                              const SizedBox(height: 14),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: p.progress,
                                  backgroundColor: Colors.grey.shade200,
                                  color: p.status.color,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${p.paidInstallments}/${p.totalInstallments} échéances', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                  RichText(text: TextSpan(children: [
                                    TextSpan(text: '${p.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                    TextSpan(text: ' / ${p.totalAmount.toStringAsFixed(0)} F', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                  ])),
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
  const _Chip({required this.label, required this.selected, required this.color, required this.onTap});

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
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary))),
      ),
    );
  }
}
