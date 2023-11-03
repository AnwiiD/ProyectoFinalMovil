import 'package:f_chat_template/ui/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key}) : super(key: key);
  final AuthenticationController authenticationController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                labelText: 'Correo Electrónico'),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                labelText: 'Número telefónico'),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'Contraseña'),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Confirmar contraseña'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              signup(emailController.text,
                                  passwordController.text);
                            },
                            child: const Text('Crear Cuenta'),
                          ),
                        ]),
                  ),
                ),
              )
            ]))));
  }

  void signup(String email, String password) {
    try {
      authenticationController.signup(email, password);
    } catch (error) {
      
    }
  }
}
