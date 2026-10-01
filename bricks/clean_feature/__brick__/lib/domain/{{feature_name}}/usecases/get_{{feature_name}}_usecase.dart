import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/{{feature_name}}_entity.dart';
import '../repositories/{{feature_name}}_repository.dart';

class Get{{feature_name.pascalCase()}}UseCase extends UseCase<{{feature_name.pascalCase()}}Entity, NoParams> {
  final {{feature_name.pascalCase()}}Repository repository;

  Get{{feature_name.pascalCase()}}UseCase(this.repository);

  @override
  Future<Either<Failure, {{feature_name.pascalCase()}}Entity>> execute(NoParams params) async {
    return await repository.get{{feature_name.pascalCase()}}();
  }
}
