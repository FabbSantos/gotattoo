import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
  
  // The  UseCase  class is an abstract class that has a method  call  which returns a  Future  of  Either  type. The  Either  type is a class from the  dartz  package that is used to represent the result of a computation that can either be a success or a failure. 