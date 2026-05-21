import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/user.dart';
import '../../domain/models/auth_result.dart';

// Ré-exporter les modèles pour la rétrocompatibilité
export '../../domain/models/user.dart';
export '../../domain/models/auth_result.dart';

/// Service d'authentification.
///
/// Gère toutes les opérations d'authentification :
/// - Login (email/téléphone + mot de passe)
/// - Inscription
/// - Authentification Google (désactivé temporairement)
/// - Rafraîchissement des tokens
/// - Récupération de mot de passe
class AuthService {
  final ApiClient _apiClient;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'identifier': identifier,
        'password': password,
      },
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResult> register({
    required String phone,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String clientType = 'PARTICULIER',
    String? companyName,
    String? taxId,
    String? sector,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'phone': phone,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'clientType': clientType,
        if (companyName != null && companyName.isNotEmpty) 'companyName': companyName,
        if (taxId != null && taxId.isNotEmpty) 'taxId': taxId,
        if (sector != null && sector.isNotEmpty) 'sector': sector,
      },
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Google Sign-In désactivé temporairement (incompatible avec chemin Windows)
  /// Pour réactiver : ajouter google_sign_in dans pubspec.yaml
  Future<AuthResult?> signInWithGoogle() async {
    throw Exception('La connexion Google n\'est pas disponible pour le moment. Utilisez l\'authentification par téléphone.');
  }

  Future<void> signOutGoogle() async {
    // Désactivé temporairement
  }

  Future<AuthResult> googleAuth({required String idToken}) async {
    final response = await _apiClient.post(
      ApiConstants.googleAuth,
      data: {'idToken': idToken},
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> verifyEmail({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.verifyEmail,
      queryParams: {'token': token},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resendVerification({required String email}) async {
    final response = await _apiClient.post(
      ApiConstants.resendVerification,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<bool> validateResetToken({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.validateResetToken,
      queryParams: {'token': token},
    );
    return (response.data as Map<String, dynamic>)['valid'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<TokenPair> refreshTokens({required String refreshToken}) async {
    final response = await _apiClient.post(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return TokenPair.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.me);
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
