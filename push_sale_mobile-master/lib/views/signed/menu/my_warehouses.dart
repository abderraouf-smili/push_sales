import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/views/signed/widgets/warehouses/show_detail_warehouse.dart';
import 'package:push_sale/views/signed/widgets/warehouses/show_my_warehouses.dart';

class MyWarehouses extends StatelessWidget {
  final WarehouseController warehouseController =
      Get.put(WarehouseController());
  final PageController pageController = PageController();

  MyWarehouses({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            ShowMyWarehouses(pageController),
            ShowDetailWarehouse(pageController),
          ],
        ),
      ),
    );
  }
}
