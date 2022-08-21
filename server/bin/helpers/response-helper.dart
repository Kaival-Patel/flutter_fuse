import 'dart:convert';

class ResponseHelper {
  static String successRes(
      {required Map<String, dynamic> payload, String message = "Success"}) {
    return jsonEncode({
      "s": 1,
      "m": message,
      "r": payload,
    });
  }

  static String errorRes(
      {String error = 'Error processing request', String message = "Error"}) {
    return jsonEncode({
      "s": 0,
      "m": message,
      "r": error,
    });
  }
}
