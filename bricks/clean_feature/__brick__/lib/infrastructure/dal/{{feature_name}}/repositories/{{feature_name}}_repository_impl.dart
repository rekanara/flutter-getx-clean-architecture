import 'package:dartz/dartz.dart';
import '../../../../domain/core/errors/failures.dart';
import '../../../../domain/{{feature_name}}/entities/{{feature_name}}_entity.dart';
import '../../../../domain/{{feature_name}}/repositories/{{feature_name}}_repository.dart';
import '../models/{{feature_name}}_model.dart';

class {{feature_name.pascalCase()}}RepositoryImpl implements {{feature_name.pascalCase()}}Repository {
  // TODO: Inject ApiService here
  // final {{feature_name.pascalCase()}}ApiService apiService;

  {{feature_name.pascalCase()}}RepositoryImpl();

  @override
  Future<Either<Failure, {{feature_name.pascalCase()}}Entity>> get{{feature_name.pascalCase()}}() async {
    try {
      // final response = await apiService.get{{feature_name.pascalCase()}}();
      // return Right(response);
      
      // Dummy response for generation
      return const Right({{feature_name.pascalCase()}}Model(id: 1, name: '{{feature_name.pascalCase()}} Feature'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
