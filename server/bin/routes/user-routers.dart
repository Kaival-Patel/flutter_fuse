import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../helpers/form-data-parser.dart';
import '../helpers/response-helper.dart';
import '../models/users/user_model.dart';
import '../network/mysql_connection.dart';
import '../queries/response/response_model.dart';
import '../queries/users/users-queries.dart';

class UserRouters {
  static Map<WebSocketChannel, String> clientsWithUserIds = {};
  //STREAMING OUT USER
  static void streamUser(WebSocketChannel webSocket) async {
    //Clients Attached to this stream
    //SINK BY DEFAULT EMPTY MODEL ON CONNECTION OR ACK THAT WE ARE IN LOVE
    webSocket.sink.add('Connected bro');
    clientsWithUserIds[webSocket] = '';
    //STREAM FROM THE CONNECTED CLIENT
    webSocket.stream.listen((event) async {
      //EDIT THE USER FROM HERE AND SINK THE CHANGE
      print("EVENT RECEIVED => ${event} WITH ${event.runtimeType}");
      var map = jsonDecode(event);
      switch (map['action']) {
        case '/get-user':
          print("CODE FOR USER TO GET => ${map['id']}");
          clientsWithUserIds[webSocket] = map['id'].toString();
          //USER WILL SEND CODE TO STREAM THE PARTICULAR USER
          sinkUser(webSocket, map['id'].toString());
          break;
      }
    }, onDone: () {
      clientsWithUserIds.remove(webSocket);
    });
  }

  static void sinkUser(WebSocketChannel webSocket, String id) async {
    var u = await UsersQueries().getUserFromCode(id: id);
    //EACH CLIENT WILL LISTEN TO DIFF UID SO WE HAVE SINKED TO PARTICULAR CLIENT
    webSocket.sink.add(jsonEncode(u.toJson()));
  }

  //UPDATE USER
  static Future<Response> updateUser(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);

      User user = User.fromJson(formData);
      var dbUser = await UsersQueries().updateUser(user: user);
      //UPDATE CLIENTS WHO ARE LISTENING FOR THIS UPDATED USER, SINK THEM UPDATED USER DATA
      clientsWithUserIds.forEach((key, value) {
        if (value == user.id.toString()) {
          sinkUser(key, user.id.toString());
        }
      });
      return Response.ok(ResponseHelper.successRes(res: dbUser));
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(res: ServerRes().errorRes),
          headers: ResponseHelper.jsonHeader);
    }
  }

  //UPDATE USER
  static Future<Response> updateUserTypingStatus(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);
      var onlineStatus =
          int.tryParse(formData['online_status'].toString()) ?? 0;
      var id = int.tryParse(formData['id'].toString()) ?? 0;
      var dbUser = await UsersQueries()
          .updateUserOnlineStatus(id: id, onlineStatus: onlineStatus);
      //UPDATE CLIENTS WHO ARE LISTENING FOR THIS UPDATED USER, SINK THEM UPDATED USER DATA
      clientsWithUserIds.forEach((key, value) {
        if (value == id.toString()) {
          sinkUser(key, id.toString());
        }
      });
      return Response.ok(ResponseHelper.successRes(res: dbUser));
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(res: ServerRes().errorRes),
          headers: ResponseHelper.jsonHeader);
    }
  }

  //REGISTER USER
  static Future<Response> registerUser(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);

      User user = User.fromJson(formData);
      var dbUser = await UsersQueries().registerUser(user: user);
      return Response.ok(ResponseHelper.successRes(res: dbUser));
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(res: ServerRes().errorRes),
          headers: ResponseHelper.jsonHeader);
    }
  }

  //LOGIN USER
  static Future<Response> loginUser(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);
      User user = User.fromJson(formData);
      var dbUser = await UsersQueries().loginUser(user: user);
      return Response.ok(ResponseHelper.successRes(res: dbUser),
          headers: ResponseHelper.jsonHeader);
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(
            res: ServerRes().errorRes,
          ),
          headers: ResponseHelper.jsonHeader);
    }
  }
}
