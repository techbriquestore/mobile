import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class User {
  final String id;
  final String? phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String clientType;
  final String? companyName;
  final String? taxId;
  final String? sector;
  final String? profilePhotoUrl;
  final String role;
  final String status;
  final bool emailVerified;
  final String authProvider;
  final DateTime createdAt;

  User({
    required this.id,
    this.phone,
    this.email,
    required this.firstName,
    required this.lastName,
    this.clientType = 'PARTICULIER',
    this.companyName,
    this.taxId,
    this.sector,
    this.profilePhotoUrl,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.authProvider,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      clientType: json['clientType'] as String? ?? 'PARTICULIER',
      companyName: json['companyName'] as String?,
      taxId: json['taxId'] as String?,
      sector: json['sector'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      role: json['role'] as String? ?? 'CLIENT',
      status: json['status'] as String? ?? 'ACTIVE',
      emailVerified: json['emailVerified'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'LOCAL',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get isActive => status == 'ACTIVE';
  bool get isProfessional => clientType == 'PROFESSIONNEL';
}

class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String? message;
  final bool? isNewUser;
  final bool? needsPhoneCompletion;

  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.message,
    this.isNewUser,
    this.needsPhoneCompletion,
  });

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
}

class TokenPair {
  final String accessToken;
  final String refreshToken;

  TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

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
      await _googleSignIn.signOut();
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
