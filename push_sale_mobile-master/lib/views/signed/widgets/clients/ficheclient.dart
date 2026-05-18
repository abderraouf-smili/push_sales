import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/reason_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/models/reason_no_delivery_sale.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/clients/editclient.dart';
import 'package:push_sale/views/signed/widgets/commandes/products.dart';
import 'package:push_sale/views/signed/widgets/orders/show_order_detail.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_status_chip.dart';

class FicheClient extends StatefulWidget {
  final Client client;

  const FicheClient(this.client, {super.key});

  @override
  State<FicheClient> createState() => _FicheClientState();
}

class _FicheClientState extends State<FicheClient> {
  final PermissionsController permissions = Get.find();
  final ReasoController reasonController = Get.put(ReasoController());
  final ProductController productController = Get.put(ProductController());
  final ClientController clientController = Get.find();
  final NumberFormat formatter = NumberFormat("#,##0.00", "fr_FR");

  String get locale => Get.locale?.languageCode ?? "fr";

  @override
  void initState() {
    super.initState();
    productController.client = widget.client;
    productController.getFullPromotion();
    clientController.getCurrentOrders(widget.client.id);
  }

  @override
  Widget build(BuildContext context) {
    final canSale = permissions.check(null, "Clients.sale") == true;
    final canEdit = permissions.check(null, "Clients.update") == true;
    final canPrint =
        permissions.check(null, "Clients.printhistorybalance") == true;

    return SafeArea(
      bottom: false,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.canvas,
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.client.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title,
            ),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Get.to(() => Products(widget.client));
                      break;
                    case 1:
                      Get.to(() => EditClient(client: widget.client));
                      break;
                    case 2:
                      showVisitOption(
                        context,
                        reasonController,
                        widget.client.id,
                        clientController,
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    enabled: canSale,
                    child: _MenuRow(
                      icon: Icons.add_shopping_cart_rounded,
                      label: "Commencer une commande",
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    enabled: canSale,
                    child: _MenuRow(
                      icon: Icons.fact_check_outlined,
                      label: "Changer l'etat de visite",
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    enabled: canEdit,
                    child: _MenuRow(
                      icon: Icons.edit_rounded,
                      label: "Modifier le client",
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    enabled: canPrint,
                    child: _MenuRow(
                      icon: Icons.print_rounded,
                      label: "Imprimer le solde",
                    ),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: _MenuRow(
                      icon: Icons.bluetooth_rounded,
                      label: "Configuration imprimante",
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.muted,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Info"),
                Tab(text: "Commandes"),
                Tab(text: "Historique"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _InfoTab(
                client: widget.client,
                formatter: formatter,
                locale: locale,
                canSale: canSale,
                canEdit: canEdit,
                productController: productController,
                onSale: () => Get.to(() => Products(widget.client)),
                onEdit: () => Get.to(() => EditClient(client: widget.client)),
                onVisit: () => showVisitOption(
                  context,
                  reasonController,
                  widget.client.id,
                  clientController,
                ),
              ),
              _OrdersTab(
                clientController: clientController,
                formatter: formatter,
              ),
              _HistoryTab(
                client: widget.client,
                locale: locale,
                onVisit: canSale
                    ? () => showVisitOption(
                          context,
                          reasonController,
                          widget.client.id,
                          clientController,
                        )
                    : null,
              ),
            ],
          ),
          bottomNavigationBar: canSale
              ? SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    child: FilledButton.icon(
                      onPressed: () => Get.to(() => Products(widget.client)),
                      icon: const Icon(Icons.shopping_cart_checkout_rounded),
                      label: Text("get_started".tr),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Client client;
  final NumberFormat formatter;
  final String locale;
  final bool canSale;
  final bool canEdit;
  final ProductController productController;
  final VoidCallback onSale;
  final VoidCallback onEdit;
  final VoidCallback onVisit;

  const _InfoTab({
    required this.client,
    required this.formatter,
    required this.locale,
    required this.canSale,
    required this.canEdit,
    required this.productController,
    required this.onSale,
    required this.onEdit,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        96,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        _ClientHeroCard(client: client, locale: locale),
        const SizedBox(height: AppSpacing.md),
        Obx(
          () {
            final isReady =
                Get.find<ClientController>().current_orders_ready.value;
            final currentOrders = isReady
                ? Get.find<ClientController>().current_orders
                : <Order>[];
            return _SummaryGrid(
              client: client,
              formatter: formatter,
              waiting: currentOrders
                  .where((order) => _isWaiting(order.state))
                  .length,
              prepared: currentOrders
                  .where((order) => _isPrepared(order.state))
                  .length,
              delivered: currentOrders
                  .where((order) => _isDelivered(order.state))
                  .length,
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _VisitStateCard(
          client: client,
          locale: locale,
          onVisit: onVisit,
        ),
        const SizedBox(height: AppSpacing.md),
        _VisitDaysCard(client: client, locale: locale),
        const SizedBox(height: AppSpacing.md),
        _QuickActions(
          canSale: canSale,
          canEdit: canEdit,
          onSale: onSale,
          onEdit: onEdit,
          onVisit: onVisit,
        ),
        const SizedBox(height: AppSpacing.md),
        _PromoStrip(productController: productController),
      ],
    );
  }
}

class _ClientHeroCard extends StatelessWidget {
  final Client client;
  final String locale;

  const _ClientHeroCard({required this.client, required this.locale});

  @override
  Widget build(BuildContext context) {
    final city = client.address?.city.getName(locale) ?? "-";
    final wilaya = client.address?.wilaya.getName(locale) ?? "-";
    final type = client.typepv?.getName(locale) ?? "Point de vente";
    final formatter = NumberFormat("#,##0.00", "fr_FR");
    final balance = client.solde ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              width: 82,
              height: 82,
              child: client.hasImage
                  ? CachedNetworkImage(
                      imageUrl: client.image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _ClientAvatarIcon(),
                    )
                  : const _ClientAvatarIcon(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _LightChip(
                      icon: Icons.location_on_outlined,
                      label: "$city, $wilaya",
                    ),
                    if ((client.sales ?? 0) > 0)
                      _LightChip(
                        icon: Icons.shopping_cart_outlined,
                        label: "${client.sales} vente",
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Credit", style: AppTextStyles.caption),
              Text(
                formatter.format(balance),
                style: AppTextStyles.title.copyWith(
                  fontSize: 20,
                  color: balance > 0 ? AppColors.danger : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppStatusChip(
                label: "Client actif",
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientAvatarIcon extends StatelessWidget {
  const _ClientAvatarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softBlue,
      child: const Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: 38,
      ),
    );
  }
}

class _LightChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LightChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.52,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final Client client;
  final NumberFormat formatter;
  final int waiting;
  final int prepared;
  final int delivered;

  const _SummaryGrid({
    required this.client,
    required this.formatter,
    required this.waiting,
    required this.prepared,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 520;
        return GridView.count(
          crossAxisCount: twoColumns ? 4 : 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: twoColumns ? 1.8 : 1.55,
          children: [
            _MetricCard(
              icon: Icons.phone_rounded,
              label: "Telephone",
              value: client.mobile.isEmpty ? "-" : client.mobile,
              color: AppColors.info,
            ),
            _MetricCard(
              icon: Icons.account_balance_wallet_outlined,
              label: "Credit",
              value: formatter.format(client.solde ?? 0),
              color: (client.solde ?? 0) > 0
                  ? AppColors.warning
                  : AppColors.success,
            ),
            _MetricCard(
              icon: Icons.pending_actions_rounded,
              label: "Attente",
              value: waiting.toString(),
              color: AppColors.warning,
            ),
            _MetricCard(
              icon: Icons.inventory_2_outlined,
              label: "Preparee",
              value: prepared.toString(),
              color: AppColors.info,
            ),
            _MetricCard(
              icon: Icons.check_circle_outline_rounded,
              label: "Livree",
              value: delivered.toString(),
              color: AppColors.success,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitStateCard extends StatelessWidget {
  final Client client;
  final String locale;
  final VoidCallback onVisit;

  const _VisitStateCard({
    required this.client,
    required this.locale,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    final lastVisit =
        client.visits?.isNotEmpty == true ? client.visits!.first : null;
    final label =
        lastVisit?.getDescription(locale) ?? "Aucune visite enregistree";
    final color = _reasonColor(lastVisit);

    return _SectionCard(
      title: "Etat de visite",
      trailing: TextButton.icon(
        onPressed: onVisit,
        icon: const Icon(Icons.edit_note_rounded, size: 18),
        label: const Text("Changer"),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(_reasonIcon(lastVisit), color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitDaysCard extends StatelessWidget {
  final Client client;
  final String locale;

  const _VisitDaysCard({required this.client, required this.locale});

  @override
  Widget build(BuildContext context) {
    final days = client.visitdays ?? [];
    return _SectionCard(
      title: "Adresse et visite",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _addressLine(client, locale),
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: days.isEmpty
                ? [
                    const AppStatusChip(
                      label: "Aucun jour planifie",
                      icon: Icons.event_busy_rounded,
                      color: AppColors.muted,
                    ),
                  ]
                : days
                    .map(
                      (day) => AppStatusChip(
                        label: day.day.tr,
                        icon: Icons.check_rounded,
                        color: AppColors.primary,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool canSale;
  final bool canEdit;
  final VoidCallback onSale;
  final VoidCallback onEdit;
  final VoidCallback onVisit;

  const _QuickActions({
    required this.canSale,
    required this.canEdit,
    required this.onSale,
    required this.onEdit,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "Actions terrain",
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          FilledButton.icon(
            onPressed: canSale ? onSale : null,
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            label: const Text("Commande"),
          ),
          OutlinedButton.icon(
            onPressed: canSale ? onVisit : null,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text("Etat visite"),
          ),
          OutlinedButton.icon(
            onPressed: canEdit ? onEdit : null,
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text("Modifier"),
          ),
        ],
      ),
    );
  }
}

class _PromoStrip extends StatelessWidget {
  final ProductController productController;

  const _PromoStrip({required this.productController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (!productController.loadVariantReady.value) {
          return const _SectionCard(
            title: "Promotions",
            child: SizedBox(
              height: 72,
              child: AppLoadingState(message: "Chargement promotions..."),
            ),
          );
        }

        final promos = productController.listPromo;
        if (promos.isEmpty) {
          return const SizedBox.shrink();
        }

        return _SectionCard(
          title: "Promotions disponibles",
          child: SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: promos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => _PromoItem(promos[index]),
            ),
          ),
        );
      },
    );
  }
}

class _PromoItem extends StatelessWidget {
  final dynamic item;

  const _PromoItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.softOrange,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Image.network(
              item.image,
              width: 56,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 72,
                color: AppColors.surface,
                child: const Icon(Icons.local_offer_outlined),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppStatusChip(
                  label: "-${item.discount.toStringAsFixed(0)}%",
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.product,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
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

class _OrdersTab extends StatelessWidget {
  final ClientController clientController;
  final NumberFormat formatter;

  const _OrdersTab({
    required this.clientController,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (!clientController.current_orders_ready.value) {
          return const AppLoadingState(message: "Chargement des commandes...");
        }

        final orders = clientController.current_orders;
        if (orders.isEmpty) {
          return const AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: "Aucune commande",
            message: "Les commandes du client apparaitront ici.",
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            96,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) => _OrderCard(
            order: orders[index],
            formatter: formatter,
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final NumberFormat formatter;

  const _OrderCard({required this.order, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("dd/MM/yyyy HH:mm").format(order.order_date);
    return InkWell(
      onTap: () => Get.to(() => ShowOrderDetail(order)),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            _OrderStateIcon(state: order.state),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _TinyInfo(
                        icon: Icons.payments_outlined,
                        label: formatter.format(order.total_amount ?? 0),
                      ),
                      _TinyInfo(
                        icon: Icons.inventory_2_outlined,
                        label: "${order.orderitems.length} lignes",
                      ),
                      _TinyInfo(icon: Icons.event_outlined, label: date),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppStatusChip(
                  label: _orderStatusLabel(order.state),
                  color: _orderColor(order.state),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final Client client;
  final String locale;
  final VoidCallback? onVisit;

  const _HistoryTab({
    required this.client,
    required this.locale,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    final visits = client.visits ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        96,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        _SectionCard(
          title: "Historique des visites",
          trailing: onVisit == null
              ? null
              : TextButton.icon(
                  onPressed: onVisit,
                  icon: const Icon(Icons.add_task_rounded, size: 18),
                  label: const Text("Ajouter"),
                ),
          child: visits.isEmpty
              ? const AppEmptyState(
                  icon: Icons.history_toggle_off_rounded,
                  title: "Aucun historique",
                  message: "Les etats de visite seront visibles ici.",
                )
              : Column(
                  children: visits
                      .map(
                        (visit) => _VisitHistoryRow(
                          visit: visit,
                          locale: locale,
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(
          () {
            final orders = Get.find<ClientController>().current_orders;
            if (!Get.find<ClientController>().current_orders_ready.value) {
              return const _SectionCard(
                title: "Activite commandes",
                child: SizedBox(
                  height: 80,
                  child: AppLoadingState(message: "Chargement..."),
                ),
              );
            }
            return _SectionCard(
              title: "Activite commandes",
              child: orders.isEmpty
                  ? const Text(
                      "Aucune commande recente pour ce client.",
                      style: AppTextStyles.subtitle,
                    )
                  : Column(
                      children: orders
                          .take(4)
                          .map(
                            (order) => _TimelineOrderRow(order: order),
                          )
                          .toList(),
                    ),
            );
          },
        ),
      ],
    );
  }
}

class _VisitHistoryRow extends StatelessWidget {
  final ReasonNoDeliverySale visit;
  final String locale;

  const _VisitHistoryRow({required this.visit, required this.locale});

  @override
  Widget build(BuildContext context) {
    final color = _reasonColor(visit);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(_reasonIcon(visit), color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.getDescription(locale),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  visit.revisit
                      ? "Revisite conseillee"
                      : "Etat enregistre pour ce client",
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineOrderRow extends StatelessWidget {
  final Order order;

  const _TimelineOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          _OrderStateIcon(state: order.state, compact: true),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  DateFormat("dd/MM/yyyy HH:mm").format(order.order_date),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          AppStatusChip(
            label: _orderStatusLabel(order.state),
            color: _orderColor(order.state),
          ),
        ],
      ),
    );
  }
}

class _OrderStateIcon extends StatelessWidget {
  final String state;
  final bool compact;

  const _OrderStateIcon({required this.state, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _orderColor(state);
    return Container(
      width: compact ? 34 : 46,
      height: compact ? 34 : 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(_orderIcon(state), color: color, size: compact ? 18 : 24),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TinyInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label)),
      ],
    );
  }
}

void showVisitOption(
  BuildContext context,
  ReasoController reasoController,
  String clientId,
  ClientController clientController,
) {
  reasoController.submittig = "new".obs;
  reasoController.selectedId.value = 0;
  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  "reason.no.sale".tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
              ),
              Flexible(
                child: Obx(
                  () {
                    if (!reasoController.loadReason.value) {
                      return const AppLoadingState(
                        message: "Chargement des raisons...",
                      );
                    }
                    if (reasoController.submittig.value == "submit") {
                      return const AppLoadingState(
                          message: "Enregistrement...");
                    }
                    if (reasoController.submittig.value == "success") {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 48,
                        ),
                      );
                    }
                    if (reasoController.submittig.value == "error") {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Icon(
                          Icons.error_rounded,
                          color: AppColors.danger,
                          size: 48,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: reasoController.ReasonSale.length,
                      itemBuilder: (context, index) {
                        final item = reasoController.ReasonSale[index];
                        return Obx(
                          () => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: InkWell(
                              onTap: () {
                                reasoController.selectedId.value = item.id;
                              },
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: reasoController.selectedId.value ==
                                          item.id
                                      ? AppColors.softBlue
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: reasoController.selectedId.value ==
                                            item.id
                                        ? AppColors.primary
                                        : AppColors.line,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    item.getIcon() ?? const Icon(Icons.info),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        item.getDescription(
                                          Get.locale?.languageCode ?? "fr",
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (item.revisit)
                                      const Icon(
                                        Icons.restart_alt_rounded,
                                        color: AppColors.warning,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text("cancel".tr),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (reasoController.selectedId.value > 0) {
                            await reasoController.submit(clientId);
                            await clientController.getClients();
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );
                            Get.back();
                          }
                        },
                        child: const Text("OK"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _addressLine(Client client, String locale) {
  final address = client.address;
  if (address == null) {
    return "-";
  }
  final city = address.city.getName(locale);
  final wilaya = address.wilaya.getName(locale);
  final street = address.street.isEmpty ? null : address.street;
  return [street, city, wilaya].whereType<String>().join(", ");
}

bool _isWaiting(String state) {
  final normalized = state.toLowerCase();
  return normalized == "new" ||
      normalized == "pending" ||
      normalized == "draft" ||
      normalized == "in_waiting";
}

bool _isPrepared(String state) {
  final normalized = state.toLowerCase();
  return normalized == "ready" ||
      normalized == "taken" ||
      normalized == "in_way" ||
      normalized == "prepared";
}

bool _isDelivered(String state) {
  final normalized = state.toLowerCase();
  return normalized == "shipped" ||
      normalized == "paid" ||
      normalized == "delivered" ||
      normalized == "done";
}

String _orderStatusLabel(String state) {
  switch (state.toLowerCase()) {
    case "new":
    case "pending":
    case "draft":
    case "in_waiting":
      return "En attente";
    case "ready":
    case "prepared":
      return "Preparee";
    case "taken":
    case "in_way":
      return "En route";
    case "shipped":
    case "delivered":
      return "Livree";
    case "paid":
      return "Payee";
    default:
      return state;
  }
}

Color _orderColor(String state) {
  if (_isDelivered(state)) {
    return AppColors.success;
  }
  if (_isPrepared(state)) {
    return AppColors.info;
  }
  if (_isWaiting(state)) {
    return AppColors.warning;
  }
  return AppColors.primary;
}

IconData _orderIcon(String state) {
  if (_isDelivered(state)) {
    return Icons.check_circle_outline_rounded;
  }
  if (_isPrepared(state)) {
    return Icons.inventory_2_outlined;
  }
  if (_isWaiting(state)) {
    return Icons.schedule_rounded;
  }
  return Icons.receipt_long_outlined;
}

Color _reasonColor(ReasonNoDeliverySale? visit) {
  switch (visit?.code) {
    case "S.D":
      return AppColors.success;
    case "G.A":
    case "N.C":
      return AppColors.danger;
    case "M.F":
      return AppColors.warning;
    case "M.O":
      return AppColors.info;
    default:
      return AppColors.muted;
  }
}

IconData _reasonIcon(ReasonNoDeliverySale? visit) {
  switch (visit?.code) {
    case "S.D":
      return Icons.check_circle_outline_rounded;
    case "G.A":
      return Icons.person_off_outlined;
    case "M.F":
      return Icons.store_mall_directory_outlined;
    case "M.O":
      return Icons.back_hand_outlined;
    case "N.C":
      return Icons.money_off_csred_outlined;
    default:
      return Icons.info_outline_rounded;
  }
}
