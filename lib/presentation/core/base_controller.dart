import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../domain/core/errors/failures.dart';
import '../../utils/helper/snackbar.dart';

/// Base controller yang menyediakan state management standar
/// untuk loading, error, dan helper method [callUseCase].
///
/// Extend controller ini di setiap presentation controller
/// untuk menghilangkan boilerplate berulang.
abstract class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Helper untuk mengeksekusi UseCase dengan handling loading & error otomatis.
  ///
  /// - [showLoading]: Jika true, otomatis set isLoading
  /// - [onSuccess]: Callback saat berhasil (Right)
  /// - [onFailure]: Custom error handler (opsional, default: show snackbar)
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
    } catch (e) {
      errorMessage.value = 'Unexpected error occurred';
      SnackbarHelper.showError('Unexpected error occurred');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }
}
