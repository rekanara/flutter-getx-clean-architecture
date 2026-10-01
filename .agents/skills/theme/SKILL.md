---
name: Theme
description: Theming with FlexColorScheme, theme switching, and accessing colors
---
# Skill: Theme

Guide to theming with FlexColorScheme, switching themes, and accessing colors/styles from the context.

---

## RkTheme — Configuration

`lib/infrastructure/theme/theme.dart`

```dart
class RkTheme {
  // Light — property named `light`, NOT `lightTheme`
  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xFF00296B),
      secondary: Color(0xFFD26900),
      tertiary: Color(0xFF5C5C95),
      // ...
    ),
    // defaultRadius: 22.0 (in subThemesData)
    // font: Quicksand
  );

  // Dark — property named `dark`, NOT `darkTheme`
  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFFB1CFF5),
      secondary: Color(0xFFFFD270),
      tertiary: Color(0xFFC9CBFC),
      // ...
    ),
  );

  // Switch theme + save preference to GetStorage
  // IMPORTANT: named parameter {required bool isLightTheme}, not positional,
  // and Future<void> (async) — not void.
  static Future<void> changeTheme({required bool isLightTheme}) async {
    GetStorageImpl storage = GetStorageImpl();
    await storage.write(StorageValue.themeIsLight, !isLightTheme);
    Get.changeThemeMode(!isLightTheme ? ThemeMode.light : ThemeMode.dark);
  }
}
```

**Known Bug:** The `changeTheme()` logic above negates `isLightTheme` (using `!isLightTheme`) when saving to storage and setting `ThemeMode`. Because of this, calling `changeTheme(isLightTheme: true)` actually activates **dark mode**. Before using this feature, fix the logic in `lib/infrastructure/theme/theme.dart` instead of copying it blindly. `main.dart` doesn't currently call `changeTheme()`—it uses a static `themeMode: ThemeMode.system`.

---

## Using Theme in GetMaterialApp

```dart
// lib/main.dart (current actual state)
GetMaterialApp(
  theme: RkTheme.light,
  darkTheme: RkTheme.dark,
  themeMode: ThemeMode.system, // follows system, not saved preference
  // ...
);
```

---

## Accessing Colors from Context

```dart
// Always use Theme.of(context) for adaptive colors
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Main colors
colorScheme.primary         // #00296B (light) / #B1CFF5 (dark)
colorScheme.secondary       // #D26900 (light) / #FFD270 (dark)
colorScheme.tertiary        // #5C5C95 (light) / #C9CBFC (dark)

// Background & surface
colorScheme.background      // main background
colorScheme.surface         // card/dialog surface
colorScheme.surfaceVariant  // alternative surface

// Text on background
colorScheme.onPrimary       // text on primary color
colorScheme.onSurface       // main text
colorScheme.onSurfaceVariant // secondary text

// Error
colorScheme.error           // error red
colorScheme.onError         // text on error color
```

---

## Accessing TextTheme

```dart
final textTheme = Theme.of(context).textTheme;

textTheme.displayLarge
textTheme.displayMedium
textTheme.displaySmall
textTheme.headlineLarge
textTheme.headlineMedium
textTheme.headlineSmall
textTheme.titleLarge
textTheme.titleMedium
textTheme.titleSmall
textTheme.bodyLarge
textTheme.bodyMedium
textTheme.bodySmall
textTheme.labelLarge
textTheme.labelMedium
textTheme.labelSmall
```

Alternatively, use `CustomText(fontType: FontType.titleLarge)` — this is highly recommended.

---

## Theme Switching

```dart
// In a controller or settings screen — use named parameters, and async
await RkTheme.changeTheme(isLightTheme: true);   // switch to light
await RkTheme.changeTheme(isLightTheme: false);  // switch to dark

// Or using a toggle
class ThemeController extends GetxController {
  bool get isLight => Get.find<GetStorageImpl>()
      .read<bool>(StorageValue.themeIsLight) ?? true;

  Future<void> toggleTheme() => RkTheme.changeTheme(isLightTheme: !isLight);
}

// In UI
Obx(() => Switch(
  value: themeController.isLight,
  onChanged: (_) => themeController.toggleTheme(),
))
```

---

## ColorData (Semantic Colors)

`lib/utils/config.dart`

```dart
class ColorData {
  static const error   = Color(0xFFD32F2F); // red
  static const success = Color(0xFF388E3C); // green
  static const warning = Color(0xFFF57C00); // yellow/orange
  static const info    = Color(0xFF1976D2); // blue
}
```

Use these for semantic colors that do not change between light and dark modes:

```dart
CustomText(
  text: 'Error: ${error.message}',
  color: ColorData.error,
)

Container(
  color: ColorData.success.withOpacity(0.1),
  child: CustomText(text: 'Success!', color: ColorData.success),
)
```

---

## defaultRadius

All components follow `defaultRadius: 22.0`:

```dart
// Example of a component respecting the theme radius
BorderRadius.circular(22) // for Cards, Containers, etc.
```

---

## Checklist

```
[ ] Main colors from Theme.of(context).colorScheme
[ ] Text styling via CustomText (fontType) or Theme.of(context).textTheme
[ ] Semantic colors (error/success) from ColorData
[ ] Theme switching via RkTheme.changeTheme(bool)
[ ] Theme preference saved to GetStorage (handled by RkTheme.changeTheme)
[ ] Avoid hardcoding Color() in widgets unless absolutely necessary
```
