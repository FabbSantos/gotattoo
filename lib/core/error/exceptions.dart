/// Exceptions thrown by the data layer (datasources).
///
/// They are caught by the repositories and mapped to [Failure]s, so the
/// domain and presentation layers never deal with raw exceptions.
library;

class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Ocorreu um erro inesperado.']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Erro ao acessar o cache local.']);

  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Registro não encontrado.']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Raised by the auth layer on sign-up/login problems (duplicate e-mail, bad
/// credentials). Carries a user-facing [message].
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
