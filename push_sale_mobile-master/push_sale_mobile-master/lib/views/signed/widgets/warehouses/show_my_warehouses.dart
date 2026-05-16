import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/warehouse.dart';
import 'package:push_sale/const/globals.dart' as global;

class ShowMyWarehouses extends StatelessWidget {
  ShowMyWarehouses(this.pageController);
  WarehouseController warehouseController = Get.find();
  PageController pageController;

  @override
  Widget build(BuildContext context) {
    warehouseController.getWarehouses();
    return Scaffold(
      appBar: AppBar(
        title: Text("mywarehouses".tr),
        centerTitle: true,
      ),
      body: Obx(() => warehouseController.ready.value
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: warehouseController.warehouses.length,
              itemBuilder: (context, index) {
                var item = warehouseController.warehouses[index];
                return GestureDetector(
                    onTap: () {
                      warehouseController.warehouse = item;
                      pageController.jumpToPage(1);
                    },
                    child: warehouseLine(item));
              })
          : Center(
              child: Container(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            )),
    );
  }
}

class warehouseLine extends StatelessWidget {
  Warehouse warehouse;
  warehouseLine(this.warehouse);

  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");

    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.infinity,
      height: Get.height / 6,
      decoration: BoxDecoration(
          border: Border.all(
            width: 0.5,
            color: Color.fromARGB(255, 150, 208, 255),
          ),
          color: Color.fromARGB(255, 245, 250, 255)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                warehouse.address.city.name,
                style: TextStyle(fontSize: 18, fontFamily: 'alata'),
              ),
              Text(warehouse.address.wilaya.name,
                  style: TextStyle(fontSize: 18, fontFamily: 'alata')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                warehouse.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                formatter.format(warehouse.total),
                style: TextStyle(fontSize: 18, fontFamily: 'alata'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${warehouse.items.length}",
                    style: TextStyle(
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
                        Icon(
                          Icons.notification_important_rounded,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          warehouse.items
                              .where((element) =>
                                  (element.quantity / element.package) <=
                                  global.alertQuantity)
                              .length
                              .toString(),
                          style: TextStyle(
                              fontFamily: 'alata',
                              fontSize: 22,
                              color: Colors.red),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          )
        ],
      ),
    );
  }
}
