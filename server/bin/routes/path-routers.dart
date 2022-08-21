import 'package:shelf_router/shelf_router.dart';

import 'message-routers.dart';
import 'user-routers.dart';

class PathRouters {
  static Router router() {
    var r = Router();
    r.get('/message', MessageRouters.getMessage);
    r.post('/users/register', UserRouters.registerUser);
    return r;
  }
}
