import 'dart:math' as math;
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
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
      data: (order) => _OrderDetailBody(order: order, orderId: orderId),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final OrderModel order;
  final String orderId;

  const _OrderDetailBody({required this.order, required this.orderId});

  List<_InstallmentData> _computeInstallments() {
    final duration = order.paymentDuration ?? 1;
    final firstPayment = (order.totalAmount * 0.15).ceilToDouble();
    final remainingPerInstallment = duration > 1
        ? ((order.totalAmount - firstPayment) / (duration - 1)).ceilToDouble()
        : 0.0;

    final List<_InstallmentData> list = [];
    for (int i = 1; i <= duration; i++) {
      final amount = i == 1 ? firstPayment : remainingPerInstallment;
      final dueDate = order.createdAt.add(Duration(days: 30 * (i - 1)));

      final payment = order.payments.firstWhere(
        (p) => p.installmentNumber == i,
        orElse: () => OrderPayment(
          id: '', amount: amount, status: 'PENDING', method: '',
          createdAt: dueDate, installmentNumber: i,
        ),
      );

      final isPaid = payment.isPaid;
      final isNext = !isPaid && order.payments.where((p) => p.isPaid).length == i - 1;

      list.add(_InstallmentData(
        number: i, amount: amount, dueDate: dueDate,
        isPaid: isPaid, isNext: isNext,
      ));
    }
    return list;
  }

  double _getNextInstallmentAmount() {
    final duration = order.paymentDuration ?? 1;
    final paidCount = order.paidInstallments;
    if (paidCount >= duration) return 0;
    final firstPayment = (order.totalAmount * 0.15).ceilToDouble();
    if (paidCount == 0) return firstPayment;
    return ((order.totalAmount - firstPayment) / (duration - 1)).ceilToDouble();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final dateTimeFormat = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');
    final totalArticles = order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final hasInstallments = order.paymentDuration != null && order.paymentDuration! > 1;
    final installments = hasInstallments ? _computeInstallments() : <_InstallmentData>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: CustomScrollView(
        slivers: [
          // ─── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Column(
              children: [
                Text(order.orderNumber, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                Text(dateTimeFormat.format(order.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(order.status.icon, size: 14, color: order.status.color),
                    const SizedBox(width: 4),
                    Text(order.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: order.status.color)),
                  ],
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ─── Hero Card - Paiement ───────────────────────────────
                if (hasInstallments) ...[
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Paiement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${order.paidInstallments}/${order.paymentDuration} mois',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Circular progress
                        SizedBox(
                          width: 110, height: 110,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 110, height: 110,
                                child: CustomPaint(
                                  painter: _CircleProgressPainter(
                                    progress: order.paymentProgress,
                                    bgColor: Colors.white.withOpacity(0.2),
                                    fgColor: Colors.white,
                                    strokeWidth: 8,
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(order.paymentProgress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    const Text('payé', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Amounts row
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('Payé', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatAmount(order.totalPaid)} F',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2)),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('Restant', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatAmount(order.remainingAmount)} F',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2)),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('Total', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatAmount(order.totalAmount)} F',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // ─── Simple total card for non-installment orders ──────
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Montant total', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatAmount(order.totalAmount)} FCFA',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ─── Timeline Statut ────────────────────────────────────
                _Section(
                  title: 'Suivi de commande',
                  icon: Icons.timeline,
                  child: _buildStatusTimeline(order, dateFormat),
                ),

                const SizedBox(height: 12),

                // ─── Articles ───────────────────────────────────────────
                _Section(
                  title: 'Articles ($totalArticles)',
                  icon: Icons.inventory_2_outlined,
                  child: Column(
                    children: order.items.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isLast = entry.key == order.items.length - 1;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.view_in_ar_rounded, size: 26, color: Color(0xFFE65100)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.quantity} unités x ${_formatAmount(item.unitPrice)} F',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_formatAmount(item.subtotal)} F',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (!isLast) Divider(height: 24, color: Colors.grey.shade100),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                // ─── Échéancier de paiement ─────────────────────────────
                if (hasInstallments) ...[
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Échéancier de paiement',
                    icon: Icons.calendar_month,
                    child: Column(
                      children: installments.asMap().entries.map((entry) {
                        final inst = entry.value;
                        final isLast = entry.key == installments.length - 1;
                        return _InstallmentRow(
                          data: inst,
                          dateFormat: dateFormat,
                          isLast: isLast,
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ─── Récapitulatif ──────────────────────────────────────
                _Section(
                  title: 'Récapitulatif',
                  icon: Icons.receipt_outlined,
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Sous-total', value: '${_formatAmount(order.subtotal)} FCFA'),
                      const SizedBox(height: 12),
                      _SummaryRow(label: 'Livraison', value: order.deliveryFee > 0 ? '${_formatAmount(order.deliveryFee)} FCFA' : 'Gratuit', valueColor: order.deliveryFee == 0 ? AppColors.success : null),
                      if (hasInstallments) ...[
                        const SizedBox(height: 12),
                        _SummaryRow(label: 'Durée de paiement', value: '${order.paymentDuration} mois'),
                        const SizedBox(height: 12),
                        _SummaryRow(label: 'Déjà payé', value: '${_formatAmount(order.totalPaid)} FCFA', valueColor: AppColors.success),
                        const SizedBox(height: 12),
                        _SummaryRow(label: 'Reste à payer', value: '${_formatAmount(order.remainingAmount)} FCFA', valueColor: AppColors.primary),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: Colors.grey.shade200),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          Text('${_formatAmount(order.totalAmount)} FCFA', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Notes livraison ────────────────────────────────────
                if (order.deliveryNotes != null && order.deliveryNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Notes de livraison',
                    icon: Icons.note_alt_outlined,
                    child: Text(
                      order.deliveryNotes!,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      // ─── Bottom Bar - Payer ─────────────────────────────────────────
      bottomNavigationBar: hasInstallments && order.remainingAmount > 0
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final nextAmount = _getNextInstallmentAmount();
                    context.push('/payment', extra: {
                      'amount': nextAmount,
                      'orderId': order.id,
                      'isFirstPayment': false,
                      'totalInstallments': order.paymentDuration,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Payer ${_formatAmount(_getNextInstallmentAmount())} FCFA',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusTimeline(OrderModel order, DateFormat dateFormat) {
    final allStatuses = [
      OrderStatus.pendingValidation,
      OrderStatus.validated,
      OrderStatus.inPreparation,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentIndex = allStatuses.indexOf(order.status);
    final isCancelled = order.status == OrderStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.cancel, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Commande annulée', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error)),
                  if (order.cancelledAt != null)
                    Text('Le ${dateFormat.format(order.cancelledAt!)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: allStatuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == allStatuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot + line
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? status.color : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: status.color.withOpacity(0.3), width: 3) : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      size: isCompleted ? 14 : 8,
                      color: isCompleted ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: isCompleted && index < currentIndex ? status.color.withOpacity(0.3) : Colors.grey.shade200,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCompleted ? AppColors.textPrimary : Colors.grey.shade400,
                      ),
                    ),
                    if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('Étape actuelle', style: TextStyle(fontSize: 12, color: status.color, fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000) {
      return NumberFormat('#,###', 'fr_FR').format(amount.round());
    }
    return amount.toStringAsFixed(0);
  }
}

// ─── Section container ──────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ─── Summary row ────────────────────────────────────────────────────────
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

// ─── Installment data ───────────────────────────────────────────────────
class _InstallmentData {
  final int number;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final bool isNext;
  const _InstallmentData({required this.number, required this.amount, required this.dueDate, required this.isPaid, required this.isNext});
}

// ─── Installment row ────────────────────────────────────────────────────
class _InstallmentRow extends StatelessWidget {
  final _InstallmentData data;
  final DateFormat dateFormat;
  final bool isLast;
  const _InstallmentRow({required this.data, required this.dateFormat, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isPaid = data.isPaid;
    final isNext = data.isNext;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withOpacity(0.05)
            : isNext
                ? AppColors.primary.withOpacity(0.05)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPaid
              ? AppColors.success.withOpacity(0.15)
              : isNext
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isPaid ? AppColors.success : isNext ? AppColors.primary : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check : isNext ? Icons.arrow_forward : Icons.schedule,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.number == 1 ? 'Acompte (15%)' : 'Échéance ${data.number}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isNext ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(data.dueDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_OrderDetailBody._formatAmount(data.amount)} F',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isPaid ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              Text(
                isPaid ? 'Payé' : isNext ? 'À payer' : 'En attente',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isPaid ? AppColors.success : isNext ? AppColors.primary : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Circular progress painter ──────────────────────────────────────────
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fgColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = fgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
