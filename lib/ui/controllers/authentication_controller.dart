import 'package:f_chat_template/data/model/local_login.dart';
import 'package:f_chat_template/data/model/user_location.dart';
import 'package:f_chat_template/domain/use_case/locator_service.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';
import 'user_controller.dart';

// este controlador esconde los detalles de la implementación de firebase
class AuthenticationController extends GetxController {
  final databaseReference = FirebaseDatabase.instance.ref();
  ConnectionController connectionController = Get.find();
  RxString name = "".obs;
  RxString ciudad = "".obs;
  RxString localEmail = "".obs;
  RxString localUid = "".obs;
  RxString localPass = "".obs;
  RxBool isLocal = false.obs;

  @override
  onInit() {
    super.onInit();
    connectionController.connected.listen((value) {
      if (value && localEmail.value != "") {
        updateUser();
      }
    });
  }

  // método usado para logearse en la aplicación
  Future<void> login(email, password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      loadUser(password);
      return Future.value();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Future.error("User not found");
      } else if (e.code == 'wrong-password') {
        return Future.error("Wrong password");
      }
    }
  }

  // método usado para crear un usuario
  Future<void> signup(email, password, name) async {
    try {

      // Get the user's location
      LocatorService locatorService = Get.find();

      UserLocation userLocation = await locatorService.getLocation();
      // Get the city name using geocoding
      String cityName = await locatorService.getCityName(
        userLocation.latitude,
        userLocation.longitude,
      );
      // primero creamos el usuario en el sistema de autenticación de firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      UserController userController = Get.find();

      // después creamos el usuario en la base de datos de tiempo real usando el
      // userController
      await userController.createUser(
          email, userCredential.user!.uid, name, cityName);
      return Future.value();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Future.error("The password is too weak");
      } else if (e.code == 'email-already-in-use') {
        return Future.error("The email is taken");
      }
    }
  }

  // método usado para hacer el signOut
  logout() async {
    try {
      if (isLocal.value) {
        logInfo("logout local");
        isLocal.value = false;
        name.value = "";
        ciudad.value = "";
        localEmail.value = "";
        localUid.value = "";
        localPass.value = "";
      } else {
        logInfo("logout remote");
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      return Future.error("Logout error");
    }
  }

  String userEmail() {
    String email;
    if (isLocal.value) {
      email = localEmail.value;
    } else {
      email = FirebaseAuth.instance.currentUser!.email ?? "a@a.com";
    }
    return email;
  }

  String getUid() {
    String uid;
    if (isLocal.value) {
      uid = localUid.value;
    } else {
      uid = FirebaseAuth.instance.currentUser!.uid;
    }
    return uid;
  }

  Future<void> joinGroup(group) async {
    logInfo(
        "Adding user to group in realTime for ${userEmail()} and ${getUid()}");
    try {
      await databaseReference
          .child('groupList')
          .child(group)
          .child('users')
          .child(getUid())
          .set({'email': userEmail(), 'uid': getUid(), 'name': name.value});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }

  getValues() async {
    DataSnapshot ref = await databaseReference.child("userList").get();
    var users = ref.children;
    for (var user in users) {
      var userMap = user.value as Map<dynamic, dynamic>;
      if (userMap["uid"] == getUid()) {
        name.value = userMap["alias"];
        ciudad.value = userMap["ciudad"];
      }
    }
  }

  void loadUser(password) {
    Hive.box("logins")
        .add(LocalLogin(userEmail(), password, getUid(), name.value, ciudad.value));
  }

  void setLocal(String email, String user, String uid, String password, String city) {
    localEmail.value = email;
    name.value = user;
    localUid.value = uid;
    localPass.value = password;
    ciudad.value = city;
    isLocal.value = true;
  }

  void updateUser() {
    logInfo("Updating user");
    login(localEmail, localPass);
  }
}
