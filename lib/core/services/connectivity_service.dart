import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class IConnectivityService {
  Future<bool> isConnected();
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) => _hasConnection(results));
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}
