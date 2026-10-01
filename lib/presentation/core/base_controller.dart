import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../config/error/global_error_handler.dart';
import '../../domain/core/errors/failures.dart';
import '../../utils/helper/snackbar.dart';

/// Base controller that provides standard state management
/// for loading, errors, and [callUseCase] helper method.
///
/// Extend this controller in every presentation controller
/// to eliminate repetitive boilerplate.
abstract class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Helper to execute UseCase with automatic loading & error handling.
  ///
  /// - [showLoading]: If true, automatically sets isLoading
  /// - [onSuccess]: Callback when successful (Right)
  /// - [onFailure]: Custom error handler (optional, default: show snackbar)
  Future<void> callUseCase<T>(
    Future<Either<Failure, T>> call, {
    required Function(T data) onSuccess,
    Function(Failure failure)? onFailure,
    bool showLoading = true,
  }) async {
    if (showLoading) isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await call;

      result.fold((failure) {
        errorMessage.value = failure.message;
        if (onFailure != null) {
          onFailure(failure);
        } else {
          SnackbarHelper.showError(failure.message);
        }
      }, (data) => onSuccess(data));
    } catch (e, stackTrace) {
      GlobalErrorHandler.reportError(
        e,
        stackTrace,
        reason: 'BaseController.callUseCase ($T)',
      );
      errorMessage.value = 'Unexpected error occurred';
      SnackbarHelper.showError('Unexpected error occurred');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }
}
