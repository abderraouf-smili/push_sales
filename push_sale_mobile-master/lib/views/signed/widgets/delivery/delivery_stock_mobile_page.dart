import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/item_stock.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';
import 'package:push_sale/widgets/common/app_status_chip.dart';

class DeliveryStockMobilePage extends StatefulWidget {
  const DeliveryStockMobilePage({super.key});

  @override
  State<DeliveryStockMobilePage> createState() =>
      _DeliveryStockMobilePageState();
}

class _DeliveryStockMobilePageState extends State<DeliveryStockMobilePage> {
  late final WarehouseController warehouseController;
  late final OrderController orderController;
  String groupBy = 'product';
  String query = '';

  @override
  void initState() {
    super.initState();
    warehouseController = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController(tag: 'delivery'));
    orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(tag: 'shipping'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      warehouseController.getCurrentStockMobile();
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
          title: 'Stock mobile',
          subtitle: 'Produits dans le camion, retours et anomalies',
          icon: Icons.view_in_ar_outlined,
        ),
        Expanded(
          child: Obx(() {
            final loaded = warehouseController.currentStockLoaded.value;
            final items = _filteredItems();
            if (!loaded) {
              return const AppLoadingState(message: 'Chargement du stock...');
            }
            if (warehouseController.currentStock.isEmpty) {
              return AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Stock mobile vide',
                message:
                    'Aucun produit charge dans le camion pour cette tournee.',
                action: ElevatedButton.icon(
                  onPressed: warehouseController.getCurrentStockMobile,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Actualiser'),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: warehouseController.getCurrentStockMobile,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  96,
                ),
                children: [
                  _groupSelector(),
                  const SizedBox(height: AppSpacing.md),
                  _searchBar(),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Produits charges',
                    style: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (items.isEmpty)
                    const AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Aucun produit trouve',
                      message:
                          'Essayez un autre filtre ou une autre recherche.',
                    )
                  else
                    ...items.map(_stockItemCard),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  List<ItemStock> _filteredItems() {
    final lowerQuery = query.trim().toLowerCase();
    final items = warehouseController.currentStock.where((item) {
      if (lowerQuery.isEmpty) return true;
      final text =
          '${item.short_description_fr} ${item.variant1_fr} ${item.variant2_fr}'
              .toLowerCase();
      return text.contains(lowerQuery);
    }).toList();

    if (groupBy == 'state') {
      items.sort((a, b) => _stockState(a).compareTo(_stockState(b)));
    } else if (groupBy == 'client') {
      items.sort((a, b) =>
          _clientsForVariant(b.variant_id).length -
          _clientsForVariant(a.variant_id).length);
    } else {
      items.sort(
          (a, b) => a.short_description_fr.compareTo(b.short_description_fr));
    }
    return items;
  }

  Widget _groupSelector() {
    final options = [
      ('product', 'Par produit', Icons.view_list_rounded),
      ('state', 'Par etat', Icons.flag_outlined),
      ('client', 'Par client', Icons.groups_outlined),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final selected = groupBy == option.$1;
        return ChoiceChip(
          selected: selected,
          label: Text(option.$2),
          avatar: Icon(
            option.$3,
            size: 18,
            color: selected ? Colors.white : AppColors.primary,
          ),
          labelStyle: AppTextStyles.button.copyWith(
            color: selected ? Colors.white : AppColors.primaryDark,
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.line),
          onSelected: (_) => setState(() => groupBy = option.$1),
        );
      }).toList(),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (value) => setState(() => query = value),
      decoration: InputDecoration(
        hintText: 'Rechercher produit, client, etat...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: () => setState(() => query = ''),
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }

  Widget _stockItemCard(ItemStock item) {
    final state = _stockState(item);
    final stateColor = _stateColor(state);
    final clients = _clientsForVariant(item.variant_id);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _showProductDetail(item),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: CachedNetworkImage(
              imageUrl: item.image,
              width: 62,
              height: 62,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  _iconBubble(Icons.inventory_2_outlined, stateColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getShortDescription(Get.locale?.languageCode ?? 'fr'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
                Text(
                  '${item.variant1_fr} ${item.variant2_fr}'.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppStatusChip(label: state, color: stateColor),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.quantity.toStringAsFixed(0),
                style: AppTextStyles.display.copyWith(fontSize: 24),
              ),
              Text(
                clients.isEmpty ? 'stock' : '${clients.length} clients',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark),
        ],
      ),
    );
  }

  void _showProductDetail(ItemStock item) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    final clients = _clientsForVariant(item.variant_id);
    final toDeliver = item.previsionnel;
    final returns = item.quantity > item.previsionnel
        ? item.quantity - item.previsionnel
        : 0.0;
    final reserve = item.quantity - toDeliver - returns;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Detail produit',
                          style: AppTextStyles.display.copyWith(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                  AppCard(
                    child: Row(
                      children: [
                        _iconBubble(Icons.inventory_2_outlined,
                            _stateColor(_stockState(item))),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.short_description_fr,
                                  style: AppTextStyles.title),
                              Text('${item.variant1_fr} ${item.variant2_fr}',
                                  style: AppTextStyles.subtitle),
                              const SizedBox(height: AppSpacing.sm),
                              AppStatusChip(
                                label: _stockState(item),
                                color: _stateColor(_stockState(item)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(item.quantity.toStringAsFixed(0),
                                style: AppTextStyles.display),
                            const Text(
                              'unites',
                              style: AppTextStyles.caption,
                            ),
                            Text('Valeur ${formatter.format(item.stock_price)}',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Repartition intelligente',
                      style: AppTextStyles.display.copyWith(fontSize: 24)),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _compactMetric(
                          'A livrer', toDeliver, AppColors.secondary),
                      _compactMetric('Retour', returns, Colors.purple),
                      _compactMetric(
                        'Reserve',
                        reserve > 0 ? reserve : 0,
                        AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Clients concernes',
                      style: AppTextStyles.display.copyWith(fontSize: 24)),
                  const SizedBox(height: AppSpacing.md),
                  if (clients.isEmpty)
                    const AppEmptyState(
                      icon: Icons.groups_outlined,
                      title: 'Aucun client associe',
                      message:
                          'Ce produit est dans le stock mobile, mais aucune livraison du jour ne le reference.',
                    )
                  else
                    ...clients.map((client) => AppCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.softGreen,
                                child: Text(
                                  client.isEmpty ? '?' : client[0],
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(client, style: AppTextStyles.title),
                              ),
                              const AppStatusChip(
                                label: 'A livrer',
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _compactMetric(String label, double value, Color color) {
    return SizedBox(
      width: 150,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBubble(Icons.circle, color),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.subtitle),
            Text('${value.toStringAsFixed(0)} unites',
                style: AppTextStyles.title),
          ],
        ),
      ),
    );
  }

  List<String> _clientsForVariant(int variantId) {
    final names = <String>{};
    for (final order in orderController.shippingOrders) {
      if (order.orderitems.any((item) => item.variant_id == variantId)) {
        final name = order.client?.name;
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return names.toList();
  }

  String _stockState(ItemStock item) {
    if (item.quantity == 0) return 'Rupture';
    if (item.quantity < item.previsionnel) return 'Anomalie';
    if (item.quantity > item.previsionnel) return 'Retour';
    return 'A livrer';
  }

  Color _stateColor(String state) {
    return switch (state) {
      'A livrer' => AppColors.secondary,
      'Retour' => Colors.purple,
      'Anomalie' => AppColors.warning,
      'Rupture' => AppColors.danger,
      _ => AppColors.primary,
    };
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(icon, color: color),
    );
  }
}
