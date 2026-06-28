import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/models/app_notification.dart';
import '../services/notification_service.dart';

// ─── Service ──────────────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ServiceLocator.apiClient);
});

// ─── Liste (première page) ─────────────────────────────────────────────────--

final notificationsProvider =
    FutureProvider.autoDispose<NotificationsPage>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getNotifications(page: 1, pageSize: 30);
});

// ─── Compteur non lus (badge) ───────────────────────────────────────────────--

/// Compteur de non-lues pour le badge. Rafraîchi via invalidation
/// (ex: à l'arrivée d'un push transactionnel ou après lecture).
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getUnreadCount();
});

// ─── Préférences ────────────────────────────────────────────────────────────--

final notificationPreferencesProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getPreferences();
});
