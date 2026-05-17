import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/tracking_order.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class TrackingDetail extends StatelessWidget {
  final PageController pageController;
  final OrderController orderController = Get.find();

  TrackingDetail(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    final order = orderController.orderToTrack;
    final formatter = NumberFormat("#,##0.00", "fr_FR");
    orderController.changeLoad.value = "nothing";

    if (order == null) {
      return AppEmptyState(
        icon: Icons.route_outlined,
        title: "Aucune commande selectionnee",
        message: "Revenez a la liste et selectionnez une commande.",
        action: FilledButton.icon(
          onPressed: () => pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text("Retour"),
        ),
      );
    }

    final tracking = order.tracking ?? [];
    final isModifiable = tracking.every(
      (suivi) =>
          suivi.state != "shipped" &&
          suivi.state != "paid" &&
          suivi.state != "partially_paid",
    );

    return ColoredBox(
      color: AppColors.canvas,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AppPageHeader(
              title: "track.order".tr,
              subtitle: order.client!.name,
              icon: Icons.route_outlined,
              actions: [
                IconButton.filledTonal(
                  onPressed: () => pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Livraison estimee",
                              style: AppTextStyles.caption),
                          Obx(
                            () => Text(
                              DateFormat("dd/MM/y HH:mm").format(
                                orderController.changeLoad.value != "success"
                                    ? order.planned_delivery_date
                                    : orderController.finalDate!,
                              ),
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isModifiable)
                      Obx(
                        () => orderController.changeLoad.value == "nothing"
                            ? IconButton.filledTonal(
                                onPressed: () => _changeDate(context),
                                icon: const Icon(Icons.edit_calendar_rounded),
                              )
                            : orderController.changeLoad.value == "sent"
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_rounded,
                                    color: AppColors.success),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (tracking.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.timeline_outlined,
                title: "Aucun evenement",
                message: "Le suivi apparaitra ici apres le premier statut.",
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: SliverList.separated(
                itemCount: tracking.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return _TrackingEventCard(
                    item: tracking[index],
                    isFirst: index == 0,
                    isLast: index == tracking.length - 1,
                    amount: tracking[index].amount == null
                        ? null
                        : formatter.format(tracking[index].amount),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _changeDate(BuildContext context) async {
    final date = await showDatePicker(
      locale: Get.locale,
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 8)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: Get.locale,
          child: child!,
        );
      },
    );
    if (time == null) return;
    orderController.finalDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await orderController.changePlannedDate();
  }
}

class _TrackingEventCard extends StatelessWidget {
  final TrackingOrder item;
  final bool isFirst;
  final bool isLast;
  final String? amount;

  const _TrackingEventCard({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final icon = item.getIcon();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 12, color: AppColors.line),
              CircleAvatar(
                radius: 21,
                backgroundColor: icon.color ?? AppColors.primary,
                child: Icon(icon.icon, color: Colors.white, size: 22),
              ),
              if (!isLast)
                Container(width: 2, height: 72, color: AppColors.line),
            ],
          ),
        ),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ("state.${item.state}").tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat("dd/MM HH:mm").format(item.date),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "${item.actor.firstname} ${item.actor.lastname}",
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.getDescription().tr,
                  style: AppTextStyles.subtitle,
                ),
                if (amount != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    amount!,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
