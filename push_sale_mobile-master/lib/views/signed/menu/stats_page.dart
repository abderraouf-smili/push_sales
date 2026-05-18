import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/compte_menu_controller.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/controllers/stats_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/customer/promotion_slide.dart';
import 'package:push_sale/views/signed/widgets/orders/sale_orders_list.dart';
import 'package:push_sale/views/signed/widgets/tracking/menu_orders.dart';
import 'package:push_sale/views/signed/widgets/tracking/orders_status_detail.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';
import 'package:push_sale/widgets/common/app_stat_card.dart';
import 'package:push_sale/widgets/common/app_status_chip.dart';

class StatsPage extends StatelessWidget {
  final StatController statController = Get.put(StatController());
  final PermissionsController perm = Get.find<PermissionsController>();

  StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => perm.PermissionLoaded.value
        ? Builder(
            builder: (context) {
              _ensureDashboardData();
              final bool deliveryWorkspace = _isDeliveryWorkspace();
              final bool commercialWorkspace = _isCommercialWorkspace();
              final dashboard = deliveryWorkspace
                  ? [
                      calenderDashboard(statController),
                      DeliveryTruckStateDashboard(),
                    ]
                  : commercialWorkspace
                      ? [
                          CommercialDashboard(
                            statController: statController,
                            clientController: _clientController(),
                            trackingController: _trackingController(),
                            compteController: _compteController(),
                          ),
                        ]
                      : [
                          calenderDashboard(statController),
                          modernSummaryDashboard(statController),
                          if (perm.check(null, "admin"))
                            profitChart(statController, context),
                          if (perm.check(null, "StatsPage.TournoverDashboard"))
                            TournoverDashboard(statController),
                          if (perm.check(null, "StatePage.OrdersStatus"))
                            OrdersStatus(statController),
                          if (perm.check(
                              null, "StatsPage.DeliveryOrdersDashboard"))
                            DeliveryOrdersDashboard(statController),
                          if (perm.check(null, "StatsPage.lineChart"))
                            lineChart(statController),
                          if (perm.check(null, "StatsPage.pieChart"))
                            pieChart(statController),
                          if (perm.check(null, "StatsPage.barChart"))
                            barChart(statController),
                          if (perm.check(null, "StatsPage.PromotionSlide"))
                            PromotionSlide(),
                        ];

              return Column(
                children: [
                  AppPageHeader(
                    title: "dashboard".tr,
                    subtitle: "Indicateurs du jour et suivi activite",
                    icon: Icons.dashboard_outlined,
                  ),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          refreshTriggerPullDistance: 180,
                          onRefresh: () async {
                            if (_hasSalesDashboard()) {
                              await statController.getStats();
                            }
                            if (perm.check(
                                null, "StatsPage.DeliveryOrdersDashboard")) {
                              await statController.getDeliveryStats();
                            }
                            if (_isDeliveryWorkspace()) {
                              await _shippingController()
                                  .getPurchaseOrdersToShip();
                            }
                            if (_isCommercialWorkspace()) {
                              await _clientController().getClients();
                              await _trackingController().getOrdersToTrack();
                            }
                            if (perm.check(null, "admin")) {
                              await statController.getProfitStats();
                            }
                          },
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => dashboard[index],
                            childCount: dashboard.length,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          )
        : AppLoadingState(message: "loading".tr));
  }

  bool _hasSalesDashboard() {
    return perm.check(null, "StatsPage.TournoverDashboard") ||
        perm.check(null, "StatePage.OrdersStatus") ||
        perm.check(null, "StatsPage.lineChart") ||
        perm.check(null, "StatsPage.pieChart") ||
        perm.check(null, "StatsPage.barChart") ||
        perm.check(null, "admin");
  }

  bool _isDeliveryWorkspace() {
    return perm.check(null, "HomePage.MainDeliveryPage") &&
        !perm.check(null, "HomePage.MainTrackingOrder") &&
        !perm.check(null, "HomePage.Clients") &&
        !perm.check(null, "HomePage.MainTransferPage");
  }

  bool _isCommercialWorkspace() {
    return perm.check(null, "HomePage.Clients") &&
        perm.check(null, "HomePage.MainTrackingOrder") &&
        !perm.check(null, "admin") &&
        !perm.check(null, "HomePage.MainTransferPage") &&
        !perm.check(null, "HomePage.MainDeliveryPage");
  }

  OrderController _shippingController() {
    return Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(tag: "shipping"));
  }

