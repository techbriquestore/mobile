import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Mock tracking data
    final steps = [
      _TrackingStep(title: 'Commande enregistrée', subtitle: '10 Mars 2026, 14:30', icon: Icons.receipt_long, isDone: true),
      _TrackingStep(title: 'Paiement confirmé', subtitle: '10 Mars 2026, 14:32', icon: Icons.payment, isDone: true),
      _TrackingStep(title: 'En préparation', subtitle: '11 Mars 2026, 08:15', icon: Icons.inventory_2, isDone: true),
      _TrackingStep(title: 'Expédiée', subtitle: '12 Mars 2026, 10:00', icon: Icons.local_shipping, isDone: true, isCurrent: true),
      _TrackingStep(title: 'Livrée', subtitle: 'Estimée : 13 Mars 2026', icon: Icons.check_circle, isDone: false),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Suivi de livraison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Order header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CMD-$orderId', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('En cours de livraison', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tracking timeline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progression', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  ...List.generate(steps.length, (i) {
                    final step = steps[i];
                    final isLast = i == steps.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
                        SizedBox(
                          width: 32,
                          child: Column(
                            children: [
                              Container(
                                width: step.isCurrent ? 28 : 22,
                                height: step.isCurrent ? 28 : 22,
                                decoration: BoxDecoration(
                                  color: step.isDone ? AppColors.primary : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  border: step.isCurrent ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3) : null,
                                ),
                                child: Icon(
                                  step.isDone ? Icons.check : step.icon,
                                  size: step.isCurrent ? 14 : 12,
                                  color: step.isDone ? Colors.white : Colors.grey.shade400,
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2, height: 48,
                                  color: step.isDone ? AppColors.primary : Colors.grey.shade200,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: step.isCurrent ? FontWeight.w700 : FontWeight.w500,
                                    color: step.isDone ? AppColors.textPrimary : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(step.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Driver info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chauffeur / Transporteur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Text('AK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Amadou Koné', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text('Camion plateau • AB 1234 CI', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.phone, color: AppColors.success, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery address
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adresse de livraison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chantier Cocody', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text('Cocody Riviera Palmeraie, lot 234\nAbidjan', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
                            const SizedBox(height: 4),
                            Text('Point de repère : Après le carrefour de la pharmacie', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TrackingStep {
  final String title, subtitle;
  final IconData icon;
  final bool isDone;
  final bool isCurrent;

  const _TrackingStep({required this.title, required this.subtitle, required this.icon, this.isDone = false, this.isCurrent = false});
}
