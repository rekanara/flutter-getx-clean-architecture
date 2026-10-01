---
name: Screen (Presentation Layer)
description: Building UI screens reactive to GetX controllers
---
# Skill: Screen (Presentation Layer)

A Screen is the UI layer that displays the state from the Controller. Extend `GetView<T>`.

---

## Screen Rules

1. Always `extends GetView<ControllerType>` — gives access to the `controller` property.
2. Use `Obx(() => ...)` for widgets that are reactive to `.obs` state.
3. Use `GetBuilder<T>(id: ..., builder: ...)` if the controller uses `BaseBuilderController`.
4. Location: `lib/presentation/{feature}/{feature}.screen.dart`
5. Feature-specific widgets go in `lib/presentation/{feature}/widgets/`

---

## Basic Template (BaseController + Obx)

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
        // One Obx for all related state
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('No products available'));
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
      title: 'Add Product',
      message: 'This feature will be available soon',
      onSubmit: () {},
    );
  }
}
```

---

## Template with BaseBuilderController + GetBuilder

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

## Accessing the Controller

```dart
// In GetView<T> — access via `controller` property (auto-injected)
class ProductScreen extends GetView<ProductController> {
  // controller property is automatically available
  // no need for Get.find<ProductController>()
}

// In standard widgets (StatelessWidget/StatefulWidget) that aren't GetView
final controller = Get.find<ProductController>();
```

---

## Pattern: Granular Obx

Split `Obx` into smaller parts so the entire screen doesn't rebuild:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // AppBar is not reactive — no Obx needed
    appBar: AppBar(title: const Text('Products')),

    // Body is reactive to isLoading and products
    body: Obx(() {
      if (controller.isLoading.value) return const CircularProgressIndicator();
      return _buildList();
    }),

    // FAB is only reactive to isCreating
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

## Navigation from Screen

```dart
// Push to a new screen
Get.toNamed(Routes.productDetail, arguments: {'id': product.id});

// Replace current screen
Get.offNamed(Routes.home);

// Clear all stack and go to a new screen
Get.offAllNamed(Routes.login);

// Go back
Get.back();

// Go back with a result
Get.back(result: 'created');

// Retrieve arguments in destination screen
final args = Get.arguments as Map<String, dynamic>;
final id = args['id'] as String;
```

---

## Feature-Specific Widgets

Widgets used only in this screen go in the widgets sub-folder:

```
lib/presentation/product/
├── product.screen.dart
├── controllers/
│   └── product.controller.dart
└── widgets/
    ├── product_card.dart       # reusable only within this feature
    └── create_product_form.dart
```

---

## Checklist

```
[ ] Class extends GetView<ControllerType>
[ ] No state in the Screen (all state is in the Controller)
[ ] Reactive: Obx for BaseController, GetBuilder for BaseBuilderController
[ ] Navigation uses Routes.xxx (no hardcoded strings)
[ ] Complex widgets are split into _build functions or separate files in widgets/
[ ] Import only components from components/ or domain entities (not infrastructure)
```
