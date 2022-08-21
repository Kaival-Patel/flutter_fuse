import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'network/mysql_connection.dart';
import 'routes/path-routers.dart';

void main() async {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() async {
  // Configure routes.
  final _router = PathRouters.router();
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  //START SQL DATABASE
  try {
    await Database().init();
  } catch (err) {
    print('Error initing Db => $err');
  }

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, ip, port);
  print('Dart Server started & listening on port ${server.port}');
  return server;
}
