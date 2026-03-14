import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class _Payment {
  final String reference, label, method;
  final double amount;
  final DateTime date;
  final bool isSuccess;

  const _Payment({required this.reference, required this.label, required this.amount, required this.date, required this.method, this.isSuccess = true});
}

final _mockPayments = [
  _Payment(reference: 'PAY-2026-0088', label: 'CMD-2026-0042', amount: 515000, date: DateTime.now().subtract(const Duration(hours: 2)), method: 'Orange Money'),
  _Payment(reference: 'PAY-2026-0085', label: 'CMD-2026-0041', amount: 225000, date: DateTime.now().subtract(const Duration(days: 1)), method: 'Wave'),
  _Payment(reference: 'PAY-2026-0080', label: 'PRE-2026-0012 (éch. 2)', amount: 312500, date: DateTime.now().subtract(const Duration(days: 5)), method: 'Virement SGBCI'),
  _Payment(reference: 'PAY-2026-0074', label: 'CMD-2026-0038', amount: 190000, date: DateTime.now().subtract(const Duration(days: 10)), method: 'MTN Money'),
  _Payment(reference: 'PAY-2026-0070', label: 'CMD-2026-0030', amount: 670000, date: DateTime.now().subtract(const Duration(days: 15)), method: 'Orange Money', isSuccess: false),
  _Payment(reference: 'PAY-2026-0068', label: 'CMD-2026-0030', amount: 670000, date: DateTime.now().subtract(const Duration(days: 15)), method: 'Virement BICICI'),
];

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy, HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Historique paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockPayments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final p = _mockPayments[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: p.isSuccess ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p.isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                    color: p.isSuccess ? AppColors.success : AppColors.error, size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(p.method, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      Text(df.format(p.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${p.isSuccess ? "-" : ""}${p.amount.toStringAsFixed(0)} F',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.isSuccess ? AppColors.textPrimary : AppColors.error),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.isSuccess ? 'Réussi' : 'Échoué',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.isSuccess ? AppColors.success : AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
