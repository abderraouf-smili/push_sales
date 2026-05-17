import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/stock_operation_controller.dart';

class ShowDetailTransfer extends StatelessWidget {
  StockOperationController stockController = Get.find();
  PageController pageController;
  ShowDetailTransfer(this.pageController, {super.key});
  //
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height - 250,
      child: Column(
        children: [
          Container(
            height: 50,
            width: Get.width,
            color: const Color.fromARGB(255, 170, 217, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 30,
                  child: IconButton(
                      onPressed: () {
                        pageController.jumpToPage(1);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                ),
                SizedBox(
                  width: Get.width - 30,
                  child: Center(
                    child: Text(
                      stockController.itemSelected!.code!,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: Get.height - 255,
            child: ListView.builder(
                itemCount: stockController.itemSelected!.items.length,
                itemBuilder: (context, index) {
                  var item = stockController.itemSelected!.items[index];

                  return Obx(
                    () => ListTile(
                      title: Text(
                        item.product_name,
                        style: TextStyle(
                            color: stockController.stock_out.value &&
                                    stockController.unvalaibleProduct
                                        .where(((element) =>
                                            element["id"] == item.variant_id))
                                        .isNotEmpty
                                ? Colors.red
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
                      subtitle: Text("${item.variant_1} ${item.variant_2}",
                          style: TextStyle(
                              color: stockController.stock_out.value &&
                                      stockController.unvalaibleProduct
                                          .where(((element) =>
                                              element["id"] == item.variant_id))
                                          .isNotEmpty
                                  ? Colors.red
                                  : null)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              item.quantity ~/ item.package != 0
                                  ? "${(item.quantity ~/ item.package).toStringAsFixed(0)} Cart"
                                  : "",
                              style: TextStyle(
                                  color: stockController.stock_out.value &&
                                          stockController.unvalaibleProduct
                                              .where(((element) =>
                                                  element["id"] ==
                                                  item.variant_id))
                                              .isNotEmpty
                                      ? Colors.red
                                      : null)),
                          Text(
                              item.quantity % item.package != 0
                                  ? "${(item.quantity % item.package).toStringAsFixed(0)} Pcs"
                                  : "",
                              style: TextStyle(
                                  color: stockController.stock_out.value &&
                                          stockController.unvalaibleProduct
                                              .where(((element) =>
                                                  element["id"] ==
                                                  item.variant_id))
                                              .isNotEmpty
                                      ? Colors.red
                                      : null)),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
