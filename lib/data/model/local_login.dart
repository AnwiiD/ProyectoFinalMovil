
import 'package:hive/hive.dart';

part "local_login.g.dart";

@HiveType(typeId: 0)
class LocalLogin extends HiveObject {
  @HiveField(0)
  String email;
  @HiveField(1)
  String password;
  @HiveField(2)
  String name;
  @HiveField(3)
  String senderUid;
  @HiveField(4)
  String ciudad;
  
  
LocalLogin(this.email, this.password, this.senderUid, this.name, this.ciudad);

  toJson() {
    return {
      "name": name,
      "senderUid": senderUid,
      'email' : email,
      'ciudad':ciudad
    };
  }
}