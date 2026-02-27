import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class untuk semua UseCase.
///
/// [T] = Return type on success
/// [Params] = Parameter yang dibutuhkan UseCase
///
/// Gunakan [NoParams] jika UseCase tidak membutuhkan parameter.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> execute(Params params);
}

/// Digunakan ketika UseCase tidak membutuhkan parameter.
class NoParams {}
