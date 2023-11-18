import 'dart:async';
import 'package:f_chat_template/data/model/local_message.dart';
import 'package:f_chat_template/ui/controllers/authentication_controller.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';

import '../../data/model/message.dart';

class ChatController extends GetxController {
  var messages = [].obs;

  final databaseReference = FirebaseDatabase.instance.ref();
  ConnectionController connectionController = Get.find();

  late StreamSubscription<DatabaseEvent> newEntryStreamSubscription;
  late StreamSubscription<DatabaseEvent> updateEntryStreamSubscription;

  // método en el que nos suscribimos  a los dos streams
  void subscribeToUpdated(uidUser) {
    messages.clear();
    // obtenemos la instancia del AuthenticationController
    AuthenticationController authenticationController = Get.find();
    String chatKey = getChatKey(authenticationController.getUid(), uidUser);
    if (connectionController.connected.value) {
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
    } else {
      getLocalMessages(chatKey);
    }
  }

  void subscribeToUpdatedGroup(uidGroup) {
    messages.clear();
    // obtenemos la instancia del AuthenticationController

    if (connectionController.connected.value) {
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
    }else{
      getLocalGroupMessages(uidGroup);
    }
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

  String getChatKey(uidUser1, uidUser2) {
    List<String> uidList = [uidUser1, uidUser2];
    uidList.sort();
    return uidList[0] + "--" + uidList[1];
  }

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
      for (var groupMessage in groupMessages.children) {
        var message = groupMessage.value as Map<dynamic, dynamic>;
        LocalMessage localMessage = LocalMessage(groupMessages.key,
            message["msg"], message["senderUid"], message["senderName"]);
        Hive.box("messages").add(localMessage);
      }
    }

    for (var chatMessages in chatsMessages) {
      for (var chatMessage in chatMessages.children) {
        var message = chatMessage.value as Map<dynamic, dynamic>;
        LocalMessage localMessage = LocalMessage(
            chatMessages.key, message["msg"], message["senderUid"], "noname");
        Hive.box("messages").add(localMessage);
      }
    }
  }

  void updateMessages() {}

  void getLocalMessages(String key) {
    for (LocalMessage message in Hive.box("messages").values) {
      if (message.key == key) {
        messages.add(message);
      }
    }
  }

  void getLocalGroupMessages(String key) {
    for (LocalMessage message in Hive.box("messages").values) {
      if (message.key == key) {
        messages.add(message);
      }
    }
  }
}
