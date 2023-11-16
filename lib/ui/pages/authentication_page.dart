import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:f_chat_template/ui/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/authentication_controller.dart';

// una interfaz muy sencilla en la que podemos crear los tres usuarios (signup)
// y después logearse (login) con cualquiera de las tres

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({Key? key}) : super(key: key);
  final AuthenticationController authenticationController = Get.find();
  final ConnectionController connectionController = Get.find();

  void login(String user, String password) async {
    try {
      await authenticationController.login(user, password);
    } catch (error) {
      switch (error) {
        case 'User not found':
          Get.snackbar(
            "Login Error",
            'Los datos son erróneos, verifique y vuelva a intentar',
            icon: const Icon(Icons.person, color: Colors.red),
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        case 'Wrong password':
          Get.snackbar(
            "Login Error",
            'Los datos son erróneos, verifique y vuelva a intentar',
            icon: const Icon(Icons.person, color: Colors.red),
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController =
        TextEditingController(text: 'a@a.com');
    final TextEditingController passwordController =
        TextEditingController(text: '123456');
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.wifi),
          onPressed: () {
            var connection = connectionController.connected.value;
            if (connection == ConnectivityResult.none) {
              connectionController.connected.value = ConnectivityResult.wifi;
            } else {
              connectionController.connected.value = ConnectivityResult.none;
            }
          },
        ),
      ], title: const Text("Chat App - Login")),
      body: SafeArea(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                      labelText: 'Correo Electrónico'),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Contraseña'),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    login(emailController.text,
                                        passwordController.text);
                                  },
                                  child: const Text('Iniciar Sesión'),
                                ),
                                Obx(() => Text(
                                      connectionController.connected.value ==
                                              ConnectivityResult.none
                                          ? "No Connection"
                                          : "Connected to ${connectionController.connected.value.name}",
                                    ))
                              ]),
                        )),
                  ),
                ),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  '¿Aún no tienes una cuenta? Registrate aquí',
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (connectionController.connected.value ==
                                        ConnectivityResult.none) {
                                      Get.snackbar(
                                        "Sign Up Error",
                                        'Necesita acceder a internet para crear una cuenta',
                                        icon: const Icon(Icons.person,
                                            color: Colors.red),
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    } else {
                                      Get.to(() => SignUpPage());
                                    }
                                  },
                                  child: const Text('Crear Cuenta'),
                                ),
                              ],
                            ))))
              ]),
        ),
      ),
    );
  }
}
