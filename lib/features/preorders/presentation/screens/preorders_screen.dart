import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/preorder_providers.dart';
import '../../domain/models/preorder.dart';

Color _statusColor(String s) {
  switch (s) {
    case 'ACTIVE': return AppColors.info;
    case 'COMPLETED': return AppColors.success;
    case 'CONVERTED': return Colors.purple;
    case 'SUSPENDED': return Colors.orange;
    case 'CANCELLED': return AppColors.error;
    default: return Colors.grey;
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'ACTIVE': return 'En cours';
    case 'COMPLETED': return 'Complétée';
    case 'CONVERTED': return 'Convertie';
    case 'SUSPENDED': return 'Suspendue';
    case 'CANCELLED': return 'Annulée';
    default: return s;
  }
}

IconData _statusIcon(String s) {
  switch (s) {
    case 'ACTIVE': return Icons.hourglass_top;
    case 'COMPLETED': return Icons.check_circle;
    case 'CONVERTED': return Icons.swap_horiz_rounded;
    case 'SUSPENDED': return Icons.pause_circle;
    case 'CANCELLED': return Icons.cancel;
    default: return Icons.circle;
  }
}

String _fmt(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

class PreordersScreen extends ConsumerStatefulWidget {
  const PreordersScreen({super.key});

  @override
  ConsumerState<PreordersScreen> createState() => _PreordersScreenState();
}

class _PreordersScreenState extends ConsumerState<PreordersScreen> {
  String? _filter;

  static const _filters = [
    (null, 'Toutes', AppColors.primary),
    ('ACTIVE', 'En cours', AppColors.info),
    ('COMPLETED', 'Complétées', AppColors.success),
    ('CONVERTED', 'Converties', Colors.purple),
    ('CANCELLED', 'Annulées', AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    final preordersAsync = ref.watch(preordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes Pré-commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                children: _filters.map((f) {
                  final (status, label, color) = f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(
                      label: label,
                      selected: _filter == status,
                      color: color,
                      onTap: () {
                        setState(() => _filter = status);
                        ref.read(preorderFiltersProvider.notifier).setStatus(status);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: preordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('Impossible de charger', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => ref.invalidate(preordersProvider),
                    child: const Text('Réessayer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              data: (page) {
                final preorders = page.data;
                if (preorders.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Aucune pré-commande', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                  ]));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(preordersProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: preorders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _PreorderCard(preorder: preorders[i]),
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

class _PreorderCard extends StatelessWidget {
  final Preorder preorder;
  const _PreorderCard({required this.preorder});

  @override
  Widget build(BuildContext context) {
    final schedules = preorder.schedules;
    final paidCount = schedules.where((s) => s.status == 'PAID').length;
    final totalCount = schedules.length;
    final paidAmount = schedules.where((s) => s.status == 'PAID').fold<int>(0, (sum, s) => sum + s.amount);
    final progress = preorder.totalAmount > 0 ? paidAmount / preorder.totalAmount : 0.0;
    final color = _statusColor(preorder.status);
    final label = _statusLabel(preorder.status);
    final icon = _statusIcon(preorder.status);

    return GestureDetector(
      onTap: () => context.push('/preorders/${preorder.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PC-${preorder.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('${preorder.totalQuantity} unités — Prix bloqué : ${_fmt(preorder.lockedPrice.toDouble())} F/u', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$paidCount/$totalCount échéances', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                RichText(text: TextSpan(children: [
                  TextSpan(text: _fmt(paidAmount.toDouble()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  TextSpan(text: ' / ${_fmt(preorder.totalAmount.toDouble())} F', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ])),
              ],
            ),
          ],
        ),
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
