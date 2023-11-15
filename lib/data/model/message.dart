import 'package:firebase_database/firebase_database.dart';

class Message {
  String? key;
  String msg;
  String senderUid;
  String senderName;

  Message(this.key, this.msg, this.senderUid, this.senderName);

  Message.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        senderUid = json['senderUid'] ?? "senderUid",
        msg = json['msg'] ?? "msg",
        senderName = json['senderName'] ?? "noname"
        ;

  toJson() {
    return {
      "msg": msg,
      "senderUid": senderUid,
      "senderAlias": senderName
    };
  }
}
