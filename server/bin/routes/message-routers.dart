import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../helpers/form-data-parser.dart';
import '../helpers/response-helper.dart';
import '../models/message/message_model.dart';
import '../queries/messages/message-queries.dart';
import '../queries/response/response_model.dart';

class MessageRouters {
  static Map<WebSocketChannel, List<int>> clients = {};
  static Future<Response> newMessage(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);

      var message = MessageModel.fromJson(formData);
      var receiver = int.parse(formData['receiver'].toString());
      var sender = int.parse(formData['sender'].toString());
      var res = await MessageQueries.insertNewMessage(
          model: message, receiver: receiver, senderId: sender);
      clients.forEach((key, value) {
        if (value.contains(receiver) || value.contains(sender)) {
          sinkChatList(key, receiver);
          sinkChatMessageList(key, receiver, sender);
        }
      });
      return Response.ok(ResponseHelper.successRes(res: res),
          headers: ResponseHelper.jsonHeader);
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(res: ServerRes().errorRes),
          headers: ResponseHelper.jsonHeader);
    }
  }

  static streamChat(WebSocketChannel channel) async {
    //ACK
    channel.sink.add('Chat Message Connected');

    //LISTEN FOR PAYLOADS FROM CLIENT
    channel.stream.listen((event) {
      var map = jsonDecode(event);
      var sender = int.parse(map['sender'].toString());
      var receiver = int.parse(map['receiver'].toString());
      if (clients[channel] == null) {
        clients[channel] = [receiver, sender];
      } else {
        clients[channel]!.add(receiver);
        clients[channel]!.add(sender);
      }

      sinkChatList(channel, receiver);
    });
  }

  static streamChatList(WebSocketChannel channel) async {
    //ACK
    channel.sink.add('Chat List Connected');

    //LISTEN FOR PAYLOADS FROM CLIENT
    channel.stream.listen((event) {
      var map = jsonDecode(event);
      var receiver = int.parse(map['receiver'].toString());
      //REGISTER CLIENT
      if (clients[channel] == null) {
        clients[channel] = [receiver];
      } else {
        clients[channel]!.add(receiver);
      }

      sinkChatList(channel, receiver);
    });
  }

  static sinkChatList(WebSocketChannel channel, int reciverId) async {
    var r = await MessageQueries.getChatList(receiverId: reciverId);
    channel.sink.add(jsonEncode(r.toJson()));
  }

  static sinkChatMessageList(
      WebSocketChannel channel, int receiverId, int senderId) async {
    var r = await MessageQueries.getChatMessages(
        receiverId: receiverId, senderId: senderId);
    channel.sink.add(jsonEncode(r.toJson()));
  }
}
