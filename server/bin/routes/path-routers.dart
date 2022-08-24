import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'message-routers.dart';
import 'user-routers.dart';

class PathRouters {
  static Router router() {
    var r = Router();
    r.post('/message/new', MessageRouters.newMessage);
    r.get('/chat/stream-chat', webSocketHandler(MessageRouters.streamChat));
    r.get('/chat/stream-list', webSocketHandler(MessageRouters.streamChatList));
    r.post('/users/register', UserRouters.registerUser);
    r.post('/users/login', UserRouters.loginUser);
    r.post('/users/update', UserRouters.updateUser);
    r.post('/users/updateOnlineStatus', UserRouters.updateUserTypingStatus);
    r.get('/users/stream', webSocketHandler(UserRouters.streamUser));
    return r;
  }
}
