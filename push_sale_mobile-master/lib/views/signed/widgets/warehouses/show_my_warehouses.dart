import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/warehouse.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class ShowMyWarehouses extends StatefulWidget {
  const ShowMyWarehouses(this.pageController, {super.key});
  final PageController pageController;

  @override
  State<ShowMyWarehouses> createState() => _ShowMyWarehousesState();
}

class _ShowMyWarehousesState extends State<ShowMyWarehouses> {
  final WarehouseController warehouseController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      warehouseController.getWarehouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (!warehouseController.ready.value) {
        return const AppLoadingState();
      }

      if (warehouseController.warehouses.isEmpty) {
        return Column(
          children: [
            AppPageHeader(
              title: "mywarehouses".tr,
              subtitle: "Stock, alertes et reception",
              icon: Icons.warehouse_outlined,
            ),
            AppEmptyState(
              icon: Icons.warehouse_outlined,
              title: "mywarehouses".tr,
              message: "Aucun depot de test disponible.",
            ),
          ],
        );
      }

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AppPageHeader(
              title: "mywarehouses".tr,
              subtitle: "Stock, alertes et reception",
              icon: Icons.warehouse_outlined,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            sliver: SliverList.builder(
              itemCount: warehouseController.warehouses.length,
              itemBuilder: (context, index) {
                var item = warehouseController.warehouses[index];
                return WarehouseLine(
                  item,
                  onTap: () {
                    warehouseController.warehouse = item;
                    widget.pageController.jumpToPage(1);
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class WarehouseLine extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback onTap;
  const WarehouseLine(this.warehouse, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");

    final alertCount = warehouse.items
        .where((element) =>
            element.quantity / element.package <= global.alertQuantity)
        .length;

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.store_mall_directory_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "${warehouse.address.city.name} - ${warehouse.address.wilaya.name}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _WarehouseMetric(
                  icon: Icons.inventory_2_outlined,
                  label: "Articles",
                  value: "${warehouse.items.length}",
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _WarehouseMetric(
                  icon: Icons.payments_outlined,
                  label: "Valeur",
                  value: formatter.format(warehouse.total),
                  color: AppColors.secondary,
                ),
              ),
              if (alertCount > 0) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _WarehouseMetric(
                    icon: Icons.notification_important_outlined,
                    label: "Alertes",
                    value: "$alertCount",
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}

class _WarehouseMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WarehouseMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: 15)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
