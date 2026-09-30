# Skill: Controller Pagination (BasePaginationController)

Controller khusus untuk infinite scroll / load more. Extend `BasePaginationController<T>`.

---

## BasePaginationController API

```dart
// lib/presentation/core/base_pagination_controller.dart
abstract class BasePaginationController<T> extends BaseController {
  // State bawaan
  final items = <T>[].obs;          // semua item yang telah di-load
  final isLoadMore = false.obs;      // true saat sedang load halaman berikutnya

  int currentPage = 1;
  int lastPage = 1;
  int limit = 10;                    // bisa di-override
  late ScrollController scrollController;  // pasang di ListView

  // Harus di-override
  Future<void> fetchPage(int page);

  // Panggil di onSuccess untuk append data
  void appendData({
    required List<T> newItems,
    required int lastPage,
  });

  // Reset ke halaman 1 dan fetch ulang
  Future<void> refreshData();

  // Getter
  bool get isEmpty => items.isEmpty && !isLoading.value;
  bool get hasReachedMax => currentPage >= lastPage;
}
```

---

## Template Lengkap

```dart
// lib/presentation/product/controllers/product_list.controller.dart
import 'package:get/get.dart';
import '../../../domain/core/usecases/usecase.dart';
import '../../../domain/product/entities/product_entity.dart';
import '../../../domain/product/usecases/get_products_usecase.dart';
import '../../../infrastructure/dal/models/pagination_filter.dart';
import '../../core/base_pagination_controller.dart';

class ProductListController extends BasePaginationController<ProductEntity> {
  final GetProductsUseCase getProductsUseCase;

  ProductListController({required this.getProductsUseCase});

  // Tambahan state (opsional)
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPage(1); // Auto fetch saat init
  }

  @override
  Future<void> fetchPage(int page) async {
    final filter = PaginationFilter(
      page: page,
      limit: limit,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
    );

    await callUseCase(
      // UseCase harus return ApiResponse<List<T>> yang punya meta.lastPage
      getProductsUseCase.execute(GetProductsParams(filter: filter)),
      onSuccess: (response) {
        appendData(
          newItems: response.data ?? [],
          lastPage: response.meta?.lastPage ?? 1,
        );
      },
    );
  }

  // Reset filter + refresh dari halaman 1
  Future<void> applySearch(String query) async {
    searchQuery.value = query;
    await refreshData(); // reset currentPage=1 + fetchPage(1)
  }
}
```

---

## Di UI: PaginationListView (Recommended)

Gunakan komponen `PaginationListView<T>` yang sudah terintegrasi:

```dart
// lib/presentation/product/product_list.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/molecules/pagination_list_view.dart';
import 'controllers/product_list.controller.dart';

class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search...'),
            onChanged: controller.applySearch,
          ),
        ),
      ),
      body: PaginationListView<ProductEntity>(
        controller: controller,
        itemBuilder: (context, product, index) {
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Rp ${product.price}'),
          );
        },
        emptyMessage: 'Tidak ada produk',
        emptyIcon: Icons.inventory_2_outlined,
      ),
    );
  }
}
```

---

## Di UI: ListView Manual (jika tidak pakai PaginationListView)

```dart
Obx(() => ListView.builder(
  controller: controller.scrollController,  // PENTING: pasang scrollController
  itemCount: controller.items.length + (controller.isLoadMore.value ? 1 : 0),
  itemBuilder: (context, index) {
    // Loading indicator di bawah
    if (index == controller.items.length) {
      return const Center(child: CircularProgressIndicator());
    }
    final item = controller.items[index];
    return ListTile(title: Text(item.name));
  },
))
```

---

## Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: controller.refreshData,  // reset ke page 1
  child: PaginationListView(...)
)
```

---

## PaginationFilter

```dart
// lib/infrastructure/dal/models/pagination_filter.dart
class PaginationFilter {
  final int page;
  final int limit;
  final String? search;

  const PaginationFilter({
    required this.page,
    this.limit = 10,
    this.search,
  });

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    if (search != null && search!.isNotEmpty) 'search': search,
  };

  PaginationFilter copyWith({int? page, int? limit, String? search}) => PaginationFilter(
    page: page ?? this.page,
    limit: limit ?? this.limit,
    search: search ?? this.search,
  );
}
```

---

## ApiResponse dengan PaginationMeta

Repository harus return:
```dart
// ApiResponse<List<T>> sudah punya field meta
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final PaginationMeta? meta;  // lastPage, currentPage, perPage, total
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
}
```

Di RepositoryImpl:
```dart
final apiResponse = ApiResponse.fromJsonList(
  response.data,
  ProductModel.fromJson,
);
return Right(apiResponse); // return ApiResponse, bukan hanya list
```

---

## Checklist

```
[ ] Class extends BasePaginationController<T>
[ ] Override fetchPage(int page) — panggil appendData() di onSuccess
[ ] Panggil fetchPage(1) di onInit()
[ ] Di UI: pasang controller.scrollController ke ListView
[ ] Atau gunakan PaginationListView<T> (lebih simpel)
[ ] refreshData() otomatis reset ke page 1
[ ] UseCase return ApiResponse dengan meta.lastPage
```
