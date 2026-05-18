import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/compte_menu_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/services/session_service.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/comptesetting.dart';
import 'package:push_sale/views/signed/menu/clients.dart';
import 'package:push_sale/views/signed/menu/favorite.dart';
import 'package:push_sale/views/signed/menu/stats_page.dart';
import 'package:push_sale/views/signed/widgets/delivery/delivery_routes_page.dart';
import 'package:push_sale/views/signed/widgets/delivery/delivery_stock_mobile_page.dart';
import 'package:push_sale/views/signed/widgets/delivery/main_delivery_page.dart';
import 'package:push_sale/views/signed/widgets/products/product_main_page.dart';
import 'package:push_sale/views/signed/widgets/tracking/main_tracking_page.dart';
import 'package:push_sale/views/signed/widgets/transfert/main_transfer_page.dart';
import 'package:push_sale/views/signed/workspace/workspace_mvp_page.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';

class HomePage extends StatefulWidget {
  final int index;

  HomePage({super.key, required this.index});

  @override
  State<HomePage> createState() => _HomePageState(index);
}

class _HomePageState extends State<HomePage> {
  PermissionsController perm = Get.put(PermissionsController());
  _HomePageState(this._index);
  int _index;
  String _postedClientId = "0";
  bool _routeArgumentsConsumed = false;

  @override
  void initState() {
    super.initState();
    _ensureSessionControllers();
  }

