import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/views/signed/comptesetting.dart';
import 'package:push_sale/views/signed/menu/clients.dart';
import 'package:push_sale/views/signed/menu/favorite.dart';
import 'package:push_sale/views/signed/menu/stats_page.dart';
import 'package:push_sale/views/signed/widgets/delivery/main_delivery_page.dart';
import 'package:push_sale/views/signed/widgets/products/product_main_page.dart';
import 'package:push_sale/views/signed/widgets/tracking/main_tracking_page.dart';
import 'package:push_sale/views/signed/widgets/transfert/main_transfer_page.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';

class HomePage extends StatefulWidget {
  int index;

  HomePage({super.key, required this.index});

  @override
  State<HomePage> createState() => _HomePageState(index);
}

class _HomePageState extends State<HomePage> {
  PermissionsController perm = Get.put(PermissionsController());
  _HomePageState(this._index);
  int _index;

  @override
  Widget build(BuildContext context) {
    var screen = [];

    if (Get.arguments != null && Get.arguments["client_id"] != "0") {
      _index = 1;
      Get.arguments["client_id"] = "0";
      setState(() {});
    }
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Obx(
            () => perm.PermissionLoaded.value
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
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.dashboard_outlined),
                        selectedIcon: const Icon(Icons.dashboard_rounded),
                        label: "dashboard".tr,
                      ),
                      _secondDestination(),
                      _thirdDestination(),
                      NavigationDestination(
                        icon: const Icon(Icons.inventory_2_outlined),
                        selectedIcon: const Icon(Icons.inventory_2_rounded),
                        label: "products".tr,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.person_outline_rounded),
                        selectedIcon: const Icon(Icons.person_rounded),
                        label: "settings".tr,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          body: Obx(() {
            if (perm.PermissionLoaded.value) {
              screen = [
                perm.check(StatsPage(), "HomePage.StatsPage"),
                perm.check(null, "HomePage.Clients")
                    //for the prevente/classic profile
                    ? Clients(Get.arguments != null
                        ? Get.arguments["client_id"]
                        : "0")
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
                perm.check(ProductMainPage(), "HomePage.ProductMainPage"),
                perm.check(CompteSetting(), "HomePage.CompteSetting"),
              ];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: screen[_index] as Widget,
              );
            } else {
              return AppLoadingState(message: "loading".tr);
            }
          }),
        ),
      ),
    );
  }

  NavigationDestination _secondDestination() {
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
}
