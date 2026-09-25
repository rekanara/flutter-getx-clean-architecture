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
  status: SnackStatus.error,              // SnackStatus, BUKAN MessageType
  message: 'Pesan error lengkap di sini',
  title: 'Oops!',                         // opsional
  duration: const Duration(seconds: 5),   // default: 3s
  position: SnackPosition.TOP,            // TOP = floating, BOTTOM = grounded (huruf besar, enum dari GetX)
);
```

`status` bertipe `SnackStatus` (didefinisikan di `snackbar.dart`: `success, error, info, warning`) — beda dengan `MessageType` yang ada di `utils/config.dart`. Jangan tertukar, keduanya enum yang berbeda.

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

// Format DateTime ke string — TIDAK menerima parameter pattern,
// selalu format fixed "yyyy-MM-dd HH:mm:ss"
final formatted = DateTimeHelper.format(DateTime.now());
// "2026-06-24 10:30:00"
```

**Catatan:** `format()` tidak pakai package `intl`/`DateFormat` — kalau butuh pattern custom, format manual atau tambahkan parameter ke `DateTimeHelper.format()`.

---

## RupiahHelper

`lib/utils/helper/rupiah.dart`

```dart
import 'package:zidanfath_codebase/utils/helper/rupiah.dart';

// Method INSTANCE, bukan static — harus instantiate dulu
final rupiahHelper = RupiahHelper();

// double → IDR string
final rupiah = rupiahHelper.formatCurrencyToRupiah(150000.0);
// "Rp 150.000"

// String → IDR string
final rupiah2 = rupiahHelper.formatCurrencyStringToRupiah('150000');
// "Rp 150.000"

// Penggunaan di widget
CustomText(
  text: RupiahHelper().formatCurrencyToRupiah(product.price),
  fontType: FontType.titleMedium,
)
```

---

## OpenSetting

`lib/utils/helper/open_setting.dart`

Dialog platform-aware yang membuka pengaturan app:

```dart
import 'package:zidanfath_codebase/utils/helper/open_setting.dart';

// openSettings() adalah method INSTANCE, bukan static
OpenSetting().openSettings(
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

// PENTING: panggil init() dulu (biasanya di main.dart) sebelum baca properti di bawah
await DeviceConfig.instance.init();

device.deviceId;         // unique device ID (String?)
device.deviceOS;         // 'Android' / 'iOS' / 'Web' (String)
device.deviceMake;       // manufacturer (misal: 'Samsung')
device.deviceModel;      // model name (misal: 'Galaxy S21')
device.deviceTypeCode;   // '1' Android, '2' iOS, '3' Web (String) — BUKAN 'mobile'/'tablet'

// Device type berdasarkan screen size — getDeviceType STATIC, panggil dari class bukan instance
final deviceType = DeviceConfig.getDeviceType(context); // DeviceType.mobile/tablet/desktop
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
[ ] Format IDR: RupiahHelper().formatCurrencyToRupiah(double) — instance method
[ ] Format tanggal: DateTimeHelper.format(DateTime, pattern)
[ ] Unix timestamp: DateTimeHelper.fromUnixToLocal(unix)
[ ] Permission denied permanent: OpenSetting().openSettings() — instance method
[ ] Device info: DeviceConfig.instance.deviceId / deviceOS
```
