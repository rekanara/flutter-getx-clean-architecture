import 'dart:async';

import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/helper/open_setting.dart';

class PermissionHandler {
  final Logger _logger = Logger();

  Future<void> init() async {
    // notification permission optional
    bool isNotificationGranted = await requestNotificationPermission();
    if (isNotificationGranted) {
      _logger.i('Notification Permission Granted');
    } else {
      _logger.w('Notification Permission Denied');
      // _showToast('Notification permission is required to receive important notifications.');
    }
    // location permission optional
    bool isLocationGranted = await requestLocationPermission();
    if (isLocationGranted) {
      _logger.i('Location Permission Granted');
    } else {
      _logger.w('Location Permission Denied');
      // _showToast('Location permission is required for location-based features.');
    }

    // camera permission optional
    bool isCameraGranted = await requestCameraPermission();
    if (isCameraGranted) {
      _logger.i('Camera Permission Granted');
    } else {
      _logger.w('Camera Permission Denied');
      // _showToast('Camera permission is required to take photos or videos.');
    }
  }

  /// general method to request permission and handle error
  Future<bool> _requestPermission(
    Permission permission,
    String permissionName,
  ) async {
    try {
      PermissionStatus status = await permission.status;

      if (status.isGranted) {
        _logger.i('$permissionName Permission Granted');
        return true;
      } else if (status.isDenied) {
        status = await permission.request();
        if (status.isGranted) {
          _logger.i('$permissionName Permission Granted after request');
          return true;
        } else {
          status = await permission.request();
          _logger.w('$permissionName Permission Denied');
          // _showToast('$permissionName permission denied. Some features may not work.');
          return false;
        }
      } else if (status.isPermanentlyDenied) {
        _logger.w('$permissionName Permission Permanently Denied');
        unawaited(
          OpenSetting().openSettings(
            label: permissionName,
            message: '$permissionName Permission required for certain features',
            afterCreateUpdate: () async {
              await openAppSettings().then((value) {
                _logger.i('openAppSettings value: $value');
              });
            },
          ),
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error when requesting $permissionName permission: $e');
      // _showToast('An error occurred while requesting $permissionName permission.');
    }

    return false;
  }

  /// request notification permission
  Future<bool> requestNotificationPermission() async {
    return _requestPermission(Permission.notification, 'Notification');
  }

  /// request location permission
  Future<bool> requestLocationPermission() async {
    return _requestPermission(Permission.locationWhenInUse, 'Location');
  }

  /// request storage permission
  Future<bool> requestStoragePermission() async {
    return _requestPermission(Permission.storage, 'Storage');
  }

  /// request camera permission
  Future<bool> requestCameraPermission() async {
    return _requestPermission(Permission.camera, 'Camera');
  }
}
