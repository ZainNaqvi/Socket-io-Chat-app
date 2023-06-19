import 'package:flutter/material.dart';
import 'package:flutter_socket_io/model/message.dart';
import 'package:flutter_socket_io/providers/home.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IO.Socket _socket;
  final TextEditingController _messageInputController = TextEditingController();

  _sendMessage() {
    _socket.emit('message', {
      'message': _messageInputController.text.trim(),
      'sender': widget.username
    });
    _messageInputController.clear();
  }

  _connectSocket() {
    print('******************************************************************');
    _socket.onConnect((data) {
      print('Connection established');
    });
    _socket.onConnectError((data) {
      print('Connect Error: $data');
    });
    _socket.onDisconnect((data) {
      print('Socket.IO server disconnected');
    });
    _socket.on(
      'message',
      (data) {
        Provider.of<HomeProvider>(context, listen: false).addNewMessage(
          Message.fromJson(data),
        );
      },
    );
    print('******************************************************************');
  }

  @override
  void initState() {
    super.initState();
    _socket = IO.io(
        'http://192.168.2.165:3000',
        IO.OptionBuilder().setTransports(['websocket']).setQuery(
            {'username': widget.username}).build());
    _connectSocket();
  }

  @override
  void dispose() {
    _socket.dispose();
    _messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Socket.IO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (_, provider, __) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  final isReplyMessage = message.type == "reply" ? true : false;
                  print("************");
                  print(message.type);
                  print("************");
                  return Wrap(
                    alignment: isReplyMessage
                        ? WrapAlignment.start
                        : WrapAlignment.end,
                    children: [
                      Card(
                        color: isReplyMessage
                            ? Colors.grey.shade200
                            : Theme.of(context).primaryColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message.message),
                              Text(
                                DateFormat('hh:mm a').format(message.sentAt),
                                style: Theme.of(context).textTheme.caption,
                              ),
                              if (isReplyMessage)
                                Text(
                                  'Reply from ${message.senderUsername}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: provider.messages.length,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageInputController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageInputController.text.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageInputController.text.trim().isNotEmpty) {
                        _sendReply();
                      }
                    },
                    icon: const Icon(Icons.reply),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _sendReply() {
    _socket.emit('reply', {
      'message': _messageInputController.text.trim(),
      'sender': widget.username
    });
    _messageInputController.clear();
  }
}
