import 'package:f_chat_template/data/model/local_login.dart';
import 'package:f_chat_template/data/model/local_message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loggy/loggy.dart';
import 'config/configurarion.dart';
import 'ui/my_app.dart';

Future<List<Box>> _openBox() async {
  List<Box> boxList = [];
  await Hive.initFlutter();
  Hive.registerAdapter(LocalMessageAdapter());
  Hive.registerAdapter(LocalLoginAdapter());
  boxList.add(await Hive.openBox('messages'));
  boxList.add(await Hive.openBox("logins"));
  return boxList;
}

Future<void> main() async {
  // this is the key
  WidgetsFlutterBinding.ensureInitialized();
  await _openBox();
  Loggy.initLoggy(
    logPrinter: const PrettyPrinter(
      showColors: true,
    ),
  );
  // aquí nos conectamos a los servicios de
  // firebase
  await Firebase.initializeApp(
      name: 'ProyectoFinalMovil',
      options: const FirebaseOptions(
    apiKey: Configuration.apiKey,
    authDomain: Configuration.authDomain,
    databaseURL: Configuration.databaseURL,
    projectId: Configuration.projectId,
    // storageBucket: Configuration.storageBucket,
    messagingSenderId: Configuration.messagingSenderId,
    appId: Configuration.appId,
    // measurementId: Configuration.measurementId),
  ));
  runApp(const MyApp());
}
