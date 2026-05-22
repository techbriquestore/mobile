import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/secure_token_storage.dart';
import '../services/auth_service.dart';

// Keys for SharedPreferences
const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kUserId = 'user_id';
const _kProfileComplete = 'profile_complete';

// Secure Token Storage Provider
final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  final storage = SecureTokenStorage();
  // Initialize synchronously for provider
  storage.init();
  return storage;
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
});

// Auth State
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;
  final bool isProfileComplete;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
    this.isProfileComplete = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
    bool? isProfileComplete,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _initializeAuth();
    return const AuthState(status: AuthStatus.initial);
  }

  AuthService get _authService => ref.read(authServiceProvider);
  ApiClient get _apiClient => ref.read(apiClientProvider);
  SecureTokenStorage get _secureStorage => ref.read(secureTokenStorageProvider);

  Future<void> _initializeAuth() async {
    try {
      final accessToken = await _secureStorage.read(key: _kAccessToken);
      final refreshToken = await _secureStorage.read(key: _kRefreshToken);
      final profileComplete = await _secureStorage.readBool(key: _kProfileComplete) ?? false;
      print('[AUTH] _initializeAuth: accessToken=${accessToken != null ? "SET(${accessToken.substring(0, 10)}...)" : "NULL"}, refreshToken=${refreshToken != null ? "SET" : "NULL"}, profileComplete=$profileComplete');

      if (accessToken != null && refreshToken != null) {
        _apiClient.setTokens(access: accessToken, refresh: refreshToken);

        try {
          // Timeout de 10 secondes (Render free tier peut être lent)
          final user = await _authService.getCurrentUser().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );
          print('[AUTH] _initializeAuth: getCurrentUser OK -> user.id=${user.id}, user.firstName=${user.firstName}, user.isProfileComplete=${user.isProfileComplete}');
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isProfileComplete: profileComplete || user.isProfileComplete,
          );
          print('[AUTH] _initializeAuth: state -> authenticated, isProfileComplete=${state.isProfileComplete}');
        } catch (e) {
          print('[AUTH] _initializeAuth: getCurrentUser FAILED -> $e');
          if (profileComplete) {
            // Profil complet → garder authentifié, le refresh token gérera la suite
            print('[AUTH] _initializeAuth: profileComplete=true, garder authentifié');
            state = AuthState(
              status: AuthStatus.authenticated,
              accessToken: accessToken,
              refreshToken: refreshToken,
              isProfileComplete: true,
            );
          } else {
            print('[AUTH] _initializeAuth: profileComplete=false ET backend injoignable -> unauthenticated');
            // Profil incomplet ET backend injoignable → impossible de continuer
            // Forcer le redémarrage du flux d'authentification
            _apiClient.clearTokens();
            await _clearTokens();
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
        }
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final result = await _authService.login(
        identifier: identifier,
        password: password,
      );

      _apiClient.setTokens(access: result.accessToken, refresh: result.refreshToken);
      await _saveTokens(result.accessToken, result.refreshToken);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> register({
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
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final result = await _authService.register(
        phone: phone,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        clientType: clientType,
        companyName: companyName,
        taxId: taxId,
        sector: sector,
      );

      _apiClient.setTokens(access: result.accessToken, refresh: result.refreshToken);
      await _saveTokens(result.accessToken, result.refreshToken);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> googleAuth({required String idToken}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final result = await _authService.googleAuth(idToken: idToken);

      _apiClient.setTokens(access: result.accessToken, refresh: result.refreshToken);
      await _saveTokens(result.accessToken, result.refreshToken);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final result = await _authService.signInWithGoogle();
      
      if (result == null) {
        // User cancelled
        state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true);
        return false;
      }

      _apiClient.setTokens(access: result.accessToken, refresh: result.refreshToken);
      await _saveTokens(result.accessToken, result.refreshToken);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    _apiClient.clearTokens();
    await _clearTokens();
    await _authService.signOutGoogle();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      await _authService.forgotPassword(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractErrorMessage(e));
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _authService.resetPassword(token: token, newPassword: newPassword);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractErrorMessage(e));
      return false;
    }
  }

  Future<bool> resendVerification({required String email}) async {
    try {
      await _authService.resendVerification(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractErrorMessage(e));
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTIFICATION OTP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demande un code OTP pour le numéro de téléphone
  Future<Map<String, dynamic>> requestOtp(String phone, {String channel = 'SMS'}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      print('[AUTH] requestOtp: phone=$phone, channel=$channel');
      print('[AUTH] requestOtp: baseUrl=${_apiClient.baseUrl}');
      final response = await _apiClient.post(
        '/auth/request-otp',
        data: {'phone': phone, 'channel': channel},
      );
      print('[AUTH] requestOtp: response=${response.data}');
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('[AUTH] requestOtp: ERROR -> $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Vérifie le code OTP et authentifie l'utilisateur
  Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String code, {
    String? deviceName,
    String? deviceOs,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _apiClient.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'code': code,
          if (deviceName != null) 'deviceName': deviceName,
          if (deviceOs != null) 'deviceOs': deviceOs,
        },
      );

      final data = response.data as Map<String, dynamic>;
      print('[AUTH] verifyOtp: response data keys=${data.keys.toList()}');
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final profileComplete = data['profileComplete'] as bool? ?? false;
      print('[AUTH] verifyOtp: profileComplete=$profileComplete, isNewUser=${data['isNewUser']}');
      print('[AUTH] verifyOtp: accessToken=${accessToken.substring(0, 20)}...');

      _apiClient.setTokens(access: accessToken, refresh: refreshToken);
      await _saveTokens(accessToken, refreshToken, profileComplete);

      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: accessToken,
        refreshToken: refreshToken,
        isProfileComplete: profileComplete,
      );
      print('[AUTH] verifyOtp: state -> authenticated, isProfileComplete=${state.isProfileComplete}');

      return data;
    } catch (e) {
      print('[AUTH] verifyOtp: ERROR -> $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Complète le profil utilisateur
  Future<Map<String, dynamic>> completeProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? clientType,
    String? companyName,
    String? sector,
    String? taxId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    // S'assurer que le token est défini dans l'apiClient
    print('[AUTH] completeProfile: apiClient.accessToken=${_apiClient.accessToken != null ? "SET" : "NULL"}, state.accessToken=${state.accessToken != null ? "SET" : "NULL"}');
    if (_apiClient.accessToken == null && state.accessToken != null) {
      print('[AUTH] completeProfile: restauration du token depuis state');
      _apiClient.setTokens(access: state.accessToken, refresh: state.refreshToken);
    }

    try {
      print('[AUTH] completeProfile: envoi PATCH /auth/complete-profile avec firstName=$firstName, lastName=$lastName, clientType=$clientType');
      final response = await _apiClient.patch(
        '/auth/complete-profile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          if (email != null) 'email': email,
          if (clientType != null) 'clientType': clientType,
          if (companyName != null) 'companyName': companyName,
          if (sector != null) 'sector': sector,
          if (taxId != null) 'taxId': taxId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      print('[AUTH] completeProfile: response data=$data');
      final accessToken = data['accessToken'] as String;

      // Parser l'objet user retourné par le backend
      User? updatedUser;
      if (data['user'] != null) {
        updatedUser = User.fromJson(data['user'] as Map<String, dynamic>);
      }

      // Mettre à jour le token et le statut
      _apiClient.setTokens(access: accessToken, refresh: state.refreshToken);
      
      // Sauvegarder avec _secureStorage (cohérent avec _initializeAuth)
      await _secureStorage.write(key: _kAccessToken, value: accessToken);
      await _secureStorage.writeBool(key: _kProfileComplete, value: true);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: updatedUser,
        accessToken: accessToken,
        refreshToken: state.refreshToken,
        isProfileComplete: true,
      );

      return data;
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      // Si le token est invalide (401), redémarrer le flux d'authentification
      if (errorMsg.contains('non authentifié') || errorMsg.contains('Unauthorized') || e is UnauthorizedException) {
        _apiClient.clearTokens();
        await _clearTokens();
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: errorMsg,
        );
      }
      rethrow;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken, [bool profileComplete = false]) async {
    await _secureStorage.write(key: _kAccessToken, value: accessToken);
    // Refresh token TOUJOURS dans le stockage sécurisé
    await _secureStorage.write(key: _kRefreshToken, value: refreshToken);
    await _secureStorage.writeBool(key: _kProfileComplete, value: profileComplete);
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _kAccessToken);
    await _secureStorage.delete(key: _kRefreshToken);
    await _secureStorage.delete(key: _kUserId);
    await _secureStorage.delete(key: _kProfileComplete);
  }

  String _extractErrorMessage(dynamic error) {
    // Handle our custom exceptions directly
    if (error is ServerException) {
      return error.message;
    }
    if (error is NetworkException) {
      return error.message;
    }
    if (error is UnauthorizedException) {
      return error.message;
    }
    if (error is Exception) {
      final str = error.toString();
      return str.replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'Erreur inconnue';
  }
}

// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
