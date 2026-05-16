// views/tree_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/credit_controller.dart';
import 'package:push_sale/models/credit_client.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/models/receivable.dart';
import 'package:push_sale/views/signed/widgets/credit/confirm_diag.dart';

class MainCreditPage extends StatelessWidget {
  const MainCreditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Injection du controller
    final CreditController controller = Get.put(CreditController());

    return Scaffold(
      appBar: AppBar(
        title: Text("customers_credit".tr),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Obx(() {
        // Observer les changements d'état
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('loading'.tr + '...'),
              ],
            ),
          );
        }

        if (controller.tree.isEmpty) {
          return const Center(
            child: Text('Aucune donnée disponible'),
          );
        }

        return TreeViewWidget();
      }),
    );
  }
}

// Widget pour l'arbre
class TreeViewWidget extends StatelessWidget {
  TreeViewWidget({Key? key}) : super(key: key);

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

  YearWidget({Key? key, required this.yearNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int orderCount = controller.getYearOrderCount(yearNode);
    double totalSolde = controller.getYearTotalSolde(yearNode);
    var formatter = new NumberFormat("#,##0.0", "fr_FR");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calendar_today, color: Colors.blue),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Text(
                'year'.tr + ' ${yearNode.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 208, 228, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "💰" + formatter.format(totalSolde) + " ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$orderCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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

  MonthWidget({Key? key, required this.monthNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.0", "fr_FR");

    int orderCount = controller.getMonthOrderCount(monthNode);
    double totalSolde = controller.getMonthTotalSolde(monthNode);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
                color: Color.fromARGB(255, 208, 228, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "💰" + formatter.format(totalSolde) + " ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(
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

  DateWidget({Key? key, required this.dateNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int orderCount = controller.getDateOrderCount(dateNode);
    double totalSolde = controller.getDateTotalSolde(dateNode);
    var formatter = new NumberFormat("#,##0.0", "fr_FR");

    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                color: Color.fromARGB(255, 208, 228, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "💰" + formatter.format(totalSolde) + " ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(
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

  ClientCard({Key? key, required this.credit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromARGB(96, 174, 174, 174)),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: EdgeInsets.all(controller.credits.value.length > 0 ? 0 : 1),
      child: ListTile(
            leading: Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
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
                    const Icon(Icons.shopping_cart,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(credit.code),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 14,
                      color: Colors.green,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                    Icon(
                      Icons.add_task_sharp,
                      size: 14,
                      color: Colors.orange,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                          "👤 Client: ${credit.name}\n🏷️ ${credit.code}\n💰 Montant: " +
                              formatter.format(credit.solde),
                      color: Colors.purple,
                      icon: Icons.person,
                      confirmText: "confirm".tr,
                      cancelText: "cancel".tr,
                    ),
                  ) ??
                  false;

              if (confirm) {
                ReceivaleLine line = new ReceivaleLine(
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
