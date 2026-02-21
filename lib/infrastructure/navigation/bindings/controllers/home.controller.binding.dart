import 'package:get/get.dart';

import '../../../../domain/home/repositories/home_repository.dart';
import '../../../../domain/home/usecases/get_banners_usecase.dart';
import '../../../../infrastructure/dal/home/repositories/home_repository_impl.dart';
import '../../../../infrastructure/dal/services/home_api_service.dart';
import '../../../../presentation/home/controllers/home.controller.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeApiService>(() => HomeApiService());
    Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(apiService: Get.find()),
    );
    Get.lazyPut<GetBannersUseCase>(() => GetBannersUseCase(Get.find()));

    Get.lazyPut<HomeController>(
      () => HomeController(getBannersUseCase: Get.find()),
    );
  }
}
