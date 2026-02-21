import 'package:get/get.dart';

import '../../../../domain/home/entities/banner_entity.dart';
import '../../../../domain/home/usecases/get_banners_usecase.dart';

class HomeController extends GetxController {
  final GetBannersUseCase getBannersUseCase;

  HomeController({required this.getBannersUseCase});

  final banners = <BannerEntity>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchBanners() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getBannersUseCase.execute();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (data) {
        banners.assignAll(data);
      },
    );

    isLoading.value = false;
  }
}
