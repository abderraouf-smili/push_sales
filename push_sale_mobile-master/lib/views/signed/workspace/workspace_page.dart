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
      _searchQuery = '';
      _statusFilter = 'all';
      _future = _load();
    }
  }

  Future<ResponseHttpRequest> _load() {
    return CallApi.RequestHttp(
      AppConfig.isDemoMode ? 'workspace/mvp' : 'workspace/real',
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final scope = FocusScope.of(context);
        if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
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
                            if (_isSuperAdminListSection()) ...[
                              _SuperAdminToolbar(
                                section: widget.section,
                                searchQuery: _searchQuery,
                                statusFilter: _statusFilter,
                                onSearchChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                onStatusChanged: (value) {
                                  setState(() {
                                    _statusFilter = value;
                                  });
                                },
                              ),
                              SizedBox(
                                  height:
                                      compact ? AppSpacing.md : AppSpacing.xl),
                            ],
                            _StatsGrid(stats: _asList(data['stats'])),
                            SizedBox(
                                height:
                                    compact ? AppSpacing.lg : AppSpacing.xl),
                            if (_workspaceType == 'superadmin')
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
                            ..._sections(data).map(
                              (section) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      compact ? AppSpacing.lg : AppSpacing.xl,
                                ),
                                child: _ListSection(
                                  section: section,
                                  workspaceType: _workspaceType,
                                  deliveryFilter: _deliveryFilter,
                                  searchQuery: _searchQuery,
                                  statusFilter: _statusFilter,
                                  onItemAction: _handleItemAction,
                                ),
                              ),
                            ),
                            if (_workspaceType != 'superadmin')
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

  bool _isSuperAdminListSection() {
    return _workspaceType == 'superadmin' &&
        const {'distributors', 'actors', 'products'}.contains(widget.section);
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

    if (kind == 'filter') {
      setState(() {
        _deliveryFilter = title;
      });
      _showSnack('Filtre applique', title);
      return;
    }

    if (kind == 'product') {
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
    final title = item?['title']?.toString() ?? '';
    final parts = title.split(' ');
    final firstname = TextEditingController(
      text: editing && parts.isNotEmpty ? parts.first : '',
    );
    final lastname = TextEditingController(
      text: editing && parts.length > 1 ? parts.skip(1).join(' ') : '',
    );
    final email = TextEditingController(text: item?['email']?.toString() ?? '');
    final phone = TextEditingController(text: item?['phone']?.toString() ?? '');
    final password = TextEditingController(text: 'Test@123456');
    String workspace = item?['workspace_type']?.toString() ?? 'commercial';
    String? distributorId =
        item?['distributor_id']?.toString() ?? preselectedDistributorId;
    if (distributorId != null && distributorId.trim().isEmpty) {
      distributorId = null;
    }
    bool active = item?['is_active'] as bool? ?? true;
    bool emailVerified = item?['email_verified'] as bool? ?? true;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _superAdminList('superadmin/distributors/query'),
              builder: (context, snapshot) {
                final distributors = snapshot.data ?? const [];
                final distributorItems = <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Aucun / SuperAdmin'),
                  ),
                  ...distributors.map(
                    (distributor) {
                      final id = distributor['id']?.toString();
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
                      items: const [
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
                          .toList(),
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
                      onChanged: workspace == 'superadmin'
                          ? (value) =>
                              setSheetState(() => distributorId = value)
                          : (value) =>
                              setSheetState(() => distributorId = value),
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
                            ? 'superadmin/actors/${item['id']}/update'
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
    int? categoryId = int.tryParse(item?['category_id']?.toString() ?? '');
    String? distributorId = item?['distributor_id']?.toString();
    if (distributorId != null && distributorId.trim().isEmpty) {
      distributorId = null;
    }
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
                final categories =
                    refs.isNotEmpty ? refs[0] : const <Map<String, dynamic>>[];
                final distributors =
                    refs.length > 1 ? refs[1] : const <Map<String, dynamic>>[];
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: categoryId,
                            decoration:
                                _fieldDecoration('Categorie', Icons.category),
                            items: categories
                                .map(
                                  (category) => DropdownMenuItem<int?>(
                                    value: int.tryParse(
                                        category['id']?.toString() ?? ''),
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
                                .toList(),
                            onChanged: (value) =>
                                setSheetState(() => categoryId = value),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _showCategoryForm(
                              onCreated: (category) => setSheetState(() {
                                categoryId = int.tryParse(
                                  category['id']?.toString() ?? '',
                                );
                              }),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Categorie'),
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: distributorId,
                      decoration: _fieldDecoration(
                        'Distributeur',
                        Icons.business,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Global / tous les distributeurs'),
                        ),
                        ...distributors.map(
                          (distributor) => DropdownMenuItem<String?>(
                            value: distributor['id']?.toString(),
                            child: Text(
                              '${distributor['title'] ?? distributor['name'] ?? 'Distributeur'}'
                              ' - ${distributor['code'] ?? distributor['id']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => distributorId = value),
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
                          'category_id': categoryId,
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
    final name = TextEditingController(
      text: item?['variant1_fr']?.toString() ??
          item?['name']?.toString() ??
          item?['title']?.toString() ??
          '',
    );
    final option = TextEditingController(
      text: item?['option1_fr']?.toString() ?? 'Conditionnement',
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
              controller: name,
              decoration: _fieldDecoration('Nom variant', Icons.tune_rounded),
            ),
            TextField(
              controller: option,
              decoration:
                  _fieldDecoration('Type / unite', Icons.inventory_2_outlined),
            ),
            TextField(
              controller: package,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration('Conditionnement', Icons.numbers),
            ),
            TextField(
              controller: barcode,
              decoration: _fieldDecoration('Code barre / SKU', Icons.qr_code),
            ),
            _FormSubmitButton(
              label: editing ? 'Enregistrer variant' : 'Creer variant',
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  _showSnack('Champ requis', 'Le nom du variant est requis.');
                  return;
                }
                final payload = {
                  'variant1_fr': name.text.trim(),
                  'name': name.text.trim(),
                  'option1_fr': option.text.trim().isEmpty
                      ? 'Conditionnement'
                      : option.text.trim(),
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
          final actors = _asList(data['actors']);
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
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () {
                                    Get.back();
                                    _showActorForm(
                                      preselectedDistributorId: id,
                                    );
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Acteur'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _MiniList(items: actors),
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
          final actor = _asMap(data).isEmpty ? item : _asMap(data);
          final active = actor['is_active'] as bool? ?? true;
          final verified = actor['email_verified'] as bool? ?? false;
          final title = actor['title']?.toString() ??
              '${actor['firstname'] ?? ''} ${actor['lastname'] ?? ''}'.trim();
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
                            'Prix indicatif': product['amount'],
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
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const AppCard(
                                child: Text(
                                  'Regles d administration\n'
                                  '- Aucun bouton panier dans ce workspace\n'
                                  '- Les prix restent lies aux regles distributeur/PV\n'
                                  '- Les variants sont audites a la creation et modification',
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
    final showActorCard = workspace != 'superadmin' || section == 'dashboard';
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

class _SuperAdminToolbar extends StatelessWidget {
  final String section;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;

  const _SuperAdminToolbar({
    required this.section,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: compact ? double.infinity : 420,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: switch (section) {
                  'actors' => 'Rechercher acteur, email, role...',
                  'products' => 'Rechercher produit, reference...',
                  _ => 'Rechercher distributeur, code, contact...',
                },
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            width: compact ? 170 : 190,
            child: DropdownButtonFormField<String>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.filter_alt_outlined),
                labelText: 'Statut',
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
    return Container(
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

  const _MiniList({required this.items});

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
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
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
      },
    );
  }
}

class _VariantList extends StatelessWidget {
  final List<Map<String, dynamic>> variants;
  final ValueChanged<Map<String, dynamic>> onEdit;

  const _VariantList({
    required this.variants,
    required this.onEdit,
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

    return Column(
      children: variants.map((variant) {
        final title = variant['variant1_fr'] ??
            variant['name'] ??
            variant['title'] ??
            'Variant';
        final option = variant['option1_fr'] ?? 'Conditionnement';
        final stock = variant['stock'] ??
            variant['quantity'] ??
            variant['available'] ??
            variant['package'] ??
            '';
        final pricing = variant['pricing'];
        final firstPrice = pricing is List && pricing.isNotEmpty
            ? pricing.first
            : const <String, dynamic>{};
        final amount = variant['amount'] ??
            variant['price'] ??
            (pricing is Map ? pricing['price'] : null) ??
            (firstPrice is Map ? firstPrice['price'] : null) ??
            '';
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.softBlue,
                  child: Text(
                    _initial(title.toString()),
                    style: AppTextStyles.caption.copyWith(
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
                        title.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${variant['barcode'] ?? 'SKU'} - $option',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                      if (stock.toString().isNotEmpty)
                        AppStatusChip(
                          label: 'Stock $stock',
                          color: AppColors.secondary,
                        ),
                    ],
                  ),
                ),
                if (amount.toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Text(
                      amount.toString(),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => onEdit(variant),
                  child: const Text('Modifier'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<Map<String, dynamic>> onItemAction;

  const _ListSection({
    required this.section,
    required this.workspaceType,
    required this.deliveryFilter,
    required this.searchQuery,
    required this.statusFilter,
    required this.onItemAction,
  });

  @override
  Widget build(BuildContext context) {
    final title = section['title']?.toString() ?? 'Liste';
    final items = _filteredItems(
      title,
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
    if (title != 'Demandes de livraison' || deliveryFilter == 'Toutes') {
      return _applyCommonFilters(items);
    }

    final filtered = items.where((item) {
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
    return _applyCommonFilters(filtered);
  }

  List<Map<String, dynamic>> _applyCommonFilters(
      List<Map<String, dynamic>> items) {
    final search = searchQuery.trim().toLowerCase();
    final filteredBySearch = search.isEmpty
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

    if (statusFilter == 'all') {
      return filteredBySearch;
    }

    return filteredBySearch.where((item) {
      final active = item['is_active'];
      if (active is bool) {
        return statusFilter == 'active' ? active : !active;
      }
      final status = item['status']?.toString().toLowerCase() ?? '';
      return statusFilter == 'active'
          ? status.contains('actif') || !status.contains('inactif')
          : status.contains('inactif');
    }).toList();
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
    final action = item['action']?.toString() ?? 'Ouvrir';
    final kind = item['kind']?.toString() ?? '';
    final useChevronOnly = workspaceType == 'superadmin' &&
        const {'actor', 'product', 'distributor', 'audit', 'setting'}
            .contains(kind);

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
              if (useChevronOnly)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryDark,
                  size: compact ? 26 : 30,
                )
              else
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
        return primary
            ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: Size(0, compact ? 34 : 38),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? AppSpacing.md : AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onPressed: () => onAction(action),
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
                onPressed: () => onAction(action),
                icon: Icon(_actionIcon(action['kind']?.toString()), size: 17),
                label: Text(
                  compact ? label.replaceAll('Voir ', '') : label,
                  style: TextStyle(fontSize: compact ? 12 : 14),
                ),
              );
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
    'missing_real_api' => Icons.api_rounded,
    'create_distributor' => Icons.business_rounded,
    'create_actor' => Icons.person_add_alt_1_rounded,
    'create_product' => Icons.add_box_rounded,
    'view_audit_logs' => Icons.history_rounded,
    _ => Icons.touch_app_rounded,
  };
}
