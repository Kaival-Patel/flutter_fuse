// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    this.id = 0,
    this.messageId = 0,
    this.sender = 0,
    this.receiver = 0,
  });

  int id;
  int messageId;
  int sender;
  int receiver;

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json["id"] == null ? 0 : int.parse(json["id"].toString()),
        messageId: json["message_id"] == null
            ? 0
            : int.parse(json["message_id"].toString()),
        sender:
            json["sender"] == null ? 0 : int.parse(json["sender"].toString()),
        receiver: json["receiver"] == null
            ? 0
            : int.parse(json["receiver"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "message_id": messageId == null ? null : messageId,
        "sender": sender == null ? null : sender,
        "receiver": receiver == null ? null : receiver,
      };
}
