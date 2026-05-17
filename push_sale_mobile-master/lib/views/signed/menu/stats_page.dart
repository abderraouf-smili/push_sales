import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/controllers/stats_controller.dart';
import 'package:push_sale/views/signed/customer/promotion_slide.dart';
import 'package:push_sale/views/signed/widgets/orders/sale_orders_list.dart';
import 'package:push_sale/views/signed/widgets/tracking/menu_orders.dart';
import 'package:push_sale/views/signed/widgets/tracking/orders_status_detail.dart';

class StatsPage extends StatelessWidget {
  StatController statController = Get.put(StatController());
  PermissionsController perm = Get.find<PermissionsController>();

  StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (statController.pieCharData.isEmpty &&
        perm.check(null, "StatsPage.TournoverDashboard")) {
      statController.getStats();
    }
    if (perm.check(null, "StatsPage.DeliveryOrdersDashboard")) {
      statController.getDeliveryStats();
    }
    if (perm.check(null, "admin") &&
        statController.profitChartData.isEmpty &&
        !statController.profitStatsReady.value &&
        !statController.profitStatsLoading.value) {
      statController.getProfitStats();
    }

    List<Widget> Dashboard = [
      calenderDashboard(statController),
      const Divider(),
      perm.check(profitChart(statController, context), "admin"),
      perm.check(
          TournoverDashboard(statController), "StatsPage.TournoverDashboard"),
      perm.check(OrdersStatus(statController), "StatePage.OrdersStatus"),
      perm.check(DeliveryOrdersDashboard(statController),
          "StatsPage.DeliveryOrdersDashboard"),
      perm.check(lineChart(statController), "StatsPage.lineChart"),
      perm.check(pieChart(statController), "StatsPage.pieChart"),
      perm.check(barChart(statController), "StatsPage.barChart"),
      perm.check(PromotionSlide(), "StatsPage.PromotionSlide"),
    ];
    return Obx(() => perm.PermissionLoaded.value
        ? Column(
            children: [
              //entete DASHBOARD
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 107, 166, 255),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      "dashboard".tr,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Listing of charts
              SizedBox(
                height: Get.height - 100,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      refreshTriggerPullDistance: 180,
                      onRefresh: () async {
                        await statController.getStats();
                        if (perm.check(null, "admin")) {
                          await statController.getProfitStats();
                        }
                      },
                    ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) => Dashboard[index],
                      childCount: Dashboard.length,
                    ))
                  ],
                ),
              )
            ],
          )
        : const SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
                child: SizedBox(
                    width: 40, height: 40, child: CircularProgressIndicator())),
          ));
  }

  Widget calenderDashboard(StatController statController) {
    DateTime? date;
    String? dayName;
    String? month;
    String? day;
    String? year;
    return Obx(() {
      if (statController.statsReady.value) {
        date = statController.ServerTime!;
        dayName = DateFormat('EEE', Get.locale!.languageCode).format(date!);
        dayName = dayName!.toUpperCase().replaceAll('.', '');
        month = DateFormat('MMM', Get.locale!.languageCode)
            .format(date!)
            .toUpperCase()
            .replaceAll('.', '');
        day = DateFormat('dd').format(date!);
        year = DateFormat('y').format(date!);
      }
      return !statController.statsReady.value
          ? const SizedBox.shrink()
          : Container(
              padding:
                  EdgeInsets.symmetric(horizontal: Get.width / 6, vertical: 2),
              width: Get.width - 20,
              height: Get.height / 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day!,
                    style: TextStyle(
                      fontSize: Get.height / 8 - 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 92, 92, 92),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        dayName!,
                        style: TextStyle(
                            fontSize: Get.height / 20 - 15,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 92, 92, 92)),
                      ),
                      Text(
                        "${month!} ${year!}",
                        style: TextStyle(
                            fontSize: Get.height / 25 - 10,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 92, 92, 92)),
                      )
                    ],
                  ),
                ],
              ),
            );
    });
  }

  Widget OrdersStatus(StatController statController) {
    return SizedBox(
      width: Get.width,
      child: Column(
        children: [
          TitleDashboard("status.orders".tr),
          Obx(() => !statController.statsReady.value
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: (statController.statsOrders.length / 2).ceil() * 100,
                  width: Get.width,
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statController.statsOrders.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var item = statController.statsOrders[index];
                        return GestureDetector(
                          onTap: (() {
                            Get.to(() => OrdersStatusDetail(item.state));
                          }),
                          child: OrderWidget(
                            number: item.count,
                            state: item.state,
                          ),
                        );
                      }),
                )),
        ],
      ),
    );
  }

  Widget TournoverDashboard(StatController statController) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Obx(() {
      return !statController.statsReady.value
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () {
                if (statController.stats_day!.total != 0) {
                  Get.to(() => SaleOrderList());
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                width: Get.width - 20,
                height: Get.height / 8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              "assets/images/solde.png",
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              formatter.format(statController.stats_day!.total),
                              style: TextStyle(
                                fontSize: Get.height / 14 - 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 92, 92, 92),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.group_sharp,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              statController.stats_day!.client_count.toString(),
                              style: TextStyle(
                                fontSize: Get.height / 18 - 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 92, 92, 92),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.balance,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              formatter
                                  .format(statController.stats_day!.average),
                              style: TextStyle(
                                fontSize: Get.height / 18 - 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 92, 92, 92),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_sharp),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(statController.stats_day!.visited.toString(),
                                style: TextStyle(
                                  fontSize: Get.height / 20 - 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 92, 92, 92),
                                )),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.group_remove_outlined,
                                color: Color.fromRGBO(236, 104, 104, 1)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(statController.stats_day!.rest.toString(),
                                style: TextStyle(
                                  fontSize: Get.height / 20 - 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 236, 104, 104),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
    });
  }

  Widget DeliveryOrdersDashboard(StatController statController) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Obx(() {
      return !statController.statsReady.value
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                width: Get.width - 20,
                height: Get.height / 8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              "assets/images/solde.png",
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              formatter.format(statController
                                  .delivery_stats_day!.total_cash),
                              style: TextStyle(
                                fontSize: Get.height / 14 - 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 92, 92, 92),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Color.fromARGB(255, 160, 55, 48),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              statController
                                  .delivery_stats_day!.orders_restant_delivery
                                  .toString(),
                              style: TextStyle(
                                fontSize: Get.height / 20 - 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 160, 55, 48),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.money,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              formatter.format(statController
                                  .delivery_stats_day!.residual_amount),
                              style: TextStyle(
                                fontSize: Get.height / 16 - 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 92, 92, 92),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping_outlined),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                                statController
                                    .delivery_stats_day!.orders_total_delivery
                                    .toString(),
                                style: TextStyle(
                                  fontSize: Get.height / 20 - 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 92, 92, 92),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
    });
  }

  Widget profitChart(StatController statController, BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Column(
      children: [
        TitleDashboard("Benefice livre"),
        Obx(() {
          if (!statController.profitStatsReady.value) {
            return const SizedBox.shrink();
          }

          double maxY = statController.maxProfitY * 1.25;
          if (maxY == 0) {
            maxY = 1;
          }

          return Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat("MMMM y", Get.locale!.languageCode)
                          .format(statController.profitMonth)
                          .capitalizeFirst!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 92, 92, 92),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined),
                      onPressed: () async {
                        DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: statController.profitMonth,
                          firstDate: DateTime(2020, 1, 1),
                          lastDate: DateTime.now(),
                        );
                        if (selected != null) {
                          await statController.getProfitStats(month: selected);
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _profitSummaryItem(
                      "Ventes",
                      formatter
                          .format(statController.profitStatsSummary!.sales),
                      Colors.blue,
                    ),
                    _profitSummaryItem(
                      "Achats",
                      formatter
                          .format(statController.profitStatsSummary!.purchases),
                      Colors.orange,
                    ),
                    _profitSummaryItem(
                      "Benefice",
                      formatter
                          .format(statController.profitStatsSummary!.profit),
                      statController.profitStatsSummary!.profit >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Montant encaisse: ${formatter.format(statController.profitStatsSummary!.cashed)}",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 92, 92, 92),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: Get.width,
                  height: Get.height / 3.5,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: const Color.fromARGB(235, 40, 67, 90),
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            ProfitChartData item =
                                statController.profitChartData[groupIndex];
                            String title = rodIndex == 0 ? "Achats" : "Ventes";
                            double value =
                                rodIndex == 0 ? item.purchases : item.sales;
                            return BarTooltipItem(
                              "${item.day}\n$title: ${formatter.format(value)}",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "alata",
                              ),
                            );
                          },
                        ),
                      ),
                      gridData:
                          const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              int day = value.toInt();
                              if (day == 1 ||
                                  day == 10 ||
                                  day == 20 ||
                                  day ==
                                      statController.profitChartData.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    day.toString(),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        statController.profitChartData.length,
                        (index) {
                          ProfitChartData item =
                              statController.profitChartData[index];
                          return BarChartGroupData(
                            x: item.day,
                            barsSpace: 2,
                            barRods: [
                              BarChartRodData(
                                width: 4,
                                toY: item.purchases,
                                color: Colors.orange,
                              ),
                              BarChartRodData(
                                width: 4,
                                toY: item.sales,
                                color: Colors.blue,
                              ),
                            ],
                          );
                        },
                      ),
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Indicator(
                        color: Colors.orange, text: "Achats", isSquare: false),
                    SizedBox(width: 12),
                    Indicator(
                        color: Colors.blue, text: "Ventes", isSquare: false),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _profitSummaryItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color.fromARGB(255, 92, 92, 92),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget TitleDashboard(String titre) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: 50,
      child: Center(
          child: Text(
        titre,
        style: const TextStyle(
          color: Color.fromARGB(255, 128, 128, 128),
          fontSize: 18.0,
          letterSpacing: 1.5,
        ),
      )),
    );
  }

  Widget lineChart(StatController statController) {
    return Column(
      children: [
        TitleDashboard("turnover".tr),
        Obx(
          () => statController.statsReady.value &&
                  statController.pieCharData.isNotEmpty
              ? SizedBox(
                  width: Get.width,
                  height: Get.height / 4,
                  child: LineChart(LineChartData(
                    gridData: const FlGridData(
                      show: false,
                      drawVerticalLine: false,
                    ),
                    titlesData: const FlTitlesData(
                      show: false,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          interval: 1,
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    minX: 0,
                    maxX: statController.lineChartData.length * 1.00 - 1,
                    minY: 0,
                    maxY: statController.maxLineY * 1.25,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                            statController.lineChartData.length,
                            (index) => FlSpot(
                                statController.lineChartData[index].x,
                                statController.lineChartData[index].y)),
                        isCurved: true,
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(
                          show: false,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                        ),
                      ),
                    ],
                  )),
                )
              : statController.statsReady.value &&
                      statController.pieCharData.isEmpty
                  ? Container(
                      width: Get.width,
                      height: Get.height / 4,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/stats_empty_line.png"))),
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget pieChart(StatController statController) {
    return Column(
      children: [
        TitleDashboard("category_turnover".tr),
        Obx(
          () => statController.statsReady.value &&
                  statController.pieCharData.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      SizedBox(
                        width: Get.width / 2,
                        height: Get.height / 3,
                        child: PieChart(PieChartData(
                          sectionsSpace: 5,
                          sections: List.generate(
                              statController.pieCharData.length, (index) {
                            var item = statController.pieCharData[index];
                            return PieChartSectionData(
                              value: item.value,
                              color: item.color,
                            );
                          }),
                        )),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              statController.pieCharData.length, (int index) {
                            var item = statController.pieCharData[index];
                            return Indicator(
                              color: item.color,
                              text: item.getTitle(Get.locale!.languageCode),
                              isSquare: false,
                            );
                          }))
                    ])
              : statController.statsReady.value &&
                      statController.pieCharData.isEmpty
                  ? Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: Get.width,
                      height: Get.height / 4,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/stats_empty_pie.png"))),
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget barChart(StatController statController) {
    return Column(
      children: [
        TitleDashboard("customer_classes".tr),
        Obx(
          () => statController.statsReady.value &&
                  statController.lineChartData.isNotEmpty
              ? SizedBox(
                  width: double.infinity,
                  height: Get.height / 4,
                  child: BarChart(
                    BarChartData(
                      barTouchData: barTouchData,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (x, t) {
                              return SideTitleWidget(
                                axisSide: t.axisSide,
                                space: 4,
                                child: Text(
                                  statController.barCharData[x.toInt() - 1]
                                      .getTitle(Get.locale!.languageCode),
                                  style: const TextStyle(
                                      fontFamily: "alata",
                                      color:
                                          Color.fromARGB(255, 104, 152, 192)),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: borderData,
                      barGroups: List.generate(
                          statController.barCharData.length,
                          (index) => BarChartGroupData(
                                x: index + 1,
                                barRods: [
                                  BarChartRodData(
                                    width: 35,
                                    toY: statController.barCharData[index].x,
                                    gradient: _barsGradient,
                                  )
                                ],
                                showingTooltipIndicators: [0],
                              )),
                      gridData: const FlGridData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: statController.maxYbar * 1.5,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

FlBorderData get borderData => FlBorderData(
      show: false,
    );

BarTouchData get barTouchData => BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.transparent,
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 8,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            rod.toY.round().toString(),
            const TextStyle(
                color: Color.fromARGB(255, 40, 67, 90),
                fontWeight: FontWeight.bold,
                fontFamily: "alata"),
          );
        },
      ),
    );
LinearGradient get _barsGradient => const LinearGradient(
      colors: [
        Color.fromARGB(255, 38, 97, 146),
        Color.fromARGB(255, 175, 219, 255),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
        )
      ],
    );
  }
}
