import 'package:get/get.dart';

import '../../../domain/core/usecases/usecase.dart';
import '../../../domain/home/entities/banner_entity.dart';
import '../../../domain/home/usecases/get_banners_usecase.dart';
import '../../../presentation/core/base_controller.dart';

class HomeController extends BaseController {
  final GetBannersUseCase getBannersUseCase;

  HomeController({required this.getBannersUseCase});

  final banners = <BannerEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    await callUseCase(
      getBannersUseCase.execute(NoParams()),
      onSuccess: (data) {
        banners.assignAll(data);
      },
    );
  }
}
