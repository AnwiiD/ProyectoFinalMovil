import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

class ConnectionController extends GetxController {

Connectivity connectivity = Connectivity();

Rx<ConnectivityResult> connected = ConnectivityResult.none.obs;

void initState() {
  logInfo("Listening to connection...");
  connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    connected.value =  result;
  });
}

}