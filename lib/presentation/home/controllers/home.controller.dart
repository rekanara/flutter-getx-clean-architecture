import 'package:get/get.dart';

import '../../../config/lifecycle/app_lifecycle_service.dart';
import '../../../domain/core/usecases/usecase.dart';
import '../../../domain/home/entities/banner_entity.dart';
import '../../../domain/home/usecases/get_banners_usecase.dart';
import '../../../presentation/core/base_controller.dart';
import '../../../utils/helper/logger.dart';

class HomeController extends BaseController {
  final GetBannersUseCase getBannersUseCase;

  HomeController({required this.getBannersUseCase});

  final banners = <BannerEntity>[].obs;

  AppLifecycleService? _lifecycleService;

  @override
  void onInit() {
    super.onInit();

    // Fetch data terlebih dahulu
    fetchBanners();

    // Daftarkan callback refresh saat app kembali dari background
    try {
      _lifecycleService = Get.find<AppLifecycleService>();
      _lifecycleService?.addOnResumeCallback(_onAppResumed);
    } catch (_) {
      // AppLifecycleService belum di-register — skip
    }
  }

  @override
  void onClose() {
    // Hapus callback saat controller di-dispose
    _lifecycleService?.removeOnResumeCallback(_onAppResumed);
    super.onClose();
  }

  /// Dipanggil otomatis saat app kembali ke foreground.
  void _onAppResumed() {
    LoggerHelper.d('HomeController: App resumed — refreshing banners');
    fetchBanners();
  }

  /// Fetch banners dari API.
  Future<void> fetchBanners() async {
    await callUseCase(
      getBannersUseCase.execute(NoParams()),
      onSuccess: (data) {
        banners.assignAll(data);
      },
    );
  }
}
