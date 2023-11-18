import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

class ConnectionController extends GetxController {
  Connectivity connectivity = Connectivity();
  Rx<ConnectivityResult> connected = ConnectivityResult.none.obs;
  late StreamSubscription<ConnectivityResult> conSubs;

  @override
  Future<void> onInit() async {
    logInfo("First connection...");
    connected.value = await connectivity.checkConnectivity();
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      logInfo("Connection Changed");
      connected.value = result;
    });

    connected.listen((value) {
      logInfo("connection changed $value");
      
    });
    super.onInit();
  }
}
