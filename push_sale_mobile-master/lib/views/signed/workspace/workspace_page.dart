import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/config/app_config.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_error_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_status_chip.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkspacePage extends StatefulWidget {
  final String section;

  const WorkspacePage({
    super.key,
    required this.section,
  });

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  static final List<Map<String, dynamic>> _cart = [];

  late Future<ResponseHttpRequest> _future;
  String _deliveryFilter = 'Toutes';
  String _workspaceType = '';
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _categoryFilter = 'all';
  String _deliveryWarehouseFilter = 'all';
  String _dashboardDistributorFilter = 'all';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant WorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) {
      _deliveryFilter = 'Toutes';
      _deliveryWarehouseFilter = 'all';
      _dashboardDistributorFilter = 'all';
      _searchQuery = '';
      _statusFilter = 'all';
      _categoryFilter = 'all';
      _future = _load();
    }
  }

  Future<ResponseHttpRequest> _load() {
    final payload = <String, dynamic>{'section': widget.section};
    if (widget.section == 'dashboard' && _dashboardDistributorFilter != 'all') {
      payload['distributor_id'] = _dashboardDistributorFilter;
    }

    return CallApi.RequestHttp(
      AppConfig.isDemoMode ? 'workspace/mvp' : 'workspace/real',
      data: payload,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final scope = FocusScope.of(context);
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        if (keyboardOpen || scope.focusedChild != null) {
          scope.unfocus();
          return;
        }
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Material(
        color: AppColors.canvas,
        child: ColoredBox(
          color: AppColors.canvas,
          child: FutureBuilder<ResponseHttpRequest>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoadingState(
                    message: 'Chargement des donnees...');
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
              _workspaceType = data['workspace_type']?.toString() ?? '';
              final dashboardDistributors = _dashboardDistributorOptions(data);
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
                              _Header(
                                data: data,
                                onNotifications: () => _showServiceInfo(
                                  'Notifications',
                                  'Notifications connectees au workspace ${_workspaceType.isEmpty ? 'actuel' : _workspaceType}.',
                                  Icons.notifications_active_outlined,
                                ),
                                onMessages: () => _showServiceInfo(
                                  'Messages',
                                  'Messagerie workspace prete cote UI. Branchez le support/chat API pour les conversations reelles.',
                                  Icons.chat_bubble_outline_rounded,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      compact ? AppSpacing.md : AppSpacing.xl),
                              if (_usesCompactToolbar()) ...[
                                _SuperAdminToolbar(
                                  section: widget.section,
                                  searchQuery: _searchQuery,
                                  statusFilter: _statusFilter,
                                  categoryFilter: _categoryFilter,
                                  categoryOptions: widget.section == 'products'
                                      ? _productCategoryOptions(_sections(data))
                                      : const <Map<String, String>>[],
                                  onSearchChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  onCategoryChanged: (value) {
                                    setState(() {
                                      _categoryFilter = value;
                                    });
                                  },
                                  onStatusChanged: (value) {
                                    setState(() {
                                      _statusFilter = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                    height: compact
                                        ? AppSpacing.md
                                        : AppSpacing.xl),
                              ],
                              if (data['section']?.toString() ==
                                  'dashboard') ...[
                                if (dashboardDistributors.length > 1) ...[
                                  _DashboardDistributorFilter(
                                    value: _safeDashboardDistributorValue(
                                      dashboardDistributors,
                                    ),
                                    options: dashboardDistributors,
                                    onChanged: (value) {
                                      setState(() {
                                        _dashboardDistributorFilter =
                                            value ?? 'all';
                                        _future = _load();
                                      });
                                    },
                                  ),
                                  SizedBox(
                                      height: compact
                                          ? AppSpacing.md
                                          : AppSpacing.lg),
                                ],
                                _StatsGrid(stats: _asList(data['stats'])),
                                SizedBox(
                                    height: compact
                                        ? AppSpacing.lg
                                        : AppSpacing.xl),
                              ],
                              if (_workspaceType == 'superadmin' ||
                                  _workspaceType == 'distributeur')
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        compact ? AppSpacing.lg : AppSpacing.xl,
                                  ),
                                  child: _QuickActionsBar(
                                    actions: _primaryActions(
                                      _asList(data['actions']),
                                    ),
                                    onAction: _handleAction,
                                  ),
                                ),
                              if (widget.section == 'cart')
                                _CartSection(onAction: _handleAction),
                              ..._sections(data).map((section) {
                                final deliveryWarehouses =
                                    _deliveryWarehouseOptions(section);
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        compact ? AppSpacing.lg : AppSpacing.xl,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_isDeliverySection(section) &&
                                          deliveryWarehouses.length > 1) ...[
                                        _DeliveryWarehouseFilter(
                                          value: _safeDeliveryWarehouseValue(
                                            deliveryWarehouses,
                                          ),
                                          options: deliveryWarehouses,
                                          onChanged: (value) {
                                            setState(() {
                                              _deliveryWarehouseFilter =
                                                  value ?? 'all';
                                            });
                                          },
                                        ),
                                        SizedBox(
                                            height: compact
                                                ? AppSpacing.sm
                                                : AppSpacing.md),
                                      ],
                                      _ListSection(
                                        section: section,
                                        workspaceType: _workspaceType,
                                        deliveryFilter: _deliveryFilter,
                                        deliveryWarehouseFilter:
                                            _deliveryWarehouseFilter,
                                        searchQuery: _searchQuery,
                                        statusFilter: _statusFilter,
                                        categoryFilter: _categoryFilter,
                                        onItemAction: _handleItemAction,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (_workspaceType != 'superadmin' &&
                                  _workspaceType != 'distributeur')
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
        ),
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

  List<Map<String, String>> _dashboardDistributorOptions(
    Map<String, dynamic> data,
  ) {
    final filters = _asMap(data['dashboard_filters']);
    final distributors = _asList(filters['distributors']);
    if (distributors.isEmpty) {
      return const [];
    }

    final seen = <String>{};
    return distributors.map((item) {
      final id = item['id']?.toString() ?? 'all';
      final title = item['title']?.toString() ?? 'Distributeur';
      final subtitle = item['subtitle']?.toString() ?? '';
      return {'id': id, 'title': title, 'subtitle': subtitle};
    }).where((item) {
      final id = item['id'] ?? 'all';
      return seen.add(id);
    }).toList();
  }

  String _safeDashboardDistributorValue(List<Map<String, String>> options) {
    final hasSelected =
        options.any((item) => item['id'] == _dashboardDistributorFilter);
    if (hasSelected) {
      return _dashboardDistributorFilter;
    }
    _dashboardDistributorFilter = 'all';
    return 'all';
  }

  bool _isDeliverySection(Map<String, dynamic> section) {
    return (section['title']?.toString() ?? '') == 'Demandes de livraison';
  }

  List<Map<String, String>> _deliveryWarehouseOptions(
    Map<String, dynamic> section,
  ) {
    if (!_isDeliverySection(section)) {
      return const [];
    }

    final options = <Map<String, String>>[
      {
        'id': 'all',
        'title': 'Tous les depots',
        'subtitle': 'Demandes tous depots',
      },
    ];
    final seen = <String>{'all'};
    for (final item in _asList(section['items'])) {
      final id = item['warehouse_id']?.toString();
      if (id == null || id.isEmpty || !seen.add(id)) continue;
      options.add({
        'id': id,
        'title': item['warehouse_name']?.toString() ?? 'Depot $id',
        'subtitle': 'Demandes associees',
      });
    }
    return options;
  }

  String _safeDeliveryWarehouseValue(List<Map<String, String>> options) {
    final hasSelected =
        options.any((item) => item['id'] == _deliveryWarehouseFilter);
    if (hasSelected) {
      return _deliveryWarehouseFilter;
    }
    _deliveryWarehouseFilter = 'all';
    return 'all';
  }

  List<Map<String, String>> _productCategoryOptions(
    List<Map<String, dynamic>> sections,
  ) {
    final seen = <String>{};
    final options = <Map<String, String>>[];
    for (final section in sections) {
      final title = section['title']?.toString().toLowerCase() ?? '';
      if (!title.contains('produit')) continue;
      for (final item in _asList(section['items'])) {
        final id = _dropdownId(item['category_id']) ??
            _dropdownId(item['category_label']) ??
            _dropdownId(item['category']) ??
            _dropdownId(item['subtitle']);
        if (id == null || !seen.add(id)) continue;
        final label = (item['category_label'] ??
                item['category'] ??
                item['category_name'] ??
                item['subtitle'] ??
                'Categorie')
            .toString();
        options.add({'id': id, 'label': label});
      }
    }
    options.sort((a, b) => (a['label'] ?? '').compareTo(b['label'] ?? ''));
    return options;
  }

  bool _usesCompactToolbar() {
    return const {
      'distributors',
      'actors',
      'products',
      'warehouses',
      'warehouse_stock',
      'stock',
      'clients',
      'orders',
      'my_orders',
      'deliveries',
      'delivery',
      'prepare_orders',
      'loadings',
      'stock_mobile',
      'routes',
      'payments',
      'credit',
      'reports',
      'promotions',
      'coupons',
      'more',
    }.contains(widget.section);
  }

  List<Map<String, dynamic>> _primaryActions(
      List<Map<String, dynamic>> actions) {
    return actions
        .where((action) => action['kind']?.toString() != 'refresh')
        .take(4)
        .toList();
  }

  void _handleItemAction(Map<String, dynamic> item) {
    final kind = item['kind']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'Element';

    if (_workspaceType == 'superadmin') {
      if (kind == 'distributor') {
        _showSuperAdminDistributorSheet(item);
        return;
      }
      if (kind == 'actor') {
        _showSuperAdminActorSheet(item);
        return;
      }
      if (kind == 'product') {
        _showSuperAdminProductSheet(item);
        return;
      }
      if (kind == 'audit') {
        _showSuperAdminAuditSheet();
        return;
      }
      if (kind == 'setting') {
        _showExternalServiceSheet(item);
        return;
      }
    }

    if (kind == 'workspace_link') {
      final target = item['target_section']?.toString();
      if (target == null || target.isEmpty) {
        _showSnack('Navigation', 'Cette section n est pas disponible.');
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WorkspacePage(section: target),
        ),
      );
      return;
    }

    if (kind == 'filter') {
      setState(() {
        _deliveryFilter = title;
      });
      _showSnack('Filtre applique', title);
      return;
    }

    if (kind == 'product') {
      if (_workspaceType == 'distributeur') {
        _showDistributorProductSheet(item);
        return;
      }
      if (_workspaceType == 'depot') {
        _showDetailsSheet(item);
        return;
      }
      setState(() {
        _cart.add(Map<String, dynamic>.from(item));
      });
      _showSnack('Panier mis a jour', '$title ajoute au panier.');
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
      _showSnack(
        'Bon de reception',
        AppConfig.isDemoMode
            ? 'Bon genere en environnement de test pour $title.'
            : 'Generation du bon disponible depuis la fiche operationnelle de livraison.',
      );
      return;
    }

    _showDetailsSheet(item);
  }

  void _handleAction(Map<String, dynamic> action) {
    final kind = action['kind']?.toString() ?? '';
    final label = action['label']?.toString() ?? 'Action';

    if (action['enabled'] == false) {
      _showSnack(
        label,
        action['subtitle']?.toString() ??
            'Cette action est indisponible dans cet etat.',
      );
      return;
    }

    if (kind == 'refresh') {
      _refresh();
      return;
    }

    if (_workspaceType == 'superadmin') {
      if (kind == 'create_distributor') {
        _showDistributorForm();
        return;
      }
      if (kind == 'create_actor') {
        _showActorForm();
        return;
      }
      if (kind == 'create_product') {
        _showProductForm();
        return;
      }
      if (kind == 'create_category') {
        _showCategoryForm();
        return;
      }
      if (kind == 'view_audit_logs') {
        _showSuperAdminAuditSheet();
        return;
      }
    }

    if (kind == 'submit_order') {
      if (AppConfig.isRealDataMode) {
        _showRealApiMissing(
          'Commande',
          'La validation commande point de vente doit appeler une API reelle avec client, lignes, variants et prix. Le panier local ne sera pas envoye en mode ${AppConfig.environment.name}.',
        );
        return;
      }
      _showSnack(
        'Commande',
        _cart.isEmpty
            ? 'Ajoutez un produit avant de valider.'
            : 'Demande de commande prete avec ${_cart.length} produit(s).',
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

    if (_workspaceType == 'distributeur') {
      if (kind == 'open_delivery') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const WorkspacePage(section: 'deliveries'),
          ),
        );
        return;
      }
      if (kind == 'distributor_manage_prices') {
        _showDistributorPriceForm();
        return;
      }
      if (kind == 'distributor_adjust_stock') {
        _showDistributorStockForm();
        return;
      }
      if (kind == 'distributor_create_actor') {
        _showDistributorActorForm();
        return;
      }
      if (kind == 'distributor_create_warehouse') {
        _showDistributorWarehouseForm();
        return;
      }
      if (kind == 'distributor_create_client') {
        _showDistributorClientForm();
        return;
      }
      if (kind == 'distributor_create_promotion') {
        _showDistributorPromotionForm();
        return;
      }
      if (kind == 'distributor_create_coupon') {
        _showDistributorCouponForm();
        return;
      }
    }

    if (kind == 'missing_real_api') {
      _showRealApiMissing(
        label,
        'Cette action doit etre branchee sur une API metier reelle avant usage terrain.',
      );
      return;
    }

    _showSnack(label, 'Action connectee aux donnees reelles disponibles.');
  }

  void _showRealApiMissing(String title, String message) {
    debugPrint(
      'DEMO_ACTION_NOT_ALLOWED_IN_REAL_ENV: $title - ${AppConfig.environment.name}',
    );
    _showSnack('API reelle requise', message);
  }

  Future<ResponseHttpRequest> _superAdminRequest(
    String route, {
    Map<String, dynamic>? data,
    String method = 'POST',
  }) {
    return CallApi.RequestHttp(route, data: data, method: method).timeout(
      const Duration(seconds: 18),
      onTimeout: () => ResponseHttpRequest(
        code: 'TIMEOUT',
        status: 'error',
        message: 'Le serveur ne repond pas. Reessayez.',
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _superAdminList(
    String route, {
    Map<String, dynamic>? data,
    String method = 'POST',
  }) async {
    final response =
        await _superAdminRequest(route, data: data, method: method);
    if (response.status != 'SUCCESS') return [];
    final payload = response.data;
    if (payload is List) return _asList(payload);
    final map = _asMap(payload);
    return _asList(map['items'] ?? map['data'] ?? payload);
  }

  Future<bool> _confirmAction(String title, String message) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return result == true;
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      isDense: true,
    );
  }

  void _showDistributorForm({Map<String, dynamic>? item}) {
    final editing = item != null;
    final name = TextEditingController(text: item?['title']?.toString() ?? '');
    final code = TextEditingController(text: item?['code']?.toString() ?? '');
    final phone = TextEditingController(text: item?['phone']?.toString() ?? '');
    final email = TextEditingController(text: item?['email']?.toString() ?? '');
    final contact =
        TextEditingController(text: item?['contact_name']?.toString() ?? '');
    final commune = TextEditingController();
    final street = TextEditingController();
    bool active = item?['is_active'] as bool? ?? true;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return _FormSheet(
              title: editing ? 'Modifier distributeur' : 'Ajouter distributeur',
              children: [
                TextField(
                  controller: name,
                  decoration: _fieldDecoration('Nom', Icons.business_rounded),
                ),
                TextField(
                  controller: code,
                  decoration: _fieldDecoration('Code', Icons.tag_rounded),
                ),
                TextField(
                  controller: contact,
                  decoration:
                      _fieldDecoration('Contact principal', Icons.badge),
                ),
                TextField(
                  controller: phone,
                  decoration:
                      _fieldDecoration('Telephone', Icons.phone_outlined),
                ),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration('Email', Icons.email_outlined),
                ),
                TextField(
                  controller: commune,
                  decoration:
                      _fieldDecoration('Ville / commune', Icons.location_city),
                ),
                TextField(
                  controller: street,
                  decoration:
                      _fieldDecoration('Adresse', Icons.location_on_outlined),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  title: const Text('Distributeur actif'),
                  onChanged: (value) => setSheetState(() => active = value),
                ),
                _FormSubmitButton(
                  label: editing ? 'Enregistrer' : 'Creer',
                  onPressed: () async {
                    if (name.text.trim().isEmpty) {
                      _showSnack('Champ requis', 'Le nom est obligatoire.');
                      return;
                    }
                    final payload = {
                      'name': name.text.trim(),
                      'code':
                          code.text.trim().isEmpty ? null : code.text.trim(),
                      'phone':
                          phone.text.trim().isEmpty ? null : phone.text.trim(),
                      'email':
                          email.text.trim().isEmpty ? null : email.text.trim(),
                      'contact_name': contact.text.trim().isEmpty
                          ? null
                          : contact.text.trim(),
                      'commune': commune.text.trim().isEmpty
                          ? null
                          : commune.text.trim(),
                      'street': street.text.trim().isEmpty
                          ? null
                          : street.text.trim(),
                      'is_active': active,
                    };
                    final route = editing
                        ? 'superadmin/distributors/${item['id']}/update'
                        : 'superadmin/distributors';
                    final response =
                        await _superAdminRequest(route, data: payload);
                    if (response.status == 'SUCCESS') {
                      Get.back();
                      _showSnack('SuperAdmin', response.message.toString());
                      _refresh();
                    } else {
                      _showSnack('Erreur', response.message.toString());
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showActorForm({
    Map<String, dynamic>? item,
    String? preselectedDistributorId,
  }) {
    final editing = item != null;
    final actorItem = _actorDisplayItem(item ?? const <String, dynamic>{});
    final firstname = TextEditingController(
      text: editing ? _actorFirstname(actorItem) : '',
    );
    final lastname = TextEditingController(
      text: editing ? _actorLastname(actorItem) : '',
    );
    final email = TextEditingController(
      text: editing ? _actorEmail(actorItem) : '',
    );
    final phone = TextEditingController(
      text: editing ? _actorPhone(actorItem) : '',
    );
    final password = TextEditingController(text: 'Test@123456');
    String workspace = _actorWorkspace(actorItem);
    String? distributorId = _dropdownId(
      _actorDistributorId(actorItem, preselectedDistributorId),
    );
    bool active = _boolValue(actorItem['is_active'], fallback: true);
    bool emailVerified =
        _boolValue(actorItem['email_verified'], fallback: true);

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _superAdminList('superadmin/distributors/query'),
              builder: (context, snapshot) {
                final distributors = _dedupeById(snapshot.data ?? const []);
                final distributorItems = <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Aucun / SuperAdmin'),
                  ),
                  ...distributors.map(
                    (distributor) {
                      final id = _dropdownId(distributor['id']);
                      final name = distributor['title'] ??
                          distributor['name'] ??
                          'Distributeur';
                      final code = distributor['code']?.toString() ?? '';
                      return DropdownMenuItem<String?>(
                        value: id,
                        child: Text(
                          '$name${code.isEmpty ? '' : ' - $code'} - ID $id',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ];
                if (distributorId != null &&
                    !distributorItems
                        .any((item) => item.value == distributorId)) {
                  distributorItems.add(
                    DropdownMenuItem<String?>(
                      value: distributorId,
                      child: Text(
                        'Distributeur actuel - ID $distributorId',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }
                distributorId =
                    _safeDropdownValue(distributorId, distributorItems);
                final workspaceItems = const [
                  'superadmin',
                  'distributeur',
                  'commercial',
                  'depot',
                  'livreur',
                  'point_vente',
                ]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList();
                workspace = _safeRequiredDropdownValue(
                  workspace,
                  workspaceItems,
                  'commercial',
                );

                return _FormSheet(
                  title: editing ? 'Modifier acteur' : 'Ajouter acteur',
                  children: [
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const AppLoadingState(
                          message: 'Chargement distributeurs...'),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: firstname,
                            decoration: _fieldDecoration(
                                'Prenom', Icons.person_outline_rounded),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: lastname,
                            decoration:
                                _fieldDecoration('Nom', Icons.person_rounded),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: email,
                      enabled: !editing,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          _fieldDecoration('Email de connexion', Icons.email),
                    ),
                    TextField(
                      controller: phone,
                      decoration: _fieldDecoration('Telephone', Icons.phone),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: workspace,
                      decoration: _fieldDecoration(
                          'Workspace', Icons.workspaces_rounded),
                      items: workspaceItems,
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            workspace = value;
                            if (workspace == 'superadmin') {
                              distributorId = null;
                            }
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: distributorId,
                      decoration: _fieldDecoration(
                        workspace == 'superadmin'
                            ? 'Distributeur (optionnel)'
                            : 'Distributeur rattache',
                        Icons.business_rounded,
                      ),
                      items: distributorItems,
                      onChanged: (value) => setSheetState(
                          () => distributorId = _dropdownId(value)),
                    ),
                    if (!editing)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: password,
                              obscureText: true,
                              decoration: _fieldDecoration(
                                  'Mot de passe temporaire', Icons.lock),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: password.text),
                                );
                                _showSnack(
                                  'Mot de passe copie',
                                  'Le mot de passe temporaire est dans le presse-papiers.',
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copier'),
                            ),
                          ),
                        ],
                      ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: emailVerified,
                      title: const Text('Email verifie'),
                      subtitle: const Text(
                        'Active par defaut pour permettre le test terrain.',
                      ),
                      onChanged: (value) =>
                          setSheetState(() => emailVerified = value),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: active,
                      title: const Text('Acteur actif'),
                      onChanged: (value) => setSheetState(() => active = value),
                    ),
                    _FormSubmitButton(
                      label: editing ? 'Enregistrer' : 'Creer acteur',
                      onPressed: () async {
                        if (firstname.text.trim().isEmpty ||
                            (!editing && email.text.trim().isEmpty)) {
                          _showSnack(
                            'Champs requis',
                            'Prenom et email sont obligatoires.',
                          );
                          return;
                        }
                        if (workspace != 'superadmin' &&
                            (distributorId == null ||
                                distributorId!.trim().isEmpty)) {
                          _showSnack(
                            'Distributeur requis',
                            'Choisissez un distributeur dans la liste.',
                          );
                          return;
                        }

                        final payload = {
                          'firstname': firstname.text.trim(),
                          'lastname': lastname.text.trim(),
                          'email': email.text.trim(),
                          'phone': phone.text.trim().isEmpty
                              ? null
                              : phone.text.trim(),
                          'workspace_type': workspace,
                          'distributor_id':
                              workspace == 'superadmin' ? null : distributorId,
                          if (!editing) 'password': password.text.trim(),
                          'is_active': active,
                          'email_verified': emailVerified,
                        };
                        final route = editing
                            ? 'superadmin/actors/${actorItem['id']}/update'
                            : 'superadmin/actors';
                        final response =
                            await _superAdminRequest(route, data: payload);
                        if (response.status == 'SUCCESS') {
                          Get.back();
                          _showSnack(
                            'Acteur enregistre',
                            '${firstname.text.trim()} peut se connecter maintenant.',
                          );
                          _refresh();
                        } else {
                          _showSnack('Erreur', response.message.toString());
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showProductForm({Map<String, dynamic>? item}) {
    final editing = item != null;
    final name = TextEditingController(text: item?['title']?.toString() ?? '');
    final ssin = TextEditingController(text: item?['ssin']?.toString() ?? '');
    final rate = TextEditingController(text: '0');
    String? categoryId = _dropdownId(item?['category_id']);
    String? distributorId = _dropdownId(item?['distributor_id']);
    bool active = item?['is_active'] as bool? ?? true;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return FutureBuilder<List<List<Map<String, dynamic>>>>(
              future: Future.wait([
                _superAdminList('superadmin/categories/query'),
                _superAdminList('superadmin/distributors/query'),
              ]),
              builder: (context, snapshot) {
                final refs =
                    snapshot.data ?? const <List<Map<String, dynamic>>>[];
                final categories = _dedupeById(
                  refs.isNotEmpty ? refs[0] : const <Map<String, dynamic>>[],
                );
                final distributors = _dedupeById(
                  refs.length > 1 ? refs[1] : const <Map<String, dynamic>>[],
                );
                final categoryItems = categories
                    .map(
                      (category) => DropdownMenuItem<String?>(
                        value: _dropdownId(category['id']),
                        child: Text(
                          (category['short_description_fr'] ??
                                  category['name'] ??
                                  category['title'] ??
                                  'Categorie')
                              .toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList();
                final safeCategoryId = categoryItems.isEmpty
                    ? categoryId
                    : _safeDropdownValue(categoryId, categoryItems);
                if (categoryItems.isNotEmpty) {
                  categoryId = safeCategoryId;
                }
                final distributorItems = <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Global / tous les distributeurs'),
                  ),
                  ...distributors.map(
                    (distributor) => DropdownMenuItem<String?>(
                      value: _dropdownId(distributor['id']),
                      child: Text(
                        '${distributor['title'] ?? distributor['name'] ?? 'Distributeur'}'
                        ' - ${distributor['code'] ?? distributor['id']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ];
                final safeDistributorId = distributors.isEmpty
                    ? distributorId
                    : _safeDropdownValue(distributorId, distributorItems);
                if (distributors.isNotEmpty) {
                  distributorId = safeDistributorId;
                }
                return _FormSheet(
                  title: editing ? 'Modifier produit' : 'Ajouter produit',
                  children: [
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const AppLoadingState(
                          message: 'Chargement referentiels...'),
                    TextField(
                      controller: name,
                      decoration:
                          _fieldDecoration('Nom produit', Icons.inventory_2),
                    ),
                    TextField(
                      controller: ssin,
                      decoration:
                          _fieldDecoration('Reference / SSIN', Icons.qr_code),
                    ),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'product-category-${safeCategoryId ?? 'none'}-${categoryItems.length}',
                      ),
                      initialValue: safeCategoryId,
                      decoration: _fieldDecoration('Categorie', Icons.category),
                      items: categoryItems,
                      onChanged: (value) =>
                          setSheetState(() => categoryId = value),
                    ),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'product-distributor-${safeDistributorId ?? 'global'}-${distributorItems.length}',
                      ),
                      initialValue: safeDistributorId,
                      decoration: _fieldDecoration(
                        'Distributeur',
                        Icons.business,
                      ),
                      items: distributorItems,
                      onChanged: (value) => setSheetState(
                          () => distributorId = _dropdownId(value)),
                    ),
                    TextField(
                      controller: rate,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration('Taux', Icons.percent),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: active,
                      title: const Text('Produit actif'),
                      onChanged: (value) => setSheetState(() => active = value),
                    ),
                    _FormSubmitButton(
                      label: editing ? 'Enregistrer' : 'Creer produit',
                      onPressed: () async {
                        if (name.text.trim().isEmpty) {
                          _showSnack(
                              'Champ requis', 'Le nom produit est requis.');
                          return;
                        }
                        final payload = {
                          'name': name.text.trim(),
                          'ssin': ssin.text.trim().isEmpty
                              ? null
                              : ssin.text.trim(),
                          'category_id': _dropdownInt(categoryId),
                          'distributor_id': distributorId,
                          'rate': int.tryParse(rate.text.trim()) ?? 0,
                          'is_active': active,
                        };
                        final route = editing
                            ? 'superadmin/products/${item['id']}/update'
                            : 'superadmin/products';
                        final response =
                            await _superAdminRequest(route, data: payload);
                        if (response.status == 'SUCCESS') {
                          Get.back();
                          _showSnack('Produit enregistre',
                              response.message.toString());
                          _refresh();
                        } else {
                          _showSnack('Erreur', response.message.toString());
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCategoryForm({ValueChanged<Map<String, dynamic>>? onCreated}) {
    final name = TextEditingController();
    final code = TextEditingController();
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: _FormSheet(
          title: 'Creer categorie',
          children: [
            TextField(
              controller: name,
              decoration: _fieldDecoration('Nom categorie', Icons.category),
            ),
            TextField(
              controller: code,
              decoration: _fieldDecoration('Code optionnel', Icons.tag),
            ),
            _FormSubmitButton(
              label: 'Creer categorie',
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  _showSnack('Champ requis', 'Le nom de categorie est requis.');
                  return;
                }
                final response = await _superAdminRequest(
                  'superadmin/categories',
                  data: {
                    'name': name.text.trim(),
                    if (code.text.trim().isNotEmpty) 'code': code.text.trim(),
                  },
                );
                if (response.status == 'SUCCESS') {
                  Get.back();
                  final category = _asMap(response.data);
                  onCreated?.call(category);
                  _showSnack('Categorie creee', response.message.toString());
                } else {
                  _showSnack('Erreur', response.message.toString());
                }
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showVariantForm({
    required String productId,
    Map<String, dynamic>? item,
    VoidCallback? onSaved,
  }) {
    final editing = item != null;
    final family = TextEditingController(
      text: item?['variant1_fr']?.toString() ??
          item?['group_label']?.toString() ??
          '',
    );
    final detail = TextEditingController(
      text: item?['variant2_fr']?.toString() ??
          item?['detail_label']?.toString() ??
          '',
    );
    final package = TextEditingController(
      text: item?['package']?.toString() ?? '1',
    );
    final barcode = TextEditingController(
      text: item?['barcode']?.toString() ?? '',
    );

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: _FormSheet(
          title: editing ? 'Modifier variant' : 'Ajouter variant',
          children: [
            TextField(
              controller: family,
              decoration: _fieldDecoration(
                'Famille / type',
                Icons.category_outlined,
              ),
            ),
            TextField(
              controller: detail,
              decoration: _fieldDecoration(
                'Detail / taille',
                Icons.tune_rounded,
              ),
            ),
            TextField(
              controller: package,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(
                'Conditionnement / stock colis',
                Icons.inventory_2_outlined,
              ),
            ),
            TextField(
              controller: barcode,
              decoration: _fieldDecoration('Code barre / SKU', Icons.qr_code),
            ),
            _FormSubmitButton(
              label: editing ? 'Enregistrer variant' : 'Creer variant',
              onPressed: () async {
                if (family.text.trim().isEmpty) {
                  _showSnack(
                    'Champ requis',
                    'La famille du variant est requise.',
                  );
                  return;
                }
                final payload = {
                  'option1_fr': 'Type',
                  'variant1_fr': family.text.trim(),
                  'name': family.text.trim(),
                  'option2_fr': 'Detail',
                  if (detail.text.trim().isNotEmpty)
                    'variant2_fr': detail.text.trim(),
                  'package': int.tryParse(package.text.trim()) ?? 1,
                  if (barcode.text.trim().isNotEmpty)
                    'barcode': barcode.text.trim(),
                };
                final route = editing
                    ? 'superadmin/variants/${item['id']}/update'
                    : 'superadmin/products/$productId/variants';
                final response = await _superAdminRequest(route, data: payload);
                if (response.status == 'SUCCESS') {
                  Get.back();
                  _showSnack('Variant enregistre', response.message.toString());
                  onSaved?.call();
                  _refresh();
                } else {
                  _showSnack('Erreur', response.message.toString());
                }
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showAttachActorSheet({
    required String distributorId,
    required String distributorName,
    required Map<String, dynamic> distributorContext,
  }) {
    String search = '';

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return _StaticManagementSheet(
              title: 'Affecter acteur',
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _superAdminList(
                  'superadmin/actors/query',
                  data: {'unassigned': true},
                ),
                builder: (context, snapshot) {
                  final actors = _dedupeById(snapshot.data ?? const [])
                      .map(_actorDisplayItem)
                      .where((actor) {
                    final workspace = actor['workspace_type']?.toString() ?? '';
                    if (workspace == 'superadmin') return false;
                    if (search.trim().isEmpty) return true;
                    final needle = search.trim().toLowerCase();
                    return [
                      actor['title'],
                      actor['email'],
                      actor['phone'],
                      actor['workspace_type'],
                      actor['distributor_label'],
                      actor['subtitle'],
                    ].whereType<Object>().any(
                          (value) =>
                              value.toString().toLowerCase().contains(needle),
                        );
                  }).toList();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rattacher un acteur existant a $distributorName.',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        decoration: _fieldDecoration(
                          'Rechercher acteur',
                          Icons.search_rounded,
                        ),
                        onChanged: (value) =>
                            setSheetState(() => search = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const AppLoadingState(message: 'Recherche acteurs...')
                      else if (actors.isEmpty)
                        AppEmptyState(
                          icon: Icons.person_add_alt_1_rounded,
                          title: 'Aucun acteur affectable',
                          message:
                              'Creez un acteur directement pour ce distributeur.',
                          action: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.back();
                              _showActorForm(
                                preselectedDistributorId: distributorId,
                              );
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Creer acteur'),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 360),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: actors.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final actor = actors[index];
                              return _WorkspaceListItem(
                                item: actor,
                                workspaceType: 'superadmin',
                                onTap: () async {
                                  final actorId = actor['id']?.toString();
                                  if (actorId == null || actorId.isEmpty) {
                                    _showSnack(
                                      'Acteur invalide',
                                      'Identifiant acteur manquant.',
                                    );
                                    return;
                                  }
                                  final response = await _superAdminRequest(
                                    'superadmin/distributors/$distributorId/attach-actor',
                                    data: {'actor_id': actorId},
                                  );
                                  if (response.status == 'SUCCESS') {
                                    Get.back();
                                    Get.back();
                                    _showSnack(
                                      'Acteur affecte',
                                      response.message.toString(),
                                    );
                                    _refresh();
                                    _showSuperAdminDistributorSheet(
                                      distributorContext,
                                    );
                                  } else {
                                    _showSnack(
                                      'Erreur',
                                      response.message.toString(),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSuperAdminDistributorSheet(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) {
      _showDetailsSheet(item);
      return;
    }

    Get.bottomSheet(
      _AsyncManagementSheet(
        title: item['title']?.toString() ?? 'Distributeur',
        future: _superAdminRequest(
          'superadmin/distributors/$id',
          method: 'GET',
        ),
        builder: (data) {
          final distributor = _asMap(data['distributor']);
          final stats = _asMap(data['stats']);
          final actors =
              _asList(data['actors']).map(_actorDisplayItem).toList();
          final warehouses = _asList(data['warehouses']);
          final products = _asList(data['products']);
          final orders = _asList(data['orders']);
          final active = distributor['is_active'] as bool? ?? true;

          return DefaultTabController(
            length: 6,
            child: Builder(builder: (context) {
              final sheetHeight = MediaQuery.sizeOf(context).height * 0.54;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      AppStatusChip(
                        label: distributor['code']?.toString() ?? 'Code',
                        color: AppColors.primary,
                      ),
                      AppStatusChip(
                        label: active ? 'Actif' : 'Inactif',
                        color: active ? AppColors.secondary : AppColors.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ManagementActions(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showDistributorForm(item: {
                            ...item,
                            ...distributor,
                            'title': distributor['name'],
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Modifier'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ok = await _confirmAction(
                            active
                                ? 'Desactiver distributeur'
                                : 'Activer distributeur',
                            active
                                ? 'Confirmer la desactivation de ${distributor['name']} ?'
                                : 'Confirmer la reactivation de ${distributor['name']} ?',
                          );
                          if (!ok) return;
                          final response = await _superAdminRequest(
                            'superadmin/distributors/$id/${active ? 'deactivate' : 'activate'}',
                          );
                          Get.back();
                          _showSnack('SuperAdmin', response.message.toString());
                          _refresh();
                        },
                        icon: Icon(active
                            ? Icons.block_rounded
                            : Icons.check_circle_outline_rounded),
                        label: Text(active ? 'Desactiver' : 'Activer'),
                      ),
                    ],
                  ),
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Infos'),
                      Tab(text: 'Acteurs'),
                      Tab(text: 'Depots'),
                      Tab(text: 'Produits'),
                      Tab(text: 'Commandes'),
                      Tab(text: 'Stats'),
                    ],
                  ),
                  SizedBox(
                    height: sheetHeight.clamp(330, 520).toDouble(),
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: _KeyValueList(values: {
                            'Nom': distributor['name'],
                            'Code': distributor['code'],
                            'Contact': distributor['contact_name'],
                            'Telephone': distributor['phone'],
                            'Email': distributor['email'],
                            'Ville': distributor['city'] ??
                                distributor['commune'] ??
                                distributor['state'],
                            'Adresse': distributor['address_label'] ??
                                distributor['street'],
                            'Statut': active ? 'Actif' : 'Inactif',
                            'Cree le': distributor['created_at'],
                          }),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ManagementActions(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () => _showAttachActorSheet(
                                      distributorId: id,
                                      distributorName:
                                          distributor['name']?.toString() ??
                                              item['title']?.toString() ??
                                              'Distributeur',
                                      distributorContext: item,
                                    ),
                                    icon: const Icon(Icons.link_rounded,
                                        size: 18),
                                    label:
                                        const Text('Affecter acteur existant'),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      Get.back();
                                      _showActorForm(
                                        preselectedDistributorId: id,
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.add_rounded, size: 18),
                                    label: const Text('Creer acteur'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _MiniList(
                                items: actors,
                                onTap: _showSuperAdminActorSheet,
                                dismissLabel: 'Retirer',
                                onDismiss: (actor) async {
                                  final actorId = actor['id']?.toString();
                                  if (actorId == null || actorId.isEmpty) {
                                    _showSnack('Acteur invalide',
                                        'Identifiant acteur manquant.');
                                    return false;
                                  }
                                  final ok = await _confirmAction(
                                    'Retirer acteur',
                                    'Supprimer l\'affectation de ${actor['title'] ?? 'cet acteur'} ?',
                                  );
                                  if (!ok) return false;
                                  final response = await _superAdminRequest(
                                    'superadmin/distributors/$id/detach-actor',
                                    data: {'actor_id': actorId},
                                  );
                                  if (response.status == 'SUCCESS') {
                                    _showSnack('Affectation retiree',
                                        response.message.toString());
                                    _refresh();
                                    Get.back();
                                    _showSuperAdminDistributorSheet(item);
                                  } else {
                                    _showSnack(
                                        'Erreur', response.message.toString());
                                  }
                                  return false;
                                },
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                            child: _MiniList(items: warehouses)),
                        SingleChildScrollView(
                            child: _MiniList(items: products)),
                        SingleChildScrollView(child: _MiniList(items: orders)),
                        SingleChildScrollView(
                            child: _KeyValueList(values: stats)),
                      ],
                    ),
                  ),
                ],
              );
            }),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSuperAdminActorSheet(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) {
      _showDetailsSheet(item);
      return;
    }
    Get.bottomSheet(
      _AsyncManagementSheet(
        title: item['title']?.toString() ?? 'Acteur',
        future: _superAdminRequest('superadmin/actors/$id', method: 'GET'),
        builder: (data) {
          final payload = _asMap(data);
          final apiActor = _asMap(payload['actor']);
          final actor = _actorDisplayItem({
            ...item,
            ...(apiActor.isNotEmpty ? apiActor : payload),
          });
          final active = _boolValue(actor['is_active'], fallback: true);
          final verified = _boolValue(actor['email_verified']);
          final title = _actorFullName(actor);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.softBlue,
                    child: Text(
                      _initial(title),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'Acteur' : title,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            AppStatusChip(
                              label: actor['workspace_type']?.toString() ??
                                  'workspace',
                              color: AppColors.primary,
                            ),
                            AppStatusChip(
                              label: active ? 'Actif' : 'Inactif',
                              color: active
                                  ? AppColors.secondary
                                  : AppColors.danger,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ManagementActions(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showActorForm(item: actor);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await _confirmAction(
                        'Reset mot de passe',
                        'Definir le mot de passe temporaire Test@123456 ?',
                      );
                      if (!ok) return;
                      final response = await _superAdminRequest(
                        'superadmin/actors/$id/reset-password',
                        data: {'password': 'Test@123456'},
                      );
                      Get.back();
                      _showSnack(
                          'Acces reinitialise', response.message.toString());
                      _refresh();
                    },
                    icon: const Icon(Icons.lock_reset_rounded),
                    label: const Text('Reset acces'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await _confirmAction(
                        active ? 'Desactiver acteur' : 'Activer acteur',
                        active
                            ? 'Confirmer la desactivation de $title ?'
                            : 'Confirmer la reactivation de $title ?',
                      );
                      if (!ok) return;
                      final response = await _superAdminRequest(
                        'superadmin/actors/$id/${active ? 'deactivate' : 'activate'}',
                      );
                      Get.back();
                      _showSnack('SuperAdmin', response.message.toString());
                      _refresh();
                    },
                    icon: Icon(active
                        ? Icons.block_rounded
                        : Icons.check_circle_outline_rounded),
                    label: Text(active ? 'Desactiver' : 'Activer'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Informations',
                  style: AppTextStyles.title
                      .copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: AppSpacing.sm),
              _KeyValueList(values: {
                'Workspace': actor['workspace_type'],
                'Distributeur': actor['distributor_label'] ??
                    actor['distributor_name'] ??
                    actor['distributor_id'],
                'Telephone': actor['phone'],
                'Email': actor['email'],
                'Email verifie': verified ? 'Oui' : 'Non',
                'Compte actif': active ? 'Oui' : 'Non',
                'Dernier acces': actor['last_access'] ?? 'Jamais connecte',
                'Cree le': actor['created_at'],
              }),
              const SizedBox(height: AppSpacing.md),
              Text('Audit recent',
                  style: AppTextStyles.title
                      .copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: AppSpacing.sm),
              const _MiniList(items: <Map<String, dynamic>>[
                {
                  'title': 'Creation acteur',
                  'subtitle': 'Journalisee dans audit logs'
                },
                {
                  'title': 'Association distributeur',
                  'subtitle': 'Controlee par SuperAdmin'
                },
              ]),
            ],
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSuperAdminProductSheet(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) {
      _showDetailsSheet(item);
      return;
    }

    Get.bottomSheet(
      _AsyncManagementSheet(
        title: item['title']?.toString() ?? 'Produit',
        future: _superAdminRequest('superadmin/products/$id', method: 'GET'),
        builder: (data) {
          final product = _asMap(data['product']);
          final variants = _asList(data['variants']);
          return DefaultTabController(
            length: 2,
            child: Builder(builder: (context) {
              final sheetHeight = MediaQuery.sizeOf(context).height * 0.56;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ManagementActions(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showProductForm(item: {
                            ...item,
                            ...product,
                            'title': product['name'] ?? item['title'],
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Modifier'),
                      ),
                    ],
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Infos'),
                      Tab(text: 'Variants'),
                    ],
                  ),
                  SizedBox(
                    height: sheetHeight.clamp(330, 540).toDouble(),
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: _KeyValueList(values: {
                            'Nom': product['name'] ?? product['title'],
                            'Reference': product['ssin'],
                            'Categorie': product['category_label'] ??
                                product['category_name'] ??
                                product['category_id'],
                            'Distributeur': product['distributor_label'] ??
                                product['distributor_name'] ??
                                'Global',
                            'Statut': (product['is_active'] as bool? ?? true)
                                ? 'Actif'
                                : 'Inactif',
                            'Prix / stock': 'Geres par les distributeurs',
                            'Variants': variants.length,
                            'Description': product['description'] ??
                                product['long_description_fr'],
                          }),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _showVariantForm(
                                    productId: id,
                                    onSaved: () {
                                      Get.back();
                                      _showSuperAdminProductSheet(item);
                                    },
                                  ),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Variant'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _VariantList(
                                variants: variants,
                                onEdit: (variant) => _showVariantForm(
                                  productId: id,
                                  item: variant,
                                  onSaved: () {
                                    Get.back();
                                    _showSuperAdminProductSheet(item);
                                  },
                                ),
                                onDelete: (variant) async {
                                  final confirmed = await _confirmAction(
                                    'Supprimer variant',
                                    'Supprimer ce variant uniquement s il n est pas utilise dans le stock, les commandes, les prix ou les promotions ?',
                                  );
                                  if (!confirmed) return;
                                  final response = await _superAdminRequest(
                                    'superadmin/variants/${variant['id']}/delete',
                                  );
                                  if (response.status == 'SUCCESS') {
                                    Get.back();
                                    _showSnack(
                                      'Variant supprime',
                                      response.message.toString(),
                                    );
                                    _showSuperAdminProductSheet(item);
                                    _refresh();
                                  } else {
                                    _showSnack(
                                      'Suppression impossible',
                                      response.message.toString(),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const AppCard(
                                child: Text(
                                  'Regles d administration\n'
                                  '- SuperAdmin injecte le catalogue maitre\n'
                                  '- Aucun bouton panier dans ce workspace\n'
                                  '- Les prix sont definis par distributeur/type PV\n'
                                  '- Le stock est gere par depot/distributeur',
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showDistributorProductSheet(Map<String, dynamic> item) {
    final variants = _asList(item['variants']);
    final title = item['title']?.toString() ?? 'Produit';
    final subtitle = item['subtitle']?.toString() ?? '';
    final status = item['status']?.toString() ?? 'Catalogue';

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Material(
          type: MaterialType.transparency,
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
            child: DefaultTabController(
              length: 2,
              child: Builder(builder: (context) {
                final sheetHeight = MediaQuery.sizeOf(context).height * 0.58;
                return Column(
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
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.softBlue,
                          child: Text(
                            _initial(title),
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        AppStatusChip(label: status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Infos'),
                        Tab(text: 'Variants'),
                      ],
                    ),
                    SizedBox(
                      height: sheetHeight.clamp(350, 560).toDouble(),
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _KeyValueList(values: {
                                  'Reference': item['ssin'] ?? item['id'],
                                  'Categorie':
                                      item['category_label'] ?? 'Catalogue',
                                  'Perimetre': item['distributor_label'] ??
                                      'Catalogue global lisible distributeurs',
                                  'Variants': variants.length,
                                  'Role SuperAdmin':
                                      'Injecte produit et variants globaux',
                                  'Role distributeur':
                                      'Prix, stock depot, disponibilite, promotions',
                                }),
                                const SizedBox(height: AppSpacing.md),
                                AppCard(
                                  child: Text(
                                    'Principe metier\n'
                                    '- SuperAdmin maintient le catalogue maitre\n'
                                    '- Le distributeur choisit l exploitation commerciale\n'
                                    '- Les prix et stocks sont geres par depot/distributeur\n'
                                    '- Aucun bouton panier dans ce workspace',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _VariantList(
                                  variants: variants,
                                  onEdit: (variant) =>
                                      _showDistributorVariantSheet(
                                    product: item,
                                    variant: variant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _showDistributorPriceForm(),
                                        icon: const Icon(
                                          Icons.price_change_rounded,
                                        ),
                                        label: const Text('Prix'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _showDistributorStockForm(),
                                        icon:
                                            const Icon(Icons.inventory_rounded),
                                        label: const Text('Stock'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showDistributorVariantSheet({
    required Map<String, dynamic> product,
    required Map<String, dynamic> variant,
  }) {
    final title = _variantDetail(variant);
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product['title']?.toString() ?? 'Produit distributeur',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                _KeyValueList(values: {
                  'SKU': _variantSku(variant),
                  'Groupe': _variantGroup(variant),
                  'Conditionnement': _variantPackageLabel(variant),
                  'Stock depots': variant['stock_label'] ??
                      '${variant['stock_quantity'] ?? 0} unites',
                  'Prix': variant['price_label'] ?? 'A definir',
                }),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showDistributorPriceForm(variant: variant),
                        icon: const Icon(Icons.price_change_rounded),
                        label: const Text('Prix'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showDistributorStockForm(variant: variant),
                        icon: const Icon(Icons.inventory_rounded),
                        label: const Text('Stock'),
                      ),
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

  void _showDistributorContextSheet({
    required String title,
    required Widget Function(Map<String, dynamic> contextData) builder,
  }) {
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: FutureBuilder<ResponseHttpRequest>(
          future: _superAdminRequest('distributor/context'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _FormSheet(
                title: 'Chargement',
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: AppLoadingState(message: 'Referentiels...'),
                  ),
                ],
              );
            }

            final response = snapshot.data;
            if (response == null || response.status != 'SUCCESS') {
              return _FormSheet(
                title: title,
                children: [
                  AppErrorState(
                    title: 'API distributeur indisponible',
                    message: response?.message?.toString() ??
                        'Impossible de charger les referentiels.',
                  ),
                ],
              );
            }

            return builder(_asMap(response.data));
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  List<DropdownMenuItem<String>> _contextDropdownItems(
    Map<String, dynamic> contextData,
    String key,
  ) {
    return _dedupeById(_asList(contextData[key]))
        .map(
          (item) => DropdownMenuItem<String>(
            value: _dropdownId(item['id']),
            child: Text(
              item['title']?.toString() ??
                  item['name']?.toString() ??
                  item['id']?.toString() ??
                  'Element',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .where((item) => item.value != null)
        .toList();
  }

  String? _firstDropdownValue(List<DropdownMenuItem<String>> items) {
    return items.isEmpty ? null : items.first.value;
  }

  Future<void> _submitDistributorOperation(
    String route,
    Map<String, dynamic> payload,
    String successMessage, {
    String method = 'POST',
  }) async {
    final response =
        await _superAdminRequest(route, data: payload, method: method);
    if (response.status == 'SUCCESS') {
      Get.back();
      _showSnack(
          'Operation reussie', response.message?.toString() ?? successMessage);
      _refresh();
      return;
    }
    _showSnack('Action impossible',
        response.message?.toString() ?? 'Verifiez les champs.');
  }

  void _showDistributorActorForm() {
    final first = TextEditingController();
    final last = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController(text: 'Test@123456');
    var workspace = 'commercial';
    var emailVerified = true;
    var active = true;

    _showDistributorContextSheet(
      title: 'Ajouter acteur',
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return _FormSheet(
            title: 'Ajouter acteur',
            children: [
              TextField(
                controller: first,
                decoration: _fieldDecoration('Prenom', Icons.person_rounded),
              ),
              TextField(
                controller: last,
                decoration: _fieldDecoration('Nom', Icons.badge_rounded),
              ),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration('Email', Icons.email_outlined),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('Telephone', Icons.phone),
              ),
              DropdownButtonFormField<String>(
                value: workspace,
                decoration: _fieldDecoration('Workspace', Icons.workspaces),
                items: const [
                  DropdownMenuItem(
                      value: 'commercial', child: Text('Commercial')),
                  DropdownMenuItem(value: 'livreur', child: Text('Livreur')),
                  DropdownMenuItem(value: 'depot', child: Text('Depot')),
                  DropdownMenuItem(
                      value: 'distributeur', child: Text('Manager')),
                ],
                onChanged: (value) =>
                    setSheetState(() => workspace = value ?? 'commercial'),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration:
                    _fieldDecoration('Mot de passe temporaire', Icons.lock),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: emailVerified,
                title: const Text('Email verifie'),
                onChanged: (value) =>
                    setSheetState(() => emailVerified = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: active,
                title: const Text('Acteur actif'),
                onChanged: (value) => setSheetState(() => active = value),
              ),
              _FormSubmitButton(
                label: 'Creer acteur',
                onPressed: () => _submitDistributorOperation(
                  'distributor/actors',
                  {
                    'firstname': first.text.trim(),
                    'lastname': last.text.trim(),
                    'email': email.text.trim(),
                    'phone': phone.text.trim(),
                    'password': password.text,
                    'workspace_type': workspace,
                    'email_verified': emailVerified,
                    'is_active': active,
                  },
                  'Acteur cree.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDistributorWarehouseForm() {
    final name = TextEditingController();
    final code = TextEditingController();
    final commune = TextEditingController();
    final street = TextEditingController();

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: _FormSheet(
          title: 'Ajouter depot',
          children: [
            TextField(
              controller: name,
              decoration: _fieldDecoration('Nom depot', Icons.warehouse),
            ),
            TextField(
              controller: code,
              decoration: _fieldDecoration('Code', Icons.tag_rounded),
            ),
            TextField(
              controller: commune,
              decoration:
                  _fieldDecoration('Ville / commune', Icons.location_city),
            ),
            TextField(
              controller: street,
              decoration: _fieldDecoration('Adresse', Icons.location_on),
            ),
            _FormSubmitButton(
              label: 'Creer depot',
              onPressed: () => _submitDistributorOperation(
                'distributor/warehouses',
                {
                  'name': name.text.trim(),
                  'code': code.text.trim(),
                  'commune': commune.text.trim(),
                  'street': street.text.trim(),
                },
                'Depot cree.',
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showDistributorClientForm() {
    final name = TextEditingController();
    final phone = TextEditingController();
    final commune = TextEditingController();
    final street = TextEditingController();
    String? typePvId;

    _showDistributorContextSheet(
      title: 'Ajouter client',
      builder: (contextData) {
        final typeItems = _contextDropdownItems(contextData, 'type_pv');
        typePvId = _safeRequiredDropdownValue(
          typePvId ?? _firstDropdownValue(typeItems) ?? '',
          typeItems,
          _firstDropdownValue(typeItems) ?? '',
        );
        return StatefulBuilder(
          builder: (context, setSheetState) => _FormSheet(
            title: 'Ajouter client',
            children: [
              TextField(
                controller: name,
                decoration: _fieldDecoration('Nom client', Icons.storefront),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('Telephone', Icons.phone),
              ),
              DropdownButtonFormField<String>(
                value: typePvId,
                decoration:
                    _fieldDecoration('Type point de vente', Icons.category),
                items: typeItems,
                onChanged: (value) => setSheetState(() => typePvId = value),
              ),
              TextField(
                controller: commune,
                decoration:
                    _fieldDecoration('Ville / commune', Icons.location_city),
              ),
              TextField(
                controller: street,
                decoration: _fieldDecoration('Adresse', Icons.location_on),
              ),
              _FormSubmitButton(
                label: 'Creer client',
                onPressed: () => _submitDistributorOperation(
                  'distributor/clients',
                  {
                    'name': name.text.trim(),
                    'phone': phone.text.trim(),
                    'typepv_id': typePvId,
                    'commune': commune.text.trim(),
                    'street': street.text.trim(),
                  },
                  'Client cree.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDistributorCouponForm() {
    final code = TextEditingController();
    final description = TextEditingController();
    final discount = TextEditingController(text: '5');
    final count = TextEditingController(text: '100');
    final minAmount = TextEditingController(text: '0');

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: _FormSheet(
          title: 'Creer coupon',
          children: [
            TextField(
              controller: code,
              decoration:
                  _fieldDecoration('Code coupon', Icons.confirmation_number),
            ),
            TextField(
              controller: description,
              decoration: _fieldDecoration('Description', Icons.notes),
            ),
            TextField(
              controller: discount,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration('Remise %', Icons.percent),
            ),
            TextField(
              controller: count,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration('Nombre utilisations', Icons.repeat),
            ),
            TextField(
              controller: minAmount,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration('Montant minimum', Icons.payments),
            ),
            _FormSubmitButton(
              label: 'Creer coupon',
              onPressed: () => _submitDistributorOperation(
                'distributor/coupons',
                {
                  'code': code.text.trim(),
                  'description': description.text.trim(),
                  'discount': double.tryParse(discount.text) ?? 0,
                  'count': int.tryParse(count.text) ?? 100,
                  'min_amount': double.tryParse(minAmount.text) ?? 0,
                  'is_pourcentage': true,
                },
                'Coupon cree.',
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showDistributorPromotionForm() {
    final description = TextEditingController();
    final discount = TextEditingController(text: '10');
    final minimum = TextEditingController(text: '1');
    String? typePvId;
    String? promotionTypeId;
    String? categoryId;
    String? productId;
    String? variantId;
    var scope = 'all';
    var unite = '%';

    _showDistributorContextSheet(
      title: 'Creer promotion',
      builder: (contextData) {
        final typeItems = _contextDropdownItems(contextData, 'type_pv');
        final promotionTypeItems =
            _contextDropdownItems(contextData, 'promotion_types');
        final categoryItems = _contextDropdownItems(contextData, 'categories');
        final productItems = _contextDropdownItems(contextData, 'products');
        final variantItems = _contextDropdownItems(contextData, 'variants');
        if (typeItems.isEmpty || promotionTypeItems.isEmpty) {
          return const _FormSheet(
            title: 'Creer promotion',
            children: [
              AppEmptyState(
                icon: Icons.local_offer_outlined,
                title: 'Configuration incomplete',
                message:
                    'Ajoutez au moins un type point de vente et un type promotion avant de creer une promotion.',
              ),
            ],
          );
        }
        typePvId = _safeRequiredDropdownValue(
          typePvId ?? _firstDropdownValue(typeItems) ?? '',
          typeItems,
          _firstDropdownValue(typeItems) ?? '',
        );
        promotionTypeId = _safeRequiredDropdownValue(
          promotionTypeId ?? _firstDropdownValue(promotionTypeItems) ?? '',
          promotionTypeItems,
          _firstDropdownValue(promotionTypeItems) ?? '',
        );
        categoryId = _safeDropdownValue(categoryId, categoryItems);
        productId = _safeDropdownValue(productId, productItems);
        variantId = _safeDropdownValue(variantId, variantItems);
        return StatefulBuilder(
          builder: (context, setSheetState) => _FormSheet(
            title: 'Creer promotion reelle',
            children: [
              TextField(
                controller: description,
                maxLines: 3,
                decoration: _fieldDecoration('Description', Icons.local_offer),
              ),
              DropdownButtonFormField<String>(
                value: typePvId,
                decoration:
                    _fieldDecoration('Type point de vente', Icons.store),
                items: typeItems,
                onChanged: (value) => setSheetState(() => typePvId = value),
              ),
              DropdownButtonFormField<String>(
                value: promotionTypeId,
                decoration: _fieldDecoration('Type promotion', Icons.discount),
                items: promotionTypeItems,
                onChanged: (value) =>
                    setSheetState(() => promotionTypeId = value),
              ),
              DropdownButtonFormField<String>(
                value: scope,
                decoration: _fieldDecoration('Portee', Icons.rule_rounded),
                items: const [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('Tout le catalogue'),
                  ),
                  DropdownMenuItem(
                    value: 'category',
                    child: Text('Categorie precise'),
                  ),
                  DropdownMenuItem(
                    value: 'product',
                    child: Text('Produit precis'),
                  ),
                  DropdownMenuItem(
                    value: 'variant',
                    child: Text('Variant precis'),
                  ),
                ],
                onChanged: (value) => setSheetState(() {
                  scope = value ?? 'all';
                  categoryId = _safeDropdownValue(categoryId, categoryItems);
                  productId = _safeDropdownValue(productId, productItems);
                  variantId = _safeDropdownValue(variantId, variantItems);
                }),
              ),
              if (scope == 'category')
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: _fieldDecoration('Categorie', Icons.category),
                  items: categoryItems,
                  onChanged: categoryItems.isEmpty
                      ? null
                      : (value) => setSheetState(() => categoryId = value),
                ),
              if (scope == 'product')
                DropdownButtonFormField<String>(
                  value: productId,
                  decoration:
                      _fieldDecoration('Produit', Icons.inventory_2_outlined),
                  items: productItems,
                  onChanged: productItems.isEmpty
                      ? null
                      : (value) => setSheetState(() => productId = value),
                ),
              if (scope == 'variant')
                DropdownButtonFormField<String>(
                  value: variantId,
                  decoration:
                      _fieldDecoration('Variant', Icons.view_in_ar_rounded),
                  items: variantItems,
                  onChanged: variantItems.isEmpty
                      ? null
                      : (value) => setSheetState(() => variantId = value),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: discount,
                      keyboardType: TextInputType.number,
                      decoration:
                          _fieldDecoration('Remise', Icons.percent_rounded),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 104,
                    child: DropdownButtonFormField<String>(
                      value: unite,
                      decoration: _fieldDecoration('Unite', Icons.tune),
                      items: const [
                        DropdownMenuItem(value: '%', child: Text('%')),
                        DropdownMenuItem(value: 'DA', child: Text('DA')),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => unite = value ?? '%'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: minimum,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration(
                  'Quantite minimum',
                  Icons.format_list_numbered_rounded,
                ),
              ),
              _FormSubmitButton(
                label: 'Creer promotion',
                onPressed: () {
                  final value =
                      double.tryParse(discount.text.replaceAll(',', '.')) ?? 0;
                  if (description.text.trim().isEmpty) {
                    _showSnack(
                      'Champ requis',
                      'La description de la promotion est obligatoire.',
                    );
                    return;
                  }
                  if (value <= 0) {
                    _showSnack(
                      'Remise invalide',
                      'La remise doit etre superieure a 0.',
                    );
                    return;
                  }
                  if (scope == 'category' && categoryId == null) {
                    _showSnack('Categorie requise',
                        'Selectionnez une categorie pour cette promotion.');
                    return;
                  }
                  if (scope == 'product' && productId == null) {
                    _showSnack('Produit requis',
                        'Selectionnez un produit pour cette promotion.');
                    return;
                  }
                  if (scope == 'variant' && variantId == null) {
                    _showSnack('Variant requis',
                        'Selectionnez un variant pour cette promotion.');
                    return;
                  }
                  _submitDistributorOperation(
                    'distributor/promotions',
                    {
                      'description': description.text.trim(),
                      'typepv_id': typePvId,
                      'type_promotion_id': promotionTypeId,
                      'discount': value,
                      'minimum': int.tryParse(minimum.text) ?? 1,
                      'unite': unite,
                      if (scope == 'category') 'category_id': categoryId,
                      if (scope == 'product') 'product_id': productId,
                      if (scope == 'variant') 'variant_id': variantId,
                    },
                    'Promotion creee.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDistributorPriceForm({Map<String, dynamic>? variant}) {
    final price = TextEditingController(
      text: variant?['price']?.toString() ?? '',
    );
    final sku = TextEditingController(text: _variantSku(variant ?? {}));
    String? variantId = _dropdownId(variant?['id']);
    String? typePvId;

    _showDistributorContextSheet(
      title: 'Definir prix',
      builder: (contextData) {
        final variantItems = _contextDropdownItems(contextData, 'variants');
        final typeItems = _contextDropdownItems(contextData, 'type_pv');
        variantId = _safeRequiredDropdownValue(
          variantId ?? _firstDropdownValue(variantItems) ?? '',
          variantItems,
          _firstDropdownValue(variantItems) ?? '',
        );
        typePvId = _safeRequiredDropdownValue(
          typePvId ?? _firstDropdownValue(typeItems) ?? '',
          typeItems,
          _firstDropdownValue(typeItems) ?? '',
        );
        return StatefulBuilder(
          builder: (context, setSheetState) => _FormSheet(
            title: 'Definir prix variant',
            children: [
              DropdownButtonFormField<String>(
                value: variantId,
                decoration: _fieldDecoration('Variant', Icons.inventory_2),
                items: variantItems,
                onChanged: (value) => setSheetState(() => variantId = value),
              ),
              DropdownButtonFormField<String>(
                value: typePvId,
                decoration:
                    _fieldDecoration('Type point de vente', Icons.store),
                items: typeItems,
                onChanged: (value) => setSheetState(() => typePvId = value),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration:
                    _fieldDecoration('Prix de vente', Icons.price_change),
              ),
              TextField(
                controller: sku,
                decoration: _fieldDecoration('SKU', Icons.qr_code),
              ),
              _FormSubmitButton(
                label: 'Enregistrer prix',
                onPressed: () {
                  final id = variantId;
                  if (id == null || id.isEmpty) {
                    _showSnack('Variant requis', 'Selectionnez un variant.');
                    return;
                  }
                  _submitDistributorOperation(
                    'distributor/variants/$id/price',
                    {
                      'typepv_id': typePvId,
                      'price': double.tryParse(price.text) ?? 0,
                      'sku': sku.text.trim(),
                    },
                    'Prix enregistre.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDistributorStockForm({Map<String, dynamic>? variant}) {
    final quantity = TextEditingController();
    String? variantId = _dropdownId(variant?['id']);
    String? warehouseId;
    var mode = 'set';

    _showDistributorContextSheet(
      title: 'Ajuster stock',
      builder: (contextData) {
        final variantItems = _contextDropdownItems(contextData, 'variants');
        final warehouseItems = _contextDropdownItems(contextData, 'warehouses');
        if (warehouseItems.isEmpty) {
          return _FormSheet(
            title: 'Ajuster stock depot',
            children: [
              AppEmptyState(
                icon: Icons.warehouse_outlined,
                title: 'Aucun depot',
                message:
                    'Creez au moins un depot avant de pouvoir ajuster le stock.',
                action: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showDistributorWarehouseForm();
                  },
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Creer depot'),
                ),
              ),
            ],
          );
        }
        if (variantItems.isEmpty) {
          return const _FormSheet(
            title: 'Ajuster stock depot',
            children: [
              AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Aucun variant',
                message:
                    'Ajoutez des variants produits avant de pouvoir alimenter le stock.',
              ),
            ],
          );
        }
        variantId = _safeRequiredDropdownValue(
          variantId ?? _firstDropdownValue(variantItems) ?? '',
          variantItems,
          _firstDropdownValue(variantItems) ?? '',
        );
        warehouseId = _safeRequiredDropdownValue(
          warehouseId ?? _firstDropdownValue(warehouseItems) ?? '',
          warehouseItems,
          _firstDropdownValue(warehouseItems) ?? '',
        );
        return StatefulBuilder(
          builder: (context, setSheetState) => _FormSheet(
            title: 'Ajuster stock depot',
            children: [
              DropdownButtonFormField<String>(
                value: warehouseId,
                decoration: _fieldDecoration('Depot', Icons.warehouse),
                items: warehouseItems,
                onChanged: (value) => setSheetState(() => warehouseId = value),
              ),
              DropdownButtonFormField<String>(
                value: variantId,
                decoration: _fieldDecoration('Variant', Icons.inventory_2),
                items: variantItems,
                onChanged: (value) => setSheetState(() => variantId = value),
              ),
              DropdownButtonFormField<String>(
                value: mode,
                decoration: _fieldDecoration('Mode', Icons.tune),
                items: const [
                  DropdownMenuItem(value: 'set', child: Text('Fixer quantite')),
                  DropdownMenuItem(value: 'add', child: Text('Ajouter')),
                  DropdownMenuItem(value: 'sub', child: Text('Retirer')),
                ],
                onChanged: (value) =>
                    setSheetState(() => mode = value ?? 'set'),
              ),
              TextField(
                controller: quantity,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Quantite', Icons.numbers),
              ),
              _FormSubmitButton(
                label: 'Valider stock',
                onPressed: () {
                  if (warehouseId == null || variantId == null) {
                    _showSnack('Stock', 'Depot et variant sont obligatoires.');
                    return;
                  }
                  _submitDistributorOperation(
                    'distributor/stock/adjust',
                    {
                      'warehouse_id': warehouseId,
                      'variant_id': variantId,
                      'mode': mode,
                      'quantity': int.tryParse(quantity.text) ?? 0,
                    },
                    'Stock ajuste.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuperAdminAuditSheet() {
    Get.bottomSheet(
      _AsyncManagementSheet(
        title: 'Audit logs',
        future: _superAdminRequest(
          'superadmin/audit-logs/query',
          data: {},
        ),
        builder: (data) {
          final logs =
              data is List ? _asList(data) : _asList(_asMap(data)['items']);
          return logs.isEmpty
              ? const AppEmptyState(
                  icon: Icons.history_rounded,
                  title: 'Aucun audit log',
                  message: 'Les actions sensibles rempliront ce journal.',
                )
              : _MiniList(items: logs);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
      _ => 'Fiche de consultation connectee aux donnees reelles disponibles.',
    };
  }

  void _showSnack(String title, String message) {
    final lower = title.toLowerCase();
    final color = lower.contains('erreur') || lower.contains('impossible')
        ? AppColors.danger
        : lower.contains('attention') || lower.contains('requis')
            ? AppColors.warning
            : lower.contains('api')
                ? AppColors.info
                : AppColors.secondary;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.primaryDark,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      borderRadius: AppSpacing.radiusLg,
      borderColor: color.withValues(alpha: 0.22),
      borderWidth: 1,
      icon: Container(
        margin: const EdgeInsets.only(left: AppSpacing.sm),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          lower.contains('erreur') ? 'ERR' : 'OK',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: AppColors.primaryDark.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 260),
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  void _showServiceInfo(String title, String message, IconData icon) {
    Get.bottomSheet(
      _StaticManagementSheet(
        title: title,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServiceStatusCard(
              icon: icon,
              title: title,
              message: message,
              status: 'Info',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _ManagementActions(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showSnack(title, message);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Compris'),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showExternalServiceSheet(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? 'Service externe';
    final lower = title.toLowerCase();
    final isMaps = lower.contains('map');
    final isBluetooth =
        lower.contains('bluetooth') || lower.contains('printer');
    final isFirebase =
        lower.contains('firebase') || lower.contains('notification');
    final color = isBluetooth
        ? AppColors.primaryDark
        : isMaps || isFirebase
            ? AppColors.primary
            : AppColors.warning;
    final icon = isBluetooth
        ? Icons.print_rounded
        : isMaps
            ? Icons.map_outlined
            : isFirebase
                ? Icons.notifications_active_outlined
                : Icons.login_rounded;

    Get.bottomSheet(
      _StaticManagementSheet(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServiceStatusCard(
              icon: icon,
              title: title,
              message: item['subtitle']?.toString() ??
                  'Configuration reelle requise avant production.',
              status: item['status']?.toString() ?? 'A configurer',
              color: color,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBluetooth
                        ? 'Workflow impression'
                        : isMaps
                            ? 'Test Google Maps'
                            : isFirebase
                                ? 'Notifications Firebase'
                                : 'Connexion sociale',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isBluetooth
                        ? 'Verifiez les permissions Bluetooth Android, scannez l imprimante puis lancez une impression de test depuis un bon.'
                        : isMaps
                            ? 'La cle doit etre restreinte par package Android et SHA. Si la carte interne manque, l app ouvre Maps externe.'
                            : isFirebase
                                ? 'Ajoutez google-services.json, demandez la permission Android 13+ et envoyez le token FCM au backend.'
                                : 'Configurez OAuth, SHA-1/SHA-256 et callback Android. Le login ne doit jamais rester en chargement infini.',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ManagementActions(
              children: [
                if (isMaps)
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _openMaps({'title': 'Push Sales', 'subtitle': 'Alger'});
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Tester Maps'),
                  ),
                if (isBluetooth)
                  ElevatedButton.icon(
                    onPressed: () => _showSnack(
                      'Bluetooth printer',
                      'Materiel requis. Interface prete pour scan, connexion et test impression.',
                    ),
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: const Text('Scanner'),
                  ),
                if (isFirebase)
                  ElevatedButton.icon(
                    onPressed: () => _showSnack(
                      'Firebase',
                      'Permission notification et token FCM a valider avec un vrai projet Firebase.',
                    ),
                    icon: const Icon(Icons.notifications_active_rounded),
                    label: const Text('Tester'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Compris'),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  static String _textValue(
    Map<String, dynamic>? item,
    List<String> keys, {
    String fallback = '',
  }) {
    if (item == null) return fallback;
    for (final key in keys) {
      final value = item[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  static bool _boolValue(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    if (text == null || text.isEmpty || text == 'null') return fallback;
    if (['1', 'true', 'yes', 'oui', 'active', 'actif'].contains(text)) {
      return true;
    }
    if (['0', 'false', 'no', 'non', 'inactive', 'inactif'].contains(text)) {
      return false;
    }
    return fallback;
  }

  static String _actorFirstname(Map<String, dynamic>? item) {
    final direct = _textValue(item, ['firstname', 'first_name', 'prenom']);
    if (direct.isNotEmpty) return direct;
    final name = _actorFullName(item);
    final parts = name.split(' ').where((part) => part.trim().isNotEmpty);
    return parts.isEmpty ? '' : parts.first;
  }

  static String _actorLastname(Map<String, dynamic>? item) {
    final direct = _textValue(item, ['lastname', 'last_name', 'nom']);
    if (direct.isNotEmpty) return direct;
    final parts =
        _actorFullName(item).split(' ').where((part) => part.trim().isNotEmpty);
    return parts.length > 1 ? parts.skip(1).join(' ') : '';
  }

  static String _actorFullName(Map<String, dynamic>? item) {
    final first = _textValue(item, ['firstname', 'first_name', 'prenom']);
    final last = _textValue(item, ['lastname', 'last_name', 'nom']);
    final composed = '$first $last'.trim();
    if (composed.isNotEmpty) return composed;
    return _textValue(item, ['title', 'full_name', 'name', 'mail', 'email'],
        fallback: 'Acteur');
  }

  static String _actorEmail(Map<String, dynamic>? item) {
    final user = _asMap(item?['user']);
    return _textValue(item, ['email', 'mail', 'user_email'],
        fallback: _textValue(user, ['email']));
  }

  static String _actorPhone(Map<String, dynamic>? item) {
    return _textValue(item, ['phone', 'telephone', 'tel', 'mobile']);
  }

  static String _actorWorkspace(Map<String, dynamic>? item) {
    final profile = _asMap(item?['profile']);
    final workspace = _textValue(
      item,
      ['workspace_type', 'workspace', 'type_actor', 'type'],
      fallback: _textValue(profile, ['workspace_type', 'code']),
    ).toLowerCase();
    const allowed = {
      'superadmin',
      'distributeur',
      'commercial',
      'depot',
      'livreur',
      'point_vente',
    };
    return allowed.contains(workspace) ? workspace : 'commercial';
  }

  static String? _actorDistributorId(
    Map<String, dynamic>? item, [
    String? fallback,
  ]) {
    final distributor = _asMap(item?['distributor']);
    final legacyDistributor = _asMap(item?['Distributor']);
    return _dropdownId(item?['distributor_id']) ??
        _dropdownId(item?['id_distributor']) ??
        _dropdownId(distributor['id']) ??
        _dropdownId(legacyDistributor['id']) ??
        _dropdownId(fallback);
  }

  static Map<String, dynamic> _actorDisplayItem(Map<String, dynamic> item) {
    final nested = _asMap(item['actor']);
    final source = <String, dynamic>{
      ...item,
      if (nested.isNotEmpty) ...nested,
    };
    final title = _actorFullName(source);
    final email = _actorEmail(source);
    final phone = _actorPhone(source);
    final workspace = _actorWorkspace(source);
    final distributor = _asMap(source['distributor']);
    final legacyDistributor = _asMap(source['Distributor']);
    final distributorLabel = _textValue(
      source,
      ['distributor_label', 'distributor_name'],
      fallback: _textValue(
        distributor,
        ['name', 'title', 'code'],
        fallback: _textValue(legacyDistributor, ['name', 'title', 'code']),
      ),
    );
    final active = _boolValue(source['is_active'], fallback: true);
    return {
      ...source,
      'title': title,
      'email': email,
      'phone': phone,
      'workspace_type': workspace,
      'distributor_id': _actorDistributorId(source),
      'distributor_label': distributorLabel,
      'subtitle': [
        if (email.isNotEmpty) email,
        if (workspace.isNotEmpty) workspace,
        if (distributorLabel.isNotEmpty) distributorLabel,
      ].join(' - '),
      'status': active ? 'Actif' : 'Inactif',
      'kind': 'actor',
      'is_active': active,
      'email_verified': _boolValue(source['email_verified']),
    };
  }

  static String? _dropdownId(dynamic value) {
    final text = value?.toString().trim();
    if (text == null ||
        text.isEmpty ||
        text.toLowerCase() == 'null' ||
        text.toLowerCase() == 'undefined') {
      return null;
    }
    return text;
  }

  static int? _dropdownInt(dynamic value) {
    final text = _dropdownId(value);
    return text == null ? null : int.tryParse(text);
  }

  static List<Map<String, dynamic>> _dedupeById(
    List<Map<String, dynamic>> items, {
    String primary = 'id',
    String secondary = 'code',
  }) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final item in items) {
      final key = _dropdownId(item[primary]) ?? _dropdownId(item[secondary]);
      if (key == null) continue;
      if (seen.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  static String? _safeDropdownValue(
    String? selected,
    List<DropdownMenuItem> items,
  ) {
    if (selected == null) return null;
    return items.where((item) => item.value == selected).length == 1
        ? selected
        : null;
  }

  static String _safeRequiredDropdownValue(
    String selected,
    List<DropdownMenuItem<String>> items,
    String fallback,
  ) {
    return items.where((item) => item.value == selected).length == 1
        ? selected
        : fallback;
  }
}

class _Header extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNotifications;
  final VoidCallback onMessages;

  const _Header({
    required this.data,
    required this.onNotifications,
    required this.onMessages,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Push Sales';
    final subtitle = data['subtitle']?.toString() ?? '';
    final actor = _WorkspacePageState._asMap(data['actor']);
    final workspace = data['workspace_type']?.toString() ?? '';
    final section = data['section']?.toString() ?? 'dashboard';
    final showActorCard = !{'superadmin', 'distributeur'}.contains(workspace) ||
        section == 'dashboard';
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
              onTap: onNotifications,
            ),
            const SizedBox(width: AppSpacing.sm),
            _HeaderIcon(
              icon: Icons.chat_bubble_outline_rounded,
              onTap: onMessages,
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
        if (showActorCard) ...[
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
                        actor['name']?.toString() ?? 'Utilisateur',
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
      ],
    );
  }
}

class _DashboardDistributorFilter extends StatelessWidget {
  final String value;
  final List<Map<String, String>> options;
  final ValueChanged<String?> onChanged;

  const _DashboardDistributorFilter({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return SizedBox(
      height: compact ? 44 : 48,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.filter_alt_outlined, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          labelText: 'Vue dashboard',
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: 0,
          ),
        ),
        items: options
            .map(
              (item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(
                  item['title'] ?? 'Distributeur',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _DeliveryWarehouseFilter extends StatelessWidget {
  final String value;
  final List<Map<String, String>> options;
  final ValueChanged<String?> onChanged;

  const _DeliveryWarehouseFilter({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return SizedBox(
      height: compact ? 44 : 48,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.warehouse_outlined, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          labelText: 'Depot',
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: 0,
          ),
        ),
        items: options
            .map(
              (item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(
                  item['title'] ?? 'Depot',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _SuperAdminToolbar extends StatelessWidget {
  final String section;
  final String searchQuery;
  final String statusFilter;
  final String categoryFilter;
  final List<Map<String, String>> categoryOptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onStatusChanged;

  const _SuperAdminToolbar({
    required this.section,
    required this.searchQuery,
    required this.statusFilter,
    required this.categoryFilter,
    required this.categoryOptions,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: compact ? double.infinity : 420,
            height: 44,
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                hintText: switch (section) {
                  'actors' => 'Acteur, email, role...',
                  'products' => 'Produit, reference...',
                  _ => 'Distributeur, code, contact...',
                },
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
          ),
          if (section == 'products')
            SizedBox(
              width: compact ? 150 : 180,
              height: 44,
              child: DropdownButtonFormField<String>(
                key: ValueKey(
                  'product-category-filter-$categoryFilter-${categoryOptions.length}',
                ),
                initialValue: categoryOptions
                        .where((item) => item['id'] == categoryFilter)
                        .isEmpty
                    ? 'all'
                    : categoryFilter,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  prefixIcon: Icon(Icons.category_outlined, size: 18),
                  prefixIconConstraints: BoxConstraints(minWidth: 36),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('Categorie'),
                  ),
                  ...categoryOptions.map(
                    (category) => DropdownMenuItem(
                      value: category['id'],
                      child: Text(
                        category['label'] ?? 'Categorie',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onCategoryChanged(value);
                  }
                },
              ),
            ),
          SizedBox(
            width: compact ? 142 : 170,
            height: 44,
            child: DropdownButtonFormField<String>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                prefixIcon: Icon(Icons.filter_alt_outlined, size: 18),
                prefixIconConstraints: BoxConstraints(minWidth: 36),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(value: 'active', child: Text('Actifs')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactifs')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onStatusChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSheet({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
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
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...children.expand(
                (child) => [
                  child,
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _FormSubmitButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded),
        label: Text(label),
      ),
    );
  }
}

class _AsyncManagementSheet extends StatelessWidget {
  final String title;
  final Future<ResponseHttpRequest> future;
  final Widget Function(dynamic data) builder;

  const _AsyncManagementSheet({
    required this.title,
    required this.future,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: _StaticManagementSheet(
        title: title,
        child: FutureBuilder<ResponseHttpRequest>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingState(message: 'Chargement...'),
              );
            }

            final response = snapshot.data;
            if (response == null || response.status != 'SUCCESS') {
              return AppErrorState(
                title: 'Chargement impossible',
                message: response?.message?.toString() ??
                    'Impossible de charger les donnees.',
              );
            }

            return builder(response.data);
          },
        ),
      ),
    );
  }
}

class _StaticManagementSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _StaticManagementSheet({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 820,
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
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
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ManagementActions extends StatelessWidget {
  final List<Widget> children;

  const _ManagementActions({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: children,
      ),
    );
  }
}

class _KeyValueList extends StatelessWidget {
  final Map<String, dynamic> values;

  const _KeyValueList({required this.values});

  @override
  Widget build(BuildContext context) {
    final entries = values.entries
        .where((entry) {
          final key = entry.key.toLowerCase();
          final value = entry.value;
          if (value == null || value.toString().isEmpty) return false;
          if (const {
            'id',
            'user_id',
            'profile_id',
            'address_id',
            'meta',
            'kind',
            'action',
            'data',
            'raw',
          }.contains(key)) {
            return false;
          }
          if (value is Map || value is List) return false;
          return true;
        })
        .take(24)
        .toList();
    if (entries.isEmpty) {
      return const AppEmptyState(
        title: 'Aucune information',
        message: 'Les donnees detaillees ne sont pas encore disponibles.',
      );
    }

    return Column(
      children: entries.map((entry) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            entry.key.replaceAll('_', ' '),
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          subtitle: Text(
            '${entry.value}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(color: AppColors.ink),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>>? onTap;
  final Future<bool> Function(Map<String, dynamic> item)? onDismiss;
  final String dismissLabel;

  const _MiniList({
    required this.items,
    this.onTap,
    this.onDismiss,
    this.dismissLabel = 'Retirer',
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyState(
        title: 'Aucune donnee',
        message: 'Aucune information dans cette section.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item['title'] ??
            item['name'] ??
            item['code'] ??
            item['action'] ??
            item['id'] ??
            'Element';
        final subtitle = item['subtitle'] ??
            item['email'] ??
            item['status'] ??
            item['created_at'] ??
            '';
        final tile = ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          onTap: onTap == null ? null : () => onTap!(item),
          leading: CircleAvatar(
            backgroundColor: AppColors.softBlue,
            child: Text(
              _initial(title.toString()),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          title: Text(
            title.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            subtitle.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
        if (onDismiss == null) {
          return tile;
        }
        return Dismissible(
          key: ValueKey('${item['kind'] ?? 'item'}-${item['id'] ?? index}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => onDismiss!(item),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_off_rounded, color: AppColors.danger),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dismissLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          child: tile,
        );
      },
    );
  }
}

class _VariantList extends StatelessWidget {
  final List<Map<String, dynamic>> variants;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final Future<void> Function(Map<String, dynamic>)? onDelete;

  const _VariantList({
    required this.variants,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return const AppEmptyState(
        icon: Icons.tune_rounded,
        title: 'Aucun variant',
        message: 'Ajoutez un variant pour rendre le produit exploitable.',
      );
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final variant in variants) {
      grouped.putIfAbsent(_variantGroup(variant), () => []).add(variant);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final groupVariants = entry.value;
        final packageLabels = groupVariants
            .map(_variantPackageLabel)
            .where((label) => label.isNotEmpty)
            .toSet()
            .toList();
        final packageLabel = packageLabels.isEmpty
            ? 'conditionnement a completer'
            : packageLabels.length == 1
                ? 'conditionnement ${packageLabels.first}'
                : '${packageLabels.length} conditionnements';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.softBlue,
                  child: Text(
                    _initial(entry.key),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${groupVariants.length} variants - $packageLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
                children: groupVariants
                    .map(
                      (variant) => _VariantTile(
                        variant: variant,
                        onTap: () => onEdit(variant),
                        onDelete: onDelete == null
                            ? null
                            : () async => onDelete!(variant),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final Map<String, dynamic> variant;
  final VoidCallback onTap;
  final Future<void> Function()? onDelete;

  const _VariantTile({
    required this.variant,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final detail = _variantDetail(variant);
    final sku = _variantSku(variant);
    final packageLabel = _variantPackageLabel(variant);

    final tile = AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.softGreen,
            child: Text(
              _initial(detail),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  [
                    if (sku.isNotEmpty) 'SKU $sku',
                    if (packageLabel.isNotEmpty)
                      'Conditionnement $packageLabel',
                    'prix/stock distributeur',
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.edit_note_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );

    if (onDelete == null) return tile;

    final id = variant['id']?.toString() ?? detail;
    return Dismissible(
      key: ValueKey('variant-$id'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onDelete?.call();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      child: tile,
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
  final String workspaceType;
  final String deliveryFilter;
  final String deliveryWarehouseFilter;
  final String searchQuery;
  final String statusFilter;
  final String categoryFilter;
  final ValueChanged<Map<String, dynamic>> onItemAction;

  const _ListSection({
    required this.section,
    required this.workspaceType,
    required this.deliveryFilter,
    required this.deliveryWarehouseFilter,
    required this.searchQuery,
    required this.statusFilter,
    required this.categoryFilter,
    required this.onItemAction,
  });

  @override
  Widget build(BuildContext context) {
    final title = _filteredTitle(section['title']?.toString() ?? 'Liste');
    final items = _filteredItems(
      section['title']?.toString() ?? 'Liste',
      _WorkspacePageState._asList(section['items']),
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
              message:
                  'Aucune donnee reelle disponible pour cette page avec le compte connecte.',
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
                workspaceType: workspaceType,
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
    var scopedItems = items;
    if (title == 'Demandes de livraison' && deliveryWarehouseFilter != 'all') {
      scopedItems = scopedItems
          .where((item) =>
              item['warehouse_id']?.toString() == deliveryWarehouseFilter)
          .toList();
    }

    if (title != 'Demandes de livraison' || deliveryFilter == 'Toutes') {
      return _applyCommonFilters(scopedItems, title);
    }

    final filtered = scopedItems.where((item) {
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
    return _applyCommonFilters(filtered, title);
  }

  List<Map<String, dynamic>> _applyCommonFilters(
    List<Map<String, dynamic>> items,
    String title,
  ) {
    final search = searchQuery.trim().toLowerCase();
    var filtered = search.isEmpty
        ? items
        : items.where((item) {
            return [
              item['title'],
              item['subtitle'],
              item['meta'],
              item['status'],
              item['email'],
              item['phone'],
              item['code'],
            ].whereType<Object>().any(
                  (value) => value.toString().toLowerCase().contains(search),
                );
          }).toList();

    if (title.toLowerCase().contains('produit') &&
        categoryFilter != 'all' &&
        categoryFilter.trim().isNotEmpty) {
      final selected = categoryFilter.toLowerCase();
      filtered = filtered.where((item) {
        final values = [
          item['category_id'],
          item['category'],
          item['category_label'],
          item['category_name'],
          item['subtitle'],
        ].whereType<Object>().map((value) => value.toString().toLowerCase());
        return values
            .any((value) => value == selected || value.contains(selected));
      }).toList();
    }

    if (statusFilter == 'all') {
      return filtered;
    }

    return filtered.where((item) {
      final active = item['is_active'];
      if (active is bool) {
        return statusFilter == 'active' ? active : !active;
      }
      final status = item['status']?.toString().toLowerCase() ?? '';
      final inactive = _isInactiveStatus(status);
      final isActive = !inactive &&
          (status.contains('actif') ||
              status.contains('active') ||
              status.contains('ok') ||
              status.contains('stock') ||
              status.isEmpty);
      return statusFilter == 'active' ? isActive : inactive;
    }).toList();
  }

  String _filteredTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('distributeur')) {
      return switch (statusFilter) {
        'active' => 'Distributeurs actifs',
        'inactive' => 'Distributeurs inactifs',
        _ => 'Distributeurs',
      };
    }
    if (lower.contains('acteur')) {
      return switch (statusFilter) {
        'active' => 'Acteurs actifs',
        'inactive' => 'Acteurs inactifs',
        _ => 'Acteurs et roles',
      };
    }
    if (lower.contains('produit')) {
      return switch (statusFilter) {
        'active' => 'Produits actifs',
        'inactive' => 'Produits inactifs',
        _ => 'Produits disponibles',
      };
    }
    return title;
  }

  bool _isInactiveStatus(String status) {
    return status.contains('inactif') ||
        status.contains('inactive') ||
        status.contains('desactiv') ||
        status.contains('désactiv') ||
        status.contains('bloque') ||
        status.contains('bloqué') ||
        status.contains('suspend');
  }
}

class _WorkspaceListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String workspaceType;
  final VoidCallback onTap;

  const _WorkspaceListItem({
    required this.item,
    this.workspaceType = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item['status']?.toString());
    final kind = item['kind']?.toString() ?? '';
    final showChevron = const {
      'actor',
      'product',
      'distributor',
      'audit',
      'setting',
      'warehouse',
      'order',
      'purchase_order',
      'client',
      'route',
    }.contains(kind);

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

          final trailing = Wrap(
            alignment: compact ? WrapAlignment.start : WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppStatusChip(
                label: item['status']?.toString() ?? 'OK',
                color: color,
              ),
              if ((item['amount']?.toString().isNotEmpty ?? false))
                Text(
                  item['amount'].toString(),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: compact ? 16 : 18,
                  ),
                ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryDark.withValues(alpha: 0.72),
                  size: compact ? 22 : 24,
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

class _ServiceStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String status;
  final Color color;

  const _ServiceStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    AppStatusChip(label: status, color: color),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                ),
              ],
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
    final cart = _WorkspacePageState._cart;
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.lg : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panier',
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
                  workspaceType: '',
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
                'label': 'Valider la commande',
                'kind': 'submit_order',
              }),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(compact ? 'Valider' : 'Valider la commande'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final ValueChanged<Map<String, dynamic>> onAction;

  const _QuickActionsBar({
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final compact = MediaQuery.sizeOf(context).width < 430;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: actions.map((action) {
        final kind = action['kind']?.toString() ?? '';
        final primary = kind.startsWith('create_');
        final label = action['label']?.toString() ?? 'Action';
        final enabled = action['enabled'] != false;
        final button = primary
            ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: Size(0, compact ? 34 : 38),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? AppSpacing.md : AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onPressed: enabled ? () => onAction(action) : null,
                icon: Icon(_actionIcon(action['kind']?.toString()), size: 17),
                label: Text(
                  compact ? label.replaceAll('Ajouter ', '+ ') : label,
                  style: TextStyle(fontSize: compact ? 12 : 14),
                ),
              )
            : OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: Size(0, compact ? 34 : 38),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? AppSpacing.md : AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onPressed: enabled ? () => onAction(action) : null,
                icon: Icon(_actionIcon(action['kind']?.toString()), size: 17),
                label: Text(
                  compact ? label.replaceAll('Voir ', '') : label,
                  style: TextStyle(fontSize: compact ? 12 : 14),
                ),
              );
        return Opacity(opacity: enabled ? 1 : 0.52, child: button);
      }).toList(),
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

String _variantGroup(Map<String, dynamic> variant) {
  final label = variant['group_label'] ??
      variant['variant1_fr'] ??
      variant['option1_fr'] ??
      'Autres variants';
  final text = label.toString().trim();
  return text.isEmpty ? 'Autres variants' : text;
}

String _variantDetail(Map<String, dynamic> variant) {
  final label = variant['detail_label'] ??
      variant['variant2_fr'] ??
      variant['variant1_fr'] ??
      variant['name'] ??
      'Variant';
  final text = label.toString().trim();
  return text.isEmpty ? 'Variant' : text;
}

String _variantSku(Map<String, dynamic> variant) {
  final pricing = variant['pricing'];
  dynamic firstPrice;
  if (pricing is List && pricing.isNotEmpty) {
    firstPrice = pricing.first;
  }
  final value = variant['sku'] ??
      variant['barcode'] ??
      (firstPrice is Map ? firstPrice['sku'] : null);
  return value?.toString().trim() ?? '';
}

String _variantPackageLabel(Map<String, dynamic> variant) {
  final value = variant['package'] ??
      variant['conditioning'] ??
      variant['conditionnement'] ??
      variant['stock_label'];
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text == 'null' || text == '0') return '';
  return text;
}

Color _statusColor(String? status) {
  final normalized = status?.toLowerCase() ?? '';
  if (normalized.contains('inactif') ||
      normalized.contains('inactive') ||
      normalized.contains('desactiv') ||
      normalized.contains('désactiv') ||
      normalized.contains('bloque') ||
      normalized.contains('bloqué') ||
      normalized.contains('suspend')) {
    return AppColors.danger;
  }
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
    'missing_real_api' => Icons.api_rounded,
    'create_distributor' => Icons.business_rounded,
    'create_actor' => Icons.person_add_alt_1_rounded,
    'create_category' => Icons.category_rounded,
    'create_product' => Icons.add_box_rounded,
    'view_audit_logs' => Icons.history_rounded,
    'distributor_create_actor' => Icons.person_add_alt_1_rounded,
    'distributor_create_warehouse' => Icons.warehouse_rounded,
    'distributor_adjust_stock' => Icons.inventory_rounded,
    'distributor_manage_prices' => Icons.price_change_rounded,
    'distributor_create_client' => Icons.storefront_rounded,
    'distributor_create_promotion' => Icons.local_offer_rounded,
    'distributor_create_coupon' => Icons.confirmation_number_rounded,
    'open_delivery' => Icons.local_shipping_rounded,
    _ => Icons.touch_app_rounded,
  };
}
