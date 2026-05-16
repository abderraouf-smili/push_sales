import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/views/signed/widgets/delivery/orders_to_ship.dart';
import 'package:push_sale/views/signed/widgets/delivery/shipping_order_detail.dart';
import 'package:push_sale/const/globals.dart' as global;

class MainDeliveryPage extends StatelessWidget {
  PageController pageController = PageController();
  OrderController orderController = Get.put(OrderController(tag: "shipping"));

  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        height: Get.height - 60,
        child: Column(children: [
          Container(
            width: double.infinity,
            height: Get.height - 60,
            child: Stack(children: [
              PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: (value) {
                  orderController.page.value = value;
                },
                children: [
                  OrdersToShip(pageController),
                  ShippingOrderDetail(pageController),
                ],
              ),
              Obx(
                () => orderController.addRestantProducts.value &&
                        orderController.page.value == 1 &&
                        (orderController.selectedPO != null &&
                            orderController.selectedPO!.state == 'in_way') &&
                        orderController.restant.length > 0
                    ? Positioned(
                        bottom: 55,
                        left: Get.deviceLocale!.languageCode == "ar"
                            ? Get.width / 2 - 27.5
                            : null,
                        right: Get.deviceLocale!.languageCode == "ar"
                            ? null
                            : Get.width / 2 - 27.5,
                        child: FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: () {
                            showRestantProduct(context, orderController);
                          },
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ]),
          ),
        ]));
  }
}

showRestantProduct(BuildContext context, OrderController orderController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.only(top: 15),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 43, 87, 124),
          ),
          width: double.infinity,
          height: Get.height / 4,
          child: Center(
            child: Container(
              width: Get.width,
              height: 50,
              color: Colors.blue,
              child: Center(
                child: Text(
                  "restant.product.sell".tr,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        content: Container(),
      );
    },
  );
}
