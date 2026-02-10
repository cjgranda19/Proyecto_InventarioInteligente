// Failure base class
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de caché']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Error de conexión']) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Error de autenticación']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Error de validación']) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permiso denegado']) : super(message);
}
