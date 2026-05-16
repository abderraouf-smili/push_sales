import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/promotion_controller.dart';
import 'package:push_sale/models/promotion.dart';
import 'package:push_sale/views/signed/widgets/promotions/promotions_list.dart';

class EditPromotion extends StatelessWidget {
  Promotion? promotion;
  EditPromotion({this.promotion});
  PromotionController promotionController = Get.find();
  ProductController productController = Get.put(ProductController());
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    productController.client = null;
    productController.getProducts();
    productController.getPurchaseVariants();

    promotionController.product = null;
    promotionController.variant = null;
    promotionController.minimum = 1;
    promotionController.pourcentage = 1;
    promotionController.unite = "Pcs";
    if (promotion != null) {
      promotionController.items = promotion!.lines;
      descriptionController.text = promotion!.description;
      promotionController.setStartDate(promotion!.start_date);
      promotionController.setEndDate(promotion!.end_date);
      promotionController.description = promotion!.description;
      promotionController.promotionId = promotion!.id;
    } else {
      promotionController.generatePromoId();
      promotionController.setStartDate(DateTime.now());
      promotionController.setEndDate(DateTime.now());
      promotionController.items = [];
      promotionController.description = "";
    }
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showWindowProductAdd(
                  context, promotionController, productController);
              print(productController.listVariant.length);
            },
            child: const Icon(Icons.add),
          ),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor:
                const Color.fromARGB(255, 255, 17, 0).withOpacity(0.6),
            title: Text(
                promotion != null ? "edit.promotion".tr : "new.promotion".tr),
            centerTitle: true,
            actions: [
              PopupMenuButton(
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        {
                          bool result = await promotionController.save();
                          if (result) {
                            //success
                            AwesomeDialog(
                                dialogType: DialogType.success,
                                title: "sure".tr,
                                body: Text("succefully.saved".tr),
                                context: context,
                                btnOkOnPress: () {
                                  promotionController.dispose();
                                  Get.offAll(() => PromotionsList());
                                })
                              ..show();
                          } else {
                            //echec
                            AwesomeDialog(
                                dialogType: DialogType.error,
                                title: "sure".tr,
                                body: Text("error.saved".tr),
                                context: context,
                                btnOkOnPress: () {})
                              ..show();
                          }
                        }
                        break;
                      case 1:
                        {
                          // Get.to(() => EditPromotion(promotion: _promotion));
                        }
                        break;
                      case 2:
                        {
                          // Get.to(() => HomePage());
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("save".tr),
                              const Icon(Icons.save, color: Colors.blue),
                            ],
                          )),
                      PopupMenuItem(
                          value: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("close".tr),
                              const Icon(Icons.close, color: Colors.blue),
                            ],
                          )),
                    ];
                  })
            ],
          ),
          body: Container(
            width: double.infinity,
            // padding: EdgeInsets.symmetric(horizontal: 40),
            height: Get.height - 100,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: Get.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Get.width / 4,
                        child: Text(
                          "description".tr,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 97, 97, 97)),
                        ),
                      ),
                      Container(
                        height: 37,
                        width: Get.width / 1.6,
                        padding: const EdgeInsets.only(top: 16, left: 5),
                        decoration: BoxDecoration(
                            // color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1,
                                color:
                                    const Color.fromARGB(255, 214, 214, 214))),
                        child: TextFormField(
                            onChanged: (value) =>
                                promotionController.description = value,
                            controller: descriptionController,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'describe.your.promo.here'.tr,
                            )),
                      )
                    ],
                  ),
                ),
                Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Get.width / 4,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: const Icon(Icons.calendar_month_outlined,
                              color: Color.fromARGB(255, 122, 122, 122)),
                        ),
                      ),
                      Container(
                        width: Get.width / 1.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var date_start = await showDatePicker(
                                  locale:
                                      Locale(Get.deviceLocale!.languageCode),
                                  context: context,
                                  initialDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (date_start != null) {
                                  promotionController.setStartDate(date_start);
                                }
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255, 214, 214, 214))),
                                child: Obx(
                                  () => Text(
                                    DateFormat('dd/MM/y').format(
                                        promotionController
                                                .start_date_selected.value
                                            ? promotionController.start_date!
                                            : promotion != null
                                                ? promotion!.start_date
                                                : DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      // fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 122, 122, 122),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var date_end = await showDatePicker(
                                  locale:
                                      Locale(Get.deviceLocale!.languageCode),
                                  context: context,
                                  initialDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (date_end != null) {
                                  promotionController.setEndDate(date_end);
                                }
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255, 214, 214, 214))),
                                child: Obx(
                                  () => Text(
                                    DateFormat('dd/MM/y').format(
                                        promotionController
                                                .end_date_selected.value
                                            ? promotionController.end_date!
                                            : promotion != null
                                                ? promotion!.end_date
                                                : DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      // fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 122, 122, 122),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Get.width / 4,
                        child: const Text("Type",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 97, 97, 97))),
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 37,
                          width: Get.width / 1.6,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(
                                      255, 214, 214, 214))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  promotionController.promo_type.value =
                                      "discount_price";
                                },
                                child: Row(
                                  children: [
                                    Text("discount_price".tr),
                                    Container(
                                      width: 40,
                                      height: 20,
                                      child: Radio(
                                          value: "discount_price",
                                          groupValue: promotionController
                                              .promo_type.value,
                                          onChanged: (value) {
                                            promotionController.promo_type
                                                .value = value.toString();
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     promotionController.promo_type.value =
                              //         "discount_total";
                              //   },
                              //   child: Row(
                              //     children: [
                              //       Text("discount_total".tr),
                              //       Container(
                              //         width: 40,
                              //         height: 20,
                              //         child: Radio(
                              //             value: "discount_total",
                              //             groupValue: promotionController
                              //                 .promo_type.value,
                              //             onChanged: (value) {}),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                Container(
                  width: double.infinity,
                  height: Get.height / 1.5,
                  child: Obx(
                    () => ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: promotionController.listIsReady.value
                          ? promotionController.items.length
                          : 0,
                      itemBuilder: (context, index) {
                        var item = promotionController.items[index];
                        return Dismissible(
                          direction: promotionController.saved.value
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          background: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              promotionController.removeItem(item);
                            }
                          },
                          key: Key(item.id.toString()),
                          child: ListTile(
                              title: Text(item.product != null
                                  ? item.product!.short_description_fr
                                  : item
                                      .variant!.product!.short_description_fr),
                              subtitle: Text(item.product != null
                                  ? (item.product!.variants != null
                                          ? item.product!.variants!.length
                                          : item.product!.purchasevariants!
                                              .length)
                                      .toString()
                                  : item.variant!.variant1_fr +
                                      " " +
                                      item.variant!.variant2_fr),
                              trailing: Column(
                                children: [
                                  Text("-" + item.discount.toString() + "%"),
                                  Text("min " +
                                      item.minimum.toStringAsFixed(0) +
                                      " " +
                                      item.unite),
                                ],
                              ),
                              leading: CachedNetworkImage(
                                cacheManager: CacheManager(
                                  Config(
                                    item.product != null
                                        ? item.product!.image
                                        : item.variant!.image,
                                    stalePeriod: const Duration(days: 7),
                                  ),
                                ),
                                imageUrl: item.product != null
                                    ? item.product!.image
                                    : item.variant!.image,
                                placeholder: (context, url) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 2),
                                    child: const CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

showWindowProductAdd(
    BuildContext context,
    PromotionController promotionController,
    ProductController productController) {
  showModalBottomSheet<void>(
      isScrollControlled: true,
      anchorPoint: const Offset(10, 1),
      backgroundColor: Colors.black.withOpacity(0.60),
      context: context,
      builder: (context) {
        promotionController.pro_sel_tile.value = 0;
        promotionController.var_sel_tile.value = 0;
        promotionController.pourcentage = 1;
        promotionController.minimum = 1;
        promotionController.unite = "Pcs";
        TextEditingController discountController =
            TextEditingController(text: "1%");
        TextEditingController minimumController =
            TextEditingController(text: "1");
        List<dynamic> products = List.from(productController.listProducts)
            .where(
              (element) => !promotionController.items.any((item) =>
                  item.product != null && item.product!.id == element.id),
            )
            .toList();
        List<dynamic> variants = productController.listVariant
            .where((element) => !promotionController.items.any((item) =>
                item.variant != null && item.variant!.id == element.id))
            .toList();

        return Container(
          width: Get.width,
          height: Get.height / 1.5,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 192, 192, 192),
                padding: EdgeInsets.symmetric(horizontal: Get.width / 3.5),
                // width: ,
                height: 8,
                // color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.grey),
                      color: Colors.white),
                ),
              ),
              Container(
                width: Get.width,
                height: 50,
                color: const Color.fromARGB(255, 192, 192, 192),
                child: Center(child: Text("add.product".tr)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        width: 1,
                        color: const Color.fromARGB(255, 180, 180, 180))),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          promotionController.promoCateg.value = "product";
                        },
                        child: Row(
                          children: [
                            Text("product".tr),
                            Radio(
                              value: "product",
                              groupValue: promotionController.promoCateg.value,
                              onChanged: (value) {
                                promotionController.promoCateg.value =
                                    value.toString();
                              },
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          promotionController.promoCateg.value = "variant";
                        },
                        child: Row(
                          children: [
                            Text("variant".tr),
                            Radio(
                              value: "variant",
                              groupValue: promotionController.promoCateg.value,
                              onChanged: (value) {
                                promotionController.promoCateg.value =
                                    value.toString();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //product + variant
              Container(
                height: Get.height / 3,
                width: Get.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        width: 1,
                        color: const Color.fromARGB(255, 180, 180, 180))),
                child: Obx(
                  () => promotionController.promoCateg.value == "product"
                      //product
                      ? Obx(
                          () => !productController.loadProductReady.value
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    var item = products[index];
                                    return GestureDetector(
                                      onTap: () {
                                        promotionController.pro_sel_tile.value =
                                            item.id;
                                        promotionController.product = item;
                                      },
                                      child: Obx(
                                        () => Container(
                                          decoration: BoxDecoration(
                                            color: promotionController
                                                        .pro_sel_tile.value ==
                                                    item.id
                                                ? const Color.fromARGB(
                                                    255, 243, 250, 255)
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              width: 1,
                                              color: promotionController
                                                          .pro_sel_tile.value ==
                                                      item.id
                                                  ? const Color.fromARGB(
                                                      255, 156, 194, 252)
                                                  : Colors.black.withOpacity(0),
                                            ),
                                          ),
                                          child: ListTile(
                                            title:
                                                Text(item.short_description_fr),
                                            subtitle: Text(item
                                                .purchasevariants!.length
                                                .toString()),
                                            leading: CachedNetworkImage(
                                              cacheManager: CacheManager(
                                                Config(
                                                  item.image,
                                                  stalePeriod:
                                                      const Duration(days: 7),
                                                ),
                                              ),
                                              imageUrl: item.image,
                                              placeholder: (context, url) =>
                                                  Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 2,
                                                          vertical: 2),
                                                      child:
                                                          const CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        )
                      // variant
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: variants.length,
                          itemBuilder: (context, index) {
                            var item = variants[index];
                            return GestureDetector(
                              onTap: () {
                                promotionController.var_sel_tile.value =
                                    item.id;
                                promotionController.variant = item;
                              },
                              child: Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                    color: promotionController
                                                .var_sel_tile.value ==
                                            item.id
                                        ? const Color.fromARGB(
                                            255, 243, 250, 255)
                                        : null,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      width: 1,
                                      color: promotionController
                                                  .var_sel_tile.value ==
                                              item.id
                                          ? const Color.fromARGB(
                                              255, 156, 194, 252)
                                          : Colors.black.withOpacity(0),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        item.product!.short_description_fr),
                                    subtitle: Text(item.variant1_fr +
                                        " " +
                                        item.variant2_fr),
                                    leading: CachedNetworkImage(
                                      cacheManager: CacheManager(
                                        Config(
                                          item.image,
                                          stalePeriod: const Duration(days: 7),
                                        ),
                                      ),
                                      imageUrl: item.image,
                                      placeholder: (context, url) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 2),
                                          child:
                                              const CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Réduction
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("discount".tr),
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
                                Container(
                                  width: 29,
                                  child: IconButton(
                                    onPressed: () {
                                      if (promotionController.pourcentage > 1) {
                                        promotionController.pourcentage--;
                                        discountController.text =
                                            promotionController.pourcentage
                                                    .toString() +
                                                "%";
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                    ),
                                    iconSize: 16,
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.,
                                  decoration: const BoxDecoration(
                                      border: Border.symmetric(
                                          vertical: BorderSide(width: 0.1))),
                                  width: 35,
                                  height: 25,
                                  child: TextFormField(
                                    enabled: false,
                                    onTap: () {},
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                    onChanged: ((value) {
                                      promotionController.pourcentage =
                                          int.parse(value);
                                    }),
                                    controller: discountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Color.fromARGB(255, 192, 227, 255),
                                  width: 29,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                    ),
                                    iconSize: 16,
                                    onPressed: () {
                                      if (promotionController.pourcentage <=
                                          99) {
                                        promotionController.pourcentage++;
                                        discountController.text =
                                            promotionController.pourcentage
                                                    .toString() +
                                                "%";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]),
                    // Minimum
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("minimum".tr),
                          Container(
                            width: 150,
                            height: 37,
                            child: DropdownButtonFormField2(
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              value: "Pcs",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black),
                              // selectedItemHighlightColor:
                              //     const Color.fromARGB(255, 206, 235, 255),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                              isExpanded: true,
                              hint: const Text(
                                "Unité",
                                style: TextStyle(fontSize: 12),
                              ),
                              iconStyleData: IconStyleData(
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: "Pcs",
                                  child: const Text(
                                    "Paquet",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const DropdownMenuItem<String>(
                                  value: "Cart",
                                  enabled: true,
                                  child: Text(
                                    "Caisse",
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                promotionController.unite = value.toString();
                              },
                              onSaved: (value) {
                                promotionController.unite = value.toString();
                              },
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
                                Container(
                                  width: 29,
                                  child: IconButton(
                                    onPressed: () {
                                      if (promotionController.minimum > 1) {
                                        promotionController.minimum--;
                                        minimumController.text =
                                            promotionController.minimum
                                                .toString();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                    ),
                                    iconSize: 16,
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.,
                                  decoration: const BoxDecoration(
                                      border: const Border.symmetric(
                                          vertical: BorderSide(width: 0.1))),
                                  width: 35,
                                  height: 25,
                                  child: TextFormField(
                                    enabled: false,
                                    onTap: () {},
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                    onChanged: ((value) {
                                      promotionController.minimum =
                                          int.parse(value);
                                    }),
                                    controller: minimumController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Color.fromARGB(255, 192, 227, 255),
                                  width: 29,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                    ),
                                    iconSize: 16,
                                    onPressed: () {
                                      if (promotionController.minimum <= 99) {
                                        promotionController.minimum++;
                                        minimumController.text =
                                            promotionController.minimum
                                                .toString();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: Get.width,
                height: 55,
                child: Obx(
                  () => MaterialButton(
                    color: (promotionController.promoCateg.value == "product" &&
                                promotionController.pro_sel_tile.value != 0) ||
                            (promotionController.promoCateg.value ==
                                    "variant" &&
                                promotionController.var_sel_tile.value != 0)
                        ? Colors.blue
                        : const Color.fromARGB(255, 192, 192, 192),
                    onPressed: () {
                      //
                      promotionController.addItem();
                      Get.back();
                    },
                    child: Text(
                      "add".tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      });
}