  void _ensureSessionControllers() {
    if (!Get.isRegistered<CompteMenuController>()) {
      Get.put(CompteMenuController());
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureSessionControllers();
    var screen = [];
    final bool useSideBar = MediaQuery.of(context).size.width >= 720;

    if (!_routeArgumentsConsumed &&
        Get.arguments is Map &&
        Get.arguments["client_id"] != null &&
        Get.arguments["client_id"].toString() != "0") {
      _postedClientId = Get.arguments["client_id"].toString();
      _index = 1;
      _routeArgumentsConsumed = true;
    }
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: !useSideBar
              ? _PushSalesDrawer(
                  selectedIndex: _index,
                  onSelect: (index) {
                    Navigator.of(context).pop();
                    setState(() {
                      _index = index;
                    });
                  },
                  destinations: _drawerItems(),
                )
              : null,
          bottomNavigationBar: Obx(
            () => perm.PermissionLoaded.value && !useSideBar
                ? NavigationBar(
                    selectedIndex: _index,
                    height: 68,
                    backgroundColor: AppColors.surface,
                    indicatorColor: AppColors.softBlue,
                    onDestinationSelected: (index) {
                      setState(() {
                        _index = index;
                      });
                    },
                    destinations: _bottomDestinations(),
                  )
                : const SizedBox.shrink(),
          ),
          body: Obx(() {
            if (perm.PermissionLoaded.value) {
              final bool workspaceMvp = _usesWorkspaceMvp();
              final bool deliveryWorkspace = _isDeliveryWorkspace();
              screen = workspaceMvp
                  ? _workspaceTabs()
                      .map((tab) => WorkspaceMvpPage(section: tab.section))
                      .toList()
                  : deliveryWorkspace
                      ? [
                          perm.check(StatsPage(), "HomePage.StatsPage"),
                          const DeliveryStockMobilePage(),
                          MainDeliveryPage(),
                          const DeliveryRoutesPage(),
                          perm.check(CompteSetting(), "HomePage.CompteSetting"),
                        ]
                      : [
                          perm.check(StatsPage(), "HomePage.StatsPage"),
                          perm.check(null, "HomePage.Clients")
                              //for the prevente/classic profile
                              ? Clients(_postedClientId)
                              : perm.check(null, "HomePage.MainTransferPage")
                                  // for delivery profile
                                  ? MainTransferPage()
                                  : const Favorite(),
                          perm.check(null, "HomePage.MainTrackingOrder")
                              //for the prevente profile
                              ? MainTrackingOrder()
                              : perm.check(null, "HomePage.MainDeliveryPage")
                                  // for delivery profile
                                  ? MainDeliveryPage()
                                  : const Favorite(),
                          perm.check(
                              ProductMainPage(), "HomePage.ProductMainPage"),
                          perm.check(CompteSetting(), "HomePage.CompteSetting"),
                        ];
              if (_index < 0 || _index >= screen.length) {
                _index = 0;
              }
              final Widget currentScreen = KeyedSubtree(
                key: ValueKey<int>(_index),
                child: screen[_index] as Widget,
              );
              if (useSideBar) {
                return Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      backgroundColor: AppColors.surface,
                      extended: MediaQuery.of(context).size.width >= 980,
                      labelType: MediaQuery.of(context).size.width >= 980
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      onDestinationSelected: (index) {
                        setState(() {
                          _index = index;
                        });
                      },
                      destinations: _railDestinations(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: currentScreen),
                  ],
                );
              }
              return Stack(
                children: [
                  currentScreen,
                  PositionedDirectional(
                    top: 78,
                    end: 12,
                    child: Builder(
                      builder: (context) => SafeArea(
                        child: Material(
                          color: AppColors.surface,
                          elevation: 4,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          child: IconButton(
                            tooltip: "Menu",
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu_rounded,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return AppLoadingState(message: "loading".tr);
            }
          }),
        ),
      ),
    );
  }

  List<_DrawerItem> _drawerItems() {
    if (_usesWorkspaceMvp()) {
      return _workspaceTabs()
          .map((tab) => _DrawerItem(label: tab.label, icon: tab.selectedIcon))
          .toList();
    }

    final bool deliveryWorkspace = _isDeliveryWorkspace();
    return [
      _DrawerItem(
        label: "dashboard".tr,
        icon: Icons.dashboard_rounded,
      ),
      _DrawerItem(
        label: deliveryWorkspace
            ? "Stock"
            : perm.check(null, "HomePage.Clients")
                ? "clients".tr
                : perm.check(null, "HomePage.MainTransferPage")
                    ? "transfer".tr
                    : "favorite".tr,
        icon: deliveryWorkspace
            ? Icons.view_in_ar_rounded
            : perm.check(null, "HomePage.Clients")
                ? Icons.groups_rounded
                : perm.check(null, "HomePage.MainTransferPage")
                    ? Icons.local_shipping_rounded
                    : Icons.favorite_rounded,
      ),
      _DrawerItem(
        label: perm.check(null, "HomePage.MainTrackingOrder")
            ? "tracking".tr
            : perm.check(null, "HomePage.MainDeliveryPage")
                ? "delivery".tr
                : "activity".tr,
        icon: perm.check(null, "HomePage.MainTrackingOrder")
            ? Icons.route_rounded
            : perm.check(null, "HomePage.MainDeliveryPage")
                ? Icons.delivery_dining_rounded
                : Icons.access_time_filled_rounded,
      ),
      _DrawerItem(
        label: deliveryWorkspace ? "Trajets" : "products".tr,
        icon:
            deliveryWorkspace ? Icons.route_rounded : Icons.inventory_2_rounded,
      ),
      _DrawerItem(label: "settings".tr, icon: Icons.person_rounded),
    ];
  }

  bool _isDeliveryWorkspace() {
    if (_usesWorkspaceMvp()) {
      return false;
    }

    return perm.check(null, "HomePage.MainDeliveryPage") &&
        !perm.check(null, "HomePage.MainTrackingOrder") &&
        !perm.check(null, "HomePage.Clients") &&
        !perm.check(null, "HomePage.MainTransferPage");
  }

  bool _usesWorkspaceMvp() {
    return const {
      "superadmin",
      "distributeur",
      "depot",
      "livreur",
      "point_vente",
    }.contains(perm.workspaceType.value);
  }

  List<_WorkspaceTab> _workspaceTabs() {
    switch (perm.workspaceType.value) {
      case "superadmin":
        return const [
          _WorkspaceTab(
            section: "dashboard",
            label: "Accueil",
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _WorkspaceTab(
            section: "distributors",
            label: "Distributeurs",
            icon: Icons.business_outlined,
            selectedIcon: Icons.business_rounded,
          ),
          _WorkspaceTab(
            section: "actors",
            label: "Acteurs",
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups_rounded,
          ),
          _WorkspaceTab(
            section: "products",
            label: "Produits",
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2_rounded,
          ),
          _WorkspaceTab(
            section: "profile",
            label: "Profil",
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case "distributeur":
        return const [
          _WorkspaceTab(
            section: "dashboard",
            label: "Accueil",
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _WorkspaceTab(
            section: "actors",
            label: "Acteurs",
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups_rounded,
          ),
          _WorkspaceTab(
            section: "warehouses",
            label: "Depots",
            icon: Icons.warehouse_outlined,
            selectedIcon: Icons.warehouse_rounded,
          ),
          _WorkspaceTab(
            section: "products",
            label: "Produits",
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2_rounded,
          ),
          _WorkspaceTab(
            section: "profile",
            label: "Profil",
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case "depot":
        return const [
          _WorkspaceTab(
            section: "dashboard",
            label: "Accueil",
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _WorkspaceTab(
            section: "prepare_orders",
            label: "Preparations",
            icon: Icons.fact_check_outlined,
            selectedIcon: Icons.fact_check_rounded,
          ),
          _WorkspaceTab(
            section: "loadings",
            label: "Chargements",
            icon: Icons.local_shipping_outlined,
            selectedIcon: Icons.local_shipping_rounded,
          ),
          _WorkspaceTab(
            section: "warehouse_stock",
            label: "Stock",
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2_rounded,
          ),
          _WorkspaceTab(
            section: "profile",
            label: "Profil",
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case "livreur":
        return const [
          _WorkspaceTab(
            section: "dashboard",
            label: "Accueil",
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _WorkspaceTab(
            section: "stock_mobile",
            label: "Stock",
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2_rounded,
          ),
          _WorkspaceTab(
            section: "delivery",
            label: "Delivery",
            icon: Icons.local_shipping_outlined,
            selectedIcon: Icons.local_shipping_rounded,
          ),
          _WorkspaceTab(
            section: "routes",
            label: "Trajets",
            icon: Icons.route_outlined,
            selectedIcon: Icons.route_rounded,
          ),
          _WorkspaceTab(
            section: "profile",
            label: "Profil",
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case "point_vente":
        return const [
          _WorkspaceTab(
            section: "dashboard",
            label: "Accueil",
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _WorkspaceTab(
            section: "catalog",
            label: "Catalogue",
            icon: Icons.storefront_outlined,
            selectedIcon: Icons.storefront_rounded,
          ),
          _WorkspaceTab(
            section: "cart",
            label: "Panier",
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart_rounded,
          ),
          _WorkspaceTab(
            section: "my_orders",
            label: "Commandes",
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
          ),
          _WorkspaceTab(
            section: "profile",
            label: "Profil",
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      default:
        return const [];
    }
  }

  List<NavigationDestination> _bottomDestinations() {
    if (_usesWorkspaceMvp()) {
      return _workspaceTabs()
          .map(
            (tab) => NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
          )
          .toList();
    }

    return [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: "dashboard".tr,
      ),
      _secondDestination(),
      _thirdDestination(),
      _fourthDestination(),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: "settings".tr,
      ),
    ];
  }

  List<NavigationRailDestination> _railDestinations() {
    if (_usesWorkspaceMvp()) {
      return _workspaceTabs()
          .map(
            (tab) => NavigationRailDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: Text(tab.label),
            ),
          )
          .toList();
    }

    return [
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: Text("dashboard".tr),
      ),
      _secondRailDestination(),
      _thirdRailDestination(),
      _fourthRailDestination(),
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text("settings".tr),
      ),
    ];
  }

  NavigationDestination _secondDestination() {
    if (_isDeliveryWorkspace()) {
      return const NavigationDestination(
        icon: Icon(Icons.view_in_ar_outlined),
        selectedIcon: Icon(Icons.view_in_ar_rounded),
        label: "Stock",
      );
    }
    if (perm.check(null, "HomePage.Clients")) {
      return NavigationDestination(
        icon: const Icon(Icons.groups_outlined),
        selectedIcon: const Icon(Icons.groups_rounded),
        label: "clients".tr,
      );
    }
    if (perm.check(null, "HomePage.MainTransferPage")) {
      return NavigationDestination(
        icon: const Icon(Icons.local_shipping_outlined),
        selectedIcon: const Icon(Icons.local_shipping_rounded),
        label: "transfer".tr,
      );
    }
    return NavigationDestination(
      icon: const Icon(Icons.favorite_border_rounded),
      selectedIcon: const Icon(Icons.favorite_rounded),
      label: "favorite".tr,
    );
  }

  NavigationDestination _thirdDestination() {
    if (perm.check(null, "HomePage.MainTrackingOrder")) {
      return NavigationDestination(
        icon: const Icon(Icons.route_outlined),
        selectedIcon: const Icon(Icons.route_rounded),
        label: "tracking".tr,
      );
    }
    if (perm.check(null, "HomePage.MainDeliveryPage")) {
      return NavigationDestination(
        icon: const Icon(Icons.delivery_dining_outlined),
        selectedIcon: const Icon(Icons.delivery_dining_rounded),
        label: "delivery".tr,
      );
    }
    return NavigationDestination(
      icon: const Icon(Icons.access_time_outlined),
      selectedIcon: const Icon(Icons.access_time_filled_rounded),
      label: "activity".tr,
    );
  }

  NavigationDestination _fourthDestination() {
    if (_isDeliveryWorkspace()) {
      return const NavigationDestination(
        icon: Icon(Icons.route_outlined),
        selectedIcon: Icon(Icons.route_rounded),
        label: "Trajets",
      );
    }
    return NavigationDestination(
      icon: const Icon(Icons.inventory_2_outlined),
      selectedIcon: const Icon(Icons.inventory_2_rounded),
      label: "products".tr,
    );
  }

  NavigationRailDestination _secondRailDestination() {
    if (_isDeliveryWorkspace()) {
      return const NavigationRailDestination(
        icon: Icon(Icons.view_in_ar_outlined),
        selectedIcon: Icon(Icons.view_in_ar_rounded),
        label: Text("Stock"),
      );
    }
    if (perm.check(null, "HomePage.Clients")) {
      return NavigationRailDestination(
        icon: const Icon(Icons.groups_outlined),
        selectedIcon: const Icon(Icons.groups_rounded),
        label: Text("clients".tr),
      );
    }
    if (perm.check(null, "HomePage.MainTransferPage")) {
      return NavigationRailDestination(
        icon: const Icon(Icons.local_shipping_outlined),
        selectedIcon: const Icon(Icons.local_shipping_rounded),
        label: Text("transfer".tr),
      );
    }
    return NavigationRailDestination(
      icon: const Icon(Icons.favorite_border_rounded),
      selectedIcon: const Icon(Icons.favorite_rounded),
      label: Text("favorite".tr),
    );
  }

  NavigationRailDestination _thirdRailDestination() {
    if (perm.check(null, "HomePage.MainTrackingOrder")) {
      return NavigationRailDestination(
        icon: const Icon(Icons.route_outlined),
        selectedIcon: const Icon(Icons.route_rounded),
        label: Text("tracking".tr),
      );
    }
    if (perm.check(null, "HomePage.MainDeliveryPage")) {
      return NavigationRailDestination(
        icon: const Icon(Icons.delivery_dining_outlined),
        selectedIcon: const Icon(Icons.delivery_dining_rounded),
        label: Text("delivery".tr),
      );
    }
    return NavigationRailDestination(
      icon: const Icon(Icons.access_time_outlined),
      selectedIcon: const Icon(Icons.access_time_filled_rounded),
      label: Text("activity".tr),
    );
  }

  NavigationRailDestination _fourthRailDestination() {
    if (_isDeliveryWorkspace()) {
      return const NavigationRailDestination(
        icon: Icon(Icons.route_outlined),
        selectedIcon: Icon(Icons.route_rounded),
        label: Text("Trajets"),
      );
    }
    return NavigationRailDestination(
      icon: const Icon(Icons.inventory_2_outlined),
      selectedIcon: const Icon(Icons.inventory_2_rounded),
      label: Text("products".tr),
    );
  }
}

class _DrawerItem {
  final String label;
  final IconData icon;

  const _DrawerItem({required this.label, required this.icon});
}

class _WorkspaceTab {
  final String section;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _WorkspaceTab({
    required this.section,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _PushSalesDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<_DrawerItem> destinations;

  const _PushSalesDrawer({
    required this.selectedIndex,
    required this.onSelect,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final compteController = Get.isRegistered<CompteMenuController>()
        ? Get.find<CompteMenuController>()
        : null;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: AppColors.primaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: compteController?.actor?.image != null
                        ? NetworkImage(compteController!.actor!.image)
                        : null,
                    child: compteController?.actor?.image == null
                        ? const Icon(Icons.person_rounded,
                            color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          compteController?.actor == null
                              ? "Push Sales"
                              : "${compteController!.actor!.firstname} ${compteController.actor!.lastname}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          compteController?.actor == null
                              ? "Mobile"
                              : compteController!.actor!.mail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final item = destinations[index];
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      selected: selected,
                      selectedTileColor: Colors.white.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      leading: Icon(
                        item.icon,
                        color: selected ? Colors.white : Colors.white70,
                      ),
                      title: Text(
                        item.label,
                        style: AppTextStyles.body.copyWith(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      onTap: () => onSelect(index),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                leading: const Icon(Icons.logout_rounded, color: Colors.white),
                title: Text(
                  "disconnect".tr,
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                onTap: SessionService.logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
