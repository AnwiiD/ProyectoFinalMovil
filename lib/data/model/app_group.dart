import 'package:firebase_database/firebase_database.dart';

class AppGroup {
  String? key;
  String name;
  String gid;
  String city;
  Map<String, dynamic> users;

  AppGroup(this.key, this.name, this.gid, this.city, this.users);

  AppGroup.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        name = json['name'] ?? "somename",
        gid = json['gid'] ?? "gid",
        city = json['city'] ?? "city",
        users = parseUsers(json['users']) ?? {};

  toJson() {
    return {
      "name": name,
      "gid": gid,
      "city": city,
      "users": users,
    };
  }

  static Map<String, dynamic>? parseUsers(Map<dynamic, dynamic>? usersMap) {
    if (usersMap == null) {
      return null;
    }

    Map<String, dynamic> parsedUsers = {};

    usersMap.forEach((key, value) {
      parsedUsers[key] = value;
    });

    return parsedUsers;
  }
}