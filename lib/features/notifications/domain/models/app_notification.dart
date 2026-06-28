import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Famille visuelle d'une notification, déduite du préfixe de son `type`.
enum NotificationFamily {
  order(Icons.inventory_2_outlined, AppColors.info),
  preorder(Icons.calendar_month_outlined, Color(0xFF9C27B0)),
  invoice(Icons.receipt_long_outlined, Color(0xFF00897B)),
  claim(Icons.support_agent_outlined, Color(0xFFEF6C00)),
  auth(Icons.lock_outline, Color(0xFFD32F2F)),
  reward(Icons.card_giftcard_outlined, Color(0xFF43A047)),
  system(Icons.info_outline, Color(0xFF607D8B));

  final IconData icon;
  final Color color;
  const NotificationFamily(this.icon, this.color);

  static NotificationFamily fromType(String type) {
    if (type.startsWith('ORDER_')) return NotificationFamily.order;
    if (type.startsWith('PREORDER_')) return NotificationFamily.preorder;
    if (type.startsWith('INVOICE_')) return NotificationFamily.invoice;
    if (type.startsWith('CLAIM_')) return NotificationFamily.claim;
    if (type.startsWith('AUTH_')) return NotificationFamily.auth;
    if (type.startsWith('REWARD_')) return NotificationFamily.reward;
    return NotificationFamily.system;
  }
}

/// Notification transactionnelle telle que renvoyée par l'API.
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String content;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  NotificationFamily get family => NotificationFamily.fromType(type);

  /// Route de deep-link à ouvrir au tap (fournie par le backend dans metadata).
  String? get deepLink => metadata['deepLink'] as String?;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'SYSTEM',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        content: content,
        metadata: metadata,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

/// Page paginée de notifications.
class NotificationsPage {
  final List<AppNotification> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final int unreadCount;

  const NotificationsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.unreadCount,
  });

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    return NotificationsPage(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
