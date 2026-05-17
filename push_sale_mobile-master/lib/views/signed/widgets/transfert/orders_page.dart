import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';

class OrdersPage extends StatelessWidget {
  PurchaseOrderController purchaseController = Get.find();

  OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Column(
      children: [
        SizedBox(
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
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 0.5),
                      decoration: purchaseController.BLs.value
                              .where((element) => element == item.id)
                              .isNotEmpty
                          ? BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color:
                                      const Color.fromARGB(255, 185, 224, 255)),
                              borderRadius: BorderRadius.circular(5),
                              color: const Color.fromARGB(255, 239, 248, 255))
                          : BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color.fromARGB(255, 209, 209, 209),
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: const Color.fromARGB(255, 255, 255, 255)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
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
                              "${item.client!.address!.city.name} - ${item.client!.address!.wilaya.name}",
                            ),
                            Text(item.warehouse!.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))
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
                        trailing: SizedBox(
                          width: 90,
                          height: 45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatter.format(item.total_amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'alata')),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      item.orderitems.length.toString(),
                                      style: const TextStyle(
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
        const Divider(
          height: 0,
          thickness: 1,
        ),
        Obx(() {
          double total = 0;
          List<int> totalVar = [];
          purchaseController.ordersReadyToShip
              .where((element) => purchaseController.BLs.where(
                  (selected) => element.id == selected).isNotEmpty)
              .toList()
              .forEach((element) {
            total += element.total_amount;

            for (var item in element.orderitems) {
              if (totalVar
                  .where((variant) => variant == item.variant_id)
                  .isEmpty) {
                totalVar.add(item.variant_id);
              }
            }
          });

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: Get.width,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.category,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        totalVar.length.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt,
                        color: Colors.orange,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(purchaseController.BLs.value.length.toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/solde.png",
                        width: 24,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(formatter.format(total),
                          style: const TextStyle(
                              fontSize: 16, fontFamily: 'alata')),
                    ],
                  ),
                ]),
          );
        }),
      ],
    );
  }
}
