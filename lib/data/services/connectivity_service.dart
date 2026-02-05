// 🌐 Connectivity Service
//
// Monitors network connectivity status

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Check initial connectivity
    _connectivity.checkConnectivity().then((result) {
      _updateConnectionStatus(result);
    });

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}
