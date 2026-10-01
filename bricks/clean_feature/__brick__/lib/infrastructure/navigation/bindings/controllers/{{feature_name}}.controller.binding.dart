import 'package:get/get.dart';
import '../../../../domain/{{feature_name}}/repositories/{{feature_name}}_repository.dart';
import '../../../../domain/{{feature_name}}/usecases/get_{{feature_name}}_usecase.dart';
import '../../../../infrastructure/dal/{{feature_name}}/repositories/{{feature_name}}_repository_impl.dart';
import '../../../../presentation/{{feature_name}}/controllers/{{feature_name}}.controller.dart';

class {{feature_name.pascalCase()}}ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<{{feature_name.pascalCase()}}Repository>(
      () => {{feature_name.pascalCase()}}RepositoryImpl(),
    );
    Get.lazyPut<Get{{feature_name.pascalCase()}}UseCase>(
      () => Get{{feature_name.pascalCase()}}UseCase(Get.find()),
    );
    Get.lazyPut<{{feature_name.pascalCase()}}Controller>(
      () => {{feature_name.pascalCase()}}Controller(useCase: Get.find()),
    );
  }
}
