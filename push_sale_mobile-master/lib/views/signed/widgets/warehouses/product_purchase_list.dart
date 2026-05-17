import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/models/product.dart';

class ProductPurchaseList extends StatelessWidget {
  PrinterController printerController = Get.find();

  PurchaseOrderController purchaseController =
      Get.put(PurchaseOrderController());
  ProductController productController = Get.find();
  ProductPurchaseList(this.pageController, {super.key});
  PageController pageController;

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          switch (productController.page.value) {
            case 2:
              pageController.jumpToPage(1);
              break;
            case 1:
              pageController.jumpToPage(0);
              break;
            default:
              if (purchaseController.orderitems.isNotEmpty) {
                if (purchaseController.saved.value) {
                  AwesomeDialog(
                      dialogType: DialogType.question,
                      title: "sure".tr,
                      body: Text("are.you.sure.to.quit.order".tr),
                      context: context,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        purchaseController.saved.value = false;
                        Get.back();
                      }).show();
                } else {
                  AwesomeDialog(
                      dialogType: DialogType.question,
                      title: "sure".tr,
                      body: Text("are.you.sure.to.ignore".tr),
                      context: context,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        purchaseController.saved.value = false;
                        Get.back();
                      }).show();
                }
              } else {
                purchaseController.saved.value = false;
                Get.back();
              }
          }

          // avant de quitter l'écran
          return false; // Retourne true pour autoriser le retour
          // et false pour bloquer le retour
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          body: Column(
            children: [
              // Obx(
              //   () => productController.page.value == 1
              //       ?
              //       : productController.page.value == 2
              //           ? Container(
              //               width: double.infinity,
              //               child: Positioned(
              //                 left: 0,
              //                 child: IconButton(
              //                   icon: Icon(Icons.arrow_back),
              //                   onPressed: () {
              //                     pageController.jumpToPage(1);
              //                     productController.page.value = 1;
              //                     print("=====================>");
              //                   },
              //                 ),
              //               ),
              //             )
              //           : SizedBox.shrink(),
              // ),
              Container(
                color: const Color.fromARGB(255, 239, 247, 255),
                width: Get.width,
                height: Get.height - 40,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // entete search bar
                          SizedBox(
                            height: 40,
                            // margin: const EdgeInsets.only(right: 10),
                            width: Get.width - 20,
                            child: TextFormField(
                              controller: searchController,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontFamily: 'alata',
                              ),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 231, 244, 255),
                                  prefixIcon: const Icon(
                                    Icons.search_outlined,
                                    color: Color.fromARGB(255, 135, 201, 255),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      productController.ready.value = false;
                                      productController.filter = "";
                                      searchController.text = "";
                                      productController.ready.value = true;
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                  ),
                                  hintText: "search".tr,
                                  hintStyle: const TextStyle(
                                      fontFamily: "alata",
                                      color:
                                          Color.fromARGB(255, 135, 201, 255))),
                              onChanged: (value) {
                                productController.ready.value = false;
                                productController.filter = value;
                                productController.ready.value = true;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    //filter bar + mode view vbar
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: Column(
                        children: [
                          // view mode bar
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 231, 244, 255),
                              border: Border.all(
                                width: 0.5,
                                color: const Color.fromARGB(255, 198, 230, 255),
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(30)),
                            ),
                            width: double.infinity,
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    pageController.jumpToPage(
                                        productController.page.value == 2
                                            ? 1
                                            : 0);
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                Container(
                                  width: Get.width / 1.3,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      !productController.ready.value ||
                                              productController.listProducts
                                                  .where((element) => element
                                                      .long_description_fr
                                                      .contains(
                                                          productController
                                                              .filter))
                                                  .toList()
                                                  .toList()
                                                  .isNotEmpty
                                          ? const SizedBox.shrink()
                                          : IconButton(
                                              onPressed: () async {
                                                productController.ready.value =
                                                    false;
                                                await productController
                                                    .getProducts();
                                                productController.ready.value =
                                                    true;
                                              },
                                              icon: const Icon(
                                                Icons.change_circle_outlined,
                                                color: Colors.blue,
                                              ),
                                            ),
                                      IconButton(
                                        onPressed: () {
                                          productController.page.value = 0;
                                          pageController.jumpToPage(0);
                                        },
                                        icon: Icon(
                                          Icons.view_headline_rounded,
                                          color:
                                              productController.page.value == 0
                                                  ? const Color.fromARGB(
                                                      255, 197, 110, 83)
                                                  : Colors.blue,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          productController.page.value = 1;
                                          pageController.jumpToPage(1);
                                        },
                                        icon: Icon(
                                          Icons.grid_view_rounded,
                                          color:
                                              productController.page.value == 1
                                                  ? const Color.fromARGB(
                                                      255, 197, 110, 83)
                                                  : Colors.blue,
                                          size: 23,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          productController.page.value = 2;
                                          pageController.jumpToPage(2);
                                        },
                                        icon: Icon(
                                          Icons.hive_sharp,
                                          color:
                                              productController.page.value == 2
                                                  ? const Color.fromARGB(
                                                      255, 197, 110, 83)
                                                  : Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Obx(() => productController.loadProductReady.value
                          ? SizedBox(
                              height: Get.height - 200,
                              child: Obx(
                                () => ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: productController.ready.value
                                        ? productController.listProducts
                                            .where((element) => element
                                                .long_description_fr
                                                .toUpperCase()
                                                .contains(productController
                                                    .filter
                                                    .toUpperCase()))
                                            .length
                                        : productController.listProducts.length,
                                    itemBuilder: (context, index) {
                                      var item = productController.ready.value
                                          ? productController.listProducts
                                              .where((element) => element
                                                  .long_description_fr
                                                  .toUpperCase()
                                                  .contains(productController
                                                      .filter
                                                      .toUpperCase()))
                                              .toList()[index]
                                          : productController
                                              .listProducts[index];
                                      return PurchaseProductListWidget(
                                        item,
                                        pageController,
                                      );
                                    }),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width / 2 - 20,
                                  vertical: (Get.height / 2) - 80),
                              child: const CircularProgressIndicator(),
                            )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PurchaseProductListWidget extends StatelessWidget {
  ProductController productController = Get.find();

  Product product;
  PageController pageController;
  PurchaseProductListWidget(this.product, this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          productController.productSelected = product;
          productController.isProSelected.value = true;
          productController.page.value = 2;
          pageController.jumpToPage(2);
        },
        child: ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config(
                  product.image,
                  stalePeriod: const Duration(days: 7),
                ),
              ),
              imageUrl: product.image,
              placeholder: (context, url) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: const CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          title: Text(product.getShortDescription(Get.locale!.languageCode)),
          subtitle: Text(product.purchasevariants!.length.toString()),
        ),
      ),
    );
  }
}
