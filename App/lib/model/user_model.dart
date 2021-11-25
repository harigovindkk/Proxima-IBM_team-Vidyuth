import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  Users({
    this.uid,
    this.name,
    this.email,
    this.phone,
  });

  String uid;
  String name;
  String email;
  String phone;

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        uid: json["uid"] ?? '',
        name: json["name"] ?? "",
        email: json["email"] ?? '',
        phone: json["phone"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "email": email,
        "phone": phone,
      };
}
