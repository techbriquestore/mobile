import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class PreorderDetailScreen extends StatelessWidget {
  final String preorderId;
  const PreorderDetailScreen({super.key, required this.preorderId});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy', 'fr_FR');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Détail pré-commande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Header ───
            Container(
              color: Colors.white, width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('PRE-2026-0012', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.hourglass_top, size: 16, color: AppColors.info),
                      SizedBox(width: 6),
                      Text('En cours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.info)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  // Progress circle
                  SizedBox(
                    width: 100, height: 100,
                    child: Stack(
                      children: [
                        SizedBox(width: 100, height: 100, child: CircularProgressIndicator(value: 0.5, strokeWidth: 8, backgroundColor: Colors.grey.shade200, color: AppColors.primary)),
                        const Center(child: Text('50%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('500 000 / 1 250 000 FCFA', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── Product ───
            _Section(title: 'Produit', child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.view_in_ar_rounded, color: Color(0xFFE65100), size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Brique Pleine 20cm Standard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('5 000 unités x 250 F = 1 250 000 FCFA', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ])),
            ])),
            const SizedBox(height: 12),

            // ─── Payment Schedule ───
            _Section(title: 'Échéancier de paiement', child: Column(children: [
              _InstallmentRow(number: 1, amount: 312500, date: df.format(DateTime.now().subtract(const Duration(days: 30))), isPaid: true),
              _InstallmentRow(number: 2, amount: 312500, date: df.format(DateTime.now().subtract(const Duration(days: 5))), isPaid: true),
              _InstallmentRow(number: 3, amount: 312500, date: df.format(DateTime.now().add(const Duration(days: 15))), isPaid: false, isNext: true),
              _InstallmentRow(number: 4, amount: 312500, date: df.format(DateTime.now().add(const Duration(days: 45))), isPaid: false),
            ])),
            const SizedBox(height: 12),

            // ─── Notes ───
            _Section(title: 'Notes', child: Text(
              'Livraison prévue après le paiement complet.\nLe produit sera disponible sous 7 jours après la dernière échéance.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        color: Colors.white,
        child: SizedBox(width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.payment, size: 20),
            label: const Text('Payer la prochaine échéance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, width: double.infinity, padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 14), child,
      ]),
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
            Text('Échéance $number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isNext ? AppColors.primary : AppColors.textPrimary)),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ])),
          Text('${amount.toStringAsFixed(0)} F', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isPaid ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