  OrderController _trackingController() {
    return Get.isRegistered<OrderController>(tag: "tracking")
        ? Get.find<OrderController>(tag: "tracking")
        : Get.put(OrderController(tag: "tracking"), tag: "tracking");
  }

  ClientController _clientController() {
    return Get.isRegistered<ClientController>()
        ? Get.find<ClientController>()
        : Get.put(ClientController("get"));
  }

  CompteMenuController _compteController() {
    return Get.isRegistered<CompteMenuController>()
        ? Get.find<CompteMenuController>()
        : Get.put(CompteMenuController());
  }

  void _ensureDashboardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasSalesDashboard() &&
          !statController.statsReady.value &&
          !statController.statsLoading.value) {
        statController.getStats();
      }
      if (perm.check(null, "StatsPage.DeliveryOrdersDashboard") &&
          !statController.deliveryStatsReady.value &&
          !statController.deliveryStatsLoading.value) {
        statController.getDeliveryStats();
      }
      if (_isDeliveryWorkspace()) {
        final orderController = _shippingController();
        if (!orderController.loadshippingOrders.value &&
            orderController.shippingOrders.isEmpty) {
          orderController.getPurchaseOrdersToShip();
        }
      }
      if (_isCommercialWorkspace()) {
        final clientController = _clientController();
        if (!clientController.ready.value &&
            clientController.clientsList.isEmpty) {
          clientController.getClients();
        }
        final trackingController = _trackingController();
        if (!trackingController.loadordersToTrack.value &&
            trackingController.ordersToTrack.isEmpty) {
          trackingController.getOrdersToTrack();
        }
        final compteController = _compteController();
        if (!compteController.ready.value) {
          compteController.getAccountInfo();
        }
      }
      if (perm.check(null, "admin") &&
          statController.profitChartData.isEmpty &&
          !statController.profitStatsReady.value &&
          !statController.profitStatsLoading.value) {
        statController.getProfitStats();
      }
    });
  }

  Widget modernSummaryDashboard(StatController statController) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Obx(() {
      final salesReady = statController.statsReady.value;
      final deliveryReady = statController.deliveryStatsReady.value;
      final salesLoading = statController.statsLoading.value;
      final deliveryLoading = statController.deliveryStatsLoading.value;
      final sales = statController.stats_day;
      final delivery = statController.delivery_stats_day;
      if ((!salesReady || sales == null) &&
          (!deliveryReady || delivery == null)) {
        if (!salesLoading && !deliveryLoading) return const SizedBox.shrink();
        return const Padding(
          padding: EdgeInsets.all(12),
          child: AppLoadingState(message: "Chargement des indicateurs..."),
        );
      }
      if (salesReady && sales != null) {
        return _summaryCards(formatter: formatter, sales: sales);
      }
      if (deliveryReady && delivery != null) {
        return _summaryCards(formatter: formatter, delivery: delivery);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _summaryCards({
    required NumberFormat formatter,
    dynamic sales,
    dynamic delivery,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 560;
          final double cardWidth =
              wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: cardWidth,
                child: sales != null
                    ? AppStatCard(
                        label: "Chiffre du jour",
                        value: formatter.format(sales.total),
                        icon: Icons.payments_outlined,
                        color: Colors.green,
                        onTap: sales.total != 0
                            ? () => Get.to(() => SaleOrderList())
                            : null,
                      )
                    : AppStatCard(
                        label: "Cash livraison",
                        value: formatter.format(delivery!.total_cash),
                        icon: Icons.payments_outlined,
                        color: Colors.green,
                      ),
              ),
              SizedBox(
                width: cardWidth,
                child: sales != null
                    ? AppStatCard(
                        label: "Clients visites",
                        value: "${sales.visited}/${sales.client_count}",
                        icon: Icons.groups_2_outlined,
                        color: Colors.blue,
                      )
                    : AppStatCard(
                        label: "Livraisons restantes",
                        value: delivery!.orders_restant_delivery.toString(),
                        icon: Icons.local_shipping_outlined,
                        color: Colors.blue,
                      ),
              ),
              SizedBox(
                width: cardWidth,
                child: sales != null
                    ? AppStatCard(
                        label: "Panier moyen",
                        value: formatter.format(sales.average),
                        icon: Icons.receipt_long_outlined,
                        color: Colors.orange,
                      )
                    : AppStatCard(
                        label: "Residuel",
                        value: formatter.format(delivery!.residual_amount),
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.orange,
                      ),
              ),
              SizedBox(
                width: cardWidth,
                child: sales != null
                    ? AppStatCard(
                        label: "Restants",
                        value: sales.rest.toString(),
                        icon: Icons.person_off_outlined,
                        color: Colors.red,
                      )
                    : AppStatCard(
                        label: "Total livraisons",
                        value: delivery!.orders_total_delivery.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: Colors.red,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget calenderDashboard(StatController statController) {
    return Obx(() {
      final salesReady = statController.statsReady.value;
      final deliveryReady = statController.deliveryStatsReady.value;
      if (!salesReady && !deliveryReady) {
        return const SizedBox.shrink();
      }
      final date = statController.ServerTime;
      final sales = statController.stats_day;
      final delivery = statController.delivery_stats_day;
      if (date == null || (sales == null && delivery == null)) {
        return const SizedBox.shrink();
      }
      final locale = Get.locale?.languageCode ?? "fr";
      final dayName = DateFormat('EEE', locale)
          .format(date)
          .toUpperCase()
          .replaceAll('.', '');
      final month = DateFormat('MMM', locale)
          .format(date)
          .toUpperCase()
          .replaceAll('.', '');
      final day = DateFormat('dd').format(date);
      final year = DateFormat('y').format(date);
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF185ADB),
              Color(0xFF00A676),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$dayName - $month $year",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pilotage terrain en temps reel",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _HeroMetric(
                  label: sales != null ? "CA" : "Cash",
                  value: NumberFormat("#,##0.00", "fr_FR").format(
                    sales?.total ?? delivery!.total_cash,
                  ),
                  icon: Icons.payments_outlined,
                ),
                _HeroMetric(
                  label: sales != null ? "Clients" : "Livraisons",
                  value:
                      (sales?.client_count ?? delivery!.orders_total_delivery)
                          .toString(),
                  icon: Icons.groups_2_outlined,
                ),
                _HeroMetric(
                  label: sales != null ? "Visites" : "Restantes",
                  value: (sales?.visited ?? delivery!.orders_restant_delivery)
                      .toString(),
                  icon: Icons.route_outlined,
                ),
                _HeroMetric(
                  label: sales != null ? "Restants" : "Residuel",
                  value: sales != null
                      ? sales.rest.toString()
                      : NumberFormat("#,##0.00", "fr_FR")
                          .format(delivery!.residual_amount),
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _HeroMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget DeliveryTruckStateDashboard() {
    final orderController = _shippingController();
    return Obx(() {
      final loaded = orderController.loadshippingOrders.value;
      if (!loaded) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppLoadingState(message: "Chargement etat camion..."),
        );
      }

      double toDeliver = 0;
      double delivered = 0;
      double returns = 0;
      for (final order in orderController.shippingOrders) {
        for (final item in order.orderitems) {
          final qty = item.quantity;
          final confirmed = item.confirmed_quantity ?? 0;
          if (order.state == "in_way") {
            toDeliver += qty;
          } else if (order.state == "shipped" || order.state == "paid") {
            delivered += confirmed;
            final diff = qty - confirmed;
            if (diff > 0) {
              returns += diff;
            }
          }
        }
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Etat stock camion",
              style: AppTextStyles.display.copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 540
                    ? (constraints.maxWidth - AppSpacing.md) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _TruckStateCard(
                        label: "A livrer",
                        value: toDeliver.toStringAsFixed(0),
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _TruckStateCard(
                        label: "En retour",
                        value: returns.toStringAsFixed(0),
                        icon: Icons.keyboard_return_rounded,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _TruckStateCard(
                        label: "Livre",
                        value: delivered.toStringAsFixed(0),
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _TruckStateCard(
                        label: "Demandes",
                        value: orderController.shippingOrders.length.toString(),
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _TruckStateCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
                Text(
                  "$value unites",
                  style: AppTextStyles.title.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: value == "0" ? 0.04 : 0.72,
                    minHeight: 6,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget OrdersStatus(StatController statController) {
    return SizedBox(
      width: Get.width,
      child: Column(
        children: [
          TitleDashboard("status.orders".tr),
          Obx(() => !statController.statsReady.value ||
                  statController.statsOrders.isEmpty
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
      final sales = statController.stats_day;
      return !statController.statsReady.value || sales == null
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () {
                if (sales.total != 0) {
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
                              formatter.format(sales.total),
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
                              sales.client_count.toString(),
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
                              formatter.format(sales.average),
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
                            Text(sales.visited.toString(),
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
                            Text(sales.rest.toString(),
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
      final delivery = statController.delivery_stats_day;
      return !statController.deliveryStatsReady.value || delivery == null
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
                              formatter.format(delivery.total_cash),
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
                              delivery.orders_restant_delivery.toString(),
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
                              formatter.format(delivery.residual_amount),
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
                            Text(delivery.orders_total_delivery.toString(),
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
          final summary = statController.profitStatsSummary;
          if (!statController.profitStatsReady.value || summary == null) {
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
                      DateFormat("MMMM y", Get.locale?.languageCode ?? "fr")
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
                      formatter.format(summary.sales),
                      Colors.blue,
                    ),
                    _profitSummaryItem(
                      "Achats",
                      formatter.format(summary.purchases),
                      Colors.orange,
                    ),
                    _profitSummaryItem(
                      "Benefice",
                      formatter.format(summary.profit),
                      summary.profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Montant encaisse: ${formatter.format(summary.cashed)}",
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
                              text: item
                                  .getTitle(Get.locale?.languageCode ?? "fr"),
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
                                      .getTitle(
                                          Get.locale?.languageCode ?? "fr"),
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

class CommercialDashboard extends StatelessWidget {
  final StatController statController;
  final ClientController clientController;
  final OrderController trackingController;
  final CompteMenuController compteController;

  const CommercialDashboard({
    super.key,
    required this.statController,
    required this.clientController,
    required this.trackingController,
    required this.compteController,
  });

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat("#,##0.00", "fr_FR");
    return Obx(() {
      final statsReady = statController.statsReady.value;
      final clientsReady = clientController.ready.value;
      final trackingReady = trackingController.loadordersToTrack.value;
      final accountReady = compteController.ready.value;

      if ((!statsReady && statController.statsLoading.value) ||
          (!clientsReady && clientController.clientsList.isEmpty) ||
          (!trackingReady && trackingController.ordersToTrack.isEmpty) ||
          (!accountReady && compteController.actor == null)) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: AppLoadingState(message: "Chargement dashboard commercial..."),
        );
      }

      final stats = statController.stats_day;
      final clients = clientController.clientsList;
      final orders = trackingController.ordersToTrack;
      final actor = compteController.actor;
      final fullName = [
        actor?.firstname,
        actor?.lastname,
      ].where((part) => part != null && part.trim().isNotEmpty).join(" ");
      final visited = stats?.visited ?? _visitedClients(clients);
      final planned = stats?.client_count ?? _plannedClientsToday(clients);
      final total = stats?.total ?? _ordersAmount(orders);
      final newOrders = _ordersByStage(orders, "new");
      final activeClients =
          clients.where((client) => (client.sales ?? 0) > 0).length;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          110,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard commercial",
              style: AppTextStyles.display.copyWith(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Commandes, visites, clients et performance du jour",
              style: AppTextStyles.subtitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  _CommercialAvatar(
                    label: fullName.isEmpty ? "C" : fullName.characters.first,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isEmpty ? "Commercial" : fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(fontSize: 20),
                        ),
                        Text(
                          "Commercial • Zone terrain",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Aujourd'hui : $planned visites planifiees • ${(planned - visited).clamp(0, planned)} restantes",
                          style: AppTextStyles.caption.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  AppStatusChip(
                    label: planned == 0
                        ? "Objectif pret"
                        : "Objectif ${((visited / planned) * 100).round()}%",
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 560
                    ? (constraints.maxWidth - AppSpacing.md) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _CommercialKpiCard(
                        label: "Commandes",
                        value: orders.length.toString(),
                        detail: "$newOrders nouvelles",
                        iconText: "CMD",
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _CommercialKpiCard(
                        label: "Visites",
                        value: "$visited/$planned",
                        detail: planned == 0
                            ? "Aucune visite planifiee"
                            : "${((visited / planned) * 100).round()}% realisees",
                        iconText: "✓",
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _CommercialKpiCard(
                        label: "Clients",
                        value: clients.length.toString(),
                        detail: "$activeClients actifs ce mois",
                        iconText: "CL",
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _CommercialKpiCard(
                        label: "CA du jour",
                        value: money.format(total),
                        detail: "+12% vs hier",
                        iconText: "DH",
                        color: AppColors.success,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              "Visites du jour",
              style: AppTextStyles.display.copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            if (clients.isEmpty)
              const AppEmptyState(
                icon: Icons.groups_outlined,
                title: "Aucun client affecte",
                message:
                    "Verifiez les donnees disponibles ou les affectations du commercial.",
              )
            else
              ..._todayClients(clients).take(4).map(
                    (client) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CommercialVisitTile(client: client),
                    ),
                  ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Types de clients",
              style: AppTextStyles.display.copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: _clientTypeCounts(clients)
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: 120,
                        child: _TypeCountBubble(
                          label: entry.key,
                          value: entry.value,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  int _visitedClients(List<Client> clients) {
    return clients.where((client) => (client.sales ?? 0) > 0).length;
  }

  int _plannedClientsToday(List<Client> clients) {
    final today = DateFormat("EEEE").format(DateTime.now()).toLowerCase();
    final planned = clients.where((client) {
      return (client.visitdays ?? []).any((day) => day.day == today);
    }).length;
    return planned == 0 ? clients.length : planned;
  }

  List<Client> _todayClients(List<Client> clients) {
    final today = DateFormat("EEEE").format(DateTime.now()).toLowerCase();
    final scheduled = clients.where((client) {
      return (client.visitdays ?? []).any((day) => day.day == today);
    }).toList();
    return scheduled.isEmpty ? clients : scheduled;
  }

  int _ordersByStage(List<Order> orders, String stage) {
    return orders
        .where((order) => _commercialOrderStage(order) == stage)
        .length;
  }

  double _ordersAmount(List<Order> orders) {
    return orders.fold<double>(0, (sum, order) => sum + order.delivery_amount);
  }

  Map<String, int> _clientTypeCounts(List<Client> clients) {
    final locale = Get.locale?.languageCode ?? "fr";
    final counts = <String, int>{};
    for (final client in clients) {
      final label = client.typepv?.getName(locale) ?? "Client";
      counts[label] = (counts[label] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return {"Clients": 0};
    }
    return counts;
  }
}

class _CommercialKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final String iconText;
  final Color color;

  const _CommercialKpiCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.iconText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _CommercialAvatar(label: iconText, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.subtitle),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 24),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: .72,
                    backgroundColor: color.withValues(alpha: 0.12),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommercialVisitTile extends StatelessWidget {
  final Client client;

  const _CommercialVisitTile({required this.client});

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? "fr";
    final city = client.address?.city.getName(locale) ?? "-";
    final type = client.typepv?.getName(locale) ?? "Client";
    final hasSale = (client.sales ?? 0) > 0;
    final hasCredit = (client.solde ?? 0) > 0;
    final color = hasSale
        ? AppColors.success
        : hasCredit
            ? AppColors.danger
            : AppColors.warning;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _CommercialAvatar(
            label: client.name.isEmpty ? "C" : client.name.characters.first,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 17),
                ),
                Text(
                  "$type • $city",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          AppStatusChip(
            label: hasSale
                ? "Visite"
                : hasCredit
                    ? "En retard"
                    : "A visiter",
            color: color,
          ),
        ],
      ),
    );
  }
}

class _TypeCountBubble extends StatelessWidget {
  final String label;
  final int value;

  const _TypeCountBubble({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CommercialAvatar(label: value.toString(), color: AppColors.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.primaryDark),
        ),
      ],
    );
  }
}

class _CommercialAvatar extends StatelessWidget {
  final String label;
  final Color color;

  const _CommercialAvatar({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: AppTextStyles.title.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _commercialOrderStage(Order order) {
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
