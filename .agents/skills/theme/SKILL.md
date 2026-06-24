# Skill: Theme

Panduan theming dengan FlexColorScheme, switch tema, dan mengakses warna/style dari context.

---

## RkTheme — Konfigurasi

`lib/infrastructure/theme/theme.dart`

```dart
class RkTheme {
  // Light
  static ThemeData get lightTheme => FlexThemeData.light(
    primary: const Color(0xFF00296B),
    secondary: const Color(0xFFD26900),
    tertiary: const Color(0xFF5C5C95),
    // defaultRadius: 22.0
    // font: Quicksand
  );

  // Dark
  static ThemeData get darkTheme => FlexThemeData.dark(
    primary: const Color(0xFFB1CFF5),
    secondary: const Color(0xFFFFD270),
    tertiary: const Color(0xFFC9CBFC),
    // defaultRadius: 22.0
  );

  // Switch tema + simpan preference ke GetStorage
  static void changeTheme(bool isLightTheme) {
    Get.changeThemeMode(isLightTheme ? ThemeMode.light : ThemeMode.dark);
    Get.find<GetStorageImpl>().write(StorageValue.themeIsLight, isLightTheme);
  }
}
```

---

## Menggunakan Tema di GetMaterialApp

```dart
// lib/main.dart
GetMaterialApp(
  theme: RkTheme.lightTheme,
  darkTheme: RkTheme.darkTheme,
  themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
  // ...
);
```

---

## Mengakses Warna dari Context

```dart
// Selalu gunakan Theme.of(context) untuk warna adaptive
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Warna utama
colorScheme.primary         // #00296B (light) / #B1CFF5 (dark)
colorScheme.secondary       // #D26900 (light) / #FFD270 (dark)
colorScheme.tertiary        // #5C5C95 (light) / #C9CBFC (dark)

// Background & surface
colorScheme.background      // background utama
colorScheme.surface         // surface card/dialog
colorScheme.surfaceVariant  // surface alternatif

// Text on background
colorScheme.onPrimary       // teks di atas primary color
colorScheme.onSurface       // teks utama
colorScheme.onSurfaceVariant // teks secondary

// Error
colorScheme.error           // merah error
colorScheme.onError         // teks di atas error
```

---

## Mengakses TextTheme

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

Atau gunakan `CustomText(fontType: FontType.titleLarge)` — lebih direkomendasikan.

---

## Switch Tema

```dart
// Di controller / setting screen
RkTheme.changeTheme(true);   // switch ke light
RkTheme.changeTheme(false);  // switch ke dark

// Atau dengan toggle
class ThemeController extends GetxController {
  bool get isLight => Get.find<GetStorageImpl>()
      .read<bool>(StorageValue.themeIsLight) ?? true;

  void toggleTheme() => RkTheme.changeTheme(!isLight);
}

// Di UI
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
  static const error   = Color(0xFFD32F2F); // merah
  static const success = Color(0xFF388E3C); // hijau
  static const warning = Color(0xFFF57C00); // kuning/oranye
  static const info    = Color(0xFF1976D2); // biru
}
```

Gunakan untuk warna semantik yang tidak berubah antara light/dark:

```dart
CustomText(
  text: 'Error: ${error.message}',
  color: ColorData.error,
)

Container(
  color: ColorData.success.withOpacity(0.1),
  child: CustomText(text: 'Berhasil!', color: ColorData.success),
)
```

---

## defaultRadius

Semua komponen mengikuti `defaultRadius: 22.0`:

```dart
// Contoh komponen yang ikut tema
BorderRadius.circular(22) // untuk Card, Container, dll
```

---

## Checklist

```
[ ] Warna utama dari Theme.of(context).colorScheme
[ ] Text style dari CustomText (fontType) atau Theme.of(context).textTheme
[ ] Warna semantik (error/success) dari ColorData
[ ] Switch tema via RkTheme.changeTheme(bool)
[ ] Preference tema tersimpan ke GetStorage (sudah dilakukan RkTheme.changeTheme)
[ ] Tidak hardcode Color() di widget kecuali sangat diperlukan
```
