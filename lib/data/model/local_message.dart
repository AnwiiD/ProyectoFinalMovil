import 'package:firebase_database/firebase_database.dart';

import 'package:hive/hive.dart';

part "local_message.g.dart";

@HiveType(typeId: 0)
class LocalMessage extends HiveObject {
  @override
  @HiveField(0)
  String? key;
  @HiveField(1)
  String msg;
  @HiveField(2)
  String senderUid;
  @HiveField(3)
  String senderName;

  LocalMessage(this.key, this.msg, this.senderUid, this.senderName);

  LocalMessage.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        senderUid = json['senderUid'] ?? "senderUid",
        msg = json['msg'] ?? "msg",
        senderName = json['senderName'] ?? "noname";

  toJson() {
    return {
      "msg": msg,
      "senderUid": senderUid,
      'senderName' : senderName
    };
  }
}
