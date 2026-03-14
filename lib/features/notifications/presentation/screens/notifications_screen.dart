import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

enum _NotifType {
  order(Icons.inventory_2_outlined, AppColors.info),
  delivery(Icons.local_shipping_outlined, AppColors.success),
  promo(Icons.local_offer_outlined, Color(0xFFFF6D00)),
  payment(Icons.payment, Color(0xFF9C27B0)),
  system(Icons.info_outline, Color(0xFF607D8B));

  final IconData icon;
  final Color color;
  const _NotifType(this.icon, this.color);
}

class _Notif {
  final String title, body;
  final _NotifType type;
  final DateTime date;
  final bool isRead;

  const _Notif({required this.title, required this.body, required this.type, required this.date, this.isRead = false});
}

final _mockNotifs = [
  _Notif(title: 'Commande confirmée', body: 'Votre commande CMD-2026-0042 a été confirmée et est en cours de préparation.', type: _NotifType.order, date: DateTime.now().subtract(const Duration(minutes: 30))),
  _Notif(title: 'Paiement reçu', body: 'Paiement de 515 000 FCFA reçu via Orange Money.', type: _NotifType.payment, date: DateTime.now().subtract(const Duration(hours: 1))),
  _Notif(title: '-15% sur les briques réfractaires', body: 'Profitez de notre offre limitée pour toute commande supérieure à 500 unités !', type: _NotifType.promo, date: DateTime.now().subtract(const Duration(hours: 5))),
  _Notif(title: 'Livraison en cours', body: 'Votre commande CMD-2026-0038 est en cours de livraison. Livraison prévue avant 17h.', type: _NotifType.delivery, date: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
  _Notif(title: 'Commande livrée', body: 'Votre commande CMD-2026-0030 a été livrée avec succès à Bingerville.', type: _NotifType.delivery, date: DateTime.now().subtract(const Duration(days: 3)), isRead: true),
  _Notif(title: 'Échéance pré-commande', body: 'Rappel : votre prochaine échéance de 312 500 FCFA pour PRE-2026-0012 est dans 15 jours.', type: _NotifType.payment, date: DateTime.now().subtract(const Duration(days: 5)), isRead: true),
  _Notif(title: 'Mise à jour de l\'application', body: 'Une nouvelle version de BRIQUE STORE est disponible avec de nouvelles fonctionnalités.', type: _NotifType.system, date: DateTime.now().subtract(const Duration(days: 7)), isRead: true),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _mockNotifs.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          if (unread > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
      body: _mockNotifs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Aucune notification', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockNotifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final n = _mockNotifs[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: n.isRead ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: n.type.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(n.type.icon, color: n.type.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(n.title, style: TextStyle(fontSize: 14, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary))),
                                if (!n.isRead)
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
                            const SizedBox(height: 6),
                            Text(_timeAgo(n.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
