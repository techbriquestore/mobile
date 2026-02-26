import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Pas de connexion internet. VÃ©rifiez votre rÃ©seau.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Erreur de cache local.'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

class PaymentFailure extends Failure {
  final String? transactionId;
  const PaymentFailure({required super.message, this.transactionId});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'La requÃªte a pris trop de temps. RÃ©essayez.',
  });
}
