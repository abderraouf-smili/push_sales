// views/tree_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/credit_controller.dart';
import 'package:push_sale/models/credit_client.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/models/receivable.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/credit/confirm_diag.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class MainCreditPage extends StatelessWidget {
  const MainCreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injection du controller
    final CreditController controller = Get.put(CreditController());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Obx(() {
        // Observer les changements d'état
        final isLoading = controller.isLoading.value;
        final totalCount = controller.credits.length;
        final periodCount = controller.tree.length;

        if (isLoading) {
          return AppLoadingState(message: "${'loading'.tr}...");
        }

        if (controller.tree.isEmpty) {
          return Center(
            child: Text('Aucune donnée disponible'),
          );
        }

        final formatter = NumberFormat("#,##0.00", "fr_FR");
        final totalSolde = controller.credits.fold<double>(
          0,
          (sum, item) => sum + (item.solde as num).toDouble(),
        );
        final totalAmount = controller.credits.fold<double>(
          0,
          (sum, item) => sum + (item.totalAmount as num).toDouble(),
        );

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: AppPageHeader(
                  title: "customers_credit".tr,
                  subtitle: "Encaissements clients et soldes restants",
                  icon: Icons.account_balance_wallet_outlined,
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
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _CreditMetric(
                        label: "Solde a encaisser",
                        value: formatter.format(totalSolde),
                        icon: Icons.payments_rounded,
                        color: AppColors.secondary,
                      ),
                      _CreditMetric(
                        label: "Montant commandes",
                        value: formatter.format(totalAmount),
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primary,
                      ),
                      _CreditMetric(
                        label: "Lignes",
                        value: "$totalCount",
                        icon: Icons.groups_rounded,
                        color: AppColors.warning,
                      ),
                      _CreditMetric(
                        label: "Periodes",
                        value: "$periodCount",
                        icon: Icons.calendar_month_rounded,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sortedYears = controller.getSortedYears();
                      final year = sortedYears[index];
                      return YearWidget(yearNode: controller.tree[year]!);
                    },
                    childCount: controller.getSortedYears().length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CreditMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CreditMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth >= 620
        ? (screenWidth - (AppSpacing.lg * 2) - AppSpacing.md) / 2
        : screenWidth - (AppSpacing.lg * 2);
    return SizedBox(
      width: width,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
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

// Widget pour l'arbre
class TreeViewWidget extends StatelessWidget {
  TreeViewWidget({super.key});

  final CreditController controller = Get.find<CreditController>();

  @override
  Widget build(BuildContext context) {
    final sortedYears = controller.getSortedYears();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        final yearNode = controller.tree[year]!;
        return YearWidget(yearNode: yearNode);
      },
    );
  }
}

// Widget pour l'année
class YearWidget extends StatelessWidget {
  final YearNode yearNode;
  final CreditController controller = Get.find<CreditController>();

  YearWidget({super.key, required this.yearNode});

  @override
  Widget build(BuildContext context) {
    int orderCount = controller.getYearOrderCount(yearNode);
    double totalSolde = controller.getYearTotalSolde(yearNode);
    var formatter = NumberFormat("#,##0.0", "fr_FR");

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(Icons.calendar_today, color: AppColors.primary),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Text(
                '${'year'.tr} ${yearNode.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 228, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "💰${formatter.format(totalSolde)} ",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$orderCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        children: controller.getSortedMonths(yearNode).map((month) {
          return MonthWidget(monthNode: yearNode.months[month]!);
        }).toList(),
      ),
    );
  }
}

// Widget pour le mois
class MonthWidget extends StatelessWidget {
  final MonthNode monthNode;
  final CreditController controller = Get.find<CreditController>();

  MonthWidget({super.key, required this.monthNode});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.0", "fr_FR");

    int orderCount = controller.getMonthOrderCount(monthNode);
    double totalSolde = controller.getMonthTotalSolde(monthNode);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.date_range, color: Colors.green),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                controller.formatMonth(monthNode.month),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 228, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "💰${formatter.format(totalSolde)} ",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$orderCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        children: controller.getSortedDates(monthNode).map((date) {
          return DateWidget(dateNode: monthNode.dates[date]!);
        }).toList(),
      ),
    );
  }
}

// Widget pour la date
class DateWidget extends StatelessWidget {
  final DateNode dateNode;
  final CreditController controller = Get.find<CreditController>();

  DateWidget({super.key, required this.dateNode});

  @override
  Widget build(BuildContext context) {
    int orderCount = controller.getDateOrderCount(dateNode);
    double totalSolde = controller.getDateTotalSolde(dateNode);
    var formatter = NumberFormat("#,##0.0", "fr_FR");

    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        leading: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.event, color: Colors.orange),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                dateNode.date,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 228, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "💰${formatter.format(totalSolde)} ",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$orderCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        children: dateNode.credits.map((order) {
          return ClientCard(credit: order);
        }).toList(),
      ),
    );
  }
}

// Widget pour le client
class ClientCard extends StatelessWidget {
  final CreditClient credit;
  final CreditController controller = Get.find<CreditController>();

  ClientCard({super.key, required this.credit});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1, color: const Color.fromARGB(96, 174, 174, 174)),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: EdgeInsets.all(controller.credits.isNotEmpty ? 0 : 1),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: CachedNetworkImage(
            cacheManager: CacheManager(
              Config(
                credit.image,
                stalePeriod: const Duration(days: 7),
              ),
            ),
            imageUrl: credit.image,
            placeholder: (context, url) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: const CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        title: Text(
          credit.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(credit.code),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  size: 14,
                  color: Colors.green,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatter.format(credit.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.add_task_sharp,
                  size: 14,
                  color: Colors.orange,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatter.format(credit.solde),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        // trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () async {
          bool confirm = await Get.dialog<bool>(
                StyledConfirmDialog(
                  message: "ask.confirm".tr,
                  details:
                      "👤 Client: ${credit.name}\n🏷️ ${credit.code}\n💰 Montant: ${formatter.format(credit.solde)}",
                  color: Colors.purple,
                  icon: Icons.person,
                  confirmText: "confirm".tr,
                  cancelText: "cancel".tr,
                ),
              ) ??
              false;

          if (confirm) {
            ReceivaleLine line = ReceivaleLine(
              purchaseorder_id: credit.purchaseorderId,
              purchase_date: DateTime.now(),
              code: credit.code,
              total_amount: credit.totalAmount,
              solde: credit.solde,
            );
            line.cashed = credit.solde;
            controller.generateTrackId();
            bool res = await controller.sendCash([line]);
            if (res) {
              controller.credits.value = [];
              await controller.loadData();
            } else {}
          }
        },
      ),
    );
  }
}
