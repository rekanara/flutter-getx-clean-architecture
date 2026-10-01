---
name: Controller Reactive
description: Main pattern for controllers using reactive state (.obs) and Obx
---
# Skill: Controller Reactive (BaseController + Obx)

The main pattern for controllers that use reactive state `.obs` and `Obx` in the UI.

---

## When to Use

Use `BaseController` when:
- State changes frequently and needs granular auto-updating UI
- Suitable for loading, data lists, form fields that need to be reactive
- The default choice for almost all screens

---

## BaseController API

```dart
// lib/presentation/core/base_controller.dart
abstract class BaseController extends GetxController {
  // Built-in state
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Helper for calling UseCases
  Future<void> callUseCase<T>(
    Future<Either<Failure, T>> call, {
    required Function(T) onSuccess,
    Function(Failure)? onFailure,  // optional — default: SnackbarHelper.showError()
    bool showLoading = true,        // optional — default: true
  });
}
```

---

## Controller Template

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

  // === State (all .obs) ===
  final products = <ProductEntity>[].obs;
  final selectedProduct = Rxn<ProductEntity>(); // nullable observable
  final searchQuery = ''.obs;
  final isCreating = false.obs;

  // === Lifecycle ===
  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Debounce search (reactive to changes in searchQuery)
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
      // showLoading: false,  // optional: disable global loading
    );
  }

  Future<void> createProduct({required String name, required double price}) async {
    await callUseCase(
      createProductUseCase.execute(CreateProductParams(name: name, price: price)),
      onSuccess: (newProduct) {
        products.add(newProduct);
        Get.back(); // close dialog/form
      },
      onFailure: (failure) {
        // Custom error handling (optional — default showError snackbar)
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

## callUseCase — Details

```dart
// Simplest
await callUseCase(
  useCase.execute(NoParams()),
  onSuccess: (data) => items.assignAll(data),
);

// With custom onFailure
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => ...,
  onFailure: (failure) => DialogHelper.showInfoDialog(failure.message, isSuccess: false),
);

// Without loading indicator (e.g., background refresh)
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  showLoading: false,
);
```

---

## Real Example in Codebase

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
    // Register callback when app is resumed
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

## Common Observable Patterns

```dart
// List
final items = <ProductEntity>[].obs;
items.assignAll(newList);   // replace all
items.add(item);            // add one
items.removeWhere((e) => e.id == id);  // remove

// Single value
final isLoading = false.obs;  // from BaseController
isLoading.value = true;

// Nullable
final selected = Rxn<ProductEntity>();  // Rxn for nullable
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
[ ] State uses .obs (Rx types)
[ ] onInit() calls super.onInit() + initial fetch
[ ] onClose() calls super.onClose() + cleanup (remove callbacks)
[ ] Every action uses callUseCase()
[ ] No try/catch in the controller (already handled by callUseCase)
[ ] In UI: use Obx(() => ...) for reactive widgets
```
