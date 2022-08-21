import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'message-routers.dart';
import 'user-routers.dart';

class PathRouters {
  static Router router() {
    var r = Router();
    r.get('/message', MessageRouters.getMessage);
    r.post('/users/register', UserRouters.registerUser);
    r.post('/users/login', UserRouters.loginUser);
    r.get('/users/stream', webSocketHandler(UserRouters.streamUser));
    return r;
  }
}
