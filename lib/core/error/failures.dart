import 'package:equatable/equatable.dart';

/// Base type for everything that can go wrong in the domain layer.
///
/// Failures carry a user-facing [message] only — never raw exception details.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Não foi possível completar a operação.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar os dados locais.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Registro não encontrado.']);
}
