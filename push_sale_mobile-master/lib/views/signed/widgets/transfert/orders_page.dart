import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';

class OrdersPage extends StatelessWidget {
  PurchaseOrderController purchaseController = Get.find();

  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return Column(
      children: [
        Container(
          width: Get.width,
          height: Get.height - 255,
          child: RefreshIndicator(
            onRefresh: purchaseController.getOrderReadyToPack,
            child: Obx(
              () => ListView.builder(
                itemCount: purchaseController.ordersReadyToShip.length *
                    (purchaseController.orts_loaded.value ? 1 : 0),
                itemBuilder: (context, index) {
                  var item = purchaseController.ordersReadyToShip[index];
                  return Obx(() {
                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                      decoration: purchaseController.BLs.value
                              .where((element) => element == item.id)
                              .isNotEmpty
                          ? BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Color.fromARGB(255, 185, 224, 255)),
                              borderRadius: BorderRadius.circular(5),
                              color: Color.fromARGB(255, 239, 248, 255))
                          : BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color.fromARGB(255, 209, 209, 209),
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: Color.fromARGB(255, 255, 255, 255)),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        onTap: () {
                          if (purchaseController.selectedOrders
                              .where((element) => element.id == item.id)
                              .isEmpty) {
                            purchaseController.selectedOrders.add(item);
                          } else {
                            purchaseController.selectedOrders.removeWhere(
                                (element) => element.id == item.id);
                          }
                          purchaseController.BLs.value = List.from(
                              purchaseController.selectedOrders
                                  .map((e) => e.id)
                                  .toList());
                        },
                        title: Container(child: Text(item.client!.name)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.client!.address!.city.name +
                                  " - " +
                                  item.client!.address!.wilaya.name,
                            ),
                            Text(item.warehouse!.name,
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ],
                        ),
                        leading: Container(
                          // margin: EdgeInsets.symmetric(horizontal: 5),
                          width: Get.width / 5,
                          // height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                item.client!.image,
                                cacheKey: item.client!.image,
                              ),
                            ),
                          ),
                        ),
                        trailing: Container(
                          width: 90,
                          height: 45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatter.format(item.total_amount),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alata')),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      item.orderitems.length.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
        Obx(() {
          double total = 0;
          List<int> total_var = [];
          purchaseController.ordersReadyToShip
              .where((element) => purchaseController.BLs.where(
                  (selected) => element.id == selected).isNotEmpty)
              .toList()
              .forEach((element) {
            total += element.total_amount;

            for (var item in element.orderitems) {
              if (total_var
                  .where((variant) => variant == item.variant_id)
                  .isEmpty) {
                total_var.add(item.variant_id);
              }
            }
          });

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: Get.width,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        total_var.length.toString(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        color: Colors.orange,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(purchaseController.BLs.value.length.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/solde.png",
                        width: 24,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(formatter.format(total),
                          style: TextStyle(fontSize: 16, fontFamily: 'alata')),
                    ],
                  ),
                ]),
          );
        }),
      ],
    );
  }
}
