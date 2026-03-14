import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class _Promo {
  final String title, description, code, productRef;
  final int discount;
  final DateTime expiresAt;
  final IconData icon;
  final Color color;

  const _Promo({required this.title, required this.description, required this.code, required this.discount, required this.expiresAt, required this.productRef, required this.icon, required this.color});
}

final _mockPromos = [
  _Promo(title: '-15% Briques Réfractaires', description: 'Pour toute commande supérieure à 500 unités de briques réfractaires.', code: 'REFRAC15', discount: 15, expiresAt: DateTime.now().add(const Duration(days: 12)), productRef: 'BRF-STD', icon: Icons.whatshot, color: Colors.deepOrange),
  _Promo(title: 'Livraison gratuite', description: 'Livraison offerte sur Abidjan pour toute commande > 500 000 FCFA.', code: 'FREEDELIVERY', discount: 0, expiresAt: DateTime.now().add(const Duration(days: 30)), productRef: '', icon: Icons.local_shipping, color: AppColors.success),
  _Promo(title: '-10% Hourdis Français', description: 'Offre spéciale sur tous les hourdis français 16 et 20.', code: 'HOURDIS10', discount: 10, expiresAt: DateTime.now().add(const Duration(days: 7)), productRef: 'HF-16', icon: Icons.view_module, color: Colors.blue),
  _Promo(title: 'Pack Chantier -20%', description: 'Achetez briques + hourdis ensemble et économisez 20% sur le lot.', code: 'PACK20', discount: 20, expiresAt: DateTime.now().add(const Duration(days: 21)), productRef: '', icon: Icons.construction, color: AppColors.primary),
];

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  String _daysLeft(DateTime date) {
    final d = date.difference(DateTime.now()).inDays;
    if (d <= 0) return 'Expire aujourd\'hui';
    if (d == 1) return 'Expire demain';
    return 'Expire dans $d jours';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Promotions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF6D00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Icon(Icons.local_offer, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                const Text('Offres du moment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Profitez de nos promotions exclusives !', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),

          // Promos list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _mockPromos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final p = _mockPromos[index];
                final isUrgent = p.expiresAt.difference(DateTime.now()).inDays <= 7;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isUrgent ? Border.all(color: AppColors.error.withValues(alpha: 0.3)) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                            child: Icon(p.icon, color: p.color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(
                                  _daysLeft(p.expiresAt),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUrgent ? AppColors.error : Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          if (p.discount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(10)),
                              child: Text('-${p.discount}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(p.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Text(p.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              if (p.productRef.isNotEmpty) {
                                context.push('/catalog/product/${p.productRef}');
                              } else {
                                context.push('/catalog');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                              child: const Text('Voir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
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
