# Native Flavors (Dev / Staging / Prod)

Panduan lengkap sistem **Native Android Flavors** pada boilerplate ini: konsep, file yang
ditambahkan, lokasinya, cara pakai, dan cara menambah konfigurasi baru.

> **Status saat ini: Android only.** iOS belum — lihat [Roadmap iOS](#roadmap-ios-belum-diimplementasi).
> **Terminology penting:** jangan tertukar antara *flavor* (native build, compile-time) dan
> *environment* (runtime switch di Dart). Lihat [Konsep](#konsep-flavor-vs-environment).

---

## Konsep: Flavor vs Environment

| Aspek                | Flavor (native)                                 | Environment (runtime Dart)                     |
| -------------------- | ----------------------------------------------- | ---------------------------------------------- |
| Didefinisikan di     | `android/app/build.gradle.kts`                  | `Environment` enum (`environments.dart`)       |
| Dipilih kapan        | **Compile-time** (`--flavor dev` saat build)     | Runtime (switcher UI + `GetStorage`)           |
| Mengubah apa         | Package ID, nama app, icon, FCM project         | Base URL backend, MQTT, Firebase keys (values) |
| Install di device    | **3 app terpisah, side-by-side**                | 1 app saja                                     |
| Ganti tanpa rebuild? | ❌ Harus build ulang                            | ✅ Cukup restart app                           |

**Kenapa dua-duanya?** Flavor memastikan dev/staging/prod adalah *aplikasi berbeda* —
package ID berbeda, bisa di-install berdampingan, FCM token tidak bercampur. Environment
(runtime) tetap dipertahankan untuk fleksibilitas QA pindah backend tanpa rebuild — tapi
sekarang **dikunci oleh flavor**.

---

## Kebijakan Environment Locking

`FlavorService` (`lib/config/flavor/flavor_service.dart`) membaca flavor yang aktif dan
membatasi environment yang boleh dipilih:

| Flavor    | Package ID                  | Environment yang diizinkan        | Switcher UI |
| --------- | --------------------------- | --------------------------------- | ----------- |
| `dev`     | `com.rekanara.getx.dev`     | `dev`, `staging` (**tidak prod**) | ✅ Tampil   |
| `staging` | `com.rekanara.getx.staging` | `staging` saja (locked)           | ❌ Terkunci |
| `prod`    | `com.rekanara.getx`         | `prod` saja (locked)              | ❌ Terkunci |

Aturan teknis yang di-enforce:

1. **Flavor selalu menang atas storage.** Saat init, `EnvironmentController` membaca
   `FlavorService.lockedEnvironment`. Untuk flavor `staging`/`prod`, nilai storage diabaikan
   dan ditimpa dengan env milik flavor tersebut.
2. **Storage lama yang tidak valid di-fallback.** Jika GetStorage menyimpan `prod`
   tetapi flavor-nya `dev`, nilai itu diabaikan → kembali ke `dev`.
3. **`switchEnvironment()` silent no-op** jika env target tidak ada di
   `FlavorService.allowedEnvironments`. Tidak crash, tidak menulis storage.
4. Flavor dikirim sebagai `--dart-define=app.flavor=<flavor>` oleh build system. Saat tidak
   ada (misal `flutter test`), fallback ke `AppFlavor.dev`.

### Alur data saat app start

```
main.dart
  │  GetStorage.init()
  ▼
EnvironmentController.onInit()
  │
  ├── FlavorService.lockedEnvironment != null ?   ← flavor staging/prod
  │       YES → currentEnv = locked, timpa storage, selesai.
  │       NO  → baca StorageValue.env dari GetStorage
  │               ├── kosong / tidak dikenal → dev
  │               └── ada → validasi ada di allowedEnvironments
  │                       ├── ya  → pakai nilai storage
  │                       └── tidak → fallback dev
  ▼
ConfigEnvironments.config  ← dipakai URL.dart, DioClient, dsb.
```

---

## Daftar File yang Ditambahkan/Diubah

### File Baru

| File / Folder                                                     | Fungsi                                                                                          |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `lib/config/flavor/flavor_service.dart`                           | `AppFlavor` enum + `FlavorService` (baca compile-time flavor, expose `allowedEnvironments`)      |
| `tool/make_flavor_icons.py`                                       | Script Python (Pillow) generate icon dev/staging dengan badge warna di pojok kanan atas          |
| `assets/icons/app_icon_dev.png`                                   | Icon asli + badge **ungu** (Material Purple 500) — output script                                 |
| `assets/icons/app_icon_staging.png`                               | Icon asli + badge **oranye** (Material Orange 500) — output script                               |
| `flutter_launcher_icons-dev.yaml`                                 | Config flutter_launcher_icons untuk flavor dev                                                   |
| `flutter_launcher_icons-staging.yaml`                             | Config flutter_launcher_icons untuk flavor staging                                               |
| `android/app/src/dev/res/mipmap-*/ic_launcher.png`                | Launcher icon flavor dev (5 density: mdpi–xxxhdpi)                                               |
| `android/app/src/staging/res/mipmap-*/ic_launcher.png`            | Launcher icon flavor staging (5 density)                                                         |
| `.vscode/launch.json`                                             | 3 launch config VS Code (`rekanara dev/staging/prod`)                                            |
| `docs/flavors.md`                                                 | Dokumen ini                                                                                      |

### File Diubah

| File                                    | Perubahan                                                                                                        |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `android/app/build.gradle.kts`          | Tambah `flavorDimensions` + 3 `productFlavors` (dev/staging/prod)                                                 |
| `android/app/src/main/AndroidManifest.xml` | `android:label="rekanara getx"` → `android:label="@string/app_name"` (nama app per flavor)                    |
| `lib/infrastructure/network/environments.dart` | Import `FlavorService`; `_initEnvFromStorage()` hormati flavor lock; `switchEnvironment()` validasi flavor |
| `pubspec.yaml`                          | Tambah dependency `meta` (untuk `@visibleForTesting` di FlavorService); komentar config icon flavor                |
| `.github/workflows/ci.yml`              | `secret-guard`: path `google-services.json` diperbarui — `src/prod/` dilarang, `src/{dev,staging}/` boleh         |
| `.github/workflows/release.yml`         | **Matrix build 3 flavor** → 3 APK per release; decode `GOOGLE_SERVICES_JSON_PROD` secret untuk flavor prod        |
| `README.md`                             | Section "Native Flavors" + perintah run/build/icon                                                                |
| `test/infrastructure/network/environments_controller_test.dart` | Test baru untuk flavor lock (8 test total: 5 controller + 3 FlavorService)                 |

### Struktur Folder Android Setelah Perubahan

```
android/app/src/
├── main/            ← kode & resource umum (MainActivity, styles, icon default)
├── debug/           ← manifest debug (sudah ada, bawaan Flutter)
├── profile/         ← manifest profile (sudah ada, bawaan Flutter)
├── dev/             ← BARU (flavor dev)
│   └── res/mipmap-*/ic_launcher.png
├── staging/         ← BARU (flavor staging)
│   └── res/mipmap-*/ic_launcher.png
└── prod/            ← BELUM ADA — dibuat saat Anda menaruh google-services.json
    └── google-services.json   ← taruh di sini (jangan di-commit!)
```

Gradle otomatis menggabungkan `src/<flavor>/` **menimpa** `src/main/` saat build flavor
tersebut. Itulah kenapa icon dev/staging cukup diletakkan di folder flavor masing-masing,
dan `google-services.json` nanti juga per-flavor.

---

## Identitas Aplikasi per Flavor

| Flavor    | applicationId               | versionName     | Nama di launcher | Badge icon |
| --------- | --------------------------- | --------------- | ---------------- | ---------- |
| `dev`     | `com.rekanara.getx.dev`     | `1.0.0-dev`     | Rekanara Dev     | Ungu       |
| `staging` | `com.rekanara.getx.staging` | `1.0.0-stg`     | Rekanara Stg     | Oranye     |
| `prod`    | `com.rekanara.getx`         | `1.0.0`         | Rekanara         | —          |

Implementasinya di `android/app/build.gradle.kts` memakai **suffix**, bukan mengganti
`applicationId` — sehingga `MainActivity.kt` tidak perlu dipindah:

```kotlin
flavorDimensions += "environment"
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "Rekanara Dev")
    }
    create("staging") { /* suffix .staging, "-stg" */ }
    create("prod")    { /* tanpa suffix: ini app Play Store */ }
}
```

---

## Cara Pakai (Developer)

### Run / Build

> ⚠️ **`--flavor` sekarang WAJIB di Android.** `flutter run` tanpa `--flavor` akan gagal
> dengan error Gradle (`assembleDebug` tidak ditemukan / flavor dimension mismatch).

```bash
# Run debug per flavor
fvm flutter run --flavor dev
fvm flutter run --flavor staging
fvm flutter run --flavor prod

# Build APK release per flavor
fvm flutter build apk --release --flavor dev       # → app-dev-release.apk
fvm flutter build apk --release --flavor staging   # → app-staging-release.apk
fvm flutter build apk --release --flavor prod      # → app-prod-release.apk

# Output ada di build/app/outputs/flutter-apk/
```

**VS Code:** tekan F5 / pilih konfigurasi di tab Run and Debug:
`rekanara dev` (debug), `rekanara staging` (debug), `rekanara prod` (release mode).

### Regenerate Icon Flavor

Jalankan ini jika icon dasar `assets/icons/app_icon.png` diganti:

```bash
# 1. Generate icon ber-badget (butuh Python + Pillow)
pip install pillow
python3 tool/make_flavor_icons.py

# 2. Generate launcher icon per flavor
fvm dart run flutter_launcher_icons                                # prod (default config di pubspec.yaml)
fvm dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
fvm dart run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
```

> Flutter 3.x tidak punya bawaan Pillow/`magick` di semua mesin developer — script Python
> dipilih karena satu file, deterministik, dan warna badge terdokumentasi langsung di dalamnya.

### Test

```bash
# Semua test (termasuk flavor lock tests)
fvm flutter test

# Hanya test flavor & environment
fvm flutter test test/infrastructure/network/environments_controller_test.dart
```

---

## Firebase per Flavor (Setup yang Masih Perlu Dilakukan Manual)

Saat ini `google-services.json` **belum ada** untuk flavor manapun (file lama di
`android/app/src/google-services.json` sudah tidak dibaca lagi oleh plugin google-services
setelah ada flavor — lokasi yang benar adalah per-flavor).

**Langkah yang harus dilakukan (Firebase Console):**

1. Registrasikan **3 Android app** di project Firebase (atau 3 project terpisah — rekomendasi
   untuk isolasi penuh, konsisten dengan `.env` yang sudah memisahkan key per env):

   | App            | Package name                |
   | -------------- | --------------------------- |
   | Android (dev)  | `com.rekanara.getx.dev`     |
   | Android (stg)  | `com.rekanara.getx.staging` |
   | Android (prod) | `com.rekanara.getx`         |

2. Download `google-services.json` masing-masing dan taruh di:

   ```
   android/app/src/dev/google-services.json       ← boleh di-commit (bukan rahasia)
   android/app/src/staging/google-services.json   ← boleh di-commit (bukan rahasia)
   android/app/src/prod/google-services.json      ← JANGAN di-commit; secret-guard akan gagalkan
   ```

   > Kenapa dev/staging boleh di-commit? Isinya hanyalah identifier project + API key publik
   > klien — bukan kredensial. Namun kalau tim Anda lebih nyaman, ketiganya juga bisa
   > di-supply via CI secret seperti prod.

3. **Untuk CI/CD (prod):** encode file ke base64 dan set secret GitHub
   `GOOGLE_SERVICES_JSON_PROD`:

   ```bash
   base64 -i android/app/src/prod/google-services.json | pbcopy   # macOS, paste ke GitHub secret
   ```

   Workflow `release.yml` otomatis men-decode-nya ke `android/app/src/prod/` saat build flavor prod.

4. Update `firebase_options.dart` / `.env` jika project Firebase-nya berbeda per flavor —
   nilai per-env sudah disiapkan lewat `FIREBASE_*_DEV / _STAGING / _PROD` di `.env`.

---

## CI/CD

### `ci.yml` — secret-guard

Pola dilarang (regex) diperbarui:

```
.env
android/app/google-services.json          ← lokasi lama, tetap dilarang
android/app/src/prod/google-services.json ← prod config dilarang di-track
ios/Runner/GoogleService-Info.plist
android/key.properties
*.jks / *.keystore
```

`src/{dev,staging}/google-services.json` **sengaja tidak** masuk daftar larangan.

### `release.yml` — matrix build

Trigger tag `v*` → **3 job paralel** (dev, staging, prod) → satu GitHub Release berisi:

```
rekanara-<version>-dev.apk
rekanara-<version>-staging.apk
rekanara-<version>-prod.apk
```

- `fail-fast: false` → satu flavor gagal tidak membatalkan flavor lain.
- Flavor prod men-decode `GOOGLE_SERVICES_JSON_PROD` terlebih dahulu.
- APK di-rename per flavor + versi tag sebelum di-upload.

---

## Testing & Verifikasi

Sudah diverifikasi saat implementasi:

```bash
fvm flutter analyze   # No issues found
fvm flutter test      # 41 tests passed (termasuk 3 test FlavorService + 5 test controller)
fvm flutter build apk --release --flavor dev      # ✅ Built app-dev-release.apk
fvm flutter build apk --release --flavor staging  # ✅ Built app-staging-release.apk
fvm flutter build apk --release --flavor prod     # ✅ Built app-prod-release.apk
```

Coverage test flavor lock (`environments_controller_test.dart`):

- `FlavorService` dev: `canSwitchEnv == true`, allowed = `[dev, staging]`
- `FlavorService` staging: locked ke staging, switcher hidden
- `FlavorService` prod: locked ke prod, `isProduction == true`
- `EnvironmentController`: env dari storage yang tidak diizinkan flavor → fallback dev
- `EnvironmentController`: `switchEnvironment(prod)` di dev flavor → **ignored** (tidak crash)

---

## Troubleshooting

| Gejala                                                              | Penyebab & Solusi                                                                                              |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `flutter run` gagal: "Cannot find assembleDebug" / dimension mismatch | Lupa `--flavor`. Selalu gunakan `fvm flutter run --flavor <flavor>` atau launch config VS Code.                |
| App prod terpasang menimpa app dev (atau sebaliknya)                | Tidak mungkin jika suffix benar — cek `applicationIdSuffix` di build.gradle.kts dan uninstall app lama bawaan lama. |
| Icon device tidak berubah setelah regenerate                        | Launcher icon di-cache Android. Uninstall app lalu install ulang, atau jalankan `flutter clean` + build ulang.  |
| Crash saat init Firebase di build flavor                            | `google-services.json` belum ada di `android/app/src/<flavor>/`. Lihat [Firebase per Flavor](#firebase-per-flavor-setup-yang-masih-perlu-dilakukan-manual). |
| Switcher env tidak muncul di flavor dev                             | Cek `FlavorService.canSwitchEnv` — hanya flavor `dev` yang menampilkan switcher. Flavor staging/prod terkunci by design. |
| CI release gagal di flavor prod karena Firebase                     | Secret `GOOGLE_SERVICES_JSON_PROD` belum di-set di repo Settings → Secrets → Actions.                           |

---

## Roadmap iOS (belum diimplementasi)

iOS tidak punya "flavor" native — pendekatannya **Schemes + Build Configurations**:

1. 6 build configurations: `Debug-dev/Release-dev`, `Debug-staging/Release-staging`,
   `Debug-prod/Release-prod`.
2. 3 xcconfig per flavor (`ios/Flavors/{dev,staging,prod}.xcconfig`) berisi
   `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`, `ASSETCATALOG_COMPILER_APPICON_NAME`.
3. 3 Xcode schemes: `dev`, `staging`, `prod` (Flutter `--flavor` otomatis map ke scheme).
4. `GoogleService-Info.plist` per flavor + build phase script yang menyalin sesuai configuration.
5. Ikuti pola yang sama dengan `FlavorService` (tidak perlu ubah Dart code).

Referensi konsep: dokumentasi Flutter "Flavor assets and flavors on iOS".
