class AppConstants {
  AppConstants._();

  static const String appName = 'BRIQUES.STORE';
  static const String appTagline = 'Vos briques, livrÃ©es.';
  static const String currency = 'FCFA';

  // Validation
  static const int otpLength = 6;
  static const int otpValidityMinutes = 5;
  static const int otpResendCooldownSeconds = 60;
  static const int pinLength = 4;
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 10;
  static const List<String> validPhonePrefixes = ['07', '05', '01'];

  // Cart
  static const int maxCartItems = 50;
  static const int cartPersistenceDaysVisitor = 7;

  // Preorders
  static const double minPreorderDepositPercent = 0.15;
  static const int maxPreorderMonths = 12;
  static const List<int> paymentDurations = [3, 6, 9, 12];
  static const int gracePeriodDays = 5;
  static const double latePenaltyPercent = 0.05;

  // Delivery
  static const int standardDeliveryMinDays = 3;
  static const int standardDeliveryMaxDays = 5;

  // Simulator
  static const double defaultWasteMarginPercent = 0.10;
  static const double maxLinearMeters = 1000;
  static const double maxWallHeight = 10;

  // Session
  static const int sessionTimeoutMinutes = 30;

  // Cache
  static const int catalogCacheHours = 24;
  static const int maxSearchHistoryItems = 20;

  // Support
  static const String whatsappNumber = '+2250700000000';
  static const String phoneNumber = '+2250700000000';
  static const String supportEmail = 'support@briques.store';
}
