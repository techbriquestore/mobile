class StorageKeys {
  StorageKeys._();

  // Secure storage (tokens)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String biometricEnabled = 'biometric_enabled';

  // Hive boxes
  static const String cartBox = 'cart_box';
  static const String catalogCacheBox = 'catalog_cache_box';
  static const String addressesBox = 'addresses_box';
  static const String userBox = 'user_box';
  static const String searchHistoryBox = 'search_history_box';

  // Preferences
  static const String isFirstLaunch = 'is_first_launch';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fcmToken = 'fcm_token';
  static const String preferredLocale = 'preferred_locale';
}
