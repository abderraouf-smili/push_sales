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
import 'package:push_sale/widgets/common/app_status_chip.dart';

class DeliveryRequestsPage extends StatefulWidget {
  final PageController pageController;

  const DeliveryRequestsPage(this.pageController, {super.key});

  @override
  State<DeliveryRequestsPage> createState() => _DeliveryRequestsPageState();
}

class _DeliveryRequestsPageState extends State<DeliveryRequestsPage> {
  final OrderController orderController = Get.isRegistered<OrderController>()
      ? Get.find<OrderController>()
      : Get.put(OrderController(tag: 'shipping'));
  final Set<String> selectedStates = {'in_way', 'shipped', 'paid'};

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
          title: 'Delivery',
          subtitle: 'Demandes preparees, en cours et livrees',
          icon: Icons.local_shipping_outlined,
        ),
        Expanded(
          child: Obx(() {
            final loaded = orderController.loadshippingOrders.value;
            if (!loaded) {
              return const AppLoadingState(message: 'Chargement livraisons...');
            }
            final orders = _filteredOrders();
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
                  _filterCard(),
                  const SizedBox(height: AppSpacing.md),
                  _statusCounters(),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Demandes de livraison',
                    style: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (orders.isEmpty)
                    const AppEmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'Aucune demande',
                      message:
                          'Aucune livraison ne correspond aux filtres selectionnes.',
                    )
                  else
                    ...orders.map(_deliveryCard),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  List<PurchaseOrder> _filteredOrders() {
    return orderController.shippingOrders
        .where((order) => selectedStates.contains(order.state))
        .toList()
      ..sort((a, b) => a.planned_delivery_date.compareTo(
            b.planned_delivery_date,
          ));
  }

  Widget _filterCard() {
    final filters = [
      ('in_way', 'A livrer'),
      ('shipped', 'Livrees'),
      ('paid', 'Payees'),
      ('returned', 'Retours'),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filtre intelligent',
                  style: AppTextStyles.subtitle,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedStates
                      ..clear()
                      ..addAll(filters.map((e) => e.$1));
                  });
                },
                icon: const Icon(Icons.done_all_rounded),
                label: const Text('Tout'),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: filters.map((filter) {
              final selected = selectedStates.contains(filter.$1);
              return FilterChip(
                selected: selected,
                label: Text(filter.$2),
                checkmarkColor: Colors.white,
                selectedColor: _stateColor(filter.$1),
                backgroundColor: AppColors.surface,
                labelStyle: AppTextStyles.button.copyWith(
                  color: selected ? Colors.white : AppColors.primaryDark,
                ),
                side: const BorderSide(color: AppColors.line),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      selectedStates.add(filter.$1);
                    } else if (selectedStates.length > 1) {
                      selectedStates.remove(filter.$1);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _statusCounters() {
    final all = orderController.shippingOrders.length;
    final inWay =
        orderController.shippingOrders.where((e) => e.state == 'in_way').length;
    final shipped = orderController.shippingOrders
        .where((e) => e.state == 'shipped')
        .length;
    final paid =
        orderController.shippingOrders.where((e) => e.state == 'paid').length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _counter('Toutes', all, AppColors.primary, width),
            _counter('A livrer', inWay, AppColors.warning, width),
            _counter('Livrees', shipped, AppColors.secondary, width),
            _counter('Payees', paid, Colors.purple, width),
          ],
        );
      },
    );
  }

  Widget _counter(String label, int value, Color color, double width) {
    return SizedBox(
      width: width,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.subtitle),
            Text(
              value.toString(),
              style: AppTextStyles.display.copyWith(color: color, fontSize: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryCard(PurchaseOrder order) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    final color = _stateColor(order.state);
    final client = order.client;
    final city = client?.address?.city.name ?? '';
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _openOrder(order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBubble(_stateIcon(order.state), color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.code, style: AppTextStyles.title),
                    Text(
                      client?.name ?? 'Client non renseigne',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body,
                    ),
                    Text(
                      [
                        if (city.isNotEmpty) city,
                        '${order.orderitems.length} articles',
                        formatter.format(order.total_amount),
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
              AppStatusChip(
                label: _stateLabel(order.state),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: 210,
              child: order.state == 'in_way'
                  ? ElevatedButton.icon(
                      onPressed: () => _openOrder(order),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Bon reception'),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => _openOrder(order),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Voir details'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openOrder(PurchaseOrder order) {
    orderController.selectedPO = order;
    if (widget.pageController.hasClients) {
      widget.pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  String _stateLabel(String state) {
    return switch (state) {
      'in_way' => 'A livrer',
      'shipped' => 'Livree',
      'paid' => 'Payee',
      'returned' => 'Retour',
      _ => state,
    };
  }

  IconData _stateIcon(String state) {
    return switch (state) {
      'in_way' => Icons.inventory_2_outlined,
      'shipped' => Icons.local_shipping_outlined,
      'paid' => Icons.payments_outlined,
      'returned' => Icons.keyboard_return_rounded,
      _ => Icons.receipt_long_outlined,
    };
  }

  Color _stateColor(String state) {
    return switch (state) {
      'in_way' => AppColors.warning,
      'shipped' => AppColors.primary,
      'paid' => AppColors.secondary,
      'returned' => Colors.purple,
      _ => AppColors.primary,
    };
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Icon(icon, color: color),
    );
  }
}
