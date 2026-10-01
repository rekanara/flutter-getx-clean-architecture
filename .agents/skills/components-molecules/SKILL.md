---
name: Molecule Components
description: Reusable composite components like CustomCachedImage and PaginationListView
---
# Skill: Molecule Components

Molecule-level components: `CustomCachedImage` and `PaginationListView<T>`.

---

## CustomCachedImage

`lib/components/molecules/custom_cached_image.dart`

Widget for displaying images from a URL with cache, placeholder, and error handling.

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

### Usage Example

```dart
// Standard product image
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: 120,
  height: 120,
),

// Full width banner
CustomCachedImage(
  imageUrl: banner.bannerUrl,
  width: double.infinity,
  height: 180,
  borderRadius: 12,
  fit: BoxFit.fill,
),

// Circular avatar
ClipOval(
  child: CustomCachedImage(
    imageUrl: user.avatarUrl,
    width: 48,
    height: 48,
    borderRadius: 0, // ClipOval handles the shape
  ),
),

// With custom placeholder
CustomCachedImage(
  imageUrl: product.imageUrl,
  width: 200,
  height: 200,
  placeholder: Container(
    color: Colors.grey[100],
    child: const Icon(Icons.image, size: 48, color: Colors.grey),
  ),
),

// Without border radius
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

A list widget integrated with `BasePaginationController<T>`. Automatically handles loading, error, empty state, and infinite scrolling.

### Props

```dart
PaginationListView<T>({
  required BasePaginationController<T> controller,
  required Widget Function(BuildContext, T, int) itemBuilder,
  Widget Function(BuildContext, int)? separatorBuilder,
  String emptyMessage,           // default: 'Data not found'
  IconData emptyIcon,            // default: Icons.inbox_outlined
  Widget? loadingWidget,         // default: CircularProgressIndicator
  Widget? emptyWidget,           // custom empty state widget
  EdgeInsetsGeometry? padding,
  ScrollPhysics? physics,        // default: AlwaysScrollableScrollPhysics
  bool enableRefresh,            // default: true (pull-to-refresh)
})
```

### Automatically Displayed States

| Condition | UI |
|---|---|
| isLoading.value == true AND items.isEmpty | Fullscreen loading indicator |
| errorMessage != '' AND items.isEmpty | Error message + retry button |
| items.isEmpty AND !isLoading | Empty state (icon + message) |
| items.isNotEmpty | List + bottom load-more indicator |

### Usage Example

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

// With separator
PaginationListView<ProductEntity>(
  controller: controller,
  itemBuilder: (context, product, index) {
    return ProductCard(product: product);
  },
  separatorBuilder: (context, index) => const Divider(),
  emptyMessage: 'No products yet',
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
      CustomText(text: 'No orders yet', fontType: FontType.titleMedium),
      const SizedBox(height: 8),
      CustomButton(
        title: 'Start Shopping',
        onPressed: () => Get.toNamed(Routes.product),
        width: 180,
      ),
    ],
  ),
),

// With padding
PaginationListView<NotificationEntity>(
  controller: controller,
  itemBuilder: (context, notif, index) => NotificationTile(notif: notif),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
),

// Without pull-to-refresh
PaginationListView<LogEntity>(
  controller: controller,
  itemBuilder: (context, log, index) => LogTile(log: log),
  enableRefresh: false,
),
```

---

## Usage in Screen

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
        emptyMessage: 'No products available yet',
        emptyIcon: Icons.inventory_2_outlined,
      ),
    );
  }
}
```

---

## Checklist

```
[ ] Image from URL → CustomCachedImage (not Image.network)
[ ] List with pagination → PaginationListView<T> + BasePaginationController<T>
[ ] Controller has overridden fetchPage() and calls appendData()
[ ] emptyMessage and emptyIcon are customized according to context
[ ] If a custom empty state is needed, use emptyWidget
```
