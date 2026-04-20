class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.146:3000/api/v1'; // Appareil physique → IP WiFi du PC
  static const String emulatorUrl = 'http://10.0.2.2:3000/api/v1'; // Émulateur Android → alias localhost
  static const String devUrl = 'http://localhost:3000/api/v1';   // Web / Chrome
  static const String stagingUrl = 'https://staging-api.briques.store/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 60);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String validateResetToken = '/auth/validate-reset-token';
  static const String resetPassword = '/auth/reset-password';
  
  // Users
  static const String me = '/users/me';
  static const String userProfile = '/users/profile';
  static const String userPreferences = '/users/preferences';

  // Products
  static const String products = '/products';
  static const String categories = '/categories';
  static const String productSearch = '/products/search';

  // Cart
  static const String cart = '/cart';

  // Orders
  static const String orders = '/orders';

  // Preorders
  static const String preorders = '/preorders';
  static const String preorderSchedule = '/preorders/schedule';

  // Payments
  static const String payments = '/payments';
  static const String paymentInit = '/payments/init';
  static const String paymentVerify = '/payments/verify';

  // Profile
  static const String profile = '/profile';
  static const String addresses = '/users/addresses';
  static const String preferences = '/profile/preferences';

  // Simulator
  static const String simulate = '/simulator/calculate';

  // Claims
  static const String claims = '/claims';

  // Notifications
  static const String notifications = '/notifications';
  static const String fcmToken = '/notifications/fcm-token';

  static const int defaultPageSize = 20;
}
