# Skill: Responsive UI

Panduan membuat UI yang responsif untuk mobile, tablet, dan desktop menggunakan `Responsive` widget dan `ResponsiveExtension`.

---

## Breakpoints

```dart
// lib/utils/responsive.dart
class Breakpoints {
  static const double mobile = 600;   // < 600
  static const double tablet = 900;   // 600 - 1200
  static const double desktop = 1200; // >= 1200 (atau >= tablet threshold)
}
```

---

## Responsive Widget

`Responsive` widget memilih layout berdasarkan lebar layar:

```dart
// lib/utils/responsive.dart
Responsive(
  mobile: MobileLayout(),          // required — tampil di < 600px
  tablet: TabletLayout(),          // opsional — tampil di 600-1199px
  desktop: DesktopLayout(),        // opsional — tampil di >= 1200px
)

// Jika tablet tidak disediakan, mobile dipakai untuk tablet juga
// Jika desktop tidak disediakan, tablet (atau mobile) dipakai untuk desktop
```

### Contoh

```dart
class ProductScreen extends GetView<ProductController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Responsive(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      itemCount: controller.products.length,
      itemBuilder: (_, i) => ProductListTile(product: controller.products[i]),
    );
  }

  Widget _buildTabletLayout() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: controller.products.length,
      itemBuilder: (_, i) => ProductCard(product: controller.products[i]),
    );
  }

  Widget _buildDesktopLayout() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: controller.products.length,
      itemBuilder: (_, i) => ProductCard(product: controller.products[i]),
    );
  }
}
```

---

## ResponsiveExtension on BuildContext

Akses responsive values langsung dari `context`:

```dart
// Boolean checks
context.isMobile    // true jika width < 600
context.isTablet    // true jika 600 <= width < 1200
context.isDesktop   // true jika width >= 1200

// Shortcuts
context.screenWidth  // MediaQuery.of(context).size.width
context.screenHeight // MediaQuery.of(context).size.height

// Responsive value — return nilai sesuai breakpoint
context.responsive<int>(
  mobile: 1,     // required
  tablet: 2,     // opsional
  desktop: 4,    // opsional
)

context.responsive<double>(
  mobile: 16.0,  // padding mobile
  desktop: 24.0, // padding desktop
)
```

### Contoh Penggunaan

```dart
@override
Widget build(BuildContext context) {
  // Jumlah kolom grid berdasarkan device
  final crossAxisCount = context.responsive<int>(
    mobile: 1,
    tablet: 2,
    desktop: 3,
  );

  // Padding adaptif
  final padding = context.responsive<EdgeInsets>(
    mobile: const EdgeInsets.all(12),
    tablet: const EdgeInsets.all(16),
    desktop: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
  );

  return Padding(
    padding: padding,
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      // ...
    ),
  );
}
```

---

## DeviceConfig — Device Type

```dart
// lib/config/device/device_config.dart
// getDeviceType adalah method STATIC — panggil dari class, bukan dari .instance
final deviceType = DeviceConfig.getDeviceType(context);
// DeviceType.mobile / DeviceType.tablet / DeviceType.desktop
```

---

## Pattern Responsif Sederhana

```dart
// Tanpa Responsive widget — cukup dengan context extension
Widget _buildContent(BuildContext context) {
  if (context.isMobile) {
    return const _MobileContent();
  }
  return const _DesktopContent();
}

// Atau conditional sizing
SizedBox(
  width: context.isMobile ? double.infinity : 400,
  child: const LoginForm(),
),
```

---

## Checklist

```
[ ] Layout berbeda per device → Responsive widget
[ ] Nilai berbeda per device → context.responsive<T>(mobile: ..., desktop: ...)
[ ] Check device type → context.isMobile / isTablet / isDesktop
[ ] Tidak hardcode nilai width/height — gunakan responsive values
[ ] LayoutBuilder untuk container yang tergantung parent (bukan screen)
```
