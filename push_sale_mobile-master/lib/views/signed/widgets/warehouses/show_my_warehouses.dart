import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/warehouse.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/widgets/common/app_empty_state.dart';

class ShowMyWarehouses extends StatelessWidget {
  ShowMyWarehouses(this.pageController, {super.key});
  final WarehouseController warehouseController = Get.find();
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    warehouseController.getWarehouses();
    return Scaffold(
      appBar: AppBar(
        title: Text("mywarehouses".tr),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!warehouseController.ready.value) {
          return const Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (warehouseController.warehouses.isEmpty) {
          return AppEmptyState(
            icon: Icons.warehouse_outlined,
            title: "mywarehouses".tr,
            message: "Aucun depot de test disponible.",
          );
        }

        return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: warehouseController.warehouses.length,
            itemBuilder: (context, index) {
              var item = warehouseController.warehouses[index];
              return GestureDetector(
                  onTap: () {
                    warehouseController.warehouse = item;
                    pageController.jumpToPage(1);
                  },
                  child: WarehouseLine(item));
            });
      }),
    );
  }
}

class WarehouseLine extends StatelessWidget {
  final Warehouse warehouse;
  const WarehouseLine(this.warehouse, {super.key});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(
            width: 0.5,
            color: const Color.fromARGB(255, 150, 208, 255),
          ),
          color: const Color.fromARGB(255, 245, 250, 255)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                warehouse.address.city.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontFamily: 'alata'),
              ),
              Text(warehouse.address.wilaya.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontFamily: 'alata')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                warehouse.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                formatter.format(warehouse.total),
                style: const TextStyle(fontSize: 18, fontFamily: 'alata'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${warehouse.items.length}",
                    style: const TextStyle(
                        fontFamily: 'alata', fontSize: 22, color: Colors.blue),
                  ),
                ],
              ),
              warehouse.items
                      .where((element) =>
                          element.quantity / element.package <=
                          global.alertQuantity)
                      .isNotEmpty
                  ? Row(
                      children: [
                        const Icon(
                          Icons.notification_important_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          warehouse.items
                              .where((element) =>
                                  (element.quantity / element.package) <=
                                  global.alertQuantity)
                              .length
                              .toString(),
                          style: const TextStyle(
                              fontFamily: 'alata',
                              fontSize: 22,
                              color: Colors.red),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          )
        ],
      ),
    );
  }
}
