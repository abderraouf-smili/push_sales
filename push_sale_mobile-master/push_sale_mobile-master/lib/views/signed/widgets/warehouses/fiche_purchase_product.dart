import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/product.dart';
import 'package:push_sale/models/purchase_variant.dart';

class FichePurchaseProduct extends StatelessWidget {
  PageController pageController;
  FichePurchaseProduct(this.pageController);
  ProductController productController = Get.find();
  PurchaseOrderController purchaseController = Get.find();
  WarehouseController warehouseController = Get.find();
  late Product product;
  var formatter = new NumberFormat("#,##0.00", "fr_FR");
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (purchaseController.purchaseorderId == null) {
      purchaseController.generateId();
    }
    purchaseController.uniteItem.value = "Cart";
    purchaseController.quantityItem.value = 1.0;
    purchaseController.priceItem.value = 0.0;
    qtyController.text = "1";
    productController.opt1.value = false;
    productController.client = null;
    productController.selectedVariantReady.value = false;

    product = productController.productSelected!;

    List<PurchaseVariant> _variants = List.from(product.purchasevariants!
        .where((article) => !purchaseController.orderitems
            .any((item) => item.variant_id == article.id))
        .toList());

    List<String> var1 = productController.getOption(_variants, 1);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          print(productController.page.value);
          switch (productController.page.value) {
            case 2:
              productController.selectedVariant = null;
              productController.opt1.value = false;
              productController.productSelected = null;
              productController.selectedVariantReady.value = false;
              productController.page.value = 1;
              pageController.jumpToPage(1);
              break;
            case 1:
              productController.page.value = 0;
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
                        purchaseController.saved.value = false;
                        Get.back();
                      })
                    ..show();
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
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
                  () => Container(
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: Get.height / 2.23,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      Container(
                        child: Text(
                          "***",
                          style: TextStyle(
                            fontFamily: 'alata',
                          ),
                        ),
                      ),

                      Divider(
                        thickness: 1,
                      ),
                      // Long description of article
                      Container(
                        height: 40,
                        child: Text(
                          product.getLongDescription(Get.locale!.languageCode),
                          style:
                              TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
                        ),
                      ),
                      //Premiere Option du Vartiant

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        height: 30,
                        child: Row(
                          children: [
                            Text(
                              _variants.length > 0
                                  ? _variants.first
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
                                              .getVariantName1(
                                                  Get.locale!.languageCode)
                                      : "",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 116, 116, 116),
                                      fontSize: 12),
                                ))
                          ],
                        ),
                      ),
                      //Liste des variant 1
                      _variants.length > 0
                          ? Container(
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
                                        productController
                                            .selectedVariantReady.value = false;
                                        productController.option1 = _variants
                                            .where((element) =>
                                                element.getVariantName1(
                                                    Get.locale!.languageCode) ==
                                                var1[index])
                                            .toList();
                                        if (productController.option1.length ==
                                            1) {
                                          productController.selectedVariant =
                                              productController.option1.first;
                                          productController.selectedVariantReady
                                              .value = true;
                                          purchaseController.priceItem.value =
                                              productController.selectedVariant
                                                  .lastpurchaseprice;
                                        }
                                        productController.opt1.value = true;
                                      },
                                      child: Obx(() => Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              border: Border.all(
                                                width: 1,
                                                color: productController
                                                            .opt1.value &&
                                                        productController
                                                                .option1.first
                                                                .getVariantName1(Get
                                                                    .locale!
                                                                    .languageCode) ==
                                                            var1[index]
                                                    ? Color.fromARGB(
                                                        255, 128, 145, 182)
                                                    : Color.fromARGB(
                                                            255, 205, 221, 253)
                                                        .withOpacity(0.5),
                                              ),
                                              color: productController
                                                          .opt1.value &&
                                                      productController
                                                              .option1.first
                                                              .getVariantName1(Get
                                                                  .locale!
                                                                  .languageCode) ==
                                                          var1[index]
                                                  ? Color.fromARGB(
                                                      255, 215, 228, 255)
                                                  : Color.fromARGB(
                                                          255, 244, 248, 255)
                                                      .withOpacity(0.5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                var1[index],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: productController
                                                              .opt1.value &&
                                                          productController
                                                                  .option1.first
                                                                  .getVariantName1(Get
                                                                      .locale!
                                                                      .languageCode) ==
                                                              var1[index]
                                                      ? Color.fromARGB(
                                                          255, 16, 18, 112)
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
                                productController.option1.first.getOptionName2(
                                        Get.locale!.languageCode) !=
                                    "")
                            ? SizedBox.shrink()
                            : Container(
                                padding: EdgeInsets.only(top: 20),
                                height: 45,
                                child: Row(
                                  children: [
                                    Text(
                                      productController.option1.first
                                          .getOptionName2(
                                              Get.locale!.languageCode),
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 88, 88, 88),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      (productController
                                              .selectedVariantReady.value
                                          ? " : " +
                                              productController.selectedVariant!
                                                  .getVariantName2(
                                                      Get.locale!.languageCode)
                                          : ""),
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 116, 116, 116),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      //Liste des variant 2
                      Obx(() => !(productController.opt1.value &&
                              productController.option1.first.getOptionName2(
                                      Get.locale!.languageCode) !=
                                  "")
                          ? SizedBox.shrink()
                          : Container(
                              height: 40.0 *
                                  (productController.option1.length / 4).ceil(),
                              child: GridView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        (productController.option1.length / 4)
                                            .ceil(),
                                    childAspectRatio: 0.415,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                  ),
                                  itemCount: productController.option1.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: GestureDetector(
                                        onTap: () {
                                          productController.selectedVariantReady
                                              .value = false;
                                          productController.selectedVariant =
                                              productController.option1[index];
                                          productController.selectedVariantReady
                                              .value = true;
                                          purchaseController.priceItem.value =
                                              productController.selectedVariant
                                                  .lastpurchaseprice;
                                        },
                                        child: Obx(
                                          () => Container(
                                            height: productController
                                                    .selectedVariantReady.value
                                                ? 10
                                                : 11,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
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
                                                    ? Color.fromARGB(
                                                        255, 128, 145, 182)
                                                    : Color.fromARGB(
                                                            255, 205, 221, 253)
                                                        .withOpacity(0.5),
                                              ),
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
                                                  ? Color.fromARGB(
                                                      255, 215, 228, 255)
                                                  : Color.fromARGB(
                                                      255, 244, 248, 255),
                                            ),
                                            child: Center(
                                              widthFactor: productController
                                                      .selectedVariantReady
                                                      .value
                                                  ? 0
                                                  : 1,
                                              child: Text(
                                                productController.option1[index]
                                                    .getVariantName2(Get
                                                        .locale!.languageCode),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: productController
                                                              .selectedVariantReady
                                                              .value &&
                                                          productController
                                                                  .selectedVariant!
                                                                  .getVariantName2(Get
                                                                      .locale!
                                                                      .languageCode) ==
                                                              productController
                                                                  .option1[
                                                                      index]
                                                                  .getVariantName2(Get
                                                                      .locale!
                                                                      .languageCode)
                                                      ? Color.fromARGB(
                                                          255, 16, 18, 112)
                                                      : Color.fromARGB(
                                                          255, 98, 108, 196),
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
                      Obx(() {
                        priceController.text =
                            productController.selectedVariantReady.value
                                ? productController
                                    .selectedVariant.lastpurchaseprice
                                    .toString()
                                : "0.0";
                        return productController.selectedVariantReady.value
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: Get.width / 3,
                                    child: DropdownButtonFormField2(
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      key: purchaseController.keyUnite,
                                      value: "Cart",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      // selectedItemHighlightColor:
                                      //     Color.fromARGB(255, 206, 235, 255),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          color: Colors.black45,
                                          size: 30,
                                        ),
                                      ),
                                      buttonStyleData: ButtonStyleData(
                                        height: 45,
                                      ),
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
                                          enabled: true,
                                          child: Text(
                                            "Caisse".tr,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        purchaseController.uniteItem.value =
                                            value.toString();
                                      },
                                      onSaved: (value) {
                                        // dropController.TpvID = value as int;
                                        purchaseController.uniteItem.value =
                                            value.toString();
                                      },
                                    ),
                                  ),
                                  Container(
                                    // padding: EdgeInsets.,
                                    decoration: BoxDecoration(
                                        border: Border.symmetric(
                                            vertical: BorderSide(width: 0.1))),
                                    width: 80,
                                    height: 25,
                                    child: TextFormField(
                                      enableInteractiveSelection: false,
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                      onChanged: ((value) {
                                        purchaseController.priceItem.value =
                                            value == ""
                                                ? 0.0
                                                : double.parse(value);
                                      }),
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(width: 0.1),
                                    ),
                                    width: 120,
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: 29,
                                          child: IconButton(
                                            onPressed: () {
                                              if (purchaseController
                                                      .quantityItem.value !=
                                                  1) {
                                                purchaseController
                                                    .quantityItem.value--;
                                                qtyController.text =
                                                    purchaseController
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
                                                  vertical:
                                                      BorderSide(width: 0.1))),
                                          width: 60,
                                          height: 25,
                                          child: TextFormField(
                                            readOnly: true,
                                            enableInteractiveSelection: false,
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  TextEditingController
                                                      qtyCaisseController =
                                                      TextEditingController();
                                                  TextEditingController
                                                      qtyPcsController =
                                                      TextEditingController();
                                                  qtyCaisseController
                                                      .text = purchaseController
                                                              .uniteItem
                                                              .value ==
                                                          "Cart"
                                                      ? purchaseController
                                                          .quantityItem.value
                                                          .toStringAsFixed(0)
                                                      : (purchaseController
                                                                      .quantityItem
                                                                      .value ~/
                                                                  productController
                                                                      .selectedVariant
                                                                      .package) ==
                                                              0
                                                          ? ""
                                                          : (purchaseController
                                                                      .quantityItem
                                                                      .value ~/
                                                                  productController
                                                                      .selectedVariant
                                                                      .package)
                                                              .toStringAsFixed(
                                                                  0);

                                                  qtyPcsController
                                                      .text = purchaseController
                                                              .uniteItem
                                                              .value ==
                                                          "Pcs"
                                                      ? (purchaseController
                                                                  .quantityItem
                                                                  .value %
                                                              productController
                                                                  .selectedVariant
                                                                  .package)
                                                          .toStringAsFixed(0)
                                                      : "";

                                                  //rendre l'unité de mésure en pièces pour facilter le calcule de caisses
                                                  bool first = true;
                                                  double finalQuantity =
                                                      purchaseController
                                                                  .uniteItem
                                                                  .value ==
                                                              "Cart"
                                                          ? purchaseController
                                                                  .quantityItem
                                                                  .value *
                                                              productController
                                                                  .selectedVariant
                                                                  .package
                                                          : purchaseController
                                                              .quantityItem
                                                              .value;
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 30,
                                                            right: 30,
                                                            top: 15),
                                                    titlePadding:
                                                        EdgeInsets.zero,
                                                    title: Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(
                                                            255, 43, 87, 124),
                                                      ),
                                                      width: double.infinity,
                                                      height: 50,
                                                      child: Center(
                                                        child: Text(
                                                          'quantity'.tr +
                                                              " x" +
                                                              productController
                                                                  .selectedVariant
                                                                  .package
                                                                  .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    content: Container(
                                                      height: Get.height / 6,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 50,
                                                            child:
                                                                TextFormField(
                                                              enableInteractiveSelection:
                                                                  false,
                                                              controller:
                                                                  qtyCaisseController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                prefixIcon:
                                                                    Icon(Icons
                                                                        .school_sharp),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                labelText:
                                                                    "Cart".tr,
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                first = false;
                                                                var qty_caisse =
                                                                    double.parse(qtyCaisseController.text !=
                                                                            ""
                                                                        ? qtyCaisseController
                                                                            .text
                                                                        : "0");

                                                                var qty_pcs = int.parse(
                                                                    qtyPcsController.text !=
                                                                            ""
                                                                        ? qtyPcsController
                                                                            .text
                                                                        : "0");

                                                                int package =
                                                                    productController
                                                                        .selectedVariant
                                                                        .package;

                                                                purchaseController
                                                                        .quantityItem
                                                                        .value =
                                                                    qty_caisse *
                                                                            package +
                                                                        qty_pcs;
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 50,
                                                            child:
                                                                TextFormField(
                                                              enableInteractiveSelection:
                                                                  false,
                                                              controller:
                                                                  qtyPcsController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                prefixIcon:
                                                                    Icon(Icons
                                                                        .category_rounded),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                labelText:
                                                                    "Pcs".tr,
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                first = false;
                                                                var qty_caisse =
                                                                    double.parse(qtyCaisseController.text !=
                                                                            ""
                                                                        ? qtyCaisseController
                                                                            .text
                                                                        : "0");

                                                                var qty_pcs = int.parse(
                                                                    qtyPcsController.text !=
                                                                            ""
                                                                        ? qtyPcsController
                                                                            .text
                                                                        : "0");

                                                                int package =
                                                                    productController
                                                                        .selectedVariant
                                                                        .package;

                                                                purchaseController
                                                                        .quantityItem
                                                                        .value =
                                                                    qty_caisse *
                                                                            package +
                                                                        qty_pcs;
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Obx(
                                                                () => Text(
                                                                  first
                                                                      ? finalQuantity
                                                                          .toStringAsFixed(
                                                                              0)
                                                                      : purchaseController
                                                                          .quantityItem
                                                                          .value
                                                                          .toStringAsFixed(
                                                                              0),
                                                                  style: TextStyle(
                                                                      color: purchaseController.quantityItem.value >
                                                                              0
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
                                                        minWidth:
                                                            double.infinity,
                                                        color: Colors.blue,
                                                        child: Text(
                                                          'OK'.tr,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () {
                                                          if (purchaseController
                                                                  .quantityItem
                                                                  .value !=
                                                              0) {
                                                            var qty_caisse = double.parse(
                                                                qtyCaisseController
                                                                            .text !=
                                                                        ""
                                                                    ? qtyCaisseController
                                                                        .text
                                                                    : "0");

                                                            var qty_pcs = int.parse(
                                                                qtyPcsController
                                                                            .text !=
                                                                        ""
                                                                    ? qtyPcsController
                                                                        .text
                                                                    : "0");

                                                            int package =
                                                                productController
                                                                    .selectedVariant
                                                                    .package;
                                                            if ((qty_caisse *
                                                                            package +
                                                                        qty_pcs) %
                                                                    package ==
                                                                0) {
                                                              purchaseController
                                                                  .keyUnite!
                                                                  .currentState!
                                                                  .didChange(
                                                                      "Cart");
                                                              purchaseController
                                                                      .uniteItem
                                                                      .value =
                                                                  "Cart";
                                                              purchaseController
                                                                  .quantityItem
                                                                  .value = (qty_caisse *
                                                                          package +
                                                                      qty_pcs) /
                                                                  package;
                                                              qtyController
                                                                  .text = ((qty_caisse *
                                                                              package +
                                                                          qty_pcs) /
                                                                      package)
                                                                  .toStringAsFixed(
                                                                      0);
                                                            } else {
                                                              purchaseController
                                                                      .quantityItem
                                                                      .value =
                                                                  qty_caisse *
                                                                          package +
                                                                      qty_pcs;
                                                              qtyController
                                                                  .text = (qty_caisse *
                                                                          package +
                                                                      qty_pcs)
                                                                  .toStringAsFixed(
                                                                      0);
                                                              purchaseController
                                                                  .keyUnite!
                                                                  .currentState!
                                                                  .didChange(
                                                                      "Pcs");
                                                              purchaseController
                                                                      .uniteItem
                                                                      .value =
                                                                  "Pcs";
                                                            }
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                            onChanged: ((value) {
                                              purchaseController.quantityItem
                                                  .value = double.parse(value);
                                            }),
                                            controller: qtyController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          // color: Color.fromARGB(255, 192, 227, 255),
                                          width: 29,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.add,
                                            ),
                                            iconSize: 16,
                                            onPressed: () {
                                              purchaseController
                                                  .quantityItem.value++;
                                              qtyController.text =
                                                  purchaseController
                                                      .quantityItem.value
                                                      .toStringAsFixed(0);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox.shrink();
                      }),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total : ",
                                      ),
                                      Text(" ",
                                          style: TextStyle(
                                              fontFamily: 'alata',
                                              fontSize: 22)),
                                      Obx(() => Text(
                                            formatter.format(purchaseController
                                                    .quantityItem.value *
                                                purchaseController
                                                    .priceItem.value *
                                                (purchaseController
                                                            .uniteItem.value ==
                                                        "Cart"
                                                    ? productController
                                                        .selectedVariant.package
                                                    : 1)),
                                            style: TextStyle(
                                                fontFamily: 'alata',
                                                fontSize: 22),
                                          )),
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
                                  purchaseController.priceItem.value > 0
                              ? Colors.blue
                              : Color.fromARGB(255, 141, 204, 255),
                          onPressed: () {
                            if (productController.selectedVariantReady.value &&
                                purchaseController.priceItem.value != 0) {
                              purchaseController.addItem(
                                  variant: productController.selectedVariant!,
                                  product_name: productController
                                      .productSelected!
                                      .getShortDescription(
                                          Get.locale!.languageCode),
                                  unite: purchaseController.uniteItem.value,
                                  price: purchaseController.priceItem.value,
                                  quantity:
                                      purchaseController.quantityItem.value,
                                  warehouse_id:
                                      warehouseController.warehouse!.id);

                              productController.selectedVariant = null;
                              productController.productSelected = null;
                              productController.selectedVariantReady.value =
                                  false;
                              purchaseController.quantityItem.value = 1;
                              purchaseController.uniteItem.value = "Pcs";
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
            ),
          ),
        ),
      ),
    );
  }
}
