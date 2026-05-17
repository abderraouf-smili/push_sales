import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/product_controller.dart';
// import 'package:push_sale/views/signed/widgets/products/item_big_icon.dart';

class ProductMainPage extends StatelessWidget {
  @override
  ProductController productController = Get.put(ProductController());

  ProductMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    productController.client = null;
    productController.getProducts();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SizedBox(
        width: Get.width,
        height: Get.height - 89,
        child: Column(
          children: [
            Container(
              height: 50,
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: const Color.fromARGB(255, 214, 214, 214),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(
              height: (Get.height - 143),
              width: Get.width,
              child: Obx(
                () => ListView.builder(
                    itemCount:
                        (productController.loadProductReady.value ? 1 : 0) *
                            productController.listProducts.length,
                    itemBuilder: (Context, index) {
                      var item = productController.listProducts[index];
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: Get.width,
                            height: (Get.height / 4 - Get.height / 5),
                            // decoration:
                            //     BoxDecoration(border: Border.all(width: 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.getLongDescription(
                                      Get.deviceLocale!.languageCode),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text("Plus..."),
                              ],
                            ),
                          ),
                          Container(
                            width: Get.width,
                            height: Get.height / 5,
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1)),
                            ),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: item.purchasevariants!.length,
                                itemBuilder: (Context, index) {
                                  var element = item.purchasevariants![index];
                                  return SizedBox(
                                    width: Get.height / 4,
                                    height: Get.height / 4,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          width: Get.width / 3,
                                          height: Get.height / 8,
                                          child: CachedNetworkImage(
                                            cacheManager: CacheManager(
                                              Config(
                                                element.image,
                                                stalePeriod:
                                                    const Duration(days: 7),
                                              ),
                                            ),
                                            imageUrl: element.image,
                                            placeholder: (context, url) =>
                                                Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 50,
                                                      vertical: 40),
                                              child:
                                                  const CircularProgressIndicator(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          child: Text(
                                            "${element.getVariantName1(Get.deviceLocale!.languageCode)} ${element.getVariantName2(Get.deviceLocale!.languageCode)}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          )
                        ],
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*
GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: productController.listCatalogue.length *
                    (productController.CatalogueReady.value ? 1 : 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.9),
                itemBuilder: (context, index) {
                  var item = productController.listCatalogue[index];
                  return ItemBigIcon(item);
                },
              )
*/
