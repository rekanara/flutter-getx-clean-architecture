import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenSetting {
  Future<void> openSettings({
    required String label,
    required String message,
    Function()? afterCreateUpdate,
  }) async {
    final theme = Theme.of(Get.context!);
    await Get.dialog(
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 200),
      routeSettings: RouteSettings(name: 'openSettings $label'),
      name: 'openSettings $label',

      useSafeArea: true,

      Platform.isIOS
          ? CupertinoAlertDialog(
              title: Text('Permission $label', style: TextStyle(fontSize: 20)),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$message. Please go to settings to enable $label'),
                ],
              ),

              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    animationDuration: const Duration(milliseconds: 500),
                    shadowColor: theme.colorScheme.primary,
                    splashFactory: InkRipple.splashFactory,
                    surfaceTintColor: theme.colorScheme.primary,
                  ),

                  onPressed: () {
                    Get.back();
                    afterCreateUpdate;
                  },
                  child: const Text('Setting'),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    animationDuration: const Duration(milliseconds: 500),
                    shadowColor: Colors.red,
                    splashFactory: InkRipple.splashFactory,
                    surfaceTintColor: Colors.red,
                  ),
                  onPressed: Get.back,
                  child: const Text('Cancel'),
                ),
              ],
            )
          : AlertDialog(
              title: Text('Permission $label', style: TextStyle(fontSize: 20)),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  Text('Please go to settings to enable $label'),
                ],
              ),
              scrollable: true,
              clipBehavior: Clip.antiAlias,
              semanticLabel: 'Open Setting $label',

              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    animationDuration: const Duration(milliseconds: 500),
                    shadowColor: theme.colorScheme.primary,
                    splashFactory: InkRipple.splashFactory,
                    surfaceTintColor: theme.colorScheme.primary,
                  ),

                  onPressed: () {
                    Get.back();
                    afterCreateUpdate;
                  },
                  child: const Text('Setting'),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    animationDuration: const Duration(milliseconds: 500),
                    shadowColor: Colors.red,
                    splashFactory: InkRipple.splashFactory,
                    surfaceTintColor: Colors.red,
                  ),
                  onPressed: Get.back,
                  child: const Text('Cancel'),
                ),
              ],
            ),
    );
  }
}
