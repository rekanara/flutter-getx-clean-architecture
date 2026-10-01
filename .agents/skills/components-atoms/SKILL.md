---
name: Atom Components
description: Reusable small UI components like CustomButton and CustomText
---
# Skill: Atom Components

The smallest reusable components: `CustomButton` and `CustomText`.

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
  Widget? widget,                      // override child widget completely
})
```

### CustomButtonType

```dart
enum CustomButtonType { filled, outline }
```

---

### Usage Example

```dart
// Filled button (default)
CustomButton(
  title: 'Login',
  onPressed: controller.doLogin,
),

// Filled with loading state
Obx(() => CustomButton(
  title: controller.isLoading.value ? 'Loading...' : 'Submit',
  onPressed: controller.isLoading.value ? null : controller.submit,
  enable: !controller.isLoading.value,
)),

// Outline button
CustomButton(
  title: 'Cancel',
  onPressed: () => Get.back(),
  buttonType: CustomButtonType.outline,
  color: Colors.red,
  textColor: Colors.red,
),

// Custom color
CustomButton(
  title: 'Delete',
  onPressed: controller.delete,
  color: Colors.red,
  textColor: Colors.white,
),

// Custom size
CustomButton(
  title: 'Save',
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
      const Text('Login with Google'),
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

Font is always Quicksand (FontFamilyType.primary).

---

### Usage Example

```dart
// Regular body text
CustomText(text: 'Welcome'),

// Large title
CustomText(
  text: 'Dashboard',
  fontType: FontType.headlineMedium,
),

// Small text with custom color
CustomText(
  text: 'Optional',
  fontType: FontType.labelSmall,
  color: Colors.grey,
),

// Red error text
CustomText(
  text: controller.errorMessage.value,
  fontType: FontType.bodySmall,
  color: ColorData.error,
),

// Text with opacity
CustomText(
  text: 'Subtitle',
  fontType: FontType.bodyMedium,
  opacity: 0.6,
),

// Truncated text
CustomText(
  text: 'This very long title will be truncated with ellipsis',
  fontType: FontType.titleMedium,
  maxLines: 1,
),

// Center + bold
CustomText(
  text: 'Header',
  fontType: FontType.titleLarge,
  textAlign: TextAlign.center,
  weight: FontWeight.w700,
),

// Underline
CustomText(
  text: 'See more',
  fontType: FontType.bodySmall,
  color: Colors.blue,
  decoration: TextDecoration.underline,
),
```

---

## ColorData (from utils/config.dart)

Use for semantic colors:

```dart
ColorData.error    // Red — for errors/danger
ColorData.success  // Green — for success
ColorData.warning  // Yellow — for warnings
ColorData.info     // Blue — for information
```

---

## Checklist

```
[ ] Use CustomButton instead of raw ElevatedButton/TextButton
[ ] Use CustomText instead of raw Text()
[ ] fontType from FontType enum (do not hardcode fontSize)
[ ] color from ColorData or Theme.of(context).colorScheme.*
[ ] Loading state: enable: false or onPressed: null
[ ] Do not hardcode font family (CustomText is already Quicksand)
```
