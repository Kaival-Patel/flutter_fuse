import '../../models/chats/chat_model.dart';
import '../../models/message/message_model.dart';
import '../../network/mysql_connection.dart';
import '../response/response_model.dart';

class MessageQueries {
  static String messageDb = 'messages';
  static String chatDb = 'chats';
  static Future<ServerRes> insertNewMessage(
      {required MessageModel model,
      required int receiver,
      required int senderId}) async {
    var result = await Database().connection.query(
        'INSERT INTO $messageDb (message,attachment,type,status) VALUES (?,?,?,?)',
        [model.message, model.attachment, model.type, model.status]);
    if (result.affectedRows != null && result.affectedRows! > 0) {
      return await insertMessageInChat(
          chat: ChatModel(
              messageId: result.insertId!,
              receiver: receiver,
              sender: senderId));
    } else {
      return ServerRes(m: 'Error sending message');
    }
  }

  static Future<ServerRes> insertMessageInChat(
      {required ChatModel chat}) async {
    var result = await Database().connection.query(
        'INSERT INTO $chatDb (message_id,sender,receiver) VALUES (?,?,?)',
        [chat.messageId, chat.sender, chat.receiver]);
    if (result.affectedRows != null && result.affectedRows! > 0) {
      return ServerRes(m: 'Message Sent Successfully', s: 1);
    } else {
      return ServerRes(m: 'Error sending message');
    }
  }

  static Future<ServerRes> getChatList({required int receiverId}) async {
    try {
      print(receiverId);
      var result = await Database().connection.query(
          'SELECT ${messageDb}.*,${chatDb}.sender,${chatDb}.receiver FROM ${chatDb} INNER JOIN ${messageDb} ON ${messageDb}.id=${chatDb}.message_id WHERE ${chatDb}.receiver = ? GROUP BY ${chatDb}.sender',
          [receiverId]);
      var l = result.map((e) {
        e.fields['created_at'] = e.fields['created_at'].toString();
        return e.fields;
      }).toList();
      l.sort((a, b) =>
          a['created_at'].toString().compareTo(b['created_at'].toString()));
      print("CHAT LIST QUERY LIST => $l");
      return ServerRes(s: 1, m: "Success chat list", r: l);
    } catch (err) {
      print(err);
      return ServerRes().errorRes;
    }
  }
}
