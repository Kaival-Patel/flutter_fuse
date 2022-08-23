import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_multipart/form_data.dart';

import '../helpers/form-data-parser.dart';
import '../helpers/response-helper.dart';
import '../models/message/message_model.dart';
import '../queries/messages/message-queries.dart';
import '../queries/response/response_model.dart';

class MessageRouters {
  static Future<Response> newMessage(Request request) async {
    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      }
      var formData = await FormDataParser.parsePostFormData(
          request: request.multipartFormData);

      var message = MessageModel.fromJson(formData);
      var res = await MessageQueries.insertNewMessage(
          model: message,
          receiver: int.parse(formData['receiver'].toString()),
          senderId: int.parse(formData['sender'].toString()));
      return Response.ok(ResponseHelper.successRes(res: res),
          headers: ResponseHelper.jsonHeader);
    } catch (err) {
      print(err);
      return Response.internalServerError(
          body: ResponseHelper.errorRes(res: ServerRes().errorRes),
          headers: ResponseHelper.jsonHeader);
    }
  }
}
