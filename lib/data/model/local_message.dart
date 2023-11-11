import 'package:firebase_database/firebase_database.dart';

import 'package:hive/hive.dart';

part "local_message.g.dart";

@HiveType(typeId: 0)
class LocalMessage extends HiveObject {
  @HiveField(0)
  String key;
  @HiveField(1)
  String msg;
  @HiveField(2)
  String senderUid;

  LocalMessage(this.key, this.msg, this.senderUid);

  LocalMessage.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        senderUid = json['senderUid'] ?? "senderUid",
        msg = json['msg'] ?? "msg";

  toJson() {
    return {
      "msg": msg,
      "senderUid": senderUid,
    };
  }
}
