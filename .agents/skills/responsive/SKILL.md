---
name: Responsive UI
description: Guide for creating responsive UIs (mobile, tablet, desktop)
---
# Skill: Responsive UI

Guide to creating responsive UIs for mobile, tablet, and desktop using the `Responsive` widget and `ResponsiveExtension`.

---

## Breakpoints

```dart
// lib/utils/responsive.dart
class Breakpoints {
  static const double mobile = 600;   // < 600
  static const double tablet = 900;   // 600 - 1200
  static const double desktop = 1200; // >= 1200 (or >= tablet threshold)
}
```

---

## Responsive Widget

The `Responsive` widget chooses a layout based on screen width:

```dart
// lib/utils/responsive.dart
Responsive(
  mobile: MobileLayout(),          // required — shown for < 600px
  tablet: TabletLayout(),          // optional — shown for 600-1199px
  desktop: DesktopLayout(),        // optional — shown for >= 1200px
)

// If tablet is not provided, mobile is used for tablets too
// If desktop is not provided, tablet (or mobile) is used for desktop
```

### Example

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

Access responsive values directly from `context`:

```dart
// Boolean checks
context.isMobile    // true if width < 600
context.isTablet    // true if 600 <= width < 1200
context.isDesktop   // true if width >= 1200

// Shortcuts
context.screenWidth  // MediaQuery.of(context).size.width
context.screenHeight // MediaQuery.of(context).size.height

// Responsive value — returns value matching the breakpoint
context.responsive<int>(
  mobile: 1,     // required
  tablet: 2,     // optional
  desktop: 4,    // optional
)

context.responsive<double>(
  mobile: 16.0,  // mobile padding
  desktop: 24.0, // desktop padding
)
```

### Usage Example

```dart
@override
Widget build(BuildContext context) {
  // Grid column count based on device
  final crossAxisCount = context.responsive<int>(
    mobile: 1,
    tablet: 2,
    desktop: 3,
  );

  // Adaptive padding
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
// getDeviceType is a STATIC method — call from class, not from .instance
final deviceType = DeviceConfig.getDeviceType(context);
// DeviceType.mobile / DeviceType.tablet / DeviceType.desktop
```

---

## Simple Responsive Pattern

```dart
// Without Responsive widget — using only context extensions
Widget _buildContent(BuildContext context) {
  if (context.isMobile) {
    return const _MobileContent();
  }
  return const _DesktopContent();
}

// Or conditional sizing
SizedBox(
  width: context.isMobile ? double.infinity : 400,
  child: const LoginForm(),
),
```

---

## Checklist

```
[ ] Different layouts per device → Responsive widget
[ ] Different values per device → context.responsive<T>(mobile: ..., desktop: ...)
[ ] Check device type → context.isMobile / isTablet / isDesktop
[ ] Avoid hardcoding width/height values — use responsive values
[ ] Use LayoutBuilder for containers dependent on parents (not the screen)
```
