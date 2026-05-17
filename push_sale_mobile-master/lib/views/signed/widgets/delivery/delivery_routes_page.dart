import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/purchase_order.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class DeliveryRoutesPage extends StatefulWidget {
  const DeliveryRoutesPage({super.key});

  @override
  State<DeliveryRoutesPage> createState() => _DeliveryRoutesPageState();
}

class _DeliveryRoutesPageState extends State<DeliveryRoutesPage> {
  final OrderController orderController = Get.isRegistered<OrderController>()
      ? Get.find<OrderController>()
      : Get.put(OrderController(tag: 'shipping'));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!orderController.loadshippingOrders.value) {
        orderController.getPurchaseOrdersToShip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppPageHeader(
          title: 'Trajets',
          subtitle: 'Clients a livrer et ordre de passage recommande',
          icon: Icons.route_outlined,
        ),
        Expanded(
          child: Obx(() {
            final loaded = orderController.loadshippingOrders.value;
            if (!loaded) {
              return const AppLoadingState(message: 'Chargement trajets...');
            }
            final orders = _routeOrders();
            if (orders.isEmpty) {
              return AppEmptyState(
                icon: Icons.route_outlined,
                title: 'Aucun trajet aujourd hui',
                message:
                    'Aucune commande a livrer pour ce livreur sur la journee.',
                action: ElevatedButton.icon(
                  onPressed: orderController.getPurchaseOrdersToShip,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Actualiser'),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: orderController.getPurchaseOrdersToShip,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  96,
                ),
                children: [
                  _mapPreview(orders),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Ordre de passage recommande',
                    style: AppTextStyles.display.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...orders.asMap().entries.map((entry) {
                    return _routeCard(entry.key + 1, entry.value);
                  }),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  List<PurchaseOrder> _routeOrders() {
    return orderController.shippingOrders
        .where((order) => order.state == 'in_way' || order.state == 'shipped')
        .toList()
      ..sort((a, b) {
        final left = a.delivery_position ?? 999;
        final right = b.delivery_position ?? 999;
        if (left != right) return left.compareTo(right);
        return a.planned_delivery_date.compareTo(b.planned_delivery_date);
      });
  }

  Widget _mapPreview(List<PurchaseOrder> orders) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          height: 260,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF2FF),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _RouteMapPainter())),
              PositionedDirectional(
                top: AppSpacing.lg,
                start: AppSpacing.lg,
                child: Obx(() {
                  final status = orderController.statusLoadRoute.value;
                  final route = orderController.route_maps.isNotEmpty
                      ? orderController.route_maps.first
                      : null;
                  final label = status == 'success' && route != null
                      ? 'Chemin optimal : ${(route.distance / 1000).toStringAsFixed(0)} km • ${(route.time / 60).toStringAsFixed(0)} min'
                      : 'Chemin optimal : ${orders.length} arrets';
                  return Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  );
                }),
              ),
              ...List.generate(math.min(orders.length, 6), (index) {
                const positions = [
                  Offset(0.08, 0.72),
                  Offset(0.24, 0.52),
                  Offset(0.40, 0.64),
                  Offset(0.55, 0.38),
                  Offset(0.72, 0.48),
                  Offset(0.88, 0.25),
                ];
                final pos = positions[index];
                return Positioned(
                  left: pos.dx * MediaQuery.of(context).size.width * 0.78,
                  top: pos.dy * 230,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor:
                        index == 0 ? AppColors.primary : AppColors.softGreen,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index == 0 ? Colors.white : AppColors.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }),
              PositionedDirectional(
                bottom: AppSpacing.lg,
                end: AppSpacing.lg,
                child: Obx(() {
                  final loading =
                      orderController.statusLoadRoute.value == 'loading';
                  return ElevatedButton.icon(
                    onPressed: loading ? null : _optimizeRoute,
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.map_outlined),
                    label: Text(loading ? 'Optimisation...' : 'Optimiser'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _optimizeRoute() {
    if (orderController.MyCurrentPosition == null ||
        orderController.clients_delivery.isEmpty) {
      Get.snackbar(
        'Trajet indisponible',
        'Activez la localisation puis actualisez les livraisons.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    orderController.getOptimizedRoute();
  }

  Widget _routeCard(int index, PurchaseOrder order) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    final client = order.client;
    final time = DateFormat('HH:mm').format(order.planned_delivery_date);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                index == 1 ? AppColors.softGreen : AppColors.softBlue,
            child: Text(
              index.toString(),
              style: AppTextStyles.title.copyWith(
                color: index == 1 ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client?.name ?? order.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
                Text(
                  '$time • ${formatter.format(order.total_amount)} • ${order.orderitems.length} articles',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Get.snackbar(
                'Client',
                client?.address == null
                    ? 'Adresse client indisponible.'
                    : '${client!.address!.city.name}, ${client.address!.wilaya.name}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFD6E3F6)
      ..strokeWidth = 3;
    for (var i = -3; i < 9; i++) {
      canvas.drawLine(
        Offset(i * size.width / 5, 0),
        Offset((i + 2) * size.width / 5, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * size.height / 5),
        Offset(size.width, i * size.height / 5 + size.height / 7),
        gridPaint,
      );
    }

    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..lineTo(size.width * 0.24, size.height * 0.52)
      ..lineTo(size.width * 0.40, size.height * 0.64)
      ..lineTo(size.width * 0.55, size.height * 0.38)
      ..lineTo(size.width * 0.72, size.height * 0.48)
      ..lineTo(size.width * 0.88, size.height * 0.25);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
