import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class OrderPaymentsScreen extends StatelessWidget {
  final String orderId;
  const OrderPaymentsScreen({super.key, required this.orderId});

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy', 'fr_FR');
    final now = DateTime.now();

    // Mock installment data
    const double totalAmount = 875000;
    const int totalInstallments = 4;
    final double firstPayment = (totalAmount * 0.15).ceilToDouble();
    final double installmentAmount = ((totalAmount - firstPayment) / (totalInstallments - 1)).ceilToDouble();

    final installments = [
      _Installment(number: 1, amount: firstPayment, dueDate: now.subtract(const Duration(days: 2)), status: _InstallmentStatus.paid, paidDate: now.subtract(const Duration(days: 2)), label: '1er versement (15%)'),
      _Installment(number: 2, amount: installmentAmount, dueDate: now.add(const Duration(days: 28)), status: _InstallmentStatus.upcoming, label: '2e échéance'),
      _Installment(number: 3, amount: installmentAmount, dueDate: now.add(const Duration(days: 58)), status: _InstallmentStatus.pending, label: '3e échéance'),
      _Installment(number: 4, amount: installmentAmount, dueDate: now.add(const Duration(days: 88)), status: _InstallmentStatus.pending, label: '4e échéance'),
    ];

    final paid = installments.where((i) => i.status == _InstallmentStatus.paid).length;
    final paidAmount = installments.where((i) => i.status == _InstallmentStatus.paid).fold(0.0, (sum, i) => sum + i.amount);
    final progress = paidAmount / totalAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Overview card ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF6D00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text('CMD-$orderId', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 8),
                        Text('${_fmt(paidAmount)} / ${_fmt(totalAmount)} FCFA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$paid/$totalInstallments échéances payées', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                            Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Price locked badge ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Prix bloqué et garanti pour toute la durée', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Installments list ───
                  Text('ÉCHÉANCIER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 1)),
                  const SizedBox(height: 12),

                  ...installments.map((inst) {
                    final isPaid = inst.status == _InstallmentStatus.paid;
                    final isUpcoming = inst.status == _InstallmentStatus.upcoming;
                    final isPending = inst.status == _InstallmentStatus.pending;

                    Color statusColor = isPaid ? AppColors.success : isUpcoming ? AppColors.primary : Colors.grey.shade400;
                    String statusText = isPaid ? 'Payé' : isUpcoming ? 'Prochaine' : 'À venir';
                    IconData statusIcon = isPaid ? Icons.check_circle : isUpcoming ? Icons.schedule : Icons.radio_button_unchecked;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isUpcoming ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(statusIcon, color: statusColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(inst.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      isPaid
                                          ? 'Payé le ${df.format(inst.paidDate!)}'
                                          : 'Échéance : ${df.format(inst.dueDate)}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${_fmt(inst.amount)} F', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isPaid ? AppColors.success : AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isUpcoming) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity, height: 44,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/payment', extra: {
                                  'amount': inst.amount,
                                  'orderId': orderId,
                                  'isFirstPayment': false,
                                  'totalInstallments': totalInstallments,
                                }),
                                icon: const Icon(Icons.payment, size: 18),
                                label: const Text('Payer cette échéance', style: TextStyle(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ─── Remaining info ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Montant total', value: '${_fmt(totalAmount)} FCFA'),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Déjà payé', value: '${_fmt(paidAmount)} FCFA', color: AppColors.success),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Reste à payer', value: '${_fmt(totalAmount - paidAmount)} FCFA', color: AppColors.primary, bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Warning for late payments ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.info),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Les échéances doivent être réglées au plus tard 48h avant la date de livraison prévue. Un rappel sera envoyé chaque semaine.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _InstallmentStatus { paid, upcoming, pending }

class _Installment {
  final int number;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final _InstallmentStatus status;
  final String label;

  const _Installment({required this.number, required this.amount, required this.dueDate, required this.status, required this.label, this.paidDate});
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  final bool bold;
  const _InfoRow({required this.label, required this.value, this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}
