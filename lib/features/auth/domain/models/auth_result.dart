import 'user.dart';

/// Résultat d'une opération d'authentification (login, register, Google auth).
///
/// Contient l'utilisateur authentifié et les tokens JWT.
class AuthResult {
  /// L'utilisateur authentifié.
  final User user;

  /// Token d'accès JWT (courte durée).
  final String accessToken;

  /// Token de rafraîchissement (longue durée).
  final String refreshToken;

  /// Message optionnel du serveur.
  final String? message;

  /// Indique si c'est un nouvel utilisateur (inscription Google).
  final bool? isNewUser;

  /// Indique si l'utilisateur doit compléter son numéro de téléphone.
  final bool? needsPhoneCompletion;

  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.message,
    this.isNewUser,
    this.needsPhoneCompletion,
  });

  /// Crée un [AuthResult] à partir d'une map JSON.
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      message: json['message'] as String?,
      isNewUser: json['isNewUser'] as bool?,
      needsPhoneCompletion: json['needsPhoneCompletion'] as bool?,
    );
  }

  /// Convertit en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (message != null) 'message': message,
      if (isNewUser != null) 'isNewUser': isNewUser,
      if (needsPhoneCompletion != null) 'needsPhoneCompletion': needsPhoneCompletion,
    };
  }

  @override
  String toString() => 'AuthResult(user: ${user.email}, isNewUser: $isNewUser)';
}

/// Paire de tokens JWT.
///
/// Utilisé pour le rafraîchissement des tokens.
class TokenPair {
  /// Token d'accès JWT.
  final String accessToken;

  /// Token de rafraîchissement.
  final String refreshToken;

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Crée un [TokenPair] à partir d'une map JSON.
  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  /// Convertit en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
