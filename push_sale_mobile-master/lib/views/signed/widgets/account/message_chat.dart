import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/message_chat_controller.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_error_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_snackbar.dart';

class MessageChat extends StatelessWidget {
  const MessageChat({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageChatController());
    controller.loadMessages();
    return Scaffold(
      appBar: AppBar(
        title: Text("chat".tr),
        actions: [
          IconButton(
            tooltip: "refresh".tr,
            onPressed: controller.loadMessages,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const AppLoadingState();
        }
        if (controller.error.value.isNotEmpty) {
          return AppErrorState(
            title: "chat".tr,
            message: controller.error.value,
            onRetry: controller.loadMessages,
          );
        }
        if (controller.messages.isEmpty) {
          return AppEmptyState(
            icon: Icons.forum_outlined,
            title: "Aucune conversation",
            message:
                "Les messages internes apparaitront ici des qu'une conversation sera creee.",
            action: ElevatedButton.icon(
              onPressed: controller.loadMessages,
              icon: const Icon(Icons.refresh_rounded),
              label: Text("refresh".tr),
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final item = controller.messages[index];
            final bool mine = item.fromActorId == controller.currentActorId;
            return _ChatBubble(
              message: item,
              mine: mine,
              onReply: () => _showReplySheet(context, controller, item),
            );
          },
        );
      }),
    );
  }

  void _showReplySheet(
    BuildContext context,
    MessageChatController controller,
    ChatMessage message,
  ) {
    final textController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Repondre", style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: textController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Votre message",
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () async {
                  final ok =
                      await controller.sendReply(message, textController.text);
                  if (ok) {
                    Get.back();
                    AppSnackbar.success("chat".tr, "Message envoye");
                  } else {
                    AppSnackbar.error(
                        "chat".tr,
                        controller.error.value.isEmpty
                            ? "Message vide"
                            : controller.error.value);
                  }
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text("Envoyer"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  final VoidCallback onReply;

  const _ChatBubble({
    required this.message,
    required this.mine,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final date = message.createdAt == null
        ? ""
        : DateFormat("dd/MM HH:mm").format(message.createdAt!);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onReply,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppSpacing.radiusLg),
              topRight: const Radius.circular(AppSpacing.radiusLg),
              bottomLeft:
                  Radius.circular(mine ? AppSpacing.radiusLg : AppSpacing.xs),
              bottomRight:
                  Radius.circular(mine ? AppSpacing.xs : AppSpacing.radiusLg),
            ),
            border: mine ? null : Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mine ? "Moi" : message.fromName,
                style: AppTextStyles.caption.copyWith(
                  color: mine ? Colors.white70 : AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message.message,
                style: AppTextStyles.body.copyWith(
                  color: mine ? Colors.white : AppColors.ink,
                ),
              ),
              if (date.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  date,
                  style: AppTextStyles.caption.copyWith(
                    color: mine ? Colors.white70 : AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
