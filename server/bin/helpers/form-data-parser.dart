import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';

class FormDataParser {
  static final String uploadDir = "./uploads";

  //TO PARSE POST DATA FROM REQUEST
  static Future<Map<String, dynamic>> parsePostFormData(
      {required Stream<FormData> request}) async {
    print("PARSING FORM DATA");
    Map<String, dynamic> result = {};
    await for (final req in request) {
      //PARSE FILE REQUESTS
      if (req.filename != null) {
        result[req.name] =
            await saveFile(name: req.filename ?? req.name, multipart: req.part);
      } else {
        //PARSE MAP
        result[req.name] = await req.part.readString();
      }
    }
    return result;
  }

  static Future<String> saveFile(
      {required String name, required Multipart multipart}) async {
    try {
      if (!Directory(uploadDir).existsSync()) {
        await Directory(uploadDir).create();
      }
      var filename = '${DateTime.now().microsecondsSinceEpoch}_$name';
      var f = await File('$uploadDir/$filename')
          .writeAsBytes(await multipart.readBytes());
      return filename;
    } catch (err) {
      throw Exception('File Write error');
    }
  }
}
