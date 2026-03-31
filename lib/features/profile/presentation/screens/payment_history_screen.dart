import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../checkout/data/providers/payment_providers.dart';
import '../../../checkout/data/services/payment_service.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

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
    final df = DateFormat('dd MMM yyyy, HH:mm', 'fr_FR');
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Historique paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22, color: AppColors.textPrimary),
            onPressed: () => ref.invalidate(paymentHistoryProvider),
          ),
        ],
      ),
      body: historyAsync.when(
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
                onTap: () => ref.invalidate(paymentHistoryProvider),
                child: const Text('Réessayer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (page) {
          if (page.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payment_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Aucun paiement', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: page.data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final p = page.data[index];
              final isSuccess = p.isConfirmed;
              final orderRef = p.order?['orderNumber'] as String? ?? '';
              return GestureDetector(
                onTap: () {
                  if (p.orderId.isNotEmpty) {
                    context.push('/order-payments/${p.orderId}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isSuccess ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                          color: isSuccess ? AppColors.success : AppColors.error, size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderRef, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(p.methodLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            Text(df.format(p.paidAt ?? p.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_fmt(p.amount)} F',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isSuccess ? AppColors.textPrimary : AppColors.error),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSuccess ? 'Confirmé' : 'Échoué',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSuccess ? AppColors.success : AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
