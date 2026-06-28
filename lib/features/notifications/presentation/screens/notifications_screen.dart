import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/notification_providers.dart';
import '../../domain/models/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Étiquette de section par jour.
  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    return 'Plus ancien';
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref, AppNotification n) async {
    if (!n.isRead) {
      // Marquer comme lue puis rafraîchir badge + liste
      await ref.read(notificationServiceProvider).markAsRead(n.id);
      ref.invalidate(unreadCountProvider);
      ref.invalidate(notificationsProvider);
    }
    final link = n.deepLink;
    if (link != null && link.isNotEmpty && context.mounted) {
      context.push(link);
    }
  }

  Future<void> _markAll(WidgetRef ref) async {
    await ref.read(notificationServiceProvider).markAllAsRead();
    ref.invalidate(unreadCountProvider);
    ref.invalidate(notificationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text('Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => _markAll(ref),
            child: const Text('Tout lire', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
          await ref.read(notificationsProvider.future);
        },
        child: pageAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade600))),
            ],
          ),
          data: (page) {
            if (page.items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 140),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Aucune notification', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Construire la liste avec des séparateurs par jour.
            final widgets = <Widget>[];
            String? currentLabel;
            for (final n in page.items) {
              final label = _dayLabel(n.createdAt);
              if (label != currentLabel) {
                currentLabel = label;
                widgets.add(Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Text(label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
                ));
              }
              widgets.add(_NotificationTile(notification: n, timeAgo: _timeAgo(n.createdAt), onTap: () => _onTap(context, ref, n)));
              widgets.add(const SizedBox(height: 10));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: widgets,
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.timeAgo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final fam = n.family;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
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
                decoration: BoxDecoration(color: fam.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(fam.icon, color: fam.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              style: TextStyle(fontSize: 14, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary)),
                        ),
                        if (!n.isRead)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
