import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/promotion.dart';
import '../../data/providers/promotion_providers.dart';

class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  String _daysLeft(DateTime date) {
    final d = date.difference(DateTime.now()).inDays;
    if (d <= 0) return 'Expire aujourd\'hui';
    if (d == 1) return 'Expire demain';
    return 'Expire dans $d jours';
  }
  
  IconData _getIcon(Promotion p) {
    if (p.isFreeDelivery) return Icons.local_shipping;
    if (p.isPercentage) return Icons.percent;
    return Icons.local_offer;
  }
  
  Color _getColor(Promotion p) {
    if (p.isFreeDelivery) return AppColors.success;
    if (p.value >= 20) return AppColors.primary;
    if (p.value >= 10) return Colors.deepOrange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(activePromotionsProvider);
    
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
            child: promotionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('Impossible de charger les promotions', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => ref.invalidate(activePromotionsProvider),
                      child: const Text('Réessayer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              data: (promotions) {
                if (promotions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Aucune promotion active', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        Text('Revenez bientôt !', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: promotions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final p = promotions[index];
                    final isUrgent = p.daysRemaining <= 7;
                    final color = _getColor(p);
                    final icon = _getIcon(p);

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
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _daysLeft(p.endDate),
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUrgent ? AppColors.error : Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                                child: Text(p.displayValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ],
                          ),
                          if (p.description != null) ...[
                            const SizedBox(height: 12),
                            Text(p.description!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4)),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (p.code != null)
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
                                      Text(p.code!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  if (p.productId != null) {
                                    context.push('/catalog/product/${p.productId}');
                                  } else if (p.categoryId != null) {
                                    context.push('/catalog/category/${p.categoryId}');
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
