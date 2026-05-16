// ignore_for_file: prefer_const_constructors

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/views/signed/widgets/commandes/fiche_product.dart';
import 'package:push_sale/views/signed/widgets/commandes/orderitem_list.dart';
import 'package:push_sale/views/signed/widgets/commandes/product_list.dart';

class Products extends StatelessWidget {
  final Client _client;
  Products(this._client);

  ProductController productController = Get.find();
  OrderController orderController = Get.put(OrderController());
  PageController pageController = PageController(initialPage: 1);
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    productController.getProducts();
    productController.page.value = 1;
    productController.filter = "";
    orderController.orderitems = [];
    orderController.orderId = null;
    orderController.saved.value = false;
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          switch (productController.page.value) {
            case 2:
              productController.selectedVariant = null;
              productController.opt1.value = false;
              productController.productSelected = null;
              productController.selectedVariantReady.value = false;
              pageController.jumpToPage(1);
              break;
            case 1:
              pageController.jumpToPage(0);
              break;
            default:
              if (orderController.orderitems.isNotEmpty) {
                if (orderController.saved.value) {
                  AwesomeDialog(
                      dialogType: DialogType.question,
                      title: "sure".tr,
                      body: Text("are.you.sure.to.quit.order".tr),
                      context: context,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        orderController.saved.value = false;
                        Get.back();
                      })
                    ..show();
                } else {
                  AwesomeDialog(
                      dialogType: DialogType.question,
                      title: "sure".tr,
                      body: Text("are.you.sure.to.ignore".tr),
                      context: context,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        orderController.saved.value = false;
                        Get.back();
                      })
                    ..show();
                }
              } else {
                orderController.saved.value = false;
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
              Container(
                color: const Color.fromARGB(255, 239, 247, 255),
                width: Get.width,
                height: Get.height - 40,
                child: PageView(
                  onPageChanged: ((value) {
                    productController.page.value = value;
                  }),
                  controller: pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    OrderitemList(_client, pageController),
                    Column(
                      children: [
                        Column(
                          children: [
                            // Search Bar
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide.none),
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 231, 244, 255),
                                          prefixIcon: const Icon(
                                            Icons.search_outlined,
                                            color: Color.fromARGB(
                                                255, 135, 201, 255),
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              productController.ready.value =
                                                  false;
                                              productController.filter = "";
                                              searchController.text = "";
                                              productController.ready.value =
                                                  true;
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              size: 16,
                                            ),
                                          ),
                                          hintText: "search".tr,
                                          hintStyle: const TextStyle(
                                              fontFamily: "alata",
                                              color: Color.fromARGB(
                                                  255, 135, 201, 255))),
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 231, 244, 255),
                                      border: Border.all(
                                        width: 0.5,
                                        color: const Color.fromARGB(
                                            255, 198, 230, 255),
                                      ),
                                      borderRadius:
                                          const BorderRadius.horizontal(
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
                                                productController.page.value ==
                                                        2
                                                    ? 1
                                                    : 0);
                                          },
                                          icon: Icon(Icons.arrow_back),
                                        ),
                                        Container(
                                          width: Get.width / 1.3,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              !productController.ready.value ||
                                                      productController
                                                          .listProducts
                                                          .where((element) => element
                                                              .getLongDescription(Get
                                                                  .locale!
                                                                  .languageCode)
                                                              .contains(
                                                                  productController
                                                                      .filter))
                                                          .toList()
                                                          .toList()
                                                          .isNotEmpty
                                                  ? const SizedBox.shrink()
                                                  : IconButton(
                                                      onPressed: () async {
                                                        productController.ready
                                                            .value = false;
                                                        await productController
                                                            .getProducts();
                                                        productController
                                                            .ready.value = true;
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .change_circle_outlined,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                              IconButton(
                                                onPressed: () {
                                                  productController.page.value =
                                                      0;
                                                  pageController.jumpToPage(0);
                                                },
                                                icon: Icon(
                                                  Icons.view_headline_rounded,
                                                  color: productController
                                                              .page.value ==
                                                          0
                                                      ? const Color.fromARGB(
                                                          255, 197, 110, 83)
                                                      : Colors.blue,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  productController.page.value =
                                                      1;
                                                  pageController.jumpToPage(1);
                                                },
                                                icon: Icon(
                                                  Icons.grid_view_rounded,
                                                  color: productController
                                                              .page.value ==
                                                          1
                                                      ? const Color.fromARGB(
                                                          255, 197, 110, 83)
                                                      : Colors.blue,
                                                  size: 23,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  productController.page.value =
                                                      2;
                                                  pageController.jumpToPage(2);
                                                },
                                                icon: Icon(
                                                  Icons.hive_sharp,
                                                  color: productController
                                                              .page.value ==
                                                          2
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
                            // Content Page
                            // Stack(children: [
                          ],
                        ),
                        Container(
                          child:
                              Obx(() => productController.loadProductReady.value
                                  ? Container(
                                      height: Get.height - 200,
                                      child: Obx(
                                        () => ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: productController
                                                    .ready.value
                                                ? productController.listProducts
                                                    .where((element) => element
                                                        .getLongDescription(Get
                                                            .locale!
                                                            .languageCode)
                                                        .toUpperCase()
                                                        .contains(
                                                            productController
                                                                .filter
                                                                .toUpperCase()))
                                                    .length
                                                : productController
                                                    .listProducts.length,
                                            itemBuilder: (context, index) {
                                              var item = productController
                                                      .ready.value
                                                  ? productController
                                                      .listProducts
                                                      .where((element) => element
                                                          .getLongDescription(
                                                              Get.locale!
                                                                  .languageCode)
                                                          .toUpperCase()
                                                          .contains(
                                                              productController
                                                                  .filter
                                                                  .toUpperCase()))
                                                      .toList()[index]
                                                  : productController
                                                      .listProducts[index];
                                              return productListWidget(
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
                                      child: CircularProgressIndicator(),
                                    )),
                        ),
                      ],
                    ),
                    Container(
                      child: FicheProduct(pageController),
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
