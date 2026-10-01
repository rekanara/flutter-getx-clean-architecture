---
name: GetX State Management
description: Choosing and using state management (Obx, GetBuilder)
---
# Skill: GetX State Management

Guide to choosing and using the right state management: Obx, GetBuilder, or both.

---

## Three Main Patterns

### 1. Reactive State with Obx (most common)

Use `.obs` in the controller + `Obx(() => ...)` in the UI.

```dart
// Controller
class ProductController extends BaseController {
  final products = <ProductEntity>[].obs;
  final selectedId = ''.obs;
  final isFiltering = false.obs;
}

// UI
Obx(() {
  if (controller.isLoading.value) return const CircularProgressIndicator();
  return ListView.builder(
    itemCount: controller.products.length,
    itemBuilder: (_, i) => ProductTile(product: controller.products[i]),
  );
})
```

### 2. Manual State with GetBuilder

Use plain Dart + `update([ids])` in the controller + `GetBuilder<T>` in the UI.

```dart
// Controller
class SearchController extends BaseBuilderController {
  List<ProductEntity> results = [];
  static const resultId = 'search_result';

  void search(String query) {
    results = products.where((p) => p.name.contains(query)).toList();
    update([resultId]);
  }
}

// UI
GetBuilder<SearchController>(
  id: SearchController.resultId,
  builder: (c) => ListView.builder(
    itemCount: c.results.length,
    itemBuilder: (_, i) => ProductTile(product: c.results[i]),
  ),
)
```

### 3. GetView\<T\> — Accessing Controller in Screen

```dart
class ProductScreen extends GetView<ProductController> {
  // `controller` property is automatically available
  // = Get.find<ProductController>()
}
```

---

## Full Comparison

| | Obx + .obs | GetBuilder + update() |
|---|---|---|
| State type | Rx<T>, RxList, RxBool, etc. | Plain Dart (bool, List, etc.) |
| Trigger UI | Automatic when value changes | Manual `update([ids])` |
| Granularity | Per observable value | Per widget ID |
| Boilerplate | Minimal | Slightly more |
| Performance | Excellent (fine-grained) | Excellent (targeted) |
| Best For | Default, state changes frequently | Filters, search, targeted update |

---

## Full Rx Types

```dart
// Primitives
final isLoading = false.obs;          // RxBool
final count = 0.obs;                  // RxInt
final price = 0.0.obs;                // RxDouble
final name = ''.obs;                  // RxString

// Objects — nullable
final selected = Rxn<ProductEntity>(); // RxnNull (nullable)
final user = Rx<UserEntity?>(null);    // alternative nullable

// Lists
final items = <ProductEntity>[].obs;  // RxList<ProductEntity>
final tags = <String>[].obs;          // RxList<String>

// Sets
final ids = <String>{}.obs;           // RxSet<String>

// Maps
final config = <String, String>{}.obs; // RxMap<String, String>
```

---

## RxList Operations

```dart
final products = <ProductEntity>[].obs;

products.assignAll(newList);          // replace all
products.add(product);                // add one
products.addAll([p1, p2]);            // add multiple
products.remove(product);             // remove by reference
products.removeWhere((e) => e.id == id); // remove by condition
products.clear();                     // empty list
products[0] = updatedProduct;         // update by index

// For reading — use directly like a standard List
products.length;
products.isEmpty;
products.where((e) => e.isActive).toList();
products.first;
products[0];
```

---

## debounce and interval

```dart
class SearchController extends BaseController {
  final query = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Debounce: delay 500ms after the last change
    debounce(query, (_) => doSearch(), time: const Duration(milliseconds: 500));

    // Interval: throttle, called every 1 second even if changing continuously
    // interval(query, (_) => doSearch(), time: const Duration(seconds: 1));
  }

  void onQueryChanged(String value) {
    query.value = value; // debounce will auto-trigger doSearch()
  }

  Future<void> doSearch() async {
    await callUseCase(searchUseCase.execute(query.value), ...);
  }
}
```

---

## ever and once

```dart
@override
void onInit() {
  super.onInit();

  // ever: callback every time the value changes
  ever(isLoading, (loading) {
    if (loading) LoggerHelper.d('Loading started');
  });

  // once: callback ONLY the first time it changes
  once(items, (_) => LoggerHelper.d('First load complete'));
}
```

---

## GetBuilder without ID (update all)

```dart
// Controller: update() without ID — rebuilds all GetBuilder<T>
void refresh() {
  data = fetchNewData();
  update(); // rebuilds ALL GetBuilder<ThisController>
}

// UI
GetBuilder<ThisController>(
  builder: (c) => Text(c.data),
)
```

## GetBuilder with ID (targeted)

```dart
// Controller
update(['header', 'list']); // update two different widgets

// UI
GetBuilder<T>(id: 'header', builder: (c) => HeaderWidget()),
GetBuilder<T>(id: 'list', builder: (c) => ListWidget()),
```

---

## Checklist

```
[ ] Default → BaseController + .obs + Obx
[ ] Targeted update → BaseBuilderController + update([ids]) + GetBuilder
[ ] Do not mix .obs and plain state in the same controller
[ ] Obx: use .value for primitives (isLoading.value, name.value)
[ ] RxList: use assignAll() instead of = [] (no reassign)
[ ] GetView<T> in Screen to access the controller property
[ ] debounce for search/filter with delay
```
