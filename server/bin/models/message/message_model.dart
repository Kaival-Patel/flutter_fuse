// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) =>
    MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  MessageModel({
    this.id = 0,
    this.message = "",
    this.createdAt,
    this.attachment = "",
    this.type = 1,
    this.status = 1,
  });

  int id;
  String message;
  DateTime? createdAt;
  String attachment;
  int type;
  int status;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"] == null ? 0 : int.parse(json["id"].toString()),
        message: json["message"] == null ? "" : json["message"],
        createdAt: json["created_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["created_at"]),
        attachment: json["attachment"] == null ? "" : json["attachment"],
        type: json["type"] == null ? 1 : int.parse(json["type"].toString()),
        status:
            json["status"] == null ? 0 : int.parse(json["status"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "message": message == null ? null : message,
        "created_at": createdAt == null ? null : createdAt,
        "attachment": attachment == null ? null : attachment,
        "type": type == null ? null : type,
        "status": status == null ? null : status,
      };
}
