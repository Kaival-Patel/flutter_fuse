import 'package:shelf/shelf.dart';

class MessageRouters {
  static Response getMessage(Request request) {
    return Response.ok('Get Message');
  }
}
