import 'package:f_chat_template/ui/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key}) : super(key: key);
  final AuthenticationController authenticationController = Get.find();
  final TextEditingController emailController =
      TextEditingController(text: "a@a.com");
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[700], // Set the AppBar color here
          actions: const [],
          title: const Text("Chat App - Sign in"),
        ),
        backgroundColor: Colors.grey[300],
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
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextField(
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
                          TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Nombre de usuario",
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                              )),
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
                          TextField(
                              controller: passwordCheckController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Confirmar contraseña",
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                fillColor: Colors.grey.shade200,
                                filled: true,
                              )),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (passwordController.text == "" ||
                                  emailController.text == "") {
                                Get.snackbar(
                                  "Sign Up Error",
                                  'Todos los campos son obligatorios',
                                  icon: const Icon(Icons.person,
                                      color: Colors.red),
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else if (!emailController.text
                                  .endsWith(".com")) {
                                Get.snackbar(
                                  "Sign Up Error",
                                  'Dirección de correo inválida',
                                  icon: const Icon(Icons.person,
                                      color: Colors.red),
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                if (passwordController.text ==
                                    passwordCheckController.text) {
                                  signup(
                                      emailController.text,
                                      passwordController.text,
                                      nameController.text);
                                } else {
                                  logInfo(passwordController.text);
                                  logInfo(passwordCheckController.text);
                                  Get.snackbar(
                                    "Sign Up Error",
                                    'Las contraseñas no coinciden',
                                    icon: const Icon(Icons.person,
                                        color: Colors.red),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurple[700], // Background color
                            ),
                            child: const Text('Iniciar Sesión'),
                          ),
                        ]),
                  ),
                ),
              )
            ]))));
  }

  void signup(String email, String password, String name) async {
    try {
      await authenticationController.signup(email, password, name);
      Get.back();
      Get.snackbar(
        "Sign Up",
        'Usuario creado correctamente',
        icon: const Icon(Icons.person, color: Colors.green),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (error == 'The password is too weak') {
        Get.snackbar(
          "Sign Up Error",
          'Contraseña muy corta',
          icon: const Icon(Icons.person, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Sign Up Error",
          'Usuario ya en uso',
          icon: const Icon(Icons.person, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
