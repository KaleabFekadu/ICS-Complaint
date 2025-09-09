import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../loader/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    // Check if the connection was previously none and is now restored
    bool wasDisconnected = _connectionStatus.value == ConnectivityResult.none;
    _connectionStatus.value = result;

    if (_connectionStatus.value == ConnectivityResult.none) {
      // No internet connection
      TLoaders.warningSnackBar(
        title: 'No Internet Connection',
        message: 'Please check your internet connection',
      );
    } else if (wasDisconnected) {
      // Internet connection restored
      TLoaders.successSnackBar(
        title: 'Internet Restored',
        message: 'Your internet connection has been restored.',
      );
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } on PlatformException catch (_) {
      return false;
    }
  }

  StreamSubscription<ConnectivityResult> onConnectivityChanged(void Function(ConnectivityResult) onData) {
    return _connectivity.onConnectivityChanged.listen(onData);
  }

  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}