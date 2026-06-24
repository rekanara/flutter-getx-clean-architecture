# Skill: GetX State Management

Panduan memilih dan menggunakan state management yang tepat: Obx, GetBuilder, atau keduanya.

---

## Tiga Pattern Utama

### 1. Reactive State dengan Obx (paling umum)

Gunakan `.obs` di controller + `Obx(() => ...)` di UI.

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

### 2. Manual State dengan GetBuilder

Gunakan plain Dart + `update([ids])` di controller + `GetBuilder<T>` di UI.

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

### 3. GetView\<T\> — Akses Controller di Screen

```dart
class ProductScreen extends GetView<ProductController> {
  // `controller` property otomatis tersedia
  // = Get.find<ProductController>()
}
```

---

## Perbandingan Lengkap

| | Obx + .obs | GetBuilder + update() |
|---|---|---|
| State type | Rx<T>, RxList, RxBool, dll | Plain Dart (bool, List, dll) |
| Trigger UI | Otomatis saat nilai berubah | Manual `update([ids])` |
| Granularity | Per observable value | Per widget ID |
| Boilerplate | Minimal | Sedikit lebih banyak |
| Performance | Sangat baik (fine-grained) | Sangat baik (targeted) |
| Gunakan | Default, state sering berubah | Filter, search, targeted update |

---

## Rx Types Lengkap

```dart
// Primitif
final isLoading = false.obs;          // RxBool
final count = 0.obs;                  // RxInt
final price = 0.0.obs;                // RxDouble
final name = ''.obs;                  // RxString

// Object — nullable
final selected = Rxn<ProductEntity>(); // RxnNull (nullable)
final user = Rx<UserEntity?>(null);    // alternatif nullable

// List
final items = <ProductEntity>[].obs;  // RxList<ProductEntity>
final tags = <String>[].obs;          // RxList<String>

// Set
final ids = <String>{}.obs;           // RxSet<String>

// Map
final config = <String, String>{}.obs; // RxMap<String, String>
```

---

## Operasi RxList

```dart
final products = <ProductEntity>[].obs;

products.assignAll(newList);          // replace semua
products.add(product);                // tambah satu
products.addAll([p1, p2]);            // tambah banyak
products.remove(product);             // hapus by reference
products.removeWhere((e) => e.id == id); // hapus by condition
products.clear();                     // kosongkan
products[0] = updatedProduct;         // update by index

// Untuk read — gunakan langsung seperti List
products.length;
products.isEmpty;
products.where((e) => e.isActive).toList();
products.first;
products[0];
```

---

## debounce dan interval

```dart
class SearchController extends BaseController {
  final query = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Debounce: delay 500ms setelah terakhir berubah
    debounce(query, (_) => doSearch(), time: const Duration(milliseconds: 500));

    // Interval: throttle, panggil setiap 1 detik meski terus berubah
    // interval(query, (_) => doSearch(), time: const Duration(seconds: 1));
  }

  void onQueryChanged(String value) {
    query.value = value; // debounce auto-trigger doSearch()
  }

  Future<void> doSearch() async {
    await callUseCase(searchUseCase.execute(query.value), ...);
  }
}
```

---

## ever dan once

```dart
@override
void onInit() {
  super.onInit();

  // ever: callback setiap kali nilai berubah
  ever(isLoading, (loading) {
    if (loading) LoggerHelper.d('Loading started');
  });

  // once: callback HANYA saat pertama kali berubah
  once(items, (_) => LoggerHelper.d('First load complete'));
}
```

---

## GetBuilder tanpa ID (update semua)

```dart
// Controller: update() tanpa ID — rebuild semua GetBuilder<T>
void refresh() {
  data = fetchNewData();
  update(); // rebuild SEMUA GetBuilder<ThisController>
}

// UI
GetBuilder<ThisController>(
  builder: (c) => Text(c.data),
)
```

## GetBuilder dengan ID (targeted)

```dart
// Controller
update(['header', 'list']); // update dua widget berbeda

// UI
GetBuilder<T>(id: 'header', builder: (c) => HeaderWidget()),
GetBuilder<T>(id: 'list', builder: (c) => ListWidget()),
```

---

## Checklist

```
[ ] Default → BaseController + .obs + Obx
[ ] Targeted update → BaseBuilderController + update([ids]) + GetBuilder
[ ] Tidak mix .obs dan plain state di controller yang sama
[ ] Obx: gunakan .value untuk primitif (isLoading.value, name.value)
[ ] RxList: gunakan assignAll() bukan = [] (bukan reassign)
[ ] GetView<T> di Screen untuk akses controller property
[ ] debounce untuk search/filter dengan delay
```
