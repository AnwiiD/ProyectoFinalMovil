import 'package:f_chat_template/ui/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key}) : super(key: key);
  final AuthenticationController authenticationController = Get.find();
  final TextEditingController emailController =
      TextEditingController(text: "a@a.com");
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Chat App - Sign Up")),
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
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                labelText: 'Correo Electrónico'),
                          ),
                          TextField(
                            controller: passwordController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'Contraseña'),
                          ),
                          TextField(
                            controller: passwordCheckController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Confirmar contraseña'),
                          ),
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
                                  signup(emailController.text,
                                      passwordController.text);
                                } else {
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
                            child: const Text('Crear Cuenta'),
                          ),
                        ]),
                  ),
                ),
              )
            ]))));
  }

  void signup(String email, String password) async {
    try {
      Get.back();
      await authenticationController.signup(email, password);
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
