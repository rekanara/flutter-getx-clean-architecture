import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../domain/core/errors/failures.dart';
import '../../utils/helper/snackbar.dart';

/// Base controller using **manual update** approach (GetBuilder).
///
/// Unlike [BaseController] which uses `.obs` + `Obx` (reactive),
/// this controller uses `update()` to trigger UI rebuilds
/// and must be wrapped with `GetBuilder<T>` in the widget.
///
/// **When to use:**
/// - Heavy forms (50+ fields) — more memory efficient without `.obs` per field
/// - State that rarely changes
/// - Performance optimization in very large lists/widgets
///
/// **UI Example:**
/// ```dart
/// GetBuilder<MyController>(
///   builder: (c) => Text(c.isLoading ? 'Loading...' : 'Done'),
/// )
/// ```
abstract class BaseBuilderController extends GetxController {
  bool isLoading = false;
  String errorMessage = '';

  /// Helper to execute UseCase with automatic loading & error handling.
  ///
  /// Similar to `BaseController.callUseCase()` but uses `update()`
  /// instead of `.obs` to trigger UI rebuilds.
  ///
  /// - [id] optional — if provided, only widgets with that id will rebuild
  /// - [showLoading] If true, automatically sets isLoading + update()
  Future<void> callUseCase<T>(
    Future<Either<Failure, T>> call, {
    required Function(T data) onSuccess,
    Function(Failure failure)? onFailure,
    bool showLoading = true,
    Object? id,
  }) async {
    if (showLoading) {
      isLoading = true;
      update(id != null ? [id] : null);
    }
    errorMessage = '';

    try {
      final result = await call;

      result.fold((failure) {
        errorMessage = failure.message;
        if (onFailure != null) {
          onFailure(failure);
        } else {
          SnackbarHelper.showError(failure.message);
        }
      }, (data) => onSuccess(data));
    } catch (e) {
      errorMessage = 'Unexpected error occurred';
      SnackbarHelper.showError('Unexpected error occurred');
    } finally {
      if (showLoading) {
        isLoading = false;
        update(id != null ? [id] : null);
      }
    }
  }
}
