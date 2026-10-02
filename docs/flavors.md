# Native Flavors (Dev / Staging / Prod)

Complete guide to the **Native Android Flavors** system in this boilerplate: concepts,
files added, their locations, usage, and how to add new configuration.

> **Current status: Android only.** iOS is not done yet — see [iOS Roadmap](#ios-roadmap-not-implemented-yet).
> **Important terminology:** do not confuse *flavor* (native build, compile-time) with
> *environment* (runtime switch in Dart). See [Concepts](#concept-flavor-vs-environment).

---

## Concept: Flavor vs Environment

| Aspect               | Flavor (native)                                 | Environment (runtime Dart)                     |
| -------------------- | ----------------------------------------------- | ---------------------------------------------- |
| Defined in           | `android/app/build.gradle.kts`                  | `Environment` enum (`environments.dart`)       |
| Selected when        | **Compile-time** (`--flavor dev` at build)      | Runtime (switcher UI + `GetStorage`)           |
| Changes what         | Package ID, app name, icon, FCM project         | Backend base URL, MQTT, Firebase keys (values) |
| Installed on device  | **3 separate apps, side-by-side**               | 1 app only                                     |
| Switch without rebuild? | ❌ Must rebuild                              | ✅ App restart is enough                       |

**Why both?** Flavors ensure dev/staging/prod are *different apps* — different package
IDs, installable side-by-side, no FCM token mixing. Environment (runtime) is kept for QA
flexibility to switch backends without a rebuild — but it is now **locked by the flavor**.

---

## Environment Locking Policy

`FlavorService` (`lib/config/flavor/flavor_service.dart`) reads the active flavor and
restricts which environments may be selected:

| Flavor    | Package ID                  | Allowed environments              | Switcher UI |
| --------- | --------------------------- | --------------------------------- | ----------- |
| `dev`     | `com.rekanara.getx.dev`     | `dev`, `staging` (**not prod**)   | ✅ Shown    |
| `staging` | `com.rekanara.getx.staging` | `staging` only (locked)           | ❌ Locked   |
| `prod`    | `com.rekanara.getx`         | `prod` only (locked)              | ❌ Locked   |

Technical rules enforced:

1. **Flavor always wins over storage.** On init, `EnvironmentController` reads
   `FlavorService.lockedEnvironment`. For the `staging`/`prod` flavors, the stored value
   is ignored and overwritten with the flavor's own environment.
2. **Stale invalid storage falls back.** If GetStorage contains `prod` but the flavor is
   `dev`, that value is ignored → falls back to `dev`.
3. **`switchEnvironment()` is a silent no-op** if the target environment is not in
   `FlavorService.allowedEnvironments`. No crash, no storage write.
4. The flavor is passed as `--dart-define=app.flavor=<flavor>` by the build system. When
   absent (e.g. `flutter test`), it falls back to `AppFlavor.dev`.

### Data flow at app start

```
main.dart
  │  GetStorage.init()
  ▼
EnvironmentController.onInit()
  │
  ├── FlavorService.lockedEnvironment != null ?   ← staging/prod flavor
  │       YES → currentEnv = locked, overwrite storage, done.
  │       NO  → read StorageValue.env from GetStorage
  │               ├── empty / unknown → dev
  │               └── present → validate against allowedEnvironments
  │                       ├── valid    → use stored value
  │                       └── invalid  → fallback dev
  ▼
ConfigEnvironments.config  ← used by url.dart, DioClient, etc.
```

---

## Files Added/Changed

### New Files

| File / Folder                                                     | Purpose                                                                                          |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `lib/config/flavor/flavor_service.dart`                           | `AppFlavor` enum + `FlavorService` (reads compile-time flavor, exposes `allowedEnvironments`)    |
| `tool/make_flavor_icons.py`                                       | Python script (Pillow) generating dev/staging icons with a color badge in the top-right corner  |
| `assets/icons/app_icon_dev.png`                                   | Base icon + **purple** badge (Material Purple 500) — script output                               |
| `assets/icons/app_icon_staging.png`                               | Base icon + **orange** badge (Material Orange 500) — script output                               |
| `flutter_launcher_icons-dev.yaml`                                 | flutter_launcher_icons config for the dev flavor                                                 |
| `flutter_launcher_icons-staging.yaml`                             | flutter_launcher_icons config for the staging flavor                                             |
| `android/app/src/dev/res/mipmap-*/ic_launcher.png`                | Dev flavor launcher icon (5 densities: mdpi–xxxhdpi)                                             |
| `android/app/src/staging/res/mipmap-*/ic_launcher.png`            | Staging flavor launcher icon (5 densities)                                                       |
| `.vscode/launch.json`                                             | 3 VS Code launch configs (`rekanara dev/staging/prod`)                                           |
| `docs/flavors.md`                                                 | This document                                                                                    |

### Changed Files

| File                                    | Change                                                                                                           |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `android/app/build.gradle.kts`          | Add `flavorDimensions` + 3 `productFlavors` (dev/staging/prod)                                                   |
| `android/app/src/main/AndroidManifest.xml` | `android:label="rekanara getx"` → `android:label="@string/app_name"` (per-flavor app name)                   |
| `lib/infrastructure/network/environments.dart` | Import `FlavorService`; `_initEnvFromStorage()` respects the flavor lock; `switchEnvironment()` validates |
| `pubspec.yaml`                          | Add `meta` dependency (for `@visibleForTesting` in FlavorService); flavor icon config comments                    |
| `.github/workflows/ci.yml`              | `secret-guard`: `google-services.json` paths updated — `src/prod/` forbidden, `src/{dev,staging}/` allowed        |
| `.github/workflows/release.yml`         | **3-flavor build matrix** → 3 APKs per release; decodes the `GOOGLE_SERVICES_JSON_PROD` secret for prod           |
| `README.md`                             | "Native Flavors" section + run/build/icon commands                                                                |
| `test/infrastructure/network/environments_controller_test.dart` | New flavor-lock tests (8 total: 5 controller + 3 FlavorService)                           |

### Android Folder Structure After the Change

```
android/app/src/
├── main/            ← shared code & resources (MainActivity, styles, default icon)
├── debug/           ← debug manifest (pre-existing, from Flutter)
├── profile/         ← profile manifest (pre-existing, from Flutter)
├── dev/             ← NEW (dev flavor)
│   └── res/mipmap-*/ic_launcher.png
├── staging/         ← NEW (staging flavor)
│   └── res/mipmap-*/ic_launcher.png
└── prod/            ← DOES NOT EXIST YET — created when you place google-services.json
    └── google-services.json   ← put it here (do not commit!)
```

Gradle automatically merges `src/<flavor>/` **over** `src/main/` when building that
flavor. That is why the dev/staging icons only need to live in their flavor folders, and
why `google-services.json` will be per-flavor too.

---

## App Identity per Flavor

| Flavor    | applicationId               | versionName     | Launcher name | Icon badge |
| --------- | --------------------------- | --------------- | ------------- | ---------- |
| `dev`     | `com.rekanara.getx.dev`     | `1.0.0-dev`     | Rekanara Dev  | Purple     |
| `staging` | `com.rekanara.getx.staging` | `1.0.0-stg`     | Rekanara Stg  | Orange     |
| `prod`    | `com.rekanara.getx`         | `1.0.0`         | Rekanara      | —          |

The implementation in `android/app/build.gradle.kts` uses **suffixes** instead of
replacing `applicationId` — so `MainActivity.kt` does not need to move:

```kotlin
flavorDimensions += "environment"
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "Rekanara Dev")
    }
    create("staging") { /* .staging suffix, "-stg" */ }
    create("prod")    { /* no suffix: this is the Play Store app */ }
}
```

---

## Usage (Developer)

### Run / Build

> ⚠️ **`--flavor` is now REQUIRED on Android.** `flutter run` without `--flavor` fails
> with a Gradle error (`assembleDebug` not found / flavor dimension mismatch).

```bash
# Run debug per flavor
fvm flutter run --flavor dev
fvm flutter run --flavor staging
fvm flutter run --flavor prod

# Build release APK per flavor
fvm flutter build apk --release --flavor dev       # → app-dev-release.apk
fvm flutter build apk --release --flavor staging   # → app-staging-release.apk
fvm flutter build apk --release --flavor prod      # → app-prod-release.apk

# Output lives in build/app/outputs/flutter-apk/
```

**VS Code:** press F5 / pick a config in the Run and Debug tab:
`rekanara dev` (debug), `rekanara staging` (debug), `rekanara prod` (release mode).

### Regenerate Flavor Icons

Run these if the base icon `assets/icons/app_icon.png` changes:

```bash
# 1. Generate badged icons (requires Python + Pillow)
pip install pillow
python3 tool/make_flavor_icons.py

# 2. Generate launcher icons per flavor
fvm dart run flutter_launcher_icons                                # prod (default config in pubspec.yaml)
fvm dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
fvm dart run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
```

> Flutter 3.x does not ship Pillow/`magick` on every developer machine — the Python
> script was chosen because it is a single file, deterministic, and the badge colors are
> documented directly inside it.

### Test

```bash
# All tests (including flavor-lock tests)
fvm flutter test

# Only flavor & environment tests
fvm flutter test test/infrastructure/network/environments_controller_test.dart
```

---

## Firebase per Flavor (Manual Setup Still Required)

Currently `google-services.json` **does not exist** for any flavor (the legacy file at
`android/app/src/google-services.json` is no longer read by the google-services plugin
once flavors exist — the correct location is per-flavor).

**Steps to perform (Firebase Console):**

1. Register **3 Android apps** in the Firebase project (or 3 separate projects —
   recommended for full isolation, consistent with `.env` which already splits keys per
   environment):

   | App            | Package name                |
   | -------------- | --------------------------- |
   | Android (dev)  | `com.rekanara.getx.dev`     |
   | Android (stg)  | `com.rekanara.getx.staging` |
   | Android (prod) | `com.rekanara.getx`         |

2. Download each `google-services.json` and place it at:

   ```
   android/app/src/dev/google-services.json       ← may be committed (not a secret)
   android/app/src/staging/google-services.json   ← may be committed (not a secret)
   android/app/src/prod/google-services.json      ← DO NOT commit; secret-guard will fail
   ```

   > Why may dev/staging be committed? They only contain project identifiers + public
   > client API keys — not credentials. However, if your team prefers, all three can also
   > be supplied via CI secrets like prod.

3. **For CI/CD (prod):** encode the file to base64 and set the GitHub secret
   `GOOGLE_SERVICES_JSON_PROD`:

   ```bash
   base64 -i android/app/src/prod/google-services.json | pbcopy   # macOS, paste into the GitHub secret
   ```

   The `release.yml` workflow automatically decodes it into `android/app/src/prod/` when
   building the prod flavor.

4. Update `firebase_options.dart` / `.env` if the Firebase project differs per flavor —
   per-env values are already prepared via `FIREBASE_*_DEV / _STAGING / _PROD` in `.env`.

---

## Configuration File Examples & Locations (Copy-Paste Ready)

A complete map of the files a developer needs to provision — locations + example
contents. **For each file below, just create it at the stated path and fill in the real
values from the Firebase Console / Play Console.**

### File Location Map

```
rekanara_getx/
├── .env                                    ← gitignored, REQUIRED (copy from .env.example)
├── android/
│   ├── key.properties                      ← gitignored, only for prod release signing
│   └── app/src/
│       ├── dev/google-services.json        ← MAY be committed
│       ├── staging/google-services.json    ← MAY be committed
│       └── prod/google-services.json       ← GITIGNORED + rejected by secret-guard
└── ios/Runner/
    └── GoogleService-Info.plist            ← gitignored (iOS, see Roadmap)
```

### 1. `google-services.json` (per flavor)

Download from **Firebase Console → ⚙️ Project Settings → General → Your apps → Android
app → google-services.json**, and place it in the flavor folder per the map above.

Example for the **dev** flavor (`android/app/src/dev/google-services.json`) —
the values below are placeholders only; take the real values from the downloaded file:

```json
{
  "project_info": {
    "project_number": "123456789012",
    "project_id": "rekanara-dev",
    "storage_bucket": "rekanara-dev.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:0123456789abcdef",
        "android_client_info": {
          "package_name": "com.rekanara.getx.dev"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

**What differs between flavors** (everything else may be identical):

| Field                              | dev                        | staging                        | prod                     |
| ---------------------------------- | -------------------------- | ------------------------------ | ------------------------ |
| `project_info.project_id`          | `rekanara-dev`             | `rekanara-staging`             | `rekanara-prod`          |
| `project_info.project_number`      | from the dev app           | from the staging app           | from the prod app        |
| `client_info.mobilesdk_app_id`     | app ID `com.rekanara.getx.dev` | app ID `com.rekanara.getx.staging` | app ID `com.rekanara.getx` |
| `client[].client_info.package_name`| `com.rekanara.getx.dev`    | `com.rekanara.getx.staging`    | `com.rekanara.getx`      |
| `api_key[].current_key`            | dev project API key        | staging project API key        | prod project API key     |

> ⚠️ `package_name` **must exactly match** the flavor's `applicationId`
> (see [App Identity per Flavor](#app-identity-per-flavor)) — if it differs, the
> google-services plugin fails during Gradle sync with
> `File google-services.json is missing` even though the file exists.

### 2. `.env`

Copy the template, then fill it in:

```bash
cp .env.example .env
```

The key structure relevant for Firebase/URL (one file, suffix per environment —
prod keys are written without a suffix, exactly like `.env.example`):

```dotenv
# --- URL ---
URL_BASE_DEV=https://api.dev.rekanara.com
URL_BASE_STAGING=https://api.staging.rekanara.com
URL_BASE=https://api.rekanara.com

# --- Firebase (Dart-side options, used by firebase_options.dart) ---
FIREBASE_PROJECT_ID_DEV=rekanara-dev
FIREBASE_PROJECT_ID_STAGING=rekanara-staging
FIREBASE_PROJECT_ID=rekanara-prod

FIREBASE_MESSAGING_SENDER_ID_DEV=123456789012
FIREBASE_MESSAGING_SENDER_ID_STAGING=234567890123
FIREBASE_MESSAGING_SENDER_ID=345678901234

ANDROID_FIREBASE_API_KEY_DEV=AIzaSy...dev
ANDROID_FIREBASE_API_KEY_STAGING=AIzaSy...stg
ANDROID_FIREBASE_API_KEY=AIzaSy...prod

ANDROID_FIREBASE_APPID_DEV=1:123456789012:android:0123456789abcdef
ANDROID_FIREBASE_APPID_STAGING=1:234567890123:android:abcdef0123456789
ANDROID_FIREBASE_APPID=1:345678901234:android:fedcba9876543210
```

> See `.env.example` for the full key list. **Do not remove any key** —
> `dotenv.env[...]!` crashes if a value is empty.

### 3. `android/key.properties` (release signing, optional)

Only needed for **prod** release builds signed for the Play Store. Generate the keystore
first, then create the file:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Contents of `android/key.properties` (replace every value with your own):

```properties
storePassword=yourKeystorePassword
keyPassword=yourKeyPassword
keyAlias=upload
storeFile=upload-keystore.jks
```

> `storeFile` is relative to `android/app/`. The `.jks` file is **never committed**
> (blocked by `.gitignore` + secret-guard). Back up the keystore securely —
> losing it means you can no longer update the app on the Play Store.

### 4. `GoogleService-Info.plist` (iOS — later)

Plist format; example structure (for when iOS flavors are implemented):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BUNDLE_ID</key>
	<string>com.rekanara.getx</string>
	<key>PROJECT_ID</key>
	<string>rekanara-prod</string>
	<key>STORAGE_BUCKET</key>
	<string>rekanara-prod.appspot.com</string>
	<key>GCM_SENDER_ID</key>
	<string>345678901234</string>
	<key>GOOGLE_APP_ID</key>
	<string>1:345678901234:ios:fedcba9876543210</string>
	<key>API_KEY</key>
	<string>AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</string>
	<key>GOOGLE_URL_SCHEME</key>
	<string>com.googleusercontent.apps.345678901234-fedcba9876543210</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>com.googleusercontent.apps.345678901234-fedcba9876543210</string>
	<key>SERVER_CLIENT_ID</key>
	<string>345678901234-abcdefabcdefabcdefabcdefabcdef.apps.googleusercontent.com</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>IS_ADS_ENABLED</key>
	<false/>
	<key>IS_ANALYTICS_ENABLED</key>
	<false/>
	<key>IS_APPINVITE_ENABLED</key>
	<true/>
	<key>IS_GCM_ENABLED</key>
	<true/>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
</dict>
</plist>
```

> This file lives per-scheme at `ios/Runner/flavors/<flavor>/GoogleService-Info.plist`
> (see [iOS Flavors](#ios-flavors) for the per-flavor folder layout and CI secret).

---

## CI/CD

### `ci.yml` — secret-guard

Forbidden patterns (regex), updated:

```
.env
android/app/google-services.json          ← legacy location, still forbidden
android/app/src/prod/google-services.json ← prod config must not be tracked
ios/Runner/GoogleService-Info.plist
ios/Runner/flavors/prod/GoogleService-Info.plist ← prod iOS config via CI secret
android/key.properties
*.jks / *.keystore
```

`src/{dev,staging}/google-services.json` and `ios/Runner/flavors/{dev,staging}/GoogleService-Info.plist` are **intentionally not** on the forbidden list (public client IDs — safe to commit).

### `release.yml` — build matrix

Triggered by `v*` tags → **6 parallel jobs** (3 APK on `ubuntu-latest`, 3 IPA on `macos-latest`) → one GitHub Release containing:

```
rekanara-<version>-dev.apk
rekanara-<version>-staging.apk
rekanara-<version>-prod.apk
rekanara-<version>-ios-dev.ipa
rekanara-<version>-ios-staging.ipa
rekanara-<version>-ios-prod.ipa
```

- `fail-fast: false` → one flavor failing does not cancel the others.
- Android: prod flavor decodes `GOOGLE_SERVICES_JSON_PROD` before building the APK.
- iOS: prod flavor decodes `GOOGLE_SERVICE_INFO_PLIST_PROD` before building the IPA.
- APKs/IPAs are renamed per flavor + tag version before upload.
- IPAs are built unsigned (`--no-codesign`) and packaged via `Payload/` zip. To ship a signed `.ipa`, provision Apple signing secrets and switch to `flutter build ipa --export-options-plist`.

---

## Testing & Verification

Verified during implementation:

```bash
fvm flutter analyze   # No issues found
fvm flutter test      # 41 tests passed (including 3 FlavorService + 5 controller tests)
fvm flutter build apk --release --flavor dev      # ✅ Built app-dev-release.apk
fvm flutter build apk --release --flavor staging  # ✅ Built app-staging-release.apk
fvm flutter build apk --release --flavor prod     # ✅ Built app-prod-release.apk
```

Flavor-lock test coverage (`environments_controller_test.dart`):

- `FlavorService` dev: `canSwitchEnv == true`, allowed = `[dev, staging]`
- `FlavorService` staging: locked to staging, switcher hidden
- `FlavorService` prod: locked to prod, `isProduction == true`
- `EnvironmentController`: stored env not allowed by the flavor → fallback to dev
- `EnvironmentController`: `switchEnvironment(prod)` on the dev flavor → **ignored** (no crash)

---

## Troubleshooting

| Symptom                                                              | Cause & Fix                                                                                                    |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `flutter run` fails: "Cannot find assembleDebug" / dimension mismatch | Missing `--flavor`. Always use `fvm flutter run --flavor <flavor>` or the VS Code launch config.              |
| Prod app install overwrites the dev app (or vice versa)              | Impossible if suffixes are correct — check `applicationIdSuffix` in build.gradle.kts and uninstall old installs. |
| Device icon does not change after regeneration                       | Android caches launcher icons. Uninstall the app then reinstall, or run `flutter clean` + rebuild.              |
| Crash during Firebase init in a flavor build                         | `google-services.json` missing in `android/app/src/<flavor>/`. See [Firebase per Flavor](#firebase-per-flavor-manual-setup-still-required). |
| Env switcher does not appear in the dev flavor                       | Check `FlavorService.canSwitchEnv` — only the `dev` flavor shows the switcher. Staging/prod are locked by design. |
| CI release fails on the prod flavor due to Firebase                  | Secret `GOOGLE_SERVICES_JSON_PROD` not set in repo Settings → Secrets → Actions.                                |

---

## iOS Flavors

iOS has no native "flavor" concept — the equivalent is **Schemes + Build Configurations**.

### Setup (already configured)

The project ships with 9 build configurations in `Runner.xcodeproj`:

| Configuration | Bundle ID | Display Name |
| ------------- | --------- | ----------- |
| `Debug-dev` / `Release-dev` / `Profile-dev` | `com.rekanara.getx.dev` | Rekanara Dev |
| `Debug-staging` / `Release-staging` / `Profile-staging` | `com.rekanara.getx.staging` | Rekanara Stg |
| `Debug-prod` / `Release-prod` / `Profile-prod` | `com.rekanara.getx` | Rekanara |

3 Xcode schemes (`dev`, `staging`, `prod`) map to these configurations. Flutter's
`--flavor` flag selects the scheme automatically.

`Info.plist` uses `$(APP_DISPLAY_NAME)` for `CFBundleDisplayName`, so each flavor
gets a distinct app name on the home screen — dev/staging/prod can sit side-by-side
on one device (same as Android `applicationIdSuffix`).

### Firebase per Flavor (iOS)

Place `GoogleService-Info.plist` inside the flavor folders:

| Flavor | Path | Git |
| ------ | ---- | --- |
| dev | `ios/Runner/flavors/dev/GoogleService-Info.plist` | Committable (public client ID) |
| staging | `ios/Runner/flavors/staging/GoogleService-Info.plist` | Committable (public client ID) |
| prod | `ios/Runner/flavors/prod/GoogleService-Info.plist` | Gitignored (provision via CI secret) |

A build phase script named **"Copy GoogleService-Info.plist"** reads
`$CONFIGURATION` (e.g. `Debug-dev`), extracts the flavor suffix, and copies the
matching plist into the app bundle automatically. No manual file swapping needed.

For CI, inject the prod plist via a base64 secret (`GOOGLE_SERVICE_INFO_PLIST_PROD`)
decoded into `ios/Runner/flavors/prod/GoogleService-Info.plist` before `flutter build ipa`.

### Running iOS Flavors

```bash
# Debug
fvm flutter run --flavor dev -t lib/main.dart
fvm flutter run --flavor staging -t lib/main.dart
fvm flutter run --flavor prod -t lib/main.dart

# Release IPA
fvm flutter build ipa --flavor dev --release
fvm flutter build ipa --flavor staging --release
fvm flutter build ipa --flavor prod --release
```

### Manual Setup Reference

If you need to recreate the iOS flavor setup in a fresh project, a reference script
is documented in `docs/flavors.md` history (commit `3f5e901`). The key steps:

1. Use the `xcodeproj` Ruby gem to duplicate `Debug`/`Release`/`Profile` configs
   into `Debug-{flavor}`/`Release-{flavor}`/`Profile-{flavor}` for each flavor.
2. Set `PRODUCT_BUNDLE_IDENTIFIER` and `APP_DISPLAY_NAME` per configuration.
3. Change `Info.plist` `CFBundleDisplayName` to `$(APP_DISPLAY_NAME)`.
4. Create one `.xcscheme` per flavor pointing at the flavor-specific configurations.
5. Add a "Copy GoogleService-Info.plist" shell script build phase.

Concept reference: Flutter docs "Build flavors and flavors on iOS".
