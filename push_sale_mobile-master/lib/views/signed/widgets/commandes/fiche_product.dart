// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/models/product.dart';
import 'package:push_sale/models/variant.dart';

class FicheProduct extends StatelessWidget {
  PageController pageController;
  FicheProduct(this.pageController, {super.key});

  ProductController productController = Get.find();
  OrderController orderController = Get.find();
  TextEditingController qtyController = TextEditingController();

  late Product product;
  @override
  Widget build(BuildContext context) {
    orderController.client = productController.client;
    if (orderController.orderId == null) {
      orderController.generateId();
      orderController.generateTrackId();
    }
    orderController.uniteItem.value = "Pcs";
    orderController.quantityItem.value = 1.0;
    qtyController.text = "1";
    productController.opt1.value = false;
    productController.selectedVariantReady.value = false;

    product = productController.productSelected!;

    List<Variant> variants = List.from(productController
        .getVariantsLowPrice()
        .where((article) => !orderController.orderitems
            .any((item) => item.variant_id == article.id))
        .toList());

    List<String> var1 = productController.getOption(variants, 1);
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Get.locale!.languageCode == "ar"
                ? Alignment.topRight
                : Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                productController.selectedVariant = null;
                productController.opt1.value = false;
                productController.productSelected = null;
                productController.selectedVariantReady.value = false;
                pageController.jumpToPage(1);
                productController.page.value = 1;
              },
            ),
          ),
        ),
        Obx(
          () => Stack(
            children: [
              Positioned(
                child: SizedBox(
                  width: double.infinity,
                  height: Get.height / 3.2,
                  child: CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config(
                        productController.selectedVariantReady.value
                            ? productController.selectedVariant!.image
                            : product.image,
                        stalePeriod: const Duration(days: 7),
                      ),
                    ),
                    imageUrl: productController.selectedVariantReady.value
                        ? productController.selectedVariant!.image
                        : product.image,
                    placeholder: (context, url) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Get.width / 2 - 25,
                            vertical: (Get.height / 3.2) / 2 - 25),
                        child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              productController.selectedVariantReady.value &&
                      productController.selectedVariant.discount > 0
                  ? Positioned(
                      top: 0,
                      right: 20,
                      child: Container(
                        child: Image.asset(
                          "assets/images/promo.png",
                          width: 100,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          height: Get.height / 2.23,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Obx(
                () => Container(
                  child: Row(
                    children: [
                      Text(
                        productController.selectedVariantReady.value
                            ? formatter.format(orderController
                                            .quantityItem.value *
                                        (orderController.uniteItem.value ==
                                                "Cart"
                                            ? productController
                                                .selectedVariant.package
                                            : 1) >=
                                    productController.selectedVariant.minimum
                                ? productController.selectedVariant!.price
                                : productController
                                    .selectedVariant!.original_price)
                            : product.showPrice!.toString(),
                        style: TextStyle(
                          fontFamily: 'alata',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      productController.selectedVariantReady.value &&
                              orderController.quantityItem.value *
                                      (orderController.uniteItem.value == "Cart"
                                          ? productController
                                              .selectedVariant.package
                                          : 1) >=
                                  productController.selectedVariant.minimum &&
                              productController.selectedVariant.discount != 0
                          ? Text(
                              ("(-${productController.selectedVariant.discount}%)"),
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              // Long description of article
              SizedBox(
                height: 40,
                child: Text(
                  product.getLongDescription(Get.locale!.languageCode),
                  style: TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
                ),
              ),
              //Premiere Option du Vartiant

              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                height: 30,
                child: Row(
                  children: [
                    Text(
                      variants.isNotEmpty
                          ? variants.first
                              .getOptionName1(Get.locale!.languageCode)
                          : "",
                      style: TextStyle(
                        color: Color.fromARGB(255, 88, 88, 88),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Obx(() => Text(
                          productController.opt1.value
                              ? " : " +
                                  productController.option1.first
                                      .getVariantName1(Get.locale!.languageCode)
                              : "",
                          style: TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 12),
                        ))
                  ],
                ),
              ),
              //Liste des variant 1
              variants.isNotEmpty
                  ? SizedBox(
                      width: Get.width,
                      height: 40.0 * (var1.length / 4).ceil(),
                      child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (var1.length / 4).ceil(),
                            childAspectRatio: 0.415,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemCount: var1.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                //
                                productController.opt1.value = false;
                                productController.selectedVariantReady.value =
                                    false;
                                productController.option1 = variants
                                    .where((element) =>
                                        element.getVariantName1(
                                            Get.locale!.languageCode) ==
                                        var1[index])
                                    .toList();
                                if (productController.option1.length == 1) {
                                  productController.selectedVariant =
                                      productController.option1.first;
                                  productController.selectedVariantReady.value =
                                      true;
                                }
                                productController.opt1.value = true;
                              },
                              child: Obx(() => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        width: 1,
                                        color: productController.opt1.value &&
                                                productController.option1.first
                                                        .getVariantName1(Get
                                                            .locale!
                                                            .languageCode) ==
                                                    var1[index]
                                            ? Color.fromARGB(255, 128, 145, 182)
                                            : Color.fromARGB(255, 205, 221, 253)
                                                .withOpacity(0.5),
                                      ),
                                      color: productController.opt1.value &&
                                              productController.option1.first
                                                      .getVariantName1(Get
                                                          .locale!
                                                          .languageCode) ==
                                                  var1[index]
                                          ? Color.fromARGB(255, 215, 228, 255)
                                          : Color.fromARGB(255, 244, 248, 255)
                                              .withOpacity(0.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        var1[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: productController.opt1.value &&
                                                  productController
                                                          .option1.first
                                                          .getVariantName1(Get
                                                              .locale!
                                                              .languageCode) ==
                                                      var1[index]
                                              ? Color.fromARGB(255, 16, 18, 112)
                                              : Color.fromARGB(
                                                  255, 98, 108, 196),
                                        ),
                                      ),
                                    ),
                                  )),
                            );
                          }),
                    )
                  : SizedBox.shrink(),
              // Deuxieme  Option du Vartiant s'elle existe
              Obx(
                () => !(productController.opt1.value &&
                        productController.option1.first
                                .getOptionName2(Get.locale!.languageCode) !=
                            "")
                    ? SizedBox.shrink()
                    : Container(
                        padding: EdgeInsets.only(top: 20),
                        height: 45,
                        child: Row(
                          children: [
                            Text(
                              productController.option1.first
                                  .getOptionName2(Get.locale!.languageCode),
                              style: TextStyle(
                                color: Color.fromARGB(255, 88, 88, 88),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              (productController.selectedVariantReady.value
                                  ? " : " +
                                      productController.selectedVariant!
                                          .getVariantName2(
                                              Get.locale!.languageCode)
                                  : ""),
                              style: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              //Liste des variant 2
              Obx(() => !(productController.opt1.value &&
                      productController.option1.first
                              .getOptionName2(Get.locale!.languageCode) !=
                          "")
                  ? SizedBox.shrink()
                  : SizedBox(
                      height:
                          40.0 * (productController.option1.length / 4).ceil(),
                      child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (productController.option1.length / 4).ceil(),
                            childAspectRatio: 0.415,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemCount: productController.option1.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: GestureDetector(
                                onTap: () {
                                  productController.selectedVariantReady.value =
                                      false;
                                  productController.selectedVariant =
                                      productController.option1[index];
                                  productController.selectedVariantReady.value =
                                      true;
                                },
                                child: Obx(
                                  () => Container(
                                    height: productController
                                            .selectedVariantReady.value
                                        ? 10
                                        : 11,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        width: 1,
                                        color: productController
                                                    .selectedVariantReady
                                                    .value &&
                                                productController
                                                        .selectedVariant!
                                                        .getVariantName2(Get
                                                            .locale!
                                                            .languageCode) ==
                                                    productController
                                                        .option1[index]
                                                        .getVariantName2(Get
                                                            .locale!
                                                            .languageCode)
                                            ? Color.fromARGB(255, 128, 145, 182)
                                            : Color.fromARGB(255, 205, 221, 253)
                                                .withOpacity(0.5),
                                      ),
                                      color: productController.option1[index]
                                                  .previsionnel !=
                                              0
                                          ? productController
                                                      .selectedVariantReady
                                                      .value &&
                                                  productController
                                                          .selectedVariant!
                                                          .getVariantName2(Get
                                                              .locale!
                                                              .languageCode) ==
                                                      productController
                                                          .option1[index]
                                                          .getVariantName2(Get
                                                              .locale!
                                                              .languageCode)
                                              ? Color.fromARGB(
                                                  255, 215, 228, 255)
                                              : Color.fromARGB(
                                                  255, 244, 248, 255)
                                          : Color.fromARGB(255, 238, 238, 238),
                                    ),
                                    child: Center(
                                      widthFactor: productController
                                              .selectedVariantReady.value
                                          ? 0
                                          : 1,
                                      child: Text(
                                        productController.option1[index]
                                            .getVariantName2(
                                                Get.locale!.languageCode),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: productController
                                                      .option1[index]
                                                      .previsionnel !=
                                                  0
                                              ? productController
                                                          .selectedVariantReady
                                                          .value &&
                                                      productController
                                                              .selectedVariant!
                                                              .getVariantName2(Get
                                                                  .locale!
                                                                  .languageCode) ==
                                                          productController
                                                              .option1[index]
                                                              .getVariantName2(Get
                                                                  .locale!
                                                                  .languageCode)
                                                  ? Color.fromARGB(
                                                      255, 16, 18, 112)
                                                  : Color.fromARGB(255, 98, 108, 196)
                                              : Color.fromARGB(255, 138, 138, 138),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    )),
              SizedBox(
                height: 20,
              ),
              Obx(() => productController.selectedVariantReady.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: Get.width / 3,
                          child: Obx(
                            () => DropdownButtonFormField2(
                              key: orderController.keyUnite,
                              value: "Pcs",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black),
                              // selectedItemHighlightColor:
                              //     Color.fromARGB(255, 206, 235, 255),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                              isExpanded: true,
                              hint: Text(
                                "Unité",
                                style: TextStyle(fontSize: 12),
                              ),

                              iconStyleData: IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  size: 30,
                                  color: productController
                                              .selectedVariant!.previsionnel !=
                                          0
                                      ? Colors.black45
                                      : Colors.grey,
                                ),
                              ),
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                // padding: const EdgeInsets.only(left: 15, right: 10),
                              ),
                              // buttonPadding: const EdgeInsets.only(left: 0, right: 10),
                              items: [
                                DropdownMenuItem<String>(
                                  value: "Pcs",
                                  child: Text(
                                    "Paquet".tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Cart",
                                  enabled: productController
                                          .selectedVariantReady.value &&
                                      productController
                                              .selectedVariant!.previsionnel >=
                                          productController
                                              .selectedVariant!.package,
                                  child: Text(
                                    "Caisse".tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: productController
                                                    .selectedVariantReady
                                                    .value &&
                                                productController
                                                        .selectedVariant!
                                                        .previsionnel >=
                                                    productController
                                                        .selectedVariant!
                                                        .package
                                            ? null
                                            : Colors.grey),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                orderController.uniteItem.value =
                                    value.toString();
                              },
                              onSaved: (value) {
                                // dropController.TpvID = value as int;
                                orderController.uniteItem.value =
                                    value.toString();
                              },
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 0.1),
                          ),
                          width: 95,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 29,
                                child: IconButton(
                                  onPressed: () {
                                    if (orderController.quantityItem.value !=
                                        1) {
                                      orderController.quantityItem.value--;
                                      qtyController.text = orderController
                                          .quantityItem.value
                                          .toStringAsFixed(0);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                  ),
                                  iconSize: 16,
                                ),
                              ),
                              Container(
                                // padding: EdgeInsets.,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        vertical: BorderSide(width: 0.1))),
                                width: 35,
                                height: 25,
                                child: TextFormField(
                                  readOnly: true,
                                  enableInteractiveSelection: false,
                                  onTap: () {
                                    showWindowPackage(context);
                                  },
                                  style: TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                  onChanged: ((value) {
                                    orderController.quantityItem.value =
                                        double.parse(value);
                                  }),
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(
                                // color: Color.fromARGB(255, 192, 227, 255),
                                width: 29,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                  ),
                                  iconSize: 16,
                                  onPressed: () {
                                    if (orderController.quantityItem.value <
                                        productController
                                                .selectedVariant!.previsionnel /
                                            (orderController.uniteItem.value ==
                                                    "Cart"
                                                ? productController
                                                    .selectedVariant!.package
                                                : 1)) {
                                      orderController.quantityItem.value++;
                                      qtyController.text = orderController
                                          .quantityItem.value
                                          .toStringAsFixed(0);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        productController.selectedVariantReady.value
                            ? Container(
                                child: Text(
                                  (productController.selectedVariant!
                                                  .previsionnel /
                                              (orderController
                                                          .uniteItem.value ==
                                                      "Cart"
                                                  ? productController
                                                      .selectedVariant!.package
                                                  : 1))
                                          .toStringAsFixed(0) +
                                      " " +
                                      "Disponible".tr,
                                  style: TextStyle(fontSize: 14),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    )
                  : SizedBox.shrink()),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          padding: EdgeInsets.only(top: 5),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 245, 245, 245),
                offset: Offset(0, -2),
                blurRadius: 5,
              )
            ],
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              Obx(() => productController.selectedVariantReady.value
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${"total".tr} : ",
                              ),
                              Text(" ",
                                  style: TextStyle(
                                      fontFamily: 'alata', fontSize: 22)),
                              Text(
                                formatter.format((orderController
                                                .quantityItem.value *
                                            (orderController.uniteItem.value ==
                                                    "Cart".tr
                                                ? productController
                                                    .selectedVariant!.package
                                                : 1) >=
                                        productController
                                            .selectedVariant!.minimum
                                    ? orderController.quantityItem.value *
                                        (orderController.uniteItem.value ==
                                                "Cart".tr
                                            ? productController
                                                .selectedVariant!.package
                                            : 1) *
                                        productController.selectedVariant!.price
                                    : orderController.quantityItem.value *
                                        (orderController.uniteItem.value ==
                                                "Cart".tr
                                            ? productController
                                                .selectedVariant!.package
                                            : 1) *
                                        productController
                                            .selectedVariant!.original_price)),
                                style: TextStyle(
                                    fontFamily: 'alata', fontSize: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 25,
                    )),
              Obx(
                () => MaterialButton(
                  minWidth: Get.width - 20,
                  height: 50,
                  elevation: 10,
                  textColor: Colors.white,
                  color: productController.selectedVariantReady.value &&
                          productController.selectedVariant!.previsionnel > 0
                      ? Colors.blue
                      : Color.fromARGB(255, 141, 204, 255),
                  onPressed: () {
                    if (productController.selectedVariantReady.value &&
                        productController.selectedVariant!.previsionnel > 0) {
                      orderController.addItem(
                          variant: productController.selectedVariant!,
                          product_name: productController.productSelected!
                              .getShortDescription(Get.locale!.languageCode),
                          unite: orderController.uniteItem.value,
                          quantity: orderController.quantityItem.value,
                          warehouse_id:
                              productController.selectedVariant!.warehouse_id);

                      productController.selectedVariant = null;
                      productController.productSelected = null;
                      productController.selectedVariantReady.value = false;
                      orderController.quantityItem.value = 1;
                      orderController.uniteItem.value = "Pcs";
                      pageController.jumpToPage(0);
                    } else {
                      print("not yet selected");
                    }
                  },
                  child: Text("add".tr),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void showWindowPackage(BuildContext context) {
    TextEditingController qtyCaisseController = TextEditingController();
    TextEditingController qtyPcsController = TextEditingController();
    qtyCaisseController.text = orderController.uniteItem.value == "Cart"
        ? orderController.quantityItem.value.toStringAsFixed(0)
        : (orderController.quantityItem.value ~/
                    productController.selectedVariant.package) ==
                0
            ? ""
            : (orderController.quantityItem.value ~/
                    productController.selectedVariant.package)
                .toStringAsFixed(0);

    qtyPcsController.text = orderController.uniteItem.value == "Pcs"
        ? (orderController.quantityItem.value %
                productController.selectedVariant.package)
            .toStringAsFixed(0)
        : "";
    // qtyPcsController.text = "Smail";
    //rendre l'unité de mésure en pièces pour facilter le calcule de caisses
    bool first = true;
    double finalQuantity = orderController.quantityItem.value == "Cart"
        ? orderController.quantityItem.value *
            productController.selectedVariant.package
        : orderController.quantityItem.value;
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 30, right: 30, top: 15),
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 43, 87, 124),
            ),
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                "${'quantity'.tr} x${productController.selectedVariant.package}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          content: SizedBox(
            height: Get.height / 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextFormField(
                    enableInteractiveSelection: false,
                    controller: qtyCaisseController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.school_sharp),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "carton".tr,
                    ),
                    onChanged: (value) {
                      first = false;
                      var qtyCaisse = double.parse(
                          qtyCaisseController.text != ""
                              ? qtyCaisseController.text
                              : "0");

                      var qtyPcs = int.parse(qtyPcsController.text != ""
                          ? qtyPcsController.text
                          : "0");

                      int package = productController.selectedVariant.package;

                      orderController.quantityItem.value =
                          qtyCaisse * package + qtyPcs;
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextFormField(
                    enableInteractiveSelection: false,
                    controller: qtyPcsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "piece".tr,
                    ),
                    onChanged: (value) {
                      first = false;
                      var qtyCaisse = double.parse(
                          qtyCaisseController.text != ""
                              ? qtyCaisseController.text
                              : "0");

                      var qtyPcs = int.parse(qtyPcsController.text != ""
                          ? qtyPcsController.text
                          : "0");

                      int package = productController.selectedVariant.package;

                      orderController.quantityItem.value =
                          qtyCaisse * package + qtyPcs;
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Obx(
                      () => Text(
                        first
                            ? finalQuantity.toStringAsFixed(0)
                            : orderController.quantityItem.value
                                .toStringAsFixed(0),
                        style: TextStyle(
                            color: orderController.quantityItem.value > 0
                                ? null
                                : null),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              minWidth: double.infinity,
              color: Colors.blue,
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (orderController.quantityItem.value != 0) {
                  var qtyCaisse = double.parse(qtyCaisseController.text != ""
                      ? qtyCaisseController.text
                      : "0");

                  var qtyPcs = int.parse(qtyPcsController.text != ""
                      ? qtyPcsController.text
                      : "0");

                  int package = productController.selectedVariant.package;
                  if ((qtyCaisse * package + qtyPcs) % package == 0) {
                    orderController.keyUnite!.currentState!.didChange("Cart");
                    orderController.uniteItem.value = "Cart";
                    orderController.quantityItem.value =
                        (qtyCaisse * package + qtyPcs) / package;
                    qtyController.text =
                        ((qtyCaisse * package + qtyPcs) / package)
                            .toStringAsFixed(0);
                  } else {
                    orderController.quantityItem.value =
                        qtyCaisse * package + qtyPcs;
                    qtyController.text =
                        (qtyCaisse * package + qtyPcs).toStringAsFixed(0);
                    orderController.keyUnite!.currentState!.didChange("Pcs");
                    orderController.uniteItem.value = "Pcs";
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
