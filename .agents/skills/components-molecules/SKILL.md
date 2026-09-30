# Skill: Molecule Components

Komponen level molekul: `CustomCachedImage` dan `PaginationListView<T>`.

---

## CustomCachedImage

`lib/components/molecules/custom_cached_image.dart`

Widget untuk menampilkan gambar dari URL dengan cache, placeholder, dan error handling.

### Props

```dart
CustomCachedImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit,                    // default: BoxFit.cover
  double borderRadius,           // default: 8.0
  Widget? placeholder,           // default: grey container + CircularProgressIndicator
  Widget? errorWidget,           // default: grey container + Icons.broken_image_rounded
  Duration fadeDuration,         // default: Duration(milliseconds: 300)
})
```

### Contoh Penggunaan

```dart
// Gambar produk standar
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: 120,
  height: 120,
),

// Banner full width
CustomCachedImage(
  imageUrl: banner.bannerUrl,
  width: double.infinity,
  height: 180,
  borderRadius: 12,
  fit: BoxFit.fill,
),

// Avatar bulat
ClipOval(
  child: CustomCachedImage(
    imageUrl: user.avatarUrl,
    width: 48,
    height: 48,
    borderRadius: 0, // ClipOval sudah handle shape
  ),
),

// Dengan custom placeholder
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: 200,
  height: 200,
  placeholder: Container(
    color: Colors.grey[100],
    child: const Icon(Icons.image, size: 48, color: Colors.grey),
  ),
),

// Tanpa border radius
CustomCachedImage(
  imageUrl: imageUrl,
  width: double.infinity,
  height: 250,
  borderRadius: 0,
  fit: BoxFit.cover,
),
```

---

## PaginationListView\<T\>

`lib/components/molecules/pagination_list_view.dart`

Widget list yang terintegrasi dengan `BasePaginationController<T>`. Otomatis menangani loading, error, empty state, dan infinite scroll.

### Props

```dart
PaginationListView<T>({
  required BasePaginationController<T> controller,
  required Widget Function(BuildContext, T, int) itemBuilder,
  Widget Function(BuildContext, int)? separatorBuilder,
  String emptyMessage,           // default: 'Data tidak ditemukan'
  IconData emptyIcon,            // default: Icons.inbox_outlined
  Widget? loadingWidget,         // default: CircularProgressIndicator
  Widget? emptyWidget,           // custom empty state widget
  EdgeInsetsGeometry? padding,
  ScrollPhysics? physics,        // default: AlwaysScrollableScrollPhysics
  bool enableRefresh,            // default: true (pull-to-refresh)
})
```

### State yang Ditampilkan Otomatis

| Kondisi | UI |
|---|---|
| isLoading.value == true AND items.isEmpty | Loading indicator fullscreen |
| errorMessage != '' AND items.isEmpty | Error message + retry button |
| items.isEmpty AND !isLoading | Empty state (icon + message) |
| items.isNotEmpty | List + bottom load-more indicator |

### Contoh Penggunaan

```dart
// Minimal
PaginationListView<ProductEntity>(
  controller: controller,
  itemBuilder: (context, product, index) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('Rp ${product.price}'),
    );
  },
),

// Dengan separator
PaginationListView<ProductEntity>(
  controller: controller,
  itemBuilder: (context, product, index) {
    return ProductCard(product: product);
  },
  separatorBuilder: (context, index) => const Divider(),
  emptyMessage: 'Belum ada produk',
  emptyIcon: Icons.inventory_2_outlined,
),

// Custom empty widget
PaginationListView<OrderEntity>(
  controller: controller,
  itemBuilder: (context, order, index) => OrderTile(order: order),
  emptyWidget: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset('assets/empty_orders.png', height: 160),
      const SizedBox(height: 16),
      CustomText(text: 'Belum ada pesanan', fontType: FontType.titleMedium),
      const SizedBox(height: 8),
      CustomButton(
        title: 'Mulai Belanja',
        onPressed: () => Get.toNamed(Routes.product),
        width: 180,
      ),
    ],
  ),
),

// Dengan padding
PaginationListView<NotificationEntity>(
  controller: controller,
  itemBuilder: (context, notif, index) => NotificationTile(notif: notif),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
),

// Tanpa pull-to-refresh
PaginationListView<LogEntity>(
  controller: controller,
  itemBuilder: (context, log, index) => LogTile(log: log),
  enableRefresh: false,
),
```

---

## Dipakai di Screen

```dart
class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: PaginationListView<ProductEntity>(
        controller: controller,        // ProductListController extends BasePaginationController
        itemBuilder: (context, product, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CustomCachedImage(
                imageUrl: product.imageUrl,
                width: 48, height: 48,
              ),
              title: CustomText(
                text: product.name,
                fontType: FontType.titleSmall,
              ),
              subtitle: CustomText(
                text: RupiahHelper().formatCurrencyToRupiah(product.price),
                fontType: FontType.bodySmall,
              ),
              onTap: () => Get.toNamed(Routes.productDetail, arguments: product.id),
            ),
          );
        },
        emptyMessage: 'Belum ada produk tersedia',
        emptyIcon: Icons.inventory_2_outlined,
      ),
    );
  }
}
```

---

## Checklist

```
[ ] Gambar dari URL → CustomCachedImage (bukan Image.network)
[ ] List dengan pagination → PaginationListView<T> + BasePaginationController<T>
[ ] Controller sudah override fetchPage() dan panggil appendData()
[ ] emptyMessage dan emptyIcon dikustomisasi sesuai konteks
[ ] Jika butuh custom empty state gunakan emptyWidget
```
