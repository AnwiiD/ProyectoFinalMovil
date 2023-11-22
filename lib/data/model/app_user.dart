import 'package:firebase_database/firebase_database.dart';

class AppUser {
  String? key;
  String email;
  String uid;
  String name;
  String city;


  AppUser(this.key, this.email, this.uid, this.name, this.city);

  AppUser.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? "0",
        email = json['email'] ?? "email",
        uid = json['uid'] ?? "uid",
        name = json['alias'] ?? "noname",
        city = json['city'] ?? "city"
        ;

  toJson() {
    return {
      "email": email,
      "uid": uid,
      "alias": name,
      "city": city,
    };
  }
}
