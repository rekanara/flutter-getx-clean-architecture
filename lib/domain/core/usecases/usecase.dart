import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Base class for all UseCases.
///
/// [T] = Return type on success
/// [Params] = Parameters required by UseCase
///
/// Use [NoParams] if UseCase requires no parameters.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> execute(Params params);
}

/// Used when UseCase requires no parameters.
class NoParams {}
