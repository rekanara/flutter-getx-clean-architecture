# Skill: Screen (Presentation Layer)

Screen adalah UI layer yang menampilkan state dari Controller. Extend `GetView<T>`.

---

## Aturan Screen

1. Selalu `extends GetView<ControllerType>` — memberikan akses `controller` property
2. Gunakan `Obx(() => ...)` untuk widget yang reaktif terhadap `.obs` state
3. Gunakan `GetBuilder<T>(id: ..., builder: ...)` jika controller pakai `BaseBuilderController`
4. Lokasi: `lib/presentation/{feature}/{feature}.screen.dart`
5. Widget spesifik fitur taruh di `lib/presentation/{feature}/widgets/`

---

## Template Dasar (BaseController + Obx)

```dart
// lib/presentation/product/product.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/atoms/custom_text.dart';
import '../../utils/config.dart';
import 'controllers/product.controller.dart';

class ProductScreen extends GetView<ProductController> {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Products',
          fontType: FontType.titleLarge,
        ),
      ),
      body: Obx(() {
        // Satu Obx untuk semua state yang saling terkait
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('Belum ada produk'));
        }
        return _buildProductList();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('Rp ${product.price}'),
          onTap: () => Get.toNamed(Routes.productDetail, arguments: product.id),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    DialogHelper.showDialog(
      title: 'Tambah Produk',
      message: 'Fitur ini akan segera tersedia',
      onSubmit: () {},
    );
  }
}
```

---

## Template dengan BaseBuilderController + GetBuilder

```dart
class UserScreen extends GetView<UserController> {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: controller.onSearch,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<UserController>(
        id: UserController.listId,
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.filteredUsers.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: c.filteredUsers.length,
            itemBuilder: (context, index) {
              final user = c.filteredUsers[index];
              return ListTile(
                title: Text(user['name']!),
                subtitle: Text(user['role']!),
                selected: c.selectedUserIndex == index,
                selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                onTap: () => c.selectUser(index),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## Mengakses Controller

```dart
// Di GetView<T> — akses via `controller` property (auto-inject)
class ProductScreen extends GetView<ProductController> {
  // controller property otomatis tersedia
  // tidak perlu Get.find<ProductController>()
}

// Di widget biasa (StatelessWidget/StatefulWidget) yang bukan GetView
final controller = Get.find<ProductController>();
```

---

## Pattern: Obx Granular

Bagi `Obx` ke bagian yang lebih kecil agar tidak rebuild seluruh screen:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // AppBar tidak reaktif — tidak perlu Obx
    appBar: AppBar(title: const Text('Products')),

    // Body reaktif terhadap isLoading dan products
    body: Obx(() {
      if (controller.isLoading.value) return const CircularProgressIndicator();
      return _buildList();
    }),

    // FAB hanya reaktif terhadap isCreating
    floatingActionButton: Obx(() => FloatingActionButton(
      onPressed: controller.isCreating.value ? null : controller.showCreateForm,
      child: controller.isCreating.value
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.add),
    )),
  );
}
```

---

## Navigation dari Screen

```dart
// Push ke screen baru
Get.toNamed(Routes.productDetail, arguments: {'id': product.id});

// Replace screen saat ini
Get.offNamed(Routes.home);

// Clear semua stack dan ke screen baru
Get.offAllNamed(Routes.login);

// Kembali
Get.back();

// Kembali dengan result
Get.back(result: 'created');

// Ambil arguments di screen tujuan
final args = Get.arguments as Map<String, dynamic>;
final id = args['id'] as String;
```

---

## Widget Spesifik Fitur

Widget yang hanya dipakai di screen ini diletakkan di sub-folder widgets:

```
lib/presentation/product/
├── product.screen.dart
├── controllers/
│   └── product.controller.dart
└── widgets/
    ├── product_card.dart       # reusable dalam fitur ini saja
    └── create_product_form.dart
```

---

## Checklist

```
[ ] Class extends GetView<ControllerType>
[ ] Tidak ada state di Screen (semua state di Controller)
[ ] Reaktif: Obx untuk BaseController, GetBuilder untuk BaseBuilderController
[ ] Navigasi menggunakan Routes.xxx (tidak hardcode string)
[ ] Widget kompleks dipecah ke fungsi _build atau file terpisah di widgets/
[ ] Import hanya komponen dari components/ atau domain entities (bukan infrastructure)
```
