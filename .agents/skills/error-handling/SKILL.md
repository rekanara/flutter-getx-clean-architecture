---
name: Error Handling
description: Handling errors gracefully (GlobalErrorHandler, Either<Failure, T>)
---
# Skill: Error Handling

Guide to layered error handling: GlobalErrorHandler (uncaught), Either<Failure, T> (domain), and callUseCase (presentation).

---

## Error Handling Layers

```
Layer 1: GlobalErrorHandler (uncaught errors)
    ↓
Layer 2: Either<Failure, T> in Domain/Infrastructure
    ↓
Layer 3: callUseCase() in BaseController (presentation)
    ↓
Layer 4: UI (Obx errorMessage or custom onFailure)
```

---

## Layer 1: GlobalErrorHandler

`lib/config/error/global_error_handler.dart`

Catches unhandled errors:

```dart
// main.dart — already set up, no reconfiguration needed
GlobalErrorHandler.init(() async {
  await _initializeApp();
});

// 3 handlers:
FlutterError.onError          // Flutter framework errors (widgets, rendering)
PlatformDispatcher.instance.onError // Uncaught async errors (returns true = handled)
runZonedGuarded zone          // Safety net for all errors
```

### Manual Reporting

```dart
// Report error to Crashlytics/Sentry (future)
GlobalErrorHandler.reportError(error, stackTrace, reason: 'Context info');

// Log event to analytics
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

class TimeoutFailure extends Failure {
  TimeoutFailure([super.message = 'Connection timeout']);
}

class NoConnectionFailure extends Failure {
  NoConnectionFailure([super.message = 'No internet connection']);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([super.message = 'Unauthorized session']);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
```

### Usage in RepositoryImpl

```dart
// Network error
} on DioException catch (e) {
  final message = e.response?.data?['message'] as String?;
  return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
}

// Cache/storage error
} catch (e) {
  return Left(CacheFailure('Failed to read data: $e'));
}

// Business logic error
if (response.data['success'] == false) {
  return Left(ServerFailure(response.data['message']));
}
```

### Add a New Failure Type

`TimeoutFailure`, `NoConnectionFailure`, and `UnauthorizedFailure` **already exist** (see above) — just use them, no need to recreate. If another type is needed:

```dart
class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}
```

---

## Layer 3: callUseCase in BaseController

```dart
// Default: show SnackbarHelper.showError(failure.message)
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  // onFailure not needed → auto snackbar
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

// Without loading indicator (background refresh)
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => items.assignAll(data),
  showLoading: false,
);
```

---

## Layer 4: UI Error State

```dart
// Accessing errorMessage in UI
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
          title: 'Try Again',
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

## DioException Handling Details

```dart
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Left(ServerFailure('Connection timeout. Check your internet connection.'));

    case DioExceptionType.badResponse:
      // Server returned error status code (4xx, 5xx)
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] as String?;

      if (statusCode == 422) {
        // Validation error from server
        return Left(ServerFailure(message ?? 'Invalid data'));
      }
      if (statusCode == 403) {
        return Left(ServerFailure('Access denied'));
      }
      return Left(ServerFailure(message ?? 'Server error ($statusCode)'));

    case DioExceptionType.cancel:
      return Left(ServerFailure('Request cancelled'));

    default:
      return Left(ServerFailure(e.message ?? 'Network Error'));
  }
}
```

---

## SnackbarHelper

```dart
// Shortcuts for showing error/success
SnackbarHelper.showError('Failed to load data');
SnackbarHelper.showSuccess('Data saved successfully');
SnackbarHelper.showWarning('Unstable connection');
SnackbarHelper.showInfo('Update available');

// Custom snackbar
SnackbarHelper.show(
  status: SnackStatus.error,
  message: 'Error details',
  title: 'Oops!',
  duration: const Duration(seconds: 5),
);
```

---

## LoggerHelper

```dart
LoggerHelper.d('Debug info');           // Debug
LoggerHelper.i('Important info');       // Info
LoggerHelper.w('Warning');              // Warning
LoggerHelper.e(                         // Error with stack trace
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
[ ] GlobalErrorHandler.init() is present in main.dart
[ ] Repository: return Left(ServerFailure/CacheFailure) in catch blocks
[ ] DioException: extract message from e.response?.data?['message']
[ ] Controller: use callUseCase() — no manual folding needed
[ ] UI: display controller.errorMessage.value if not empty
[ ] Custom onFailure for errors requiring special treatment
[ ] Add Failure subclass if a new error type is needed
```
