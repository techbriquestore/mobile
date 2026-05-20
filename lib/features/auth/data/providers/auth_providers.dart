import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../services/auth_service.dart';

// Keys for SharedPreferences
const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kUserId = 'user_id';
const _kProfileComplete = 'profile_complete';

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

  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_kAccessToken);
      final refreshToken = prefs.getString(_kRefreshToken);
      final profileComplete = prefs.getBool(_kProfileComplete) ?? false;

      if (accessToken != null && refreshToken != null) {
        _apiClient.setTokens(access: accessToken, refresh: refreshToken);
        
        try {
          // Timeout de 5 secondes pour éviter le blocage
          final user = await _authService.getCurrentUser().timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isProfileComplete: profileComplete || (user.firstName != null && user.lastName != null),
          );
        } catch (_) {
          // Token expiré mais on a un refresh token → garder authentifié
          // Le routeur redirigera vers complete-profile si nécessaire
          state = AuthState(
            status: AuthStatus.authenticated,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isProfileComplete: profileComplete,
          );
        }
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      // En cas d'erreur, on considère l'utilisateur comme non authentifié
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
      final response = await _apiClient.post(
        '/auth/request-otp',
        data: {'phone': phone, 'channel': channel},
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return response.data as Map<String, dynamic>;
    } catch (e) {
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
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final profileComplete = data['profileComplete'] as bool? ?? false;

      _apiClient.setTokens(access: accessToken, refresh: refreshToken);
      await _saveTokens(accessToken, refreshToken, profileComplete);

      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: accessToken,
        refreshToken: refreshToken,
        isProfileComplete: profileComplete,
      );

      return data;
    } catch (e) {
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

    try {
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
      final accessToken = data['accessToken'] as String;

      // Mettre à jour le token et le statut
      _apiClient.setTokens(access: accessToken, refresh: state.refreshToken);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccessToken, accessToken);
      await prefs.setBool(_kProfileComplete, true);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: accessToken,
        isProfileComplete: true,
      );

      return data;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: _extractErrorMessage(e),
      );
      rethrow;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken, [bool profileComplete = false]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setString(_kRefreshToken, refreshToken);
    await prefs.setBool(_kProfileComplete, profileComplete);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kProfileComplete);
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
