import 'dart:async';
import 'dart:convert';

import 'package:app/models/chats/chat_model.dart';
import 'package:app/models/message/message_model.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  return runApp(const FuseApp());
}

class FuseApp extends StatelessWidget {
  const FuseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebSocketChannel chatMessagesChannel;
  late WebSocketChannel chatListChannel;
  List<ChatModel> list = [];
  List<MessageModel> messagesList = [];
  int connected = 0;
  int receiver = 0;
  int sender = 2;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenForChatList();
  }

  listenForChatList() {
    chatListChannel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/chat/stream-list'));
    chatMessagesChannel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/chat/stream-chat'));
    listenForChatMessageList();
    chatListChannel.sink.add(jsonEncode({'receiver': '$sender'}));
    chatListChannel.stream.listen((event) {
      var res = jsonDecode(event);
      if (res is Map<String, dynamic>) {
        print("RES => ${event}");
        if (res['s'] == 1) {
          list.clear();
          for (int i = 0; i < res['r'].length; i++) {
            list.add(ChatModel.fromJson(res['r'][i]));
          }
          if (list.isNotEmpty) {
            connected = 0;
            receiver = list[connected].sender;
          }
          // listenForChatMessageList(sender: sender, receiver: receiver);
          setState(() {});
          chatMessagesChannel.sink
              .add(jsonEncode({'receiver': '$sender', 'sender': '$receiver'}));
        }
      } else {
        print("ACK => " + event);
      }
    });
  }

  listenForChatMessageList() {
    chatMessagesChannel.stream.listen((event) {
      var res = jsonDecode(event);
      if (res is Map<String, dynamic>) {
        print("RES M => ${event}");
        if (res['s'] == 1) {
          messagesList.clear();
          for (int i = 0; i < res['r'].length; i++) {
            messagesList.add(MessageModel.fromJson(res['r'][i]));
          }
          setState(() {});
        }
      } else {
        print("ACK M => " + event);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    chatMessagesChannel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fuse App'),
        ),
        body: Row(
          children: [
            Expanded(
              child: ChatList(
                chats: list,
                connectedIndex: connected,
                onTap: (v) {
                  connected = v;
                  receiver = list[connected].sender;
                  chatMessagesChannel.sink.add(jsonEncode(
                      {'receiver': '$sender', 'sender': '$receiver'}));
                  setState(() {});
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: ChatMessagesList(
                model: messagesList,
                sender: sender,
              ),
            ),
          ],
        ));
  }
}

class ChatList extends StatelessWidget {
  List<ChatModel> chats;
  int connectedIndex;
  Function(int) onTap;
  ChatList(
      {required this.chats,
      required this.connectedIndex,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          onTap(index);
        },
        title: Text(chats[index].sender.toString()),
        selectedColor: Colors.blue[700],
        selectedTileColor: Colors.blue[100],
        selected: index == connectedIndex,
      ),
    );
  }
}

class ChatMessagesList extends StatelessWidget {
  List<MessageModel> model;
  int sender;
  ChatMessagesList({required this.model, required this.sender, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          itemCount: model.length,
          reverse: true,
          shrinkWrap: true,
          itemBuilder: (context, index) => SizedBox(
            child: Column(
              crossAxisAlignment: model[index].sender == sender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Bubble(
                  margin: BubbleEdges.only(top: 10),
                  radius: Radius.circular(20.0),
                  alignment: Alignment.topRight,
                  nip: model[index].sender == sender
                      ? BubbleNip.rightTop
                      : BubbleNip.leftTop,
                  color: model[index].sender == sender
                      ? Color.fromRGBO(225, 255, 199, 1.0)
                      : Colors.white,
                  child: Text(model[index].message, textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
