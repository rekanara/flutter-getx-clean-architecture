# Skill: Helpers & Utilities

Panduan menggunakan semua helper/utility yang tersedia: Logger, Snackbar, Dialog, DateTime, Rupiah, dan OpenSetting.

---

## LoggerHelper

`lib/utils/helper/logger.dart`

Logger dengan PrettyPrinter, color-coded, dan ProductionFilter (tidak print di production).

```dart
import 'package:zidanfath_codebase/utils/helper/logger.dart';

// Level-level logger:
LoggerHelper.d('Debug: memulai fetch data');            // Debug
LoggerHelper.i('Info: user login berhasil');            // Info (biru)
LoggerHelper.w('Warning: koneksi lambat');              // Warning (kuning)
LoggerHelper.e(                                         // Error (merah)
  'Error: gagal parse JSON',
  error: exception,
  stackTrace: stackTrace,
);
LoggerHelper.t('Trace: detail verbose');               // Trace
LoggerHelper.f('Fatal: app state corrupt');            // Fatal
```

---

## SnackbarHelper

`lib/utils/helper/snackbar.dart`

Snackbar GetX dengan posisi TOP (floating) atau BOTTOM (grounded).

```dart
import 'package:zidanfath_codebase/utils/helper/snackbar.dart';

// Shortcuts (posisi BOTTOM default)
SnackbarHelper.showError('Gagal memuat data');
SnackbarHelper.showSuccess('Data berhasil disimpan');
SnackbarHelper.showWarning('Koneksi tidak stabil');
SnackbarHelper.showInfo('Ada pembaruan tersedia');

// Full control
SnackbarHelper.show(
  status: MessageType.error,
  message: 'Pesan error lengkap di sini',
  title: 'Oops!',                         // opsional
  duration: const Duration(seconds: 5),   // default: 3s
  position: SnackPosition.top,            // TOP = floating, BOTTOM = grounded
);
```

---

## DialogHelper

`lib/utils/helper/dialog.dart`

```dart
import 'package:zidanfath_codebase/utils/helper/dialog.dart';

// Dialog konfirmasi dengan dua tombol
DialogHelper.showDialog(
  title: 'Konfirmasi Hapus',
  message: 'Yakin ingin menghapus item ini?',
  onSubmit: () {
    Get.back(); // tutup dialog
    controller.deleteItem(id);
  },
  onCancel: () => Get.back(),
  submitLabel: 'Hapus',     // opsional, default: 'OK'
  cancelLabel: 'Batal',     // opsional, default: 'Batal'
);

// Info dialog satu tombol (Cupertino style)
DialogHelper.showInfoDialog(
  'Data berhasil dihapus',
  isSuccess: true,   // true = ikon centang hijau, false = ikon X merah
  title: 'Berhasil', // opsional
);

// Tutup dialog
DialogHelper.closeDialog();
```

---

## DateTimeHelper

`lib/utils/helper/date_time.dart`

```dart
import 'package:zidanfath_codebase/utils/helper/date_time.dart';

// Unix timestamp → DateTime UTC
final utcTime = DateTimeHelper.fromUnixToUtc(1719187200);

// Unix timestamp → DateTime local
final localTime = DateTimeHelper.fromUnixToLocal(1719187200);

// DateTime → Unix timestamp
final unix = DateTimeHelper.toUnix(DateTime.now()); // int

// Format DateTime ke string
final formatted = DateTimeHelper.format(DateTime.now(), 'dd MMMM yyyy');
// "24 Juni 2026"

final formatted2 = DateTimeHelper.format(DateTime.now(), 'HH:mm');
// "10:30"

final formatted3 = DateTimeHelper.format(DateTime.now(), 'dd/MM/yyyy HH:mm');
// "24/06/2026 10:30"
```

---

## RupiahHelper

`lib/utils/helper/rupiah.dart`

```dart
import 'package:zidanfath_codebase/utils/helper/rupiah.dart';

// double → IDR string
final rupiah = RupiahHelper.formatCurrencyToRupiah(150000.0);
// "Rp 150.000"

RupiahHelper.formatCurrencyToRupiah(1500000.5);
// "Rp 1.500.001" (dibulatkan)

// String → IDR string
final rupiah2 = RupiahHelper.formatCurrencyStringToRupiah('150000');
// "Rp 150.000"

// Penggunaan di widget
CustomText(
  text: RupiahHelper.formatCurrencyToRupiah(product.price),
  fontType: FontType.titleMedium,
)
```

---

## OpenSetting

`lib/utils/helper/open_setting.dart`

Dialog platform-aware yang membuka pengaturan app:

```dart
import 'package:zidanfath_codebase/utils/helper/open_setting.dart';

OpenSetting.openSettings(
  label: 'Kamera',           // nama permission di dialog
  message: 'Izin kamera diperlukan. Buka pengaturan untuk mengaktifkan.',
  afterCreateUpdate: () {
    // callback opsional setelah dialog tampil
  },
);
// iOS: CupertinoAlertDialog dengan tombol "Pengaturan" dan "Batal"
// Android: AlertDialog dengan tombol "Pengaturan" dan "Batal"
// Tekan "Pengaturan" → buka app settings native
```

---

## DeviceConfig

`lib/config/device/device_config.dart`

```dart
import 'package:zidanfath_codebase/config/device/device_config.dart';

final device = DeviceConfig.instance;

device.deviceId;         // unique device ID (String)
device.deviceOS;         // 'android' atau 'ios' (String)
device.deviceMake;       // manufacturer (misal: 'Samsung')
device.deviceModel;      // model name (misal: 'Galaxy S21')
device.deviceTypeCode;   // 'mobile' atau 'tablet' (String)

// Device type berdasarkan screen size
final deviceType = device.getDeviceType(context); // DeviceType.mobile atau tablet
```

---

## Enums Penting (utils/config.dart)

```dart
// FontType — untuk CustomText
FontType.bodyMedium, titleLarge, headlineSmall, labelSmall, dll.

// ButtonType — untuk CustomButton (jarang dipakai langsung)
ButtonType.primary, secondary

// MessageType — untuk SnackbarHelper
MessageType.error, success, warning, info

// RequestType — untuk HTTP method tracking
RequestType.get, post, put, patch, delete

// AppFlavor — untuk feature flag
AppFlavor.dev, staging, prod

// ColorData — warna semantik
ColorData.error, success, warning, info
```

---

## Checklist

```
[ ] Logging: LoggerHelper.d/i/w/e() (tidak print() langsung)
[ ] Snackbar: SnackbarHelper.showError/Success/Warning/Info()
[ ] Dialog konfirmasi: DialogHelper.showDialog()
[ ] Dialog info: DialogHelper.showInfoDialog(message, isSuccess: bool)
[ ] Format IDR: RupiahHelper.formatCurrencyToRupiah(double)
[ ] Format tanggal: DateTimeHelper.format(DateTime, pattern)
[ ] Unix timestamp: DateTimeHelper.fromUnixToLocal(unix)
[ ] Permission denied permanent: OpenSetting.openSettings()
[ ] Device info: DeviceConfig.instance.deviceId / deviceOS
```
