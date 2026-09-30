# Skill: Controller Reactive (BaseController + Obx)

Pattern utama untuk controller yang menggunakan reactive state `.obs` dan `Obx` di UI.

---

## Kapan Digunakan

Gunakan `BaseController` ketika:
- State sering berubah dan harus auto-update UI secara granular
- Cocok untuk loading, list data, form field yang perlu reaktif
- Default pilihan untuk hampir semua screen

---

## BaseController API

```dart
// lib/presentation/core/base_controller.dart
abstract class BaseController extends GetxController {
  // State bawaan
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Helper untuk memanggil UseCase
  Future<void> callUseCase<T>(
    Future<Either<Failure, T>> call, {
    required Function(T) onSuccess,
    Function(Failure)? onFailure,  // opsional — default: SnackbarHelper.showError()
    bool showLoading = true,        // opsional — default: true
  });
}
```

---

## Template Controller

```dart
// lib/presentation/product/controllers/product.controller.dart
import 'package:get/get.dart';
import '../../../domain/core/usecases/usecase.dart';
import '../../../domain/product/entities/product_entity.dart';
import '../../../domain/product/usecases/get_products_usecase.dart';
import '../../../domain/product/usecases/create_product_usecase.dart';
import '../../core/base_controller.dart';

class ProductController extends BaseController {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;

  ProductController({
    required this.getProductsUseCase,
    required this.createProductUseCase,
  });

  // === State (semua .obs) ===
  final products = <ProductEntity>[].obs;
  final selectedProduct = Rxn<ProductEntity>(); // nullable observable
  final searchQuery = ''.obs;
  final isCreating = false.obs;

  // === Lifecycle ===
  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Debounce search (reaktif terhadap perubahan searchQuery)
    debounce(
      searchQuery,
      (_) => fetchProducts(),
      time: const Duration(milliseconds: 500),
    );
  }

  // === Actions ===
  Future<void> fetchProducts() async {
    await callUseCase(
      getProductsUseCase.execute(NoParams()),
      onSuccess: (data) => products.assignAll(data),
      // showLoading: false,  // opsional: nonaktifkan loading global
    );
  }

  Future<void> createProduct({required String name, required double price}) async {
    await callUseCase(
      createProductUseCase.execute(CreateProductParams(name: name, price: price)),
      onSuccess: (newProduct) {
        products.add(newProduct);
        Get.back(); // tutup dialog/form
      },
      onFailure: (failure) {
        // Custom error handling (opsional — default showError snackbar)
        Get.snackbar('Error', failure.message);
      },
    );
  }

  void selectProduct(ProductEntity product) {
    selectedProduct.value = product;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }
}
```

---

## callUseCase — Detail

```dart
// Paling sederhana
await callUseCase(
  useCase.execute(NoParams()),
  onSuccess: (data) => items.assignAll(data),
);

// Dengan custom onFailure
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => ...,
  onFailure: (failure) => DialogHelper.showInfoDialog(failure.message, isSuccess: false),
);

// Tanpa loading indicator (misal background refresh)
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  showLoading: false,
);
```

---

## Contoh Nyata di Codebase

```dart
// lib/presentation/home/controllers/home.controller.dart
class HomeController extends BaseController {
  final GetBannersUseCase getBannersUseCase;
  HomeController({required this.getBannersUseCase});

  final banners = <BannerEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    // Daftarkan callback saat app di-resume
    Get.find<AppLifecycleService>().addOnResumeCallback(_onAppResumed);
  }

  @override
  void onClose() {
    Get.find<AppLifecycleService>().removeOnResumeCallback(_onAppResumed);
    super.onClose();
  }

  void _onAppResumed() => fetchBanners();

  Future<void> fetchBanners() async {
    await callUseCase(
      getBannersUseCase.execute(NoParams()),
      onSuccess: (bannerList) => banners.assignAll(bannerList),
    );
  }
}
```

---

## Pattern Observable Umum

```dart
// List
final items = <ProductEntity>[].obs;
items.assignAll(newList);   // replace all
items.add(item);            // add one
items.removeWhere((e) => e.id == id);  // remove

// Single value
final isLoading = false.obs;  // dari BaseController
isLoading.value = true;

// Nullable
final selected = Rxn<ProductEntity>();  // Rxn untuk nullable
selected.value = product;
selected.value = null;

// String
final searchQuery = ''.obs;
searchQuery.value = 'new query';
```

---

## Checklist

```
[ ] Class extends BaseController
[ ] State menggunakan .obs (Rx types)
[ ] onInit() panggil super.onInit() + fetch awal
[ ] onClose() panggil super.onClose() + cleanup (remove callbacks)
[ ] Setiap action gunakan callUseCase()
[ ] Tidak ada try/catch di controller (sudah di-handle callUseCase)
[ ] Di UI: gunakan Obx(() => ...) untuk reactive widget
```
