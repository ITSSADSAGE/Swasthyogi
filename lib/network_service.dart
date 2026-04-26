import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkSpeed { high, low, none }

class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  static Future<NetworkSpeed> getNetworkSpeed() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return NetworkSpeed.none;
      }

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return NetworkSpeed.high;
      }

      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return NetworkSpeed.high;
      }

      return NetworkSpeed.none;
    } catch (e) {
      print("Error checking network speed: $e");
      return NetworkSpeed.none;
    }
  }

  static Stream<NetworkSpeed> get onSpeedChanged {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      return await getNetworkSpeed();
    });
  }
}
