---
name: Controller Pagination
description: Specialized controller for infinite scroll and pagination using BasePaginationController
---
# Skill: Controller Pagination (BasePaginationController)

Specialized controller for infinite scroll / load more. Extends `BasePaginationController<T>`.

---

## BasePaginationController API

```dart
// lib/presentation/core/base_pagination_controller.dart
abstract class BasePaginationController<T> extends BaseController {
  // Built-in state
  final items = <T>[].obs;          // all items that have been loaded
  final isLoadMore = false.obs;      // true when loading the next page

  int currentPage = 1;
  int lastPage = 1;
  int limit = 10;                    // can be overridden
  late ScrollController scrollController;  // attach to ListView

  // Must be overridden
  Future<void> fetchPage(int page);

  // Call in onSuccess to append data
  void appendData({
    required List<T> newItems,
    required int lastPage,
  });

  // Reset to page 1 and refetch
  Future<void> refreshData();

  // Getters
  bool get isEmpty => items.isEmpty && !isLoading.value;
  bool get hasReachedMax => currentPage >= lastPage;
}
```

---

## Complete Template

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

  // Additional state (optional)
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPage(1); // Auto fetch on init
  }

  @override
  Future<void> fetchPage(int page) async {
    final filter = PaginationFilter(
      page: page,
      limit: limit,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
    );

    await callUseCase(
      // UseCase must return ApiResponse<List<T>> which has meta.lastPage
      getProductsUseCase.execute(GetProductsParams(filter: filter)),
      onSuccess: (response) {
        appendData(
          newItems: response.data ?? [],
          lastPage: response.meta?.lastPage ?? 1,
        );
      },
    );
  }

  // Reset filter + refresh from page 1
  Future<void> applySearch(String query) async {
    searchQuery.value = query;
    await refreshData(); // resets currentPage=1 + fetchPage(1)
  }
}
```

---

## In UI: PaginationListView (Recommended)

Use the integrated `PaginationListView<T>` component:

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
        emptyMessage: 'No products',
        emptyIcon: Icons.inventory_2_outlined,
      ),
    );
  }
}
```

---

## In UI: Manual ListView (if not using PaginationListView)

```dart
Obx(() => ListView.builder(
  controller: controller.scrollController,  // IMPORTANT: attach scrollController
  itemCount: controller.items.length + (controller.isLoadMore.value ? 1 : 0),
  itemBuilder: (context, index) {
    // Bottom loading indicator
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
  onRefresh: controller.refreshData,  // resets to page 1
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

## ApiResponse with PaginationMeta

The Repository must return:
```dart
// ApiResponse<List<T>> already has a meta field
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

In RepositoryImpl:
```dart
final apiResponse = ApiResponse.fromJsonList(
  response.data,
  ProductModel.fromJson,
);
return Right(apiResponse); // return ApiResponse, not just the list
```

---

## Checklist

```
[ ] Class extends BasePaginationController<T>
[ ] Override fetchPage(int page) — call appendData() in onSuccess
[ ] Call fetchPage(1) in onInit()
[ ] In UI: attach controller.scrollController to ListView
[ ] Or use PaginationListView<T> (simpler)
[ ] refreshData() automatically resets to page 1
[ ] UseCase returns ApiResponse with meta.lastPage
```
