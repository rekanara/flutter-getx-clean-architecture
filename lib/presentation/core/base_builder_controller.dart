import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../domain/core/errors/failures.dart';
import '../../utils/helper/snackbar.dart';

/// Base controller menggunakan pendekatan **manual update** (GetBuilder).
///
/// Berbeda dengan [BaseController] yang menggunakan `.obs` + `Obx` (reactive),
/// controller ini menggunakan `update()` untuk trigger rebuild UI
/// dan harus di-wrap dengan `GetBuilder<T>` di widget.
///
/// **Kapan pakai:**
/// - Form berat (50+ field) — lebih hemat memory tanpa `.obs` per field
/// - State yang jarang berubah
/// - Optimasi performa di list/widget yang sangat banyak
///
/// **Contoh di UI:**
/// ```dart
/// GetBuilder<MyController>(
///   builder: (c) => Text(c.isLoading ? 'Loading...' : 'Done'),
/// )
/// ```
abstract class BaseBuilderController extends GetxController {
  bool isLoading = false;
  String errorMessage = '';

  /// Helper untuk mengeksekusi UseCase dengan handling loading & error otomatis.
  ///
  /// Sama seperti `BaseController.callUseCase()` tapi menggunakan `update()`
  /// sebagai pengganti `.obs` untuk trigger rebuild UI.
  ///
  /// - [id] opsional — jika diberikan, hanya widget dengan id tersebut yang rebuild
  /// - [showLoading] Jika true, otomatis set isLoading + update()
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
