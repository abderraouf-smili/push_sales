import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';

class StockLocationPage extends StatelessWidget {
  final WarehouseController warehouseController = Get.find();

  StockLocationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => RefreshIndicator(
          onRefresh: warehouseController.getCurrentStockMobile,
          child: ListView.builder(
              // physics: BouncingScrollPhysics(),
              itemCount: warehouseController.currentStock.length *
                  (warehouseController.currentStockLoaded.value ? 1 : 0),
              itemBuilder: (context, index) {
                var item = warehouseController.currentStock[index];
                return Container(
                  child: ListTile(
                    title: Text(
                      item.getShortDescription(Get.deviceLocale!.languageCode),
                      style: TextStyle(
                          color: item.quantity != item.previsionnel
                              ? Colors.blue
                              : null),
                    ),
                    leading: CachedNetworkImage(
                      cacheManager: CacheManager(
                        Config(
                          item.image,
                          stalePeriod: const Duration(days: 7),
                        ),
                      ),
                      imageUrl: item.image,
                      placeholder: (context, url) => const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    subtitle: Text(
                      "${item.getVariantName1(Get.deviceLocale!.languageCode)} ${item.getVariantName2(Get.deviceLocale!.languageCode)}",
                      style: TextStyle(
                          color: item.quantity != item.previsionnel
                              ? Colors.blue
                              : null),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.quantity ~/ item.package != 0 ||
                                  item.previsionnel ~/ item.package != 0
                              ? "${item.previsionnel != item.quantity ? "${(item.quantity ~/ item.package).toStringAsFixed(0)} ➝ " : ""}${(item.previsionnel ~/ item.package).toStringAsFixed(0)} Cart"
                              : "",
                          style: TextStyle(
                              color: item.quantity != item.previsionnel
                                  ? Colors.blue
                                  : null),
                        ),
                        Text(
                          item.quantity % item.package != 0 ||
                                  item.previsionnel % item.package != 0
                              ? "${item.previsionnel != item.quantity ? "${(item.quantity % item.package).toStringAsFixed(0)} ➝ " : ""}${(item.previsionnel % item.package).toStringAsFixed(0)} Pcs"
                              : "",
                          style: TextStyle(
                              color: item.quantity != item.previsionnel
                                  ? Colors.blue
                                  : null),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ));
  }
}
