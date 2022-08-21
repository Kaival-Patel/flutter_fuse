// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id = 0,
    this.code = 0,
    this.name = "",
    this.email = "",
    this.password = "",
    this.photo = "",
    this.status = 1,
    this.onlineStatus = 1,
    this.createdAt,
    this.lastSeenAt,
  });

  int id;
  int code;
  String name;
  String email;
  String password;
  String photo;
  int status;
  int onlineStatus;
  DateTime? createdAt;
  DateTime? lastSeenAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? 0 : int.parse(json["id"].toString()),
        code: json["code"] == null ? 0 : json["code"],
        name: json["name"] == null ? "" : json["name"],
        email: json["email"] == null ? "" : json["email"],
        password: json["password"] == null ? "" : json["password"],
        photo: json["photo"] == null ? "" : json["photo"],
        status: json["status"] == null ? 1 : json["status"],
        onlineStatus: json["online_status"] == null ? 1 : json["online_status"],
        createdAt:
            json["created_at"] == null ? DateTime.now() : json["created_at"],
        lastSeenAt: json["last_seen_at"] == null
            ? DateTime.now()
            : json["last_seen_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "code": code == null ? null : code,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "password": password == null ? null : password,
        "photo": photo == null ? null : photo,
        "status": status == null ? null : status,
        "online_status": onlineStatus == null ? null : onlineStatus,
        "created_at": createdAt == null
            ? DateTime.now().toString()
            : createdAt.toString(),
        "last_seen_at": lastSeenAt == null
            ? DateTime.now().toString()
            : lastSeenAt.toString(),
      };
}
