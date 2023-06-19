class Message {
  final String message;
  final String type;
  final String senderUsername;
  final DateTime sentAt;

  Message({
    required this.message,
    required this.type,
    required this.senderUsername,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      type: message['type'],
      message: message['message'],
      senderUsername: message['senderUsername'],
      sentAt: DateTime.fromMillisecondsSinceEpoch(message['sentAt']),
    );
  }
}
