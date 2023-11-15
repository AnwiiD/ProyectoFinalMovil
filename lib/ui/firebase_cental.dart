import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:f_chat_template/ui/pages/user_list_page.dart';
import 'package:f_chat_template/ui/pages/authentication_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseCentral extends StatelessWidget {
  FirebaseCentral({Key? key}) : super(key: key);

  final ConnectionController connectionController = Get.find();

  @override
  Widget build(BuildContext context) {
    // aquí dependiendo del estado de autenticación, el cual
    // obtenemos en el stream, vamos a cargar la interfaz de autenticación
    // o el UserListPage
    connectionController.onInit();
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const UserListPage();
          } else {
            return AuthenticationPage();
          }
        });
  }
}
