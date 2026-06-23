import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Contract for every use case in the domain layer.
///
/// A use case takes [Params] and returns either a [Failure] or a [Type].
/// Use [NoParams] when the use case takes no arguments.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker for use cases that do not need any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Params for use cases that operate on a single entity identified by [id].
class IdParams extends Equatable {
  final String id;

  const IdParams(this.id);

  @override
  List<Object?> get props => [id];
}
