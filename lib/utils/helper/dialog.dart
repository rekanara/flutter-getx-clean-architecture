import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/atoms/custom_text.dart';
import '../config.dart';

class DialogHelper {
  /// Show error dialog from response model
  static Future<void> showInfoDialog(
    String message, [
    bool isSuccess = false,
    String? title,
  ]) async {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text(title ?? (isSuccess ? 'Success' : 'Error')),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            isDefaultAction: true,
            child: const CustomText(
              text: 'Okay',
              fontType: FontType.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Show alert dialog
  static Future<void> showDialog({
    String? name,
    String? message,
    required String title,
    String? submitText,
    String? cancelText,
    Function()? onSubmit,
    Function()? onCancel,
    Color? submitColor,
    Color? cancelColor,
    bool barrierDismissible = true,
    Object? arguments,
    Widget? content,
    List<Widget>? actions,
  }) async {
    final theme = Get.theme;
    await Get.dialog(
      barrierDismissible: barrierDismissible,
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 200),
      routeSettings: RouteSettings(name: 'alertDialog ${name ?? 'default'}'),
      name: 'alertDialog ${name ?? 'default'}',
      arguments: arguments,

      useSafeArea: true,

      AlertDialog(
        title: CustomText(text: title, fontType: FontType.titleMedium),
        content:
            content ??
            CustomText(
              text: message ?? 'Are you sure?',
              fontType: FontType.bodyMedium,
              maxLines: 20,
            ),
        scrollable: true,
        clipBehavior: Clip.antiAlias,
        semanticLabel: 'Alert Dialog ${name ?? 'default'}',

        actions:
            actions ??
            <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: cancelColor ?? Colors.red,
                  animationDuration: const Duration(milliseconds: 500),
                  shadowColor: cancelColor ?? Colors.red,
                  splashFactory: InkRipple.splashFactory,
                  surfaceTintColor: cancelColor ?? Colors.red,
                ),
                onPressed: () {
                  Get.back();
                  onCancel == null ? null : onCancel();
                },
                child: Text(cancelText ?? 'Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: submitColor ?? theme.colorScheme.primary,
                  animationDuration: const Duration(milliseconds: 500),
                  shadowColor: submitColor ?? theme.colorScheme.primary,
                  splashFactory: InkRipple.splashFactory,
                  surfaceTintColor: submitColor ?? theme.colorScheme.primary,
                ),

                onPressed: () {
                  Get.back();
                  onSubmit == null ? null : onSubmit();
                },
                child: Text(submitText ?? 'OK'),
              ),
            ],
      ),
    );
  }

  /// Close any open dialog.
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }
}
