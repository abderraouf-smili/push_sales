import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
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

        return RefreshIndicator(
          onRefresh: orderController.getOrdersToTrack,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppPageHeader(
                  title: "orders.to.track".tr,
                  subtitle: "Suivi livraison, cash et restants",
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
                  child: Wrap(
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
                ),
              ),
              if (orderController.ordersToTrack.isEmpty)
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
                    itemCount: orderController.ordersToTrack.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = orderController.ordersToTrack[index];
                      final last = item.tracking?.isNotEmpty == true
                          ? item.tracking!.last
                          : null;
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        onTap: () {
                          orderController.orderToTrack = item;
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              child: SizedBox(
                                width: 58,
                                height: 58,
                                child: CachedNetworkImage(
                                  imageUrl: item.client!.image,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const ColoredBox(
                                    color: AppColors.softBlue,
                                    child: Icon(Icons.storefront_outlined),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.client!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    "${item.client!.address!.city.name} (${item.client!.address!.wilaya.code})",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    DateFormat("dd/MM/y HH:mm")
                                        .format(item.planned_delivery_date),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatter.format(item.delivery_amount),
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlue,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    last == null
                                        ? "-"
                                        : ("state.${last.state}").tr,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
