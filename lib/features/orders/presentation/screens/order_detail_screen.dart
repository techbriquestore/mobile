import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/order.dart';
import '../../data/providers/order_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return orderAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
          title: const Text('Chargement...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
          title: const Text('Erreur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Impossible de charger la commande', style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.invalidate(orderByIdProvider(orderId)),
                child: const Text('Réessayer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
      data: (order) => _buildDetail(context, ref, order),
    );
  }

  // Build installment rows
  List<Widget> _buildInstallments(OrderModel order) {
    final duration = order.paymentDuration ?? 1;
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    
    // Calculate installment amounts
    // First payment is 15% (acompte), rest divided equally
    final firstPayment = (order.totalAmount * 0.15).ceilToDouble();
    final remainingPerInstallment = ((order.totalAmount - firstPayment) / (duration - 1)).ceilToDouble();
    
    final List<Widget> rows = [];
    
    for (int i = 1; i <= duration; i++) {
      final amount = i == 1 ? firstPayment : remainingPerInstallment;
      final dueDate = order.createdAt.add(Duration(days: 30 * (i - 1)));
      
      // Check if this installment is paid
      final payment = order.payments.firstWhere(
        (p) => p.installmentNumber == i,
        orElse: () => OrderPayment(
          id: '',
          amount: amount,
          status: 'PENDING',
          method: '',
          createdAt: dueDate,
          installmentNumber: i,
        ),
      );
      
      final isPaid = payment.isPaid;
      final isNext = !isPaid && order.payments.where((p) => p.isPaid).length == i - 1;
      
      rows.add(_InstallmentRow(
        number: i,
        amount: amount,
        date: dateFormat.format(dueDate),
        isPaid: isPaid,
        isNext: isNext,
      ));
    }
    
    return rows;
  }
  
  double _getNextInstallmentAmount(OrderModel order) {
    final duration = order.paymentDuration ?? 1;
    final paidCount = order.paidInstallments;
    
    if (paidCount >= duration) return 0;
    
    final firstPayment = (order.totalAmount * 0.15).ceilToDouble();
    final remainingPerInstallment = ((order.totalAmount - firstPayment) / (duration - 1)).ceilToDouble();
    
    // If first installment not paid
    if (paidCount == 0) return firstPayment;
    
    // Otherwise return regular installment amount
    return remainingPerInstallment;
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, OrderModel order) {
    final dateFormat = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');
    final totalArticles = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Statut ─────────────────────────────────────────────────
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(order.status.icon, color: order.status.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.status.label,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: order.status.color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Articles ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Articles ($totalArticles)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.view_in_ar, size: 22, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} FCFA', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Text(
                          '${item.subtotal.toStringAsFixed(0)} F',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Progression paiement (si échelonné) ─────────────────────
            if (order.paymentDuration != null && order.paymentDuration! > 1)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progression du paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('${(order.paymentProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: order.paymentProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${order.totalPaid.toStringAsFixed(0)} / ${order.totalAmount.toStringAsFixed(0)} FCFA',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

            if (order.paymentDuration != null && order.paymentDuration! > 1)
              const SizedBox(height: 12),

            // ─── Échéancier de paiement ──────────────────────────────────
            if (order.paymentDuration != null && order.paymentDuration! > 1)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Échéancier de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 14),
                    ..._buildInstallments(order),
                  ],
                ),
              ),

            if (order.paymentDuration != null && order.paymentDuration! > 1)
              const SizedBox(height: 12),

            // ─── Récapitulatif ──────────────────────────────────────────
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _SummaryRow(label: 'Sous-total', value: '${order.subtotal.toStringAsFixed(0)} FCFA'),
                  const SizedBox(height: 10),
                  _SummaryRow(label: 'Livraison (${order.deliveryMode})', value: '${order.deliveryFee.toStringAsFixed(0)} FCFA'),
                  if (order.paymentDuration != null && order.paymentDuration! > 1) ...[
                    const SizedBox(height: 10),
                    _SummaryRow(label: 'Paiement échelonné', value: '${order.paymentDuration} mois'),
                    const SizedBox(height: 10),
                    _SummaryRow(label: 'Déjà payé', value: '${order.totalPaid.toStringAsFixed(0)} FCFA', valueColor: AppColors.success),
                    const SizedBox(height: 10),
                    _SummaryRow(label: 'Reste à payer', value: '${order.remainingAmount.toStringAsFixed(0)} FCFA', valueColor: AppColors.primary),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('${order.totalAmount.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Bouton payer prochaine échéance ─────────────────────────
            if (order.paymentDuration != null && order.paymentDuration! > 1 && order.remainingAmount > 0)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final nextInstallment = _getNextInstallmentAmount(order);
                      context.push('/payment', extra: {
                        'amount': nextInstallment,
                        'orderId': order.id,
                        'isFirstPayment': false,
                        'totalInstallments': order.paymentDuration,
                      });
                    },
                    icon: const Icon(Icons.payment, size: 20),
                    label: Text('Payer la prochaine échéance (${_getNextInstallmentAmount(order).toStringAsFixed(0)} F)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

            if (order.paymentDuration != null && order.paymentDuration! > 1 && order.remainingAmount > 0)
              const SizedBox(height: 12),

            // ─── Actions ────────────────────────────────────────────────
            if (order.status == OrderStatus.pendingValidation || order.status == OrderStatus.validated)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Annuler la commande ?'),
                          content: const Text('Cette action est irréversible.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui, annuler', style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          final service = ref.read(orderServiceProvider);
                          await service.cancelOrder(order.id);
                          ref.invalidate(orderByIdProvider(orderId));
                          ref.invalidate(ordersProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Commande annulée'), backgroundColor: AppColors.success),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text('Annuler la commande', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  final int number;
  final double amount;
  final String date;
  final bool isPaid;
  final bool isNext;
  const _InstallmentRow({required this.number, required this.amount, required this.date, required this.isPaid, this.isNext = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isPaid ? AppColors.success : isNext ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(isPaid ? Icons.check : Icons.schedule, size: 16, color: isPaid ? Colors.white : isNext ? AppColors.primary : Colors.grey.shade400),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Échéance $number${number == 1 ? " (Acompte 15%)" : ""}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isNext ? AppColors.primary : AppColors.textPrimary)),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ])),
          Text('${amount.toStringAsFixed(0)} F', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isPaid ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
