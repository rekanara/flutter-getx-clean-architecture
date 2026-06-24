# Skill: Error Handling

Panduan error handling berlapis: GlobalErrorHandler (uncaught), Either<Failure, T> (domain), dan callUseCase (presentation).

---

## Lapisan Error Handling

```
Layer 1: GlobalErrorHandler (uncaught errors)
    ↓
Layer 2: Either<Failure, T> di Domain/Infrastructure
    ↓
Layer 3: callUseCase() di BaseController (presentation)
    ↓
Layer 4: UI (Obx errorMessage atau custom onFailure)
```

---

## Layer 1: GlobalErrorHandler

`lib/config/error/global_error_handler.dart`

Menangkap error yang tidak di-handle:

```dart
// main.dart — sudah setup, tidak perlu konfigurasi ulang
GlobalErrorHandler.init(() async {
  await _initializeApp();
});

// 3 handler:
FlutterError.onError          // Flutter framework errors (widgets, rendering)
PlatformDispatcher.instance.onError // Uncaught async errors (returns true = handled)
runZonedGuarded zone          // Safety net untuk semua error
```

### Manual Reporting

```dart
// Report error ke Crashlytics/Sentry (future)
GlobalErrorHandler.reportError(error, stackTrace, reason: 'Context info');

// Log event ke analytics
GlobalErrorHandler.logEvent('button_tapped', {'button': 'login'});
```

---

## Layer 2: Failure Types

`lib/domain/core/errors/failures.dart`

```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
```

### Penggunaan di RepositoryImpl

```dart
// Network error
} on DioException catch (e) {
  final message = e.response?.data?['message'] as String?;
  return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
}

// Cache/storage error
} catch (e) {
  return Left(CacheFailure('Gagal membaca data: $e'));
}

// Business logic error
if (response.data['success'] == false) {
  return Left(ServerFailure(response.data['message']));
}
```

### Tambah Failure Type Baru

```dart
class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure() : super('Koneksi timeout. Coba lagi.');
}
```

---

## Layer 3: callUseCase di BaseController

```dart
// Default: tampilkan SnackbarHelper.showError(failure.message)
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  // onFailure tidak perlu → auto snackbar
);

// Custom onFailure
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  onFailure: (failure) {
    if (failure is ServerFailure) {
      DialogHelper.showInfoDialog(failure.message, isSuccess: false);
    } else {
      SnackbarHelper.showError(failure.message);
    }
  },
);

// Tanpa loading indicator (background refresh)
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  showLoading: false,
);
```

---

## Layer 4: UI Error State

```dart
// Mengakses errorMessage di UI
Obx(() {
  if (controller.isLoading.value) {
    return const CircularProgressIndicator();
  }
  if (controller.errorMessage.value.isNotEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 8),
        Text(controller.errorMessage.value),
        const SizedBox(height: 16),
        CustomButton(
          title: 'Coba Lagi',
          onPressed: controller.fetchData,
          width: 160,
        ),
      ],
    );
  }
  return _buildContent();
})
```

---

## DioException Handling Detail

```dart
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Left(ServerFailure('Koneksi timeout. Periksa koneksi internet Anda.'));

    case DioExceptionType.badResponse:
      // Server mengembalikan status code error (4xx, 5xx)
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] as String?;

      if (statusCode == 422) {
        // Validation error dari server
        return Left(ServerFailure(message ?? 'Data tidak valid'));
      }
      if (statusCode == 403) {
        return Left(ServerFailure('Akses ditolak'));
      }
      return Left(ServerFailure(message ?? 'Server error ($statusCode)'));

    case DioExceptionType.cancel:
      return Left(ServerFailure('Request dibatalkan'));

    default:
      return Left(ServerFailure(e.message ?? 'Network Error'));
  }
}
```

---

## SnackbarHelper

```dart
// Shortcuts untuk menampilkan error/success
SnackbarHelper.showError('Gagal memuat data');
SnackbarHelper.showSuccess('Data berhasil disimpan');
SnackbarHelper.showWarning('Koneksi tidak stabil');
SnackbarHelper.showInfo('Pembaruan tersedia');

// Custom snackbar
SnackbarHelper.show(
  status: MessageType.error,
  message: 'Error detail',
  title: 'Oops!',
  duration: const Duration(seconds: 5),
);
```

---

## LoggerHelper

```dart
LoggerHelper.d('Debug info');           // Debug
LoggerHelper.i('Informasi penting');    // Info
LoggerHelper.w('Peringatan');           // Warning
LoggerHelper.e(                         // Error dengan stack trace
  'Error message',
  error: exception,
  stackTrace: stackTrace,
);
LoggerHelper.t('Verbose trace');        // Trace
LoggerHelper.f('Fatal error');          // Fatal
```

---

## Checklist

```
[ ] GlobalErrorHandler.init() di main.dart sudah ada
[ ] Repository: return Left(ServerFailure/CacheFailure) di catch blocks
[ ] DioException: ambil message dari e.response?.data?['message']
[ ] Controller: gunakan callUseCase() — tidak perlu manual fold
[ ] UI: tampilkan controller.errorMessage.value jika ada
[ ] Custom onFailure untuk error yang butuh perlakuan khusus
[ ] Tambah Failure subclass jika butuh tipe error baru
```
