import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'connectivity_service.dart';

class ApiClient {
  late final Dio _dio;
  final ConnectivityService _connectivityService;
  String? _accessToken;
  String? _refreshToken;

  ApiClient({
    required ConnectivityService connectivityService,
  })  : _connectivityService = connectivityService {
    // Web → localhost, Android émulateur → 10.0.2.2, Appareil physique → IP WiFi
    final String baseUrl;
    if (kIsWeb) {
      baseUrl = ApiConstants.devUrl;
    } else if (Platform.isAndroid) {
      // En debug (émulateur), utiliser 10.0.2.2 ; en release (APK physique), IP WiFi
      baseUrl = kDebugMode ? ApiConstants.emulatorUrl : ApiConstants.baseUrl;
    } else {
      baseUrl = ApiConstants.baseUrl;
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'fr',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(apiClient: this, dio: _dio),
      _ConnectivityInterceptor(connectivityService: _connectivityService),
      _ErrorInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    ]);
  }

  void setTokens({String? access, String? refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path, {dynamic data}) =>
      _dio.delete(path, data: data);

  Future<Response> upload(String path, {required FormData data}) =>
      _dio.post(path, data: data,
        options: Options(sendTimeout: ApiConstants.uploadTimeout),
      );
}

class _AuthInterceptor extends Interceptor {
  final ApiClient _apiClient;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor({required ApiClient apiClient, required Dio dio})
      : _apiClient = apiClient, _dio = dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = _apiClient.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = _apiClient.refreshToken;
        if (refreshToken != null) {
          final response = await Dio().post(
            '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
            data: {'refreshToken': refreshToken},
          );
          final newAccess = response.data['accessToken'] as String;
          final newRefresh = response.data['refreshToken'] as String;
          _apiClient.setTokens(access: newAccess, refresh: newRefresh);

          err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retryResponse = await _dio.fetch(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        _apiClient.clearTokens();
      }
      _isRefreshing = false;
    }
    handler.next(err);
  }
}

class _ConnectivityInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;
  _ConnectivityInterceptor({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip connectivity check on web (connectivity_plus doesn't work reliably)
    if (kIsWeb) {
      handler.next(options);
      return;
    }
    if (!await _connectivityService.isConnected) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: const NetworkException(),
      ));
      return;
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final url = err.requestOptions.uri.toString();
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ServerException(message: 'Délai dépassé. Réessayez. ($url)', statusCode: 408);
      case DioExceptionType.connectionError:
        if (err.error is NetworkException) throw err.error as NetworkException;
        throw ServerException(
          message: 'Connexion impossible au serveur ($url). Vérifiez que le serveur est démarré et que vous êtes sur le même réseau WiFi.',
          statusCode: 0,
        );
      case DioExceptionType.unknown:
        final detail = err.error?.toString() ?? err.message ?? 'inconnue';
        throw ServerException(
          message: 'Erreur réseau: $detail ($url)',
          statusCode: 0,
        );
      default:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final message = data is Map ? (data['message'] ?? 'Erreur serveur') : 'Erreur serveur';
        throw ServerException(message: message.toString(), statusCode: statusCode, data: data);
    }
  }
}
