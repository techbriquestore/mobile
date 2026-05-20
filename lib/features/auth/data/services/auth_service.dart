import 'package:google_sign_in/google_sign_in.dart';
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
/// - Authentification Google
/// - Rafraîchissement des tokens
/// - Récupération de mot de passe
class AuthService {
  final ApiClient _apiClient;
  late final GoogleSignIn _googleSignIn;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
  }

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

  Future<AuthResult?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Get the ID token
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Impossible d\'obtenir le token Google');
      }

      // Send ID token to backend
      final response = await _apiClient.post(
        ApiConstants.googleAuth,
        data: {'idToken': idToken},
      );
      
      return AuthResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Sign out on error to reset state
      try { await _googleSignIn.signOut(); } catch (_) {}
      
      // Check if it's a configuration issue (no google-services.json, etc.)
      final msg = e.toString().toLowerCase();
      if (msg.contains('apiexception') || 
          msg.contains('sign_in_failed') || 
          msg.contains('developer_error') ||
          msg.contains('network_error') ||
          msg.contains('platformexception')) {
        throw Exception('La connexion Google n\'est pas disponible pour le moment. Utilisez l\'inscription par email.');
      }
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
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
