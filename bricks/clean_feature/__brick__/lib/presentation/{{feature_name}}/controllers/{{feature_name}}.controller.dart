import 'package:get/get.dart';
import '../../core/base_controller.dart';
import '../../../domain/core/usecases/usecase.dart';
import '../../../domain/{{feature_name}}/entities/{{feature_name}}_entity.dart';
import '../../../domain/{{feature_name}}/usecases/get_{{feature_name}}_usecase.dart';

class {{feature_name.pascalCase()}}Controller extends BaseController {
  final Get{{feature_name.pascalCase()}}UseCase useCase;

  {{feature_name.pascalCase()}}Controller({required this.useCase});

  final data = Rxn<{{feature_name.pascalCase()}}Entity>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    await callUseCase(
      useCase.execute(NoParams()),
      onSuccess: (result) {
        data.value = result;
      },
    );
  }
}
