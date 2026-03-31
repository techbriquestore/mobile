import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../checkout/data/providers/payment_providers.dart';
import '../../../checkout/data/services/payment_service.dart';

class OrderPaymentsScreen extends ConsumerWidget {
  final String orderId;
  const OrderPaymentsScreen({super.key, required this.orderId});

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(orderPaymentsProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.invalidate(orderPaymentsProvider(orderId)),
                child: const Text('Réessayer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (data) => _buildContent(context, ref, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, OrderPaymentsData data) {
    final dateFormat = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');
    final remaining = data.remaining;
    final progress = data.progressPercent;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Progress card ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF6D00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text('Total commandé', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text('${_fmt(data.totalAmount)} FCFA', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payé : ${_fmt(data.totalPaid)} F', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
                          Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                      if (remaining > 0) ...[
                        const SizedBox(height: 4),
                        Text('Reste : ${_fmt(remaining)} FCFA', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Payments list ───
                Text('HISTORIQUE DES PAIEMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                const SizedBox(height: 12),

                if (data.payments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Aucun paiement enregistré', style: TextStyle(color: Colors.grey.shade500))),
                  )
                else
                  ...data.payments.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: p.isConfirmed ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            p.isConfirmed ? Icons.check_circle : Icons.schedule,
                            color: p.isConfirmed ? AppColors.success : Colors.grey.shade400,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.methodLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(
                                p.paidAt != null ? dateFormat.format(p.paidAt!) : dateFormat.format(p.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${_fmt(p.amount)} F', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            Text(
                              p.isConfirmed ? 'Confirmé' : p.status,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.isConfirmed ? AppColors.success : Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ),

        // ─── Pay next installment button ───
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prochaine échéance', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    Text('${_fmt(remaining > data.totalAmount ~/ (data.paymentDuration ?? 1) ? data.totalAmount ~/ (data.paymentDuration ?? 1) : remaining)} FCFA',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final installmentAmount = remaining > data.totalAmount ~/ (data.paymentDuration ?? 1)
                          ? data.totalAmount ~/ (data.paymentDuration ?? 1)
                          : remaining;
                      context.push('/payment', extra: {
                        'amount': installmentAmount.toDouble(),
                        'orderId': orderId,
                        'isFirstPayment': false,
                        'totalInstallments': data.paymentDuration ?? 1,
                      });
                    },
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text('Payer l\'échéance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
