import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/{{feature_name}}_entity.dart';

abstract class {{feature_name.pascalCase()}}Repository {
  Future<Either<Failure, {{feature_name.pascalCase()}}Entity>> get{{feature_name.pascalCase()}}();
}
