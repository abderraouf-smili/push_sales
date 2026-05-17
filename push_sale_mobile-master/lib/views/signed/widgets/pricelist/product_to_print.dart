import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/pricelist_controller.dart';
import 'package:push_sale/models/pricelist.dart';
import 'package:push_sale/models/product.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProductToPrint extends StatelessWidget {
  PrinterController printerController = Get.put(PrinterController());
  PricelistController pricelistController = Get.find();

  ProductToPrint(this.item, {super.key});
  PriceList item;
  List<Product> products = [];
  final Map<int, int> count = {};
  @override
  Widget build(BuildContext context) {
    for (var element in item.items) {
      if (element.variant != null &&
          !products.any((pro) => pro.id == element.variant!.product!.id)) {
        products.add(element.variant!.product!);
      }
    }

    for (var itm in item.items) {
      if (itm.variant != null) {
        final int productId = itm.variant!.product!.id;

        if (count.containsKey(productId)) {
          count[productId] = count[productId]! + 1;
        } else {
          count[productId] = 1;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("product.list.title".tr),
      ),
      body: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            Product pro = products[index];
            return ListTile(
              title:
                  Text(pro.getShortDescription(Get.deviceLocale!.languageCode)),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CachedNetworkImage(
                  cacheManager: CacheManager(
                    Config(
                      pro.image,
                      stalePeriod: const Duration(days: 7),
                    ),
                  ),
                  imageUrl: pro.image,
                  placeholder: (context, url) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 40),
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              subtitle: Text("${count[pro.id]} elements"),
              trailing: showMenuPrint(pro),
            );
          }),
    );
  }

  PopupMenuButton showMenuPrint(Product pro) {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 0:
            {
              Map<String, dynamic> lines = {};
              for (var element in item.items) {
                if (element.variant != null &&
                    element.variant!.product!.id == pro.id) {
                  lines["${element.variant!.variant1_fr} ${element.variant!.variant2_fr}"] =
                      element.price;
                }
              }
              pricelistController.PrepareToPrintListing(
                  pro.getLongDescription(Get.deviceLocale!.languageCode),
                  lines);
              printerController.StartPrinting(pricelistController.textPrint);
            }
            break;
        }
      },
      elevation: 5,
      icon: const Icon(Icons.menu),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 0,
            enabled: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("print.prices".tr),
                const Icon(Icons.list_alt_sharp, color: Colors.blue),
              ],
            ),
          ),
        ];
      },
    );
  }
}
