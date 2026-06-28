import '../../../../core/network/api_client.dart';
import '../../domain/models/app_notification.dart';

/// Accès API au centre de notifications transactionnelles.
class NotificationService {
  final ApiClient _client;

  NotificationService(this._client);

  Future<NotificationsPage> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    final response = await _client.get('/notifications', queryParams: {
      'page': page,
      'pageSize': pageSize,
      if (unreadOnly) 'unreadOnly': true,
    });
    return NotificationsPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.patch('/notifications/read-all');
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _client.get('/notifications/preferences');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> body) async {
    final response = await _client.patch('/notifications/preferences', data: body);
    return response.data as Map<String, dynamic>;
  }
}
