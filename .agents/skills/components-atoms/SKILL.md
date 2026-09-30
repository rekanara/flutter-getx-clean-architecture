# Skill: Atom Components

Komponen terkecil yang reusable: `CustomButton` dan `CustomText`.

---

## CustomButton

`lib/components/atoms/custom_button.dart`

### Props

```dart
CustomButton({
  required String title,
  required VoidCallback? onPressed,
  Color? color,                        // default: Theme primary
  Color? textColor,                    // default: Theme onPrimary
  FontType fontType,                   // default: FontType.labelLarge
  double? height,                      // default: 48
  double? width,                       // default: double.infinity
  CustomButtonType buttonType,         // default: filled
  EdgeInsetsGeometry? padding,
  double? borderRadius,                // default: theme defaultRadius (22)
  bool enable,                         // default: true
  Widget? widget,                      // override child widget sepenuhnya
})
```

### CustomButtonType

```dart
enum CustomButtonType { filled, outline }
```

---

### Contoh Penggunaan

```dart
// Filled button (default)
CustomButton(
  title: 'Login',
  onPressed: controller.doLogin,
),

// Filled dengan loading state
Obx(() => CustomButton(
  title: controller.isLoading.value ? 'Loading...' : 'Submit',
  onPressed: controller.isLoading.value ? null : controller.submit,
  enable: !controller.isLoading.value,
)),

// Outline button
CustomButton(
  title: 'Batal',
  onPressed: () => Get.back(),
  buttonType: CustomButtonType.outline,
  color: Colors.red,
  textColor: Colors.red,
),

// Custom color
CustomButton(
  title: 'Hapus',
  onPressed: controller.delete,
  color: Colors.red,
  textColor: Colors.white,
),

// Custom size
CustomButton(
  title: 'Simpan',
  onPressed: controller.save,
  height: 56,
  width: 200,
  borderRadius: 8,
),

// Custom child widget
CustomButton(
  title: '',
  onPressed: controller.googleLogin,
  widget: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset('assets/google.png', height: 24),
      const SizedBox(width: 8),
      const Text('Login dengan Google'),
    ],
  ),
),
```

---

## CustomText

`lib/components/atoms/custom_text.dart`

### Props

```dart
CustomText({
  required String text,
  FontType fontType,                   // default: FontType.bodyMedium
  Color? color,
  double? opacity,
  FontWeight? weight,
  TextAlign? textAlign,
  TextDecoration? decoration,
  int? maxLines,
})
```

### FontType Mapping

```dart
// FontType enum → TextTheme style
enum FontType {
  displayLarge,   // TextTheme.displayLarge
  displayMedium,  // TextTheme.displayMedium
  displaySmall,   // TextTheme.displaySmall
  headlineLarge,  // TextTheme.headlineLarge
  headlineMedium, // TextTheme.headlineMedium
  headlineSmall,  // TextTheme.headlineSmall
  titleLarge,     // TextTheme.titleLarge
  titleMedium,    // TextTheme.titleMedium
  titleSmall,     // TextTheme.titleSmall
  bodyLarge,      // TextTheme.bodyLarge
  bodyMedium,     // TextTheme.bodyMedium (default)
  bodySmall,      // TextTheme.bodySmall
  labelLarge,     // TextTheme.labelLarge
  labelMedium,    // TextTheme.labelMedium
  labelSmall,     // TextTheme.labelSmall
}
```

Font selalu Quicksand (FontFamilyType.primary).

---

### Contoh Penggunaan

```dart
// Body text biasa
CustomText(text: 'Selamat datang'),

// Title besar
CustomText(
  text: 'Dashboard',
  fontType: FontType.headlineMedium,
),

// Text kecil dengan warna kustom
CustomText(
  text: 'Optional',
  fontType: FontType.labelSmall,
  color: Colors.grey,
),

// Error text merah
CustomText(
  text: controller.errorMessage.value,
  fontType: FontType.bodySmall,
  color: ColorData.error,
),

// Text dengan opacity
CustomText(
  text: 'Subtitle',
  fontType: FontType.bodyMedium,
  opacity: 0.6,
),

// Text terpotong
CustomText(
  text: 'Judul yang sangat panjang ini akan dipotong dengan ellipsis',
  fontType: FontType.titleMedium,
  maxLines: 1,
),

// Tengah + bold
CustomText(
  text: 'Header',
  fontType: FontType.titleLarge,
  textAlign: TextAlign.center,
  weight: FontWeight.w700,
),

// Underline
CustomText(
  text: 'Lihat selengkapnya',
  fontType: FontType.bodySmall,
  color: Colors.blue,
  decoration: TextDecoration.underline,
),
```

---

## ColorData (dari utils/config.dart)

Gunakan untuk warna semantik:

```dart
ColorData.error    // Merah — untuk error/danger
ColorData.success  // Hijau — untuk sukses
ColorData.warning  // Kuning — untuk peringatan
ColorData.info     // Biru — untuk informasi
```

---

## Checklist

```
[ ] Gunakan CustomButton bukan ElevatedButton/TextButton langsung
[ ] Gunakan CustomText bukan Text() langsung
[ ] fontType dari FontType enum (tidak hardcode fontSize)
[ ] color dari ColorData atau Theme.of(context).colorScheme.*
[ ] Loading state: enable: false atau onPressed: null
[ ] Tidak hardcode font family (CustomText sudah Quicksand)
```
