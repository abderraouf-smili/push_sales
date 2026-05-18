import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_error_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_status_chip.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkspaceMvpPage extends StatefulWidget {
  final String section;

  const WorkspaceMvpPage({
    super.key,
    required this.section,
  });

  @override
  State<WorkspaceMvpPage> createState() => _WorkspaceMvpPageState();
}

class _WorkspaceMvpPageState extends State<WorkspaceMvpPage> {
  static final List<Map<String, dynamic>> _demoCart = [];

  late Future<ResponseHttpRequest> _future;
  String _deliveryFilter = 'Toutes';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant WorkspaceMvpPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) {
      _deliveryFilter = 'Toutes';
      _future = _load();
    }
  }

  Future<ResponseHttpRequest> _load() {
    return CallApi.RequestHttp(
      'workspace/mvp',
      data: {'section': widget.section},
    ).timeout(
      const Duration(seconds: 18),
      onTimeout: () => ResponseHttpRequest(
        code: 'TIMEOUT',
        status: 'error',
        message:
            'Le serveur ne repond pas. Verifiez Laravel, le Wi-Fi/VPN puis reessayez.',
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: FutureBuilder<ResponseHttpRequest>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Chargement des donnees...');
          }

          final response = snapshot.data;
          if (response == null || response.status != 'SUCCESS') {
            return AppErrorState(
              title: 'Impossible de charger cette page',
              message: response?.message?.toString() ??
                  'Verifiez la connexion API puis reessayez.',
              onRetry: _refresh,
            );
          }

          final data = _asMap(response.data);
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    _horizontalPadding(constraints.maxWidth),
                    compact ? AppSpacing.md : AppSpacing.xl,
                    _horizontalPadding(constraints.maxWidth),
                    compact ? 86 : 104,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(data: data),
                          SizedBox(
                              height: compact ? AppSpacing.md : AppSpacing.xl),
                          _StatsGrid(stats: _asList(data['stats'])),
                          SizedBox(
                              height: compact ? AppSpacing.lg : AppSpacing.xl),
                          if (widget.section == 'cart')
                            _CartSection(onAction: _handleAction),
                          ..._sections(data).map(
                            (section) => Padding(
                              padding: EdgeInsets.only(
                                bottom: compact ? AppSpacing.lg : AppSpacing.xl,
                              ),
                              child: _ListSection(
                                section: section,
                                deliveryFilter: _deliveryFilter,
                                onItemAction: _handleItemAction,
                              ),
                            ),
                          ),
                          _ActionsBar(
                            actions: _asList(data['actions']),
                            onAction: _handleAction,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _sections(Map<String, dynamic> data) {
    final sections = _asList(data['lists']);
    if (widget.section != 'cart') {
      return sections;
    }
    return sections
        .where((section) => section['title'] != 'Produits disponibles')
        .toList();
  }

  void _handleItemAction(Map<String, dynamic> item) {
    final kind = item['kind']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'Element';

    if (kind == 'filter') {
      setState(() {
        _deliveryFilter = title;
      });
      _showSnack('Filtre applique', title);
      return;
    }

    if (kind == 'product') {
      setState(() {
        _demoCart.add(Map<String, dynamic>.from(item));
      });
      _showSnack('Panier mis a jour', '$title ajoute au panier demo.');
      return;
    }

    if (kind == 'route') {
      _openMaps(item);
      return;
    }

    if (kind == 'purchase_order' &&
        (item['action']?.toString().toLowerCase().contains('reception') ??
            false)) {
      if (item['can_receive'] != true) {
        _showSnack(
          'Bon de reception',
          'Cette demande doit etre preparee avant generation du bon.',
        );
        return;
      }
      _showSnack('Bon de reception', 'Bon genere en mode demo pour $title.');
      return;
    }

    _showDetailsSheet(item);
  }

  void _handleAction(Map<String, dynamic> action) {
    final kind = action['kind']?.toString() ?? '';
    final label = action['label']?.toString() ?? 'Action';

    if (kind == 'refresh') {
      _refresh();
      return;
    }

    if (kind == 'submit_order') {
      _showSnack(
        'Commande demo',
        _demoCart.isEmpty
            ? 'Ajoutez un produit avant de valider.'
            : 'Demande de commande prete avec ${_demoCart.length} produit(s).',
      );
      return;
    }

    if (kind == 'cart') {
      _showSnack('Panier', 'Touchez un produit pour l ajouter.');
      return;
    }

    if (kind == 'maps') {
      _openMaps({'title': 'Trajet terrain', 'subtitle': 'Alger'});
      return;
    }

    if (kind == 'reception_note') {
      _showSnack(
        'Bon de reception',
        'Selectionnez une demande preparee dans la liste pour generer son bon.',
      );
      return;
    }

    if (kind == 'confirm_delivery') {
      _showSnack(
        'Livraison',
        'Ouvrez une demande en cours puis confirmez depuis sa fiche.',
      );
      return;
    }

    if (kind == 'prepare_order' || kind == 'confirm_loading') {
      _showSnack(
        'Depot',
        'Ouvrez une commande de preparation pour appliquer cette action.',
      );
      return;
    }

    _showSnack(label, 'Action disponible dans le workspace demo.');
  }

  void _showDetailsSheet(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? 'Detail';
    final subtitle = item['subtitle']?.toString() ?? '';
    final meta = item['meta']?.toString() ?? '';
    final amount = item['amount']?.toString() ?? '';
    final status = item['status']?.toString() ?? 'OK';
    final color = _statusColor(status);

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(
                        _initial(title),
                        style: AppTextStyles.title.copyWith(color: color),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(subtitle, style: AppTextStyles.subtitle),
                          ],
                        ],
                      ),
                    ),
                    AppStatusChip(label: status, color: color),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (amount.isNotEmpty)
                      _DetailPill(
                        icon: Icons.payments_outlined,
                        label: 'Montant',
                        value: amount,
                        color: AppColors.success,
                      ),
                    if (meta.isNotEmpty)
                      _DetailPill(
                        icon: Icons.info_outline_rounded,
                        label: 'Info',
                        value: meta,
                        color: AppColors.primary,
                      ),
                    _DetailPill(
                      icon: Icons.verified_outlined,
                      label: 'Statut',
                      value: status,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _detailDescription(item),
                  style: AppTextStyles.body.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Fermer'),
                    ),
                    if (item['kind'] == 'route' || item['kind'] == 'client')
                      ElevatedButton.icon(
                        onPressed: () => _openMaps(item),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Ouvrir Maps'),
                      ),
                    if (item['kind'] == 'product')
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _handleItemAction(item);
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: const Text('Ajouter'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _detailDescription(Map<String, dynamic> item) {
    final kind = item['kind']?.toString() ?? '';
    return switch (kind) {
      'order' =>
        'Commande lisible avec montant, etat et suivi. Les actions avancees restent controlees par les permissions API.',
      'purchase_order' =>
        'Bon operationnel lie a la preparation, livraison et encaissement terrain.',
      'warehouse' =>
        'Depot avec stock et alertes. Utilisez la page Stock pour consulter les articles.',
      'actor' =>
        'Acteur lie au workspace et au distributeur. Les droits sont pilotes par les permissions.',
      'client' => 'Point de vente avec solde, commandes et acces carte.',
      'product' =>
        'Produit catalogue avec prix, stock et disponibilite selon les donnees API.',
      _ => 'Fiche de consultation connectee aux donnees API/demo du workspace.',
    };
  }

  void _showSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryDark,
      colorText: Colors.white,
      margin: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusMd,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _openMaps(Map<String, dynamic> item) async {
    final label =
        (item['subtitle'] ?? item['title'] ?? 'Alger').toString().trim();
    final query = Uri.encodeComponent(label.isEmpty ? 'Alger' : label);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    _showSnack(
      'Maps',
      'Google Maps ne peut pas etre ouvert sur cet appareil.',
    );
  }

  static double _horizontalPadding(double width) {
    if (width >= 900) return AppSpacing.xxl;
    if (width >= 600) return AppSpacing.xl;
    return AppSpacing.md;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }
}

class _Header extends StatelessWidget {
  final Map<String, dynamic> data;

  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Push Sales';
    final subtitle = data['subtitle']?.toString() ?? '';
    final actor = _WorkspaceMvpPageState._asMap(data['actor']);
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: compact ? 38 : 46,
              height: compact ? 38 : 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              alignment: Alignment.center,
              child: Text(
                'P',
                style: AppTextStyles.title.copyWith(
                  color: Colors.white,
                  fontSize: compact ? 22 : 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
            Expanded(
              child: Text(
                'Push Sales',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display.copyWith(
                  fontSize: compact ? 21 : 24,
                ),
              ),
            ),
            _HeaderIcon(
              icon: Icons.notifications_none_rounded,
              onTap: () => Get.snackbar(
                'Notifications',
                'Notifications demo disponibles dans le workspace.',
                snackPosition: SnackPosition.BOTTOM,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _HeaderIcon(
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => Get.snackbar(
                'Messages',
                'Support et chat demo disponibles.',
                snackPosition: SnackPosition.BOTTOM,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
        Text(
          title,
          style: AppTextStyles.display.copyWith(
            fontSize: compact ? 24 : 32,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTextStyles.subtitle.copyWith(fontSize: compact ? 13 : 16),
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        AppCard(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 24 : 32,
                backgroundColor: AppColors.softBlue,
                child: Text(
                  _initial(actor['name']?.toString()),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontSize: compact ? 18 : 24,
                  ),
                ),
              ),
              SizedBox(width: compact ? AppSpacing.md : AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actor['name']?.toString() ?? 'Utilisateur demo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: compact ? 16 : 22,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${actor['profile'] ?? 'Profil'} - ${actor['distributor'] ?? 'Push Sales'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: compact ? 12 : 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact)
                AppStatusChip(
                  label: actor['workspace_type']?.toString() ?? 'workspace',
                  color: AppColors.secondary,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          width: MediaQuery.sizeOf(context).width < 430 ? 38 : 44,
          height: MediaQuery.sizeOf(context).width < 430 ? 38 : 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
            size: MediaQuery.sizeOf(context).width < 430 ? 20 : 24,
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 360
                ? 2
                : 1;
        final width =
            (constraints.maxWidth - (AppSpacing.sm * (count - 1))) / count;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: width,
                  child: _StatCard(stat: stat),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final color = _colorFromName(stat['color']?.toString());
    final compact = MediaQuery.sizeOf(context).width < 430;

    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: compact ? 18 : 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              _iconFromName(stat['icon']?.toString()),
              color: color,
              size: compact ? 18 : 24,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            stat['label']?.toString() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: compact ? 12 : 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stat['value']?.toString() ?? '0',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display.copyWith(
              color: AppColors.primaryDark,
              fontSize: compact ? 21 : 26,
            ),
          ),
          Text(
            stat['detail']?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 10 : 12,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 5,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final Map<String, dynamic> section;
  final String deliveryFilter;
  final ValueChanged<Map<String, dynamic>> onItemAction;

  const _ListSection({
    required this.section,
    required this.deliveryFilter,
    required this.onItemAction,
  });

  @override
  Widget build(BuildContext context) {
    final title = section['title']?.toString() ?? 'Liste';
    final items = _filteredItems(
      title,
      _WorkspaceMvpPageState._asList(section['items']),
    );
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.display.copyWith(
            fontSize: compact ? 22 : 26,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        if (items.isEmpty)
          AppCard(
            child: AppEmptyState(
              title: 'Aucune donnee',
              message: 'Les seeders demo peuvent alimenter cette page.',
              action: OutlinedButton.icon(
                onPressed: () => onItemAction({
                  'title': title,
                  'action': 'Actualiser',
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualiser'),
              ),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: compact ? AppSpacing.sm : AppSpacing.md,
              ),
              child: _WorkspaceListItem(
                item: item,
                onTap: () => onItemAction(item),
              ),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredItems(
    String title,
    List<Map<String, dynamic>> items,
  ) {
    if (title != 'Demandes de livraison' || deliveryFilter == 'Toutes') {
      return items;
    }

    return items.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      return switch (deliveryFilter) {
        'Preparees' => status.contains('nouveau') ||
            status.contains('prepare') ||
            status.contains('prepar'),
        'A livrer' => status.contains('pris'),
        'En cours' => status.contains('route'),
        'Livrees' => status.contains('livre') || status.contains('paye'),
        _ => true,
      };
    }).toList();
  }
}

class _WorkspaceListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _WorkspaceListItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item['status']?.toString());
    final action = item['action']?.toString() ?? 'Ouvrir';

    return AppCard(
      padding: EdgeInsets.all(
        MediaQuery.sizeOf(context).width < 430 ? AppSpacing.md : AppSpacing.lg,
      ),
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final mainContent = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: compact ? 22 : 28,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  _initial(item['title']?.toString()),
                  style: AppTextStyles.title.copyWith(
                    color: color,
                    fontSize: compact ? 16 : 20,
                  ),
                ),
              ),
              SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: compact ? 16 : 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item['subtitle']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: compact ? 12 : 14,
                      ),
                    ),
                    if ((item['meta']?.toString().isNotEmpty ?? false)) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item['meta'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: compact ? 11 : 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );

          final trailing = Column(
            crossAxisAlignment:
                compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              AppStatusChip(
                label: item['status']?.toString() ?? 'OK',
                color: color,
              ),
              if ((item['amount']?.toString().isNotEmpty ?? false)) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item['amount'].toString(),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: Size(0, compact ? 32 : 36),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? AppSpacing.md : AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  action,
                  style: TextStyle(fontSize: compact ? 12 : 14),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mainContent,
                const SizedBox(height: AppSpacing.md),
                trailing,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: mainContent),
              const SizedBox(width: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: trailing,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSection extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onAction;

  const _CartSection({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final cart = _WorkspaceMvpPageState._demoCart;
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.lg : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panier demo',
            style: AppTextStyles.display.copyWith(
              fontSize: compact ? 22 : 26,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (cart.isEmpty)
            const AppCard(
              child: AppEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Panier vide',
                message: 'Ajoutez un produit depuis le catalogue.',
              ),
            )
          else
            ...cart.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _WorkspaceListItem(
                  item: item,
                  onTap: () => onAction({
                    'label': 'Produit panier',
                    'kind': 'cart_item',
                  }),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: Size(0, compact ? 40 : 46),
              ),
              onPressed: () => onAction({
                'label': 'Valider la commande demo',
                'kind': 'submit_order',
              }),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(compact ? 'Valider' : 'Valider la commande demo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final ValueChanged<Map<String, dynamic>> onAction;

  const _ActionsBar({
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final compact = MediaQuery.sizeOf(context).width < 430;
    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: actions.map((action) {
          return ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: Size(0, compact ? 34 : 40),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? AppSpacing.md : AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            onPressed: (action['enabled'] as bool?) == false
                ? null
                : () => onAction(action),
            icon: Icon(
              _actionIcon(action['kind']?.toString()),
              size: compact ? 16 : 18,
            ),
            label: Text(
              action['label']?.toString() ?? 'Action',
              style: TextStyle(fontSize: compact ? 12 : 14),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _initial(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'P';
  return text.substring(0, 1).toUpperCase();
}

Color _statusColor(String? status) {
  final normalized = status?.toLowerCase() ?? '';
  if (normalized.contains('retard') ||
      normalized.contains('rupture') ||
      normalized.contains('annul')) {
    return AppColors.danger;
  }
  if (normalized.contains('faible') ||
      normalized.contains('attention') ||
      normalized.contains('nouveau') ||
      normalized.contains('prepar')) {
    return AppColors.warning;
  }
  if (normalized.contains('livre') ||
      normalized.contains('paye') ||
      normalized.contains('actif') ||
      normalized.contains('stock') ||
      normalized.contains('sante')) {
    return AppColors.secondary;
  }
  if (normalized.contains('route') || normalized.contains('pris')) {
    return AppColors.info;
  }
  return AppColors.primary;
}

Color _colorFromName(String? name) {
  return switch (name) {
    'green' => AppColors.secondary,
    'orange' => AppColors.warning,
    'purple' => const Color(0xFF7C4DFF),
    'red' => AppColors.danger,
    _ => AppColors.primary,
  };
}

IconData _iconFromName(String? name) {
  return switch (name) {
    'business' => Icons.business_rounded,
    'inventory' => Icons.inventory_2_rounded,
    'orders' => Icons.shopping_cart_rounded,
    'delivery' => Icons.local_shipping_rounded,
    'route' => Icons.route_rounded,
    'cash' => Icons.account_balance_wallet_rounded,
    'users' => Icons.groups_rounded,
    _ => Icons.dashboard_rounded,
  };
}

IconData _actionIcon(String? kind) {
  return switch (kind) {
    'refresh' => Icons.refresh_rounded,
    'cart' => Icons.add_shopping_cart_rounded,
    'submit_order' => Icons.check_circle_outline_rounded,
    'maps' => Icons.map_outlined,
    'reception_note' => Icons.receipt_long_rounded,
    'confirm_delivery' => Icons.fact_check_rounded,
    'prepare_order' => Icons.inventory_rounded,
    'confirm_loading' => Icons.local_shipping_rounded,
    'view_orders' => Icons.visibility_outlined,
    'create_demo' => Icons.add_rounded,
    _ => Icons.touch_app_rounded,
  };
}
