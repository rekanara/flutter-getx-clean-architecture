---
name: Helpers & Utilities
description: Guide for Logger, Snackbar, Dialog, DateTime, Rupiah, OpenSetting
---
# Skill: Helpers & Utilities

Guide to using all available helpers/utilities: Logger, Snackbar, Dialog, DateTime, Rupiah, and OpenSetting.

---

## LoggerHelper

`lib/utils/helper/logger.dart`

Logger with PrettyPrinter, color-coded, and ProductionFilter (does not print in production).

```dart
import 'package:rekanara_getx/utils/helper/logger.dart';

// Logger levels:
LoggerHelper.d('Debug: starting to fetch data');            // Debug
LoggerHelper.i('Info: user login successful');            // Info (blue)
LoggerHelper.w('Warning: slow connection');              // Warning (yellow)
LoggerHelper.e(                                         // Error (red)
  'Error: failed to parse JSON',
  error: exception,
  stackTrace: stackTrace,
);
LoggerHelper.t('Trace: verbose details');               // Trace
LoggerHelper.f('Fatal: app state corrupt');            // Fatal
```

---

## SnackbarHelper

`lib/utils/helper/snackbar.dart`

GetX Snackbar with TOP (floating) or BOTTOM (grounded) positioning.

```dart
import 'package:rekanara_getx/utils/helper/snackbar.dart';

// Shortcuts (default BOTTOM position)
SnackbarHelper.showError('Failed to load data');
SnackbarHelper.showSuccess('Data saved successfully');
SnackbarHelper.showWarning('Unstable connection');
SnackbarHelper.showInfo('Update available');

// Full control
SnackbarHelper.show(
  status: SnackStatus.error,              // SnackStatus, NOT MessageType
  message: 'Full error message here',
  title: 'Oops!',                         // optional
  duration: const Duration(seconds: 5),   // default: 3s
  position: SnackPosition.TOP,            // TOP = floating, BOTTOM = grounded (uppercase, GetX enum)
);
```

`status` is of type `SnackStatus` (defined in `snackbar.dart`: `success, error, info, warning`) — different from `MessageType` in `utils/config.dart`. Do not confuse them; they are two different enums.

---

## DialogHelper

`lib/utils/helper/dialog.dart`

```dart
import 'package:rekanara_getx/utils/helper/dialog.dart';

// Confirmation dialog with two buttons
DialogHelper.showDialog(
  title: 'Confirm Deletion',
  message: 'Are you sure you want to delete this item?',
  onSubmit: () {
    Get.back(); // close dialog
    controller.deleteItem(id);
  },
  onCancel: () => Get.back(),
  submitLabel: 'Delete',     // optional, default: 'OK'
  cancelLabel: 'Cancel',     // optional, default: 'Batal'
);

// One-button info dialog (Cupertino style)
DialogHelper.showInfoDialog(
  'Data deleted successfully',
  isSuccess: true,   // true = green check icon, false = red X icon
  title: 'Success', // optional
);

// Close dialog
DialogHelper.closeDialog();
```

---

## DateTimeHelper

`lib/utils/helper/date_time.dart`

```dart
import 'package:rekanara_getx/utils/helper/date_time.dart';

// Unix timestamp → DateTime UTC
final utcTime = DateTimeHelper.fromUnixToUtc(1719187200);

// Unix timestamp → DateTime local
final localTime = DateTimeHelper.fromUnixToLocal(1719187200);

// DateTime → Unix timestamp
final unix = DateTimeHelper.toUnix(DateTime.now()); // int

// Format DateTime to string — DOES NOT accept pattern parameters,
// always fixed format "yyyy-MM-dd HH:mm:ss"
final formatted = DateTimeHelper.format(DateTime.now());
// "2026-06-24 10:30:00"
```

**Note:** `format()` does not use the `intl`/`DateFormat` package — if you need a custom pattern, format it manually or add a parameter to `DateTimeHelper.format()`.

---

## RupiahHelper

`lib/utils/helper/rupiah.dart`

```dart
import 'package:rekanara_getx/utils/helper/rupiah.dart';

// INSTANCE method, not static — must instantiate first
final rupiahHelper = RupiahHelper();

// double → IDR string
final rupiah = rupiahHelper.formatCurrencyToRupiah(150000.0);
// "Rp 150.000"

// String → IDR string
final rupiah2 = rupiahHelper.formatCurrencyStringToRupiah('150000');
// "Rp 150.000"

// Usage in widget
CustomText(
  text: RupiahHelper().formatCurrencyToRupiah(product.price),
  fontType: FontType.titleMedium,
)
```

---

## OpenSetting

`lib/utils/helper/open_setting.dart`

Platform-aware dialog that opens app settings:

```dart
import 'package:rekanara_getx/utils/helper/open_setting.dart';

// openSettings() is an INSTANCE method, not static
OpenSetting().openSettings(
  label: 'Camera',           // permission name in dialog
  message: 'Camera permission is required. Open settings to enable it.',
  afterCreateUpdate: () {
    // optional callback after dialog is shown
  },
);
// iOS: CupertinoAlertDialog with "Settings" and "Cancel" buttons
// Android: AlertDialog with "Settings" and "Cancel" buttons
// Tap "Settings" → opens native app settings
```

---

## DeviceConfig

`lib/config/device/device_config.dart`

```dart
import 'package:rekanara_getx/config/device/device_config.dart';

final device = DeviceConfig.instance;

// IMPORTANT: call init() first (usually in main.dart) before reading the properties below
await DeviceConfig.instance.init();

device.deviceId;         // unique device ID (String?)
device.deviceOS;         // 'Android' / 'iOS' / 'Web' (String)
device.deviceMake;       // manufacturer (e.g.: 'Samsung')
device.deviceModel;      // model name (e.g.: 'Galaxy S21')
device.deviceTypeCode;   // '1' Android, '2' iOS, '3' Web (String) — NOT 'mobile'/'tablet'

// Device type based on screen size — getDeviceType is STATIC, call from class not instance
final deviceType = DeviceConfig.getDeviceType(context); // DeviceType.mobile/tablet/desktop
```

---

## Important Enums (utils/config.dart)

```dart
// FontType — for CustomText
FontType.bodyMedium, titleLarge, headlineSmall, labelSmall, etc.

// ButtonType — for CustomButton (rarely used directly)
ButtonType.primary, secondary

// MessageType — for SnackbarHelper
MessageType.error, success, warning, info

// RequestType — for HTTP method tracking
RequestType.get, post, put, patch, delete

// AppFlavor — for feature flags
AppFlavor.dev, staging, prod

// ColorData — semantic colors
ColorData.error, success, warning, info
```

---

## Checklist

```
[ ] Logging: LoggerHelper.d/i/w/e() (do not use print() directly)
[ ] Snackbar: SnackbarHelper.showError/Success/Warning/Info()
[ ] Confirmation dialog: DialogHelper.showDialog()
[ ] Info dialog: DialogHelper.showInfoDialog(message, isSuccess: bool)
[ ] Format IDR: RupiahHelper().formatCurrencyToRupiah(double) — instance method
[ ] Format date: DateTimeHelper.format(DateTime, pattern)
[ ] Unix timestamp: DateTimeHelper.fromUnixToLocal(unix)
[ ] Permanent permission denied: OpenSetting().openSettings() — instance method
[ ] Device info: DeviceConfig.instance.deviceId / deviceOS
```
