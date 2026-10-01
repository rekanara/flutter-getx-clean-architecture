import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkObserverService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isFirstCheck = true;
  bool _wasOffline = false;

  Future<NetworkObserverService> init() async {
    // Listen to network changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    // Check initial status
    final initialStatus = await _connectivity.checkConnectivity();
    _updateConnectionStatus(initialStatus);

    return this;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isOffline =
        results.contains(ConnectivityResult.none) || results.isEmpty;

    if (isOffline) {
      if (!_isFirstCheck || _wasOffline == false) {
        // Show persistent offline snackbar
        if (!Get.isSnackbarOpen) {
          Get.rawSnackbar(
            message:
                'No Internet Connection. Please check your network settings.',
            isDismissible: false,
            duration: const Duration(days: 1), // Keeps it open
            backgroundColor: Colors.red[800]!,
            icon: const Icon(Icons.wifi_off, color: Colors.white),
            snackPosition: SnackPosition.TOP,
          );
        }
      }
      _wasOffline = true;
    } else {
      if (_wasOffline) {
        // Close the offline snackbar if it's open
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }

        // Show a brief back-online message
        Get.rawSnackbar(
          message: 'Back online!',
          backgroundColor: Colors.green[700]!,
          icon: const Icon(Icons.wifi, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
      _wasOffline = false;
    }

    _isFirstCheck = false;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
