import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

class ConnectionController extends GetxController {
  Connectivity connectivity = Connectivity();
  RxBool connected = false.obs;

  @override
  Future<void> onInit() async {
    logInfo("First connection...");
    connected.value = await connectivity.checkConnectivity() == ConnectivityResult.none ? false: true;
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      connected.value = result == ConnectivityResult.none ? false: true;
    });

    super.onInit();
  }

}
