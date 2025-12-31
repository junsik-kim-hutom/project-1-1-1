import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum NetworkStatus {
  online,
  offline,
}

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetConnectionChecker =
      InternetConnectionChecker();

  // Stream controller to broadcast network status updates
  final _controller = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get networkStatusStream => _controller.stream;

  // Track last emited status to avoid duplicates
  NetworkStatus? _lastStatus;

  NetworkService() {
    _initialize();
  }

  void _initialize() {
    // Listen to connectivity changes (WiFi, Mobile, None)
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkInternetConnection([result]);
    });
  }

  Future<void> _checkInternetConnection(
      List<ConnectivityResult> results) async {
    // Check if device is connected to any network interface
    bool hasConnection = results.isNotEmpty &&
        results.any((element) => element != ConnectivityResult.none);

    if (hasConnection) {
      // If connected to network, verify actual internet access
      bool hasInternet = await _internetConnectionChecker.hasConnection;
      _emitStatus(hasInternet ? NetworkStatus.online : NetworkStatus.offline);
    } else {
      _emitStatus(NetworkStatus.offline);
    }
  }

  void _emitStatus(NetworkStatus status) {
    if (_lastStatus != status) {
      _lastStatus = status;
      _controller.add(status);
    }
  }

  // Allow manual check
  Future<NetworkStatus> checkStatus() async {
    bool hasInternet = await _internetConnectionChecker.hasConnection;
    return hasInternet ? NetworkStatus.online : NetworkStatus.offline;
  }

  void dispose() {
    _controller.close();
  }
}
