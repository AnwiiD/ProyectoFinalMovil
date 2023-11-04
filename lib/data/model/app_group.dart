import 'package:firebase_database/firebase_database.dart';

class AppGroup {
  String? key;
  String name;
  String gid;
  Map<String, dynamic> users;

  AppGroup(this.key, this.name, this.gid, this.users);

  AppGroup.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        name = json['name'] ?? "somename",
        gid = json['gid'] ?? "gid",
        users = json['users'] ?? [];

  toJson() {
    return {
      "name": name,
      "gid": gid,
      "users": users,
    };
  }
}
