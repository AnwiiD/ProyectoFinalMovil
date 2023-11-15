import 'package:firebase_database/firebase_database.dart';

class AppUser {
  String? key;
  String email;
  String uid;
  String name;


  AppUser(this.key, this.email, this.uid, this.name);

  AppUser.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        email = json['email'] ?? "email",
        uid = json['uid'] ?? "uid",
        name = json['alias'] ?? "noname"
        ;

  toJson() {
    return {
      "email": email,
      "uid": uid,
      "alias": name
    };
  }
}
