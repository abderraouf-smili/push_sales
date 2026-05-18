import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class OrderToTrack extends StatelessWidget {
  final OrderController orderController = Get.find();
  final PageController pageController;
  final RxString selectedFilter = "all".obs;

  OrderToTrack(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "fr_FR");
    return ColoredBox(
      color: AppColors.canvas,
      child: Obx(() {
        if (!orderController.loadordersToTrack.value) {
          return const AppLoadingState(message: "Chargement du tracking...");
        }

        double totalNew = 0;
        double amountShipped = 0;
        double amountCash = 0;
        for (final order in orderController.ordersToTrack) {
          for (final item in order.tracking ?? []) {
            totalNew += item.state == "new" ? item.amount ?? 0 : 0;
            amountShipped += item.state == "shipped" ? item.amount ?? 0 : 0;
            amountCash += item.state == "paid" || item.state == "partially_paid"
                ? item.amount ?? 0
                : 0;
          }
        }
        final remaining = amountShipped - amountCash;

        final filteredOrders = orderController.ordersToTrack.where((order) {
          final stage = _trackStage(order);
          return selectedFilter.value == "all" ||
              selectedFilter.value == stage ||
              (selectedFilter.value == "remaining" &&
                  (stage == "new" || stage == "in_way"));
        }).toList();

        return RefreshIndicator(
          onRefresh: orderController.getOrdersToTrack,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppPageHeader(
                  title: "Tracking commandes",
                  subtitle: "Nouveau, livre, encaisse et restant a suivre",
                  icon: Icons.route_outlined,
                  actions: [
                    IconButton.filledTonal(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_month_rounded),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TrackFilterChip(
                              label: "Toutes",
                              selected: selectedFilter.value == "all",
                              onTap: () => selectedFilter.value = "all",
                            ),
                            _TrackFilterChip(
                              label: "Nouveau",
                              selected: selectedFilter.value == "new",
                              onTap: () => selectedFilter.value = "new",
                            ),
                            _TrackFilterChip(
                              label: "Livre",
                              selected: selectedFilter.value == "shipped",
                              onTap: () => selectedFilter.value = "shipped",
                            ),
                            _TrackFilterChip(
                              label: "Restant",
                              selected: selectedFilter.value == "remaining",
                              onTap: () => selectedFilter.value = "remaining",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _TrackingMetric(
                            label: "Nouveau",
                            value: formatter.format(totalNew),
                            icon: Icons.shopping_cart_checkout_rounded,
                            color: AppColors.warning,
                          ),
                          _TrackingMetric(
                            label: "Livre",
                            value: formatter.format(amountShipped),
                            icon: Icons.local_shipping_rounded,
                            color: AppColors.info,
                          ),
                          _TrackingMetric(
                            label: "Encaisse",
                            value: formatter.format(amountCash),
                            icon: Icons.payments_rounded,
                            color: AppColors.secondary,
                          ),
                          _TrackingMetric(
                            label: "Restant",
                            value: formatter.format(remaining),
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  child: Text(
                    "Etat des commandes",
                    style: AppTextStyles.display.copyWith(fontSize: 24),
                  ),
                ),
              ),
              if (filteredOrders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.route_outlined,
                    title: "Aucune commande a suivre",
                    message:
                        "Changez la date ou rechargez lorsque les commandes sont disponibles.",
                    action: FilledButton.icon(
                      onPressed: orderController.getOrdersToTrack,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Recharger"),
                    ),
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
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = filteredOrders[index];
                      final last = item.tracking?.isNotEmpty == true
                          ? item.tracking!.last
                          : null;
                      final stage = _trackStage(item);
                      final stageColor = _stageColor(stage);
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        onTap: () {
                          orderController.orderToTrack = item;
                          if (pageController.hasClients) {
                            pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                  child: SizedBox(
                                    width: 58,
                                    height: 58,
                                    child: CachedNetworkImage(
                                      imageUrl: item.client!.image,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          ColoredBox(
                                        color:
                                            stageColor.withValues(alpha: .12),
                                        child: Icon(Icons.storefront_outlined,
                                            color: stageColor),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.code,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.title
                                            .copyWith(fontSize: 18),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        item.client?.name ?? "Client",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.subtitle.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        item.client?.address?.city.name ?? "-",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat("dd MMM y", "fr_FR")
                                          .format(item.planned_delivery_date),
                                      style: AppTextStyles.caption,
                                    ),
                                    Text(
                                      formatter.format(item.delivery_amount),
                                      style: AppTextStyles.title.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            stageColor.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        last == null
                                            ? _stageLabel(stage)
                                            : ("state.${last.state}").tr,
                                        style: AppTextStyles.caption.copyWith(
                                          color: stageColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.primaryDark),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _OrderProgressMini(stage: stage),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      locale: const Locale('fr'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) {
      orderController.selectedDate = date;
      await orderController.getOrdersToTrack(date: date);
    }
  }
}

class _TrackFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TrackFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: AppTextStyles.body.copyWith(
          color: selected ? Colors.white : AppColors.primaryDark,
          fontWeight: FontWeight.w800,
        ),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _OrderProgressMini extends StatelessWidget {
  final String stage;

  const _OrderProgressMini({required this.stage});

  @override
  Widget build(BuildContext context) {
    final current = switch (stage) {
      "paid" => 4,
      "shipped" => 3,
      "in_way" => 2,
      _ => 1,
    };
    const labels = ["Creee", "Preparee", "Livree", "Payee"];
    return Row(
      children: List.generate(labels.length, (index) {
        final step = index + 1;
        final active = step <= current;
        final color = active ? _stageColor(stage) : AppColors.line;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      active ? color.withValues(alpha: 0.16) : AppColors.canvas,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  step.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: active ? color : AppColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 3,
                  color: step == labels.length ? Colors.transparent : color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

String _trackStage(Order order) {
  final lastState = order.tracking?.isNotEmpty == true
      ? order.tracking!.last.state.toLowerCase()
      : order.state.toLowerCase();
  if (lastState == "paid" || lastState == "partially_paid") {
    return "paid";
  }
  if (lastState == "shipped" || lastState == "delivered") {
    return "shipped";
  }
  if (lastState == "in_way" || lastState == "taken" || lastState == "ready") {
    return "in_way";
  }
  return "new";
}

Color _stageColor(String stage) {
  return switch (stage) {
    "paid" => AppColors.primary,
    "shipped" => AppColors.success,
    "in_way" => AppColors.warning,
    _ => AppColors.info,
  };
}

String _stageLabel(String stage) {
  return switch (stage) {
    "paid" => "Paye",
    "shipped" => "Livre",
    "in_way" => "En livraison",
    _ => "Nouveau",
  };
}

class _TrackingMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrackingMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - AppSpacing.lg * 2 - 8) / 2,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
