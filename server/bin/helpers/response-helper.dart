import 'dart:convert';

import '../queries/response/response_model.dart';

class ResponseHelper {
  static String successRes({required ServerRes res}) {
    return jsonEncode(res.toJson());
  }

  static String errorRes({required ServerRes res}) {
    return jsonEncode(res.toJson());
  }
}
