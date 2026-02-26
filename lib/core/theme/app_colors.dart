import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand (du logo)
  static const Color primary = Color(0xFFFF8C00);
  static const Color primaryDark = Color(0xFFE07B00);
  static const Color primaryLight = Color(0xFFFFAD42);
  static const Color secondary = Color(0xFF1A1A1A);

  // Backgrounds
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F8F8);

  // Text
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // Status
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Order statuses
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusValidated = Color(0xFF2196F3);
  static const Color statusFabrication = Color(0xFFFF8C00);
  static const Color statusShipped = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF28A745);
  static const Color statusCancelled = Color(0xFFDC3545);
}
