---
name: Routing & Navigation
description: Adding routes, registering pages, and navigating with GetX
---
# Skill: Routing & Navigation

Guide to adding new routes, defining pages, and navigating with GetX.

---

## Step 1: Add Route Constant

`lib/infrastructure/navigation/routes.dart`

```dart
class Routes {
  static const home = '/home';
  static const login = '/login';
  static const user = '/user';
  static const product = '/product';          // ← add
  static const productDetail = '/product/detail'; // ← add

  // initialRoute is determined based on auth state
  static Future<String> get initialRoute async {
    // TODO: check auth state
    return login;
  }
}
```

---

## Step 2: Register GetPage in Navigation

`lib/infrastructure/navigation/navigation.dart`

```dart
class Nav {
  static List<GetPage> get routes => [
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: Routes.product,
      page: () => const ProductScreen(),
      binding: ProductControllerBinding(), // ← binding is required
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailScreen(),
      binding: ProductDetailControllerBinding(),
    ),
  ];
}
```

---

## Step 3: Navigating from Controller/Screen

```dart
// Push (add to stack)
Get.toNamed(Routes.product);

// Push with arguments
Get.toNamed(
  Routes.productDetail,
  arguments: {'id': product.id, 'name': product.name},
);

// Replace current screen (stack: A → B becomes A → C)
Get.offNamed(Routes.home);

// Clear all stack and replace (for post-login)
Get.offAllNamed(Routes.home);

// Go back to previous screen
Get.back();

// Go back with a result
Get.back(result: 'deleted');

// Check if can go back
if (Get.isRegistered<MyController>()) {
  Get.back();
}
```

---

## Retrieving Arguments in the Destination Screen

```dart
// In the destination screen
class ProductDetailScreen extends GetView<ProductDetailController> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve passed arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final productId = args?['id'] as String? ?? '';
    
    // The controller can be initialized with this ID
    // (usually the controller retrieves from Get.arguments in onInit)
    return Scaffold(...);
  }
}

// In the controller — retrieve arguments in onInit
class ProductDetailController extends BaseController {
  final GetProductByIdUseCase useCase;
  
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String? ?? '';
    fetchProduct(id);
  }
}
```

---

## Transition Animation

```dart
GetPage(
  name: Routes.product,
  page: () => const ProductScreen(),
  binding: ProductControllerBinding(),
  transition: Transition.rightToLeft,           // GetX default
  transitionDuration: const Duration(milliseconds: 300),
),
```

Transition options: `rightToLeft`, `leftToRight`, `upToDown`, `downToUp`, `fade`, `zoom`, `native`

---

## EnvironmentsBadge (Dev/Staging banner)

Already integrated in `Nav.routes` via the `EnvironmentsBadge` wrapper. It only appears in non-prod environments; no extra configuration needed.

---

## Dialog Navigation

```dart
// Open a standard dialog
DialogHelper.showDialog(
  title: 'Confirmation',
  message: 'Delete this item?',
  onSubmit: () {
    Get.back(); // close dialog
    controller.deleteItem(id);
  },
);

// Close dialog/bottomsheet from controller
Get.back(); // can always be used to pop anything
```

---

## BottomSheet Navigation

```dart
Get.bottomSheet(
  Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: const Text('Option 1'), onTap: () { Get.back(); }),
        ListTile(title: const Text('Option 2'), onTap: () { Get.back(); }),
      ],
    ),
  ),
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
);
```

---

## Checklist

```
[ ] Route constant added in Routes class (routes.dart)
[ ] GetPage added in Nav.routes (navigation.dart) with binding
[ ] Binding class has been created
[ ] Navigation uses Routes.xxx (do not hardcode strings like '/product')
[ ] Arguments use Map<String, dynamic> or typed class
[ ] Controller retrieves arguments in onInit() (not in build())
```
