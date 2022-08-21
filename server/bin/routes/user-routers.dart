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
  //STREAMING OUT USER
  static void streamUser(WebSocketChannel webSocket) async {
    //Clients Attached to this stream
    Map<WebSocketChannel, String> clientsWithUserIds = {};
    //SINK BY DEFAULT EMPTY MODEL
    webSocket.sink.add(jsonEncode(User().toJson()));
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
          var u =
              await UsersQueries().getUserFromCode(id: map['id'].toString());
          //EACH CLIENT WILL REQ DIFF CODE AND USERS SO WE HAVE SINKED TO PARTICULAR CLIENT
          webSocket.sink.add(jsonEncode(u.toJson()));
          break;
        case '/update-user':
          var u = await UsersQueries().updateUser(user: User.fromJson(map));
          if (u.isValid) {
            // webSocket.sink.add(jsonEncode(u.toJson()));
            //UPDATE THE USER TO ALL CLIENTS WHO ARE LISTENING FOR THIS USER
            print(clientsWithUserIds.length);
            clientsWithUserIds.forEach((key, value) {
              if (value == map['id'].toString()) {
                print("SINKING CHANGE TO ${value}");
                key.sink.add(jsonEncode(u.toJson()));
              }
            });
          }
          break;
      }
    }, onDone: () {
      clientsWithUserIds.remove(webSocket);
    });
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
