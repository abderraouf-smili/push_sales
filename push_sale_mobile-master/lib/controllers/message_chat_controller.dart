import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/controllers/compte_menu_controller.dart';

class MessageChatController extends GetxController {
  final RxBool loading = false.obs;
  final RxString error = "".obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  String? get currentActorId {
    try {
      return Get.find<CompteMenuController>().actor?.id.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> loadMessages() async {
    loading.value = true;
    error.value = "";
    final response = await CallApi.RequestHttp(global.getMessageChat);
    if (response.status == "SUCCESS") {
      messages.value = (response.data as List<dynamic>)
          .map((item) => ChatMessage.fromMap(item))
          .toList();
    } else {
      error.value = response.message.toString();
    }
    loading.value = false;
  }

  Future<bool> sendReply(ChatMessage conversation, String message) async {
    final text = message.trim();
    if (text.isEmpty) {
      return false;
    }
    final currentId = currentActorId;
    final String toActorId = conversation.fromActorId == currentId
        ? conversation.toActorId
        : conversation.fromActorId;
    final response = await CallApi.RequestHttp(
      global.sendMessageChat,
      data: {
        "message_chat_id": "MSG-${DateTime.now().microsecondsSinceEpoch}",
        "to_actor_id": toActorId,
        "message": text,
      },
    );
    if (response.status == "SUCCESS") {
      await loadMessages();
      return true;
    }
    error.value = response.message.toString();
    return false;
  }
}

class ChatMessage {
  final String id;
  final String fromActorId;
  final String toActorId;
  final String message;
  final bool read;
  final DateTime? createdAt;
  final String fromName;
  final String toName;

  ChatMessage({
    required this.id,
    required this.fromActorId,
    required this.toActorId,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.fromName,
    required this.toName,
  });

  factory ChatMessage.fromMap(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    final from = map["from"] is Map
        ? Map<String, dynamic>.from(map["from"] as Map)
        : <String, dynamic>{};
    final to = map["to"] is Map
        ? Map<String, dynamic>.from(map["to"] as Map)
        : <String, dynamic>{};
    return ChatMessage(
      id: map["id"].toString(),
      fromActorId: map["from_actor_id"].toString(),
      toActorId: map["to_actor_id"].toString(),
      message: map["message"]?.toString() ?? "",
      read: map["read"] == true || map["read"].toString() == "1",
      createdAt: DateTime.tryParse(map["created_at"]?.toString() ?? ""),
      fromName: _actorName(from),
      toName: _actorName(to),
    );
  }

  static String _actorName(Map<String, dynamic> actor) {
    final first = actor["firstname"]?.toString() ?? "";
    final last = actor["lastname"]?.toString() ?? "";
    final full = "$first $last".trim();
    return full.isEmpty ? "Utilisateur" : full;
  }
}
