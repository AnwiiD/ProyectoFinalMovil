import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:f_chat_template/ui/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';

import '../controllers/authentication_controller.dart';

// una interfaz muy sencilla en la que podemos crear los tres usuarios (signup)
// y después logearse (login) con cualquiera de las tres

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({Key? key}) : super(key: key);
  final AuthenticationController authenticationController = Get.find();
  final ConnectionController connectionController = Get.find();

   void login(String user, String password) async {
    try {
      if (!connectionController.connected.value) {
        logInfo("local login");
        var users = Hive.box("logins").values;
        for (var boxuser in users) {
          if (boxuser.email == user && boxuser.password == password) {
            logInfo("user found");
            authenticationController.setLocal(
                boxuser.email, boxuser.name, boxuser.senderUid, boxuser.password);
            break;
          }
        }
        if (!authenticationController.isLocal.value) {
          Get.snackbar(
            "Login Error",
            'Usuario no encontrado, verifique y vuelva a intentar (local)',
            icon: const Icon(Icons.person, color: Colors.red),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        await authenticationController.login(user, password);
        loadUser(password);
      }
    } catch (error) {
      logInfo(error);
      Get.snackbar(
        "Login Error",
        'Usuario no encontrado, verifique y vuelva a intentar (normal)',
        icon: const Icon(Icons.person, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController =
        TextEditingController(text: 'a@a.com');
    final TextEditingController passwordController =
        TextEditingController(text: '123456');
    return Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.deepPurple[700], // Set the AppBar color here
    actions: [
     IconButton(
          icon: const Icon(Icons.wifi),
          onPressed: () {
           connectionController.connected.value = !connectionController.connected.value;
          },
        ),
    ],
    title: const Text("Chat App - Login"),
  ),
  backgroundColor: Colors.grey[300], // Set the background color of the entire Scaffold
  body: Container(
        padding: const EdgeInsets.all(1),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.chat_outlined, size: 100),
                
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: "Correo Electrónico",
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                    )),
                                const SizedBox(height: 40),
                                TextField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: "Contraseña",
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                    )),
                                const SizedBox(height: 28,),
                                Container(
  width: 120.0,
  decoration: const BoxDecoration(borderRadius:BorderRadius.all(Radius.circular(40))),
  height: 40.0, 
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple[700], // color de fondo
      
    ),
    onPressed: () {
      login(emailController.text, passwordController.text);
    },
    child: const Text('Iniciar Sesión'),
  ),
),
                                Obx(
                                  () => connectionController.connected.value
                                      ? const Icon(
                                          Icons.wifi,
                                          size: 40.0,
                                          color: Colors
                                              .green, // Customize the color as needed
                                        )
                                      : const Icon(
                                          Icons
                                              .signal_wifi_connected_no_internet_4_rounded,
                                          size: 40.0,
                                          color: Colors
                                              .red, // Customize the color as needed
                                        ),
                                ),
                              ]),
                        )),
                  ),
                ),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (!connectionController.connected.value) {
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No tienes una cuenta?",
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      Text(
                                        " Regístrate",
                                        style: TextStyle(
                                            color: Colors.deepPurple[700]),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ))))
              ]),
        ),
      ),
    );
  }

  void loadUser(password) {
    authenticationController.loadUser(password);
  }
}
