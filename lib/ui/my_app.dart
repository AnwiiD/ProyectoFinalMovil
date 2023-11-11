import 'package:f_chat_template/domain/use_case/locator_service.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:f_chat_template/ui/controllers/group_controller.dart';
import 'package:f_chat_template/ui/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/authentication_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/user_controller.dart';
import 'firebase_cental.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    Get.put(AuthenticationController());
    Get.put(UserController());
    Get.put(LocatorService());
    Get.put(LocationController());
    Get.put(GroupController());
    Get.put(ConnectionController());
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FirebaseCentral());
  }
}
