class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  const ServerException({required this.message, this.statusCode, this.data});
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Pas de connexion internet.'});
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Erreur de cache.'});
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Session expirée. Reconnectez-vous.'});
  @override
  String toString() => message;
}
