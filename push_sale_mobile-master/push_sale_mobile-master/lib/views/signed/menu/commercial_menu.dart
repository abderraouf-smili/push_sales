import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/views/signed/widgets/actors/actors_list.dart';
import 'package:push_sale/views/signed/widgets/coupons/coupons_list.dart';
import 'package:push_sale/views/signed/widgets/creances/main_creance_page.dart';
import 'package:push_sale/views/signed/widgets/credit/main_credit_page.dart';
import 'package:push_sale/views/signed/widgets/pricelist/pricelist_page.dart';
import 'package:push_sale/views/signed/widgets/promotions/promotions_list.dart';

class CommercialMenu extends StatelessWidget {
  PermissionsController perm = Get.find();
  List<dynamic> menu = [];
  @override
  Widget build(BuildContext context) {
    menu = [
      {
        "title": "my.listing".tr,
        "subtitle": "list.prices".tr,
        "icon": Icons.price_change,
        "color": Color.fromARGB(255, 13, 116, 4),
        "onTap": () {
          Get.to(() => PricelistPage());
        }
      },
      perm.check(null, "admin")
          ? {
              "title": "my.actors".tr,
              "subtitle": "actor.config".tr,
              "icon": Icons.groups_outlined,
              "color": Color.fromARGB(255, 236, 116, 247),
              "onTap": () {
                Get.to(() => ActorsList());
              }
            }
          : null,
      perm.check(null, "admin")
          ? {
              "title": "my.coupons".tr,
              "subtitle": "coupons.config".tr,
              "icon": Icons.redeem,
              "color": Color.fromARGB(255, 172, 173, 75),
              "onTap": () {
                Get.to(() => CouponsList());
              }
            }
          : null,
      perm.check(null, "admin")
          ? {
              "title": "my.promotions".tr,
              "subtitle": "pormo.config".tr,
              "icon": Icons.local_offer,
              "color": Colors.teal,
              "onTap": () {
                Get.to(() => PromotionsList());
              }
            }
          : null,
      perm.check(null, "admin")
          ? {
              "title": "receivables".tr,
              "subtitle": "customers_balance".tr,
              "icon": Icons.paid_sharp,
              "color": Color.fromARGB(255, 174, 103, 231),
              "onTap": () {
                Get.to(() => MainCreancePage());
              }
            }
          : null,
                perm.check(null, "admin")
          ? {
              "title": "credit".tr,
              "subtitle": "customers_credit".tr,
              "icon": Icons.money,
              "color": Color.fromARGB(255, 242, 107, 94),
              "onTap": () {
                Get.to(() => MainCreditPage());
              }
            }
          : null,
    ];
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "commercial".tr,
            style: TextStyle(
                color: Color.fromARGB(255, 19, 21, 121),
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: Get.height - 204,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  return menu[index] != null
                      ? menu[index]["divider"] != null
                          ? Divider(
                              height: 10,
                              thickness: 1,
                              endIndent: 50,
                            )
                          : Container(
                              child: ListTile(
                                onTap: menu[index]["onTap"],
                                leading: Icon(
                                  menu[index]["icon"],
                                  color: menu[index]["color"],
                                  size: 30,
                                ),
                                title: Text(
                                  menu[index]["title"],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(menu[index]["subtitle"]),
                                trailing:
                                    Icon(Icons.arrow_forward_ios_outlined),
                              ),
                            )
                      : SizedBox.shrink();
                }),
          )
        ]),
      ),
    );
  }
}
