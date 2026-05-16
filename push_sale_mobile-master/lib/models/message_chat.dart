import 'package:push_sale/models/actor.dart';

class MessageChat {
  String id;
  Actor from_actor_id;
  Actor to_actor_id;
  String message;
  bool read;
  bool sent;
  DateTime date;
  MessageChat({
    required this.id,
    required this.from_actor_id,
    required this.to_actor_id,
    required this.message,
    required this.read,
    required this.sent,
    required this.date,
  });

  static MessageChat fromMap(Map<String, dynamic> value) {
    return MessageChat(
      id: value["id"],
      from_actor_id: value["from_actor_id"],
      to_actor_id: value["to_actor_id"],
      message: value["message"],
      read: value["read"].toString() == "1" ? true : false,
      sent: value["sent"].toString() == "1" ? true : false,
      date: DateTime.parse(value["created_at"]),
    );
  }
}
