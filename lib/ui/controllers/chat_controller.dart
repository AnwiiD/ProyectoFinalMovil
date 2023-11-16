import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'package:f_chat_template/data/model/local_message.dart';
import 'package:f_chat_template/ui/controllers/authentication_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';

import '../../data/model/message.dart';

// En este controlador manejamos los mensajes entre el usuario logeado y el seleccionado
class ChatController extends GetxController {
  // Lista de los mensajes, está lista es observada por el UI
  var messages = <Message>[].obs;

  // referencia a la base de datos
  final databaseReference = FirebaseDatabase.instance.ref();

  // stream de nuevas entradas
  late StreamSubscription<DatabaseEvent> newEntryStreamSubscription;

  // stream de actualizaciones
  late StreamSubscription<DatabaseEvent> updateEntryStreamSubscription;

  // método en el que nos suscribimos  a los dos streams
  void subscribeToUpdated(uidUser) {
    messages.clear();

    // obtenemos la instancia del AuthenticationController
    AuthenticationController authenticationController = Get.find();

    String chatKey = getChatKey(authenticationController.getUid(), uidUser);

    newEntryStreamSubscription = databaseReference
        .child("msg")
        .child(chatKey)
        .onChildAdded
        .listen(_onEntryAdded);

    updateEntryStreamSubscription = databaseReference
        .child("msg")
        .child(chatKey)
        .onChildChanged
        .listen(_onEntryChanged);
  }

  void subscribeToUpdatedGroup(uidGroup) {
    messages.clear();
    // obtenemos la instancia del AuthenticationController

    newEntryStreamSubscription = databaseReference
        .child("group-msg")
        .child(uidGroup)
        .onChildAdded
        .listen(_onEntryAdded);

    updateEntryStreamSubscription = databaseReference
        .child("group-msg")
        .child(uidGroup)
        .onChildChanged
        .listen(_onEntryChanged);
  }

  // método en el que cerramos los streams
  void unsubscribe() {
    newEntryStreamSubscription.cancel();
    updateEntryStreamSubscription.cancel();
  }

  // este método es llamado cuando se tiene una nueva entrada
  _onEntryAdded(DatabaseEvent event) {
    final json = event.snapshot.value as Map<dynamic, dynamic>;
    messages.add(Message.fromJson(event.snapshot, json));
  }

  // este método es llamado cuando hay un cambio es un mensaje
  _onEntryChanged(DatabaseEvent event) {
    var oldEntry = messages.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    final json = event.snapshot.value as Map<dynamic, dynamic>;
    messages[messages.indexOf(oldEntry)] =
        Message.fromJson(event.snapshot, json);
  }

  // este método nos da la llave con la que localizamos la "tabla" de mensajes
  // entre los dos usuarios
  String getChatKey(uidUser1, uidUser2) {
    List<String> uidList = [uidUser1, uidUser2];
    uidList.sort();
    return uidList[0] + "--" + uidList[1];
  }

  // creamos la "tabla" de mensajes entre dos usuarios
  Future<void> createChat(uidUser1, uidUser2, senderUid, msg) async {
    String key = getChatKey(uidUser1, uidUser2);
    try {
      databaseReference
          .child('msg')
          .child(key)
          .push()
          .set({'senderUid': senderUid, 'msg': msg});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }

  // Este método es usado para agregar una nueva entrada en la "tabla" entre los
  // dos usuarios
  Future<void> sendChat(remoteUserUid, msg) async {
    AuthenticationController authenticationController = Get.find();
    String key = getChatKey(authenticationController.getUid(), remoteUserUid);
    String senderUid = authenticationController.getUid();
    try {
      databaseReference
          .child('msg')
          .child(key)
          .push()
          .set({'senderUid': senderUid, 'msg': msg});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }

  Future<void> sendGroupChat(
      remoteUserUid, remoteGroupUid, msg, remoteUserName) async {
    AuthenticationController authenticationController = Get.find();
    String senderUid = authenticationController.getUid();
    try {
      databaseReference.child('group-msg').child(remoteGroupUid).push().set(
          {'senderUid': senderUid, 'msg': msg, 'senderName': remoteUserName});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }

  void loadMessages() async {
    DataSnapshot groups = await databaseReference.child('group-msg').get();
    DataSnapshot chats = await databaseReference.child('msg').get();

    var groupsMessages = groups.children;
    var chatsMessages = chats.children;
    var messageKeys = Hive.box("messages").keys;
    Hive.box("messages").deleteAll(messageKeys);

    for (var groupMessages in groupsMessages) {
      for(var groupMessage in groupMessages.children){
        
        //LocalMessage localMessage = LocalMessage(null, message["msg"], message["senderUid"] , message["senderName"]);
        //Hive.box("messages").add(localMessage); 
      }
    }
    for (LocalMessage cacheMessage in Hive.box("messages").values) {
      //logInfo(cacheMessage.senderName);
    }
  }
}
