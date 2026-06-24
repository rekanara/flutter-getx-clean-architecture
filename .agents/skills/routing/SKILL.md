# Skill: Routing & Navigation

Panduan menambah route baru, mendefinisikan halaman, dan melakukan navigasi dengan GetX.

---

## Step 1: Tambah Route Constant

`lib/infrastructure/navigation/routes.dart`

```dart
class Routes {
  static const home = '/home';
  static const login = '/login';
  static const user = '/user';
  static const product = '/product';          // ← tambahkan
  static const productDetail = '/product/detail'; // ← tambahkan

  // initialRoute ditentukan berdasarkan auth state
  static Future<String> get initialRoute async {
    // TODO: cek auth state
    return login;
  }
}
```

---

## Step 2: Daftarkan GetPage di Navigation

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
      binding: ProductControllerBinding(), // ← binding wajib ada
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

## Step 3: Navigasi dari Controller/Screen

```dart
// Push (tambahkan ke stack)
Get.toNamed(Routes.product);

// Push dengan arguments
Get.toNamed(
  Routes.productDetail,
  arguments: {'id': product.id, 'name': product.name},
);

// Replace screen saat ini (stack: A → B menjadi A → C)
Get.offNamed(Routes.home);

// Clear semua stack dan replace (untuk post-login)
Get.offAllNamed(Routes.home);

// Kembali ke screen sebelumnya
Get.back();

// Kembali dengan hasil
Get.back(result: 'deleted');

// Cek apakah bisa back
if (Get.isRegistered<MyController>()) {
  Get.back();
}
```

---

## Mengambil Arguments di Screen Tujuan

```dart
// Di screen tujuan
class ProductDetailScreen extends GetView<ProductDetailController> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil arguments yang dikirim
    final args = Get.arguments as Map<String, dynamic>?;
    final productId = args?['id'] as String? ?? '';
    
    // Controller dapat diinisialisasi dengan ID ini
    // (biasanya controller mengambil dari Get.arguments di onInit)
    return Scaffold(...);
  }
}

// Di controller — ambil arguments di onInit
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
  transition: Transition.rightToLeft,           // default GetX
  transitionDuration: const Duration(milliseconds: 300),
),
```

Transition options: `rightToLeft`, `leftToRight`, `upToDown`, `downToUp`, `fade`, `zoom`, `native`

---

## EnvironmentsBadge (Banner dev/staging)

Sudah terintegrasi di `Nav.routes` via `EnvironmentsBadge` wrapper. Hanya muncul di non-prod environment, tidak perlu konfigurasi tambahan.

---

## Navigasi Dialog

```dart
// Buka dialog biasa
DialogHelper.showDialog(
  title: 'Konfirmasi',
  message: 'Hapus item ini?',
  onSubmit: () {
    Get.back(); // tutup dialog
    controller.deleteItem(id);
  },
);

// Tutup dialog/bottomsheet dari controller
Get.back(); // selalu bisa digunakan untuk pop apapun
```

---

## Navigasi BottomSheet

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
[ ] Route constant ditambahkan di Routes class (routes.dart)
[ ] GetPage ditambahkan di Nav.routes (navigation.dart) dengan binding
[ ] Binding class sudah dibuat
[ ] Navigasi menggunakan Routes.xxx (tidak hardcode string '/product')
[ ] Arguments menggunakan Map<String, dynamic> atau typed class
[ ] Controller mengambil arguments di onInit() (bukan di build())
```
