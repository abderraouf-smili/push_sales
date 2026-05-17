import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/order.dart';

class OrdersStatusDetail extends StatelessWidget {
  String state;
  OrderController orderController = Get.find();
  OrdersStatusDetail(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    orderController.getOrdersByStatus(state);
    double total = 0;

    return Scaffold(
        appBar: AppBar(
          title: Text("${"orders.to.track".tr} ${("state.$state").tr}"),
          centerTitle: true,
        ),
        body: Obx(() {
          if (orderController.status_orders_loaded.value) {
            for (var _o in orderController.status_orders) {
              for (var item in _o.purchase_orders!) {
                total += item.total_amount;
              }
            }
          }
          return orderController.status_orders_loaded.value
              ? Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 500,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(" "),
                          const Text(" "),
                          Text(orderController.status_orders_loaded.value
                              ? formatter.format(total)
                              : ""),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.height - 140,
                      child: Container(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: orderController.status_orders.length,
                          itemBuilder: (context, index) {
                            Order item = orderController.status_orders[index];
                            return itemOrderStatus(item);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  width: Get.width,
                  height: Get.height,
                  margin: EdgeInsets.symmetric(
                      horizontal: Get.width / 2 - 30,
                      vertical: Get.height / 2 - 75),
                  child: const CircularProgressIndicator(),
                );
        }));
  }
}

class itemOrderStatus extends StatelessWidget {
  Order order;
  itemOrderStatus(this.order, {super.key});
  OrderController orderController = Get.find();

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    double total = 0.0;
    for (var item in order.purchase_orders!) {
      total += item.total_amount;
    }
    return GestureDetector(
      onLongPress: () {
        if (order.purchase_orders![0].state == "expired") {
          showMenuExpired(context, order, orderController);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 173, 218, 255),
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        width: Get.width,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              width: Get.width / 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 165, 165, 165),
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                      order.client!.image,
                      cacheKey: order.client!.image,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: Get.width - Get.width / 3.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    // width: Get.width * 2 / 3,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    // color: Colors.greenAccent,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.client!.name,
                          style: const TextStyle(
                              fontFamily: "alata", fontSize: 17),
                        ),
                        Text(
                          DateFormat('dd/MM/y', Get.locale!.languageCode)
                              .format(order.order_date),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(order.code,
                            style: const TextStyle(
                                fontFamily: "alata", color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    // color: Colors.green,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(formatter.format(total),
                            style: const TextStyle(
                                fontFamily: "alata", fontSize: 12))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMenuExpired(
      BuildContext context, Order order, OrderController orderController) {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return AlertDialog(
            contentPadding: const EdgeInsets.only(left: 30, right: 30, top: 15),
            titlePadding: EdgeInsets.zero,
            title: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 43, 87, 124),
              ),
              width: double.infinity,
              height: 50,
              child: Center(
                child: Text(
                  order.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            content: SizedBox(
              width: double.infinity,
              height: 50,
              child: Text("renew.order.question".tr),
            ),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: Get.width * 0.75,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        minWidth: Get.width * 0.25,
                        color: Colors.red,
                        child: Text(
                          "cancel".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        minWidth: Get.width * 0.25,
                        color: Colors.blue,
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          await orderController.reNew(order.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ]),
              ),
            ],
          );
        });
  }
}
