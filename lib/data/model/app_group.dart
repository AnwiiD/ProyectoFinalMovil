import 'package:f_chat_template/data/model/app_user.dart';
import 'package:firebase_database/firebase_database.dart';

class AppGroup {
  String? key;
  String name;
  String uid;
  List<AppUser> users;

  AppGroup(this.key, this.name, this.uid, this.users);

  AppGroup.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        name = json['name'] ?? "somename",
        uid = json['uid'] ?? "uid",
        users = json['users'] ?? [];

  toJson() {
    return {
      "name": name,
      "uid": uid,
    };
  }
}
