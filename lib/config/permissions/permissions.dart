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
      // _showToast('Izin notifikasi diperlukan untuk menerima pemberitahuan penting.');
    }
    // location permission optional
    bool isLocationGranted = await requestLocationPermission();
    if (isLocationGranted) {
      _logger.i('Location Permission Granted');
    } else {
      _logger.w('Location Permission Denied');
      // _showToast('Izin lokasi diperlukan untuk fitur berbasis lokasi.');
    }

    // camera permission optional
    bool isCameraGranted = await requestCameraPermission();
    if (isCameraGranted) {
      _logger.i('Camera Permission Granted');
    } else {
      _logger.w('Camera Permission Denied');
      // _showToast('Izin kamera diperlukan untuk mengambil foto atau video.');
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
          // _showToast('Izin $permissionName ditolak. Beberapa fitur mungkin tidak berfungsi.');
          return false;
        }
      } else if (status.isPermanentlyDenied) {
        _logger.w('$permissionName Permission Permanently Denied');
        OpenSetting().openSettings(
          label: permissionName,
          message: '$permissionName Permission required for certain features',
          afterCreateUpdate: () async {
            await openAppSettings().then((value) {
              _logger.i('openAppSettings value: $value');
            });
          },
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error when requesting $permissionName permission: $e');
      // _showToast('Terjadi kesalahan saat meminta izin $permissionName.');
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
