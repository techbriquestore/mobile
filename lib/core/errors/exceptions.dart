class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  const ServerException({required this.message, this.statusCode, this.data});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Pas de connexion internet.'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Erreur de cache.'});
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Session expirÃ©e. Reconnectez-vous.'});
}
