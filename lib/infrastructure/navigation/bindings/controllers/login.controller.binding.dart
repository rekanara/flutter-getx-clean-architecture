import 'package:get/get.dart';

import '../../../../domain/auth/repositories/auth_repository.dart';
import '../../../../domain/auth/usecases/login_usecase.dart';
import '../../../../infrastructure/dal/auth/repositories/auth_repository_impl.dart';
import '../../../../infrastructure/dal/services/auth_api_service.dart';
import '../../../../infrastructure/platform/storage/get_storage_impl.dart';
import '../../../../presentation/login/controllers/login.controller.dart';

class LoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(() => AuthApiService());
    Get.lazyPut<GetStorageImpl>(() => GetStorageImpl());
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(apiService: Get.find(), storage: Get.find()),
    );
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find()));

    Get.lazyPut<LoginController>(
      () => LoginController(loginUseCase: Get.find()),
    );
  }
}
