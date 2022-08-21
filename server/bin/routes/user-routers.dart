import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_multipart/form_data.dart';

import '../helpers/form-data-parser.dart';
import '../helpers/response-helper.dart';
import '../models/users/user_model.dart';
import '../queries/response/response_model.dart';
import '../queries/users/users-queries.dart';

class UserRouters {
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
          body: ResponseHelper.errorRes(res: ServerRes().errorRes));
    }
  }

  static Future<Response> loginUser(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);
      User user = User.fromJson(formData);
      var dbUser = await UsersQueries().loginUser(user: user);
      return Response.ok(ResponseHelper.successRes(res: dbUser));
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(res: ServerRes().errorRes));
    }
  }
}
