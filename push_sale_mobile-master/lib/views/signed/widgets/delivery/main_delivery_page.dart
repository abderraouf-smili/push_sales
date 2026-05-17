import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/views/signed/widgets/delivery/orders_to_ship.dart';
import 'package:push_sale/views/signed/widgets/delivery/shipping_order_detail.dart';

class MainDeliveryPage extends StatelessWidget {
  final PageController pageController = PageController();
  final OrderController orderController =
      Get.put(OrderController(tag: "shipping"));

  MainDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: (value) {
              orderController.page.value = value;
            },
            children: [
              OrdersToShip(pageController),
              ShippingOrderDetail(pageController),
            ],
          ),
        ),
        Obx(
          () => orderController.addRestantProducts.value &&
                  orderController.page.value == 1 &&
                  (orderController.selectedPO != null &&
                      orderController.selectedPO!.state == 'in_way') &&
                  orderController.restant.isNotEmpty
              ? Positioned(
                  bottom: 16,
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
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

showRestantProduct(BuildContext context, OrderController orderController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.only(top: 15),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: const BoxDecoration(
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
                  style: const TextStyle(color: Colors.white, fontSize: 18),
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
