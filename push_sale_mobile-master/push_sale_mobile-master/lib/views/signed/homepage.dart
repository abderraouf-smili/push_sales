import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/views/signed/comptesetting.dart';
import 'package:push_sale/views/signed/menu/clients.dart';
import 'package:push_sale/views/signed/menu/favorite.dart';
import 'package:push_sale/views/signed/menu/stats_page.dart';
import 'package:push_sale/views/signed/widgets/delivery/main_delivery_page.dart';
import 'package:push_sale/views/signed/widgets/products/product_main_page.dart';
import 'package:push_sale/views/signed/widgets/tracking/main_tracking_page.dart';
import 'package:push_sale/views/signed/widgets/transfert/main_transfer_page.dart';

class HomePage extends StatefulWidget {
  int index;

  HomePage({Key? key, required this.index}) : super(key: key);

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
          extendBody: true,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Obx(
            () => CurvedNavigationBar(
              index: _index,
              height: 55,
              animationDuration: Duration(milliseconds: 300),
              // color: Colors.transparent,
              // buttonBackgroundColor: Colors.green,
              backgroundColor: Colors.transparent,
              color: perm.PermissionLoaded.value
                  ? Colors.blue
                  : Colors.transparent,
              buttonBackgroundColor: Color.fromARGB(255, 197, 110, 83),
              items: <Widget>[
                Icon(Icons.home_outlined, size: 30, color: Colors.white),
                perm.check(null, "HomePage.Clients")
                    ? Icon(Icons.groups_outlined, size: 30, color: Colors.white)
                    : perm.check(null, "HomePage.Delivery")
                        ? Icon(Icons.shopping_cart_rounded,
                            size: 30, color: Colors.white)
                        : Icon(Icons.access_time_outlined,
                            size: 30, color: Colors.white),
                perm.check(null, "HomePage.MainTrackingOrder")
                    ? Icon(Icons.track_changes, size: 30, color: Colors.white)
                    : perm.check(null, "HomePage.MainDeliveryPage")
                        ? Icon(Icons.local_shipping_outlined,
                            size: 30, color: Colors.white)
                        : Icon(Icons.mic_none_outlined,
                            size: 30, color: Colors.white),
                Icon(Icons.category_outlined, size: 30, color: Colors.white),
                const Icon(Icons.person_outline_outlined,
                    size: 30, color: Colors.white),
              ],

              onTap: (index) {
                setState(() {
                  _index = index;
                });
              },
            ),
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
                        : Favorite(),
                perm.check(null, "HomePage.MainTrackingOrder")
                    //for the prevente profile
                    ? MainTrackingOrder()
                    : perm.check(null, "HomePage.MainDeliveryPage")
                        // for delivery profile
                        ? MainDeliveryPage()
                        : Favorite(),
                perm.check(ProductMainPage(), "HomePage.ProductMainPage"),
                perm.check(CompteSetting(), "HomePage.CompteSetting"),
              ];
              return Column(children: [screen[_index]]);
            } else {
              return SizedBox.shrink();
            }
          }),
        ),
      ),
    );
  }
}
