import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/item_stock.dart';
import 'package:push_sale/views/signed/widgets/warehouses/product_reception.dart';
import 'package:push_sale/const/globals.dart' as global;

class ShowDetailWarehouse extends StatelessWidget {
  WarehouseController warehouseController = Get.find();
  PageController pageController;
  PageController _pageController = PageController();
  ShowDetailWarehouse(this.pageController);

  @override
  Widget build(BuildContext context) {
    warehouseController.adjustedPrice = [];
    warehouseController.adjustedStock = [];
    warehouseController.adjusted.value = [];
    warehouseController.outOfStock.value = [];
    return WillPopScope(
      onWillPop: () async {
        pageController.jumpToPage(0);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(warehouseController.warehouse!.name),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      {
                        var response =
                            await warehouseController.adjustPriceStock();
                        if (response.status == "SUCCESS") {
                          AwesomeDialog(
                              dialogType: DialogType.success,
                              title: "sure".tr,
                              body: Text("succefully.saved".tr),
                              context: context,
                              btnOkOnPress: () async {
                                pageController.jumpToPage(0);
                              })
                            ..show();
                        } else {
                          if (warehouseController.adjustedPrice.length > 0) {
                            Flushbar(
                              title: "info".tr,
                              message: "price.is.updated.if.changed".tr,
                              titleColor: Color.fromARGB(255, 255, 255, 255),
                              messageColor: Color.fromARGB(255, 253, 254, 255),
                              duration: Duration(seconds: 3),
                              icon: Icon(Icons.check,
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              backgroundColor:
                                  Color.fromARGB(255, 122, 122, 122),
                              flushbarPosition: FlushbarPosition.TOP,
                              borderRadius: BorderRadius.circular(10),
                              // borderColor: Color.fromARGB(255, 186, 224, 255),
                            )..show(context);
                          }
                          AwesomeDialog(
                              dialogType: DialogType.error,
                              title: "error".tr,
                              body: Text("quantity.not.available".tr),
                              context: context,
                              btnOkOnPress: () {})
                            ..show();
                        }
                      }
                      break;
                    case 1:
                      {
                        Get.to(() => ProductReception());
                      }
                      break;
                  }
                },
                elevation: 5,
                icon: Icon(Icons.menu),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("reception.product".tr),
                          Icon(Icons.receipt_long, color: Colors.blue),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 0,
                      enabled: warehouseController.adjusted.length > 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("apply.adjust".tr),
                          Icon(Icons.inventory_sharp, color: Colors.blue),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("print.stock".tr),
                            Icon(Icons.print, color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                      enabled: true,
                      value: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("printer.settings".tr,
                              style: TextStyle(color: Colors.black)),
                          Icon(Icons.bluetooth, color: Colors.blue),
                        ],
                      ),
                    ),
                  ];
                })
          ],
        ),
        body: Container(
          width: Get.width,
          height: Get.height,
          child: Column(
            children: [
              Container(
                height: Get.height - 146,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    warehouseController.page.value = value;
                  },
                  children: [
                    PageVariantDetail(filter: "All"),
                    PageVariantDetail(
                      filter: "AvailableOnly",
                    ),
                    PageVariantDetail(
                      filter: "OnAlertOnly",
                    ),
                    PageVariantDetail(
                      filter: "outOfStock",
                    ),
                  ],
                ),
              ),
              Divider(
                height: 5,
              ),
              Obx(
                () => Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: Get.width / 4 - 2,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor(0, warehouseController.page.value),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: borderColor(
                                  0, warehouseController.page.value)),
                        ),
                        child: Center(child: Text("all".tr)),
                      ),
                      Container(
                        width: Get.width / 4 - 2,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor(1, warehouseController.page.value),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: borderColor(
                                  1, warehouseController.page.value)),
                        ),
                        child: Center(child: Text("dispo.only".tr)),
                      ),
                      Container(
                        width: Get.width / 4 - 2,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor(2, warehouseController.page.value),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: borderColor(
                                  2, warehouseController.page.value)),
                        ),
                        child: Center(child: Text("alert.only".tr)),
                      ),
                      Container(
                        width: Get.width / 4 - 2,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor(3, warehouseController.page.value),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: borderColor(
                                  3, warehouseController.page.value)),
                        ),
                        child: Center(child: Text("empty.only".tr)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color borderColor(int current, int selected) {
    if (current == selected) {
      return Color.fromARGB(255, 213, 212, 255);
    }
    return Color.fromARGB(255, 249, 249, 255);
  }

  Color bgColor(int current, int selected) {
    if (current == selected) {
      return Color.fromARGB(255, 232, 228, 255);
    }
    return Color.fromARGB(255, 248, 248, 255);
  }
}

class PageVariantDetail extends StatelessWidget {
  String filter;
  PageVariantDetail({required this.filter});
  WarehouseController warehouseController = Get.find();
  var formatter = new NumberFormat("#,##0.00", "fr_FR");
  @override
  Widget build(BuildContext context) {
    List<ItemStock> list = [];
    switch (filter) {
      case "AvailableOnly":
        list = warehouseController.warehouse!.items
            .where(
              (element) =>
                  element.quantity / element.package > global.alertQuantity,
            )
            .toList();
        break;
      case "OnAlertOnly":
        list = warehouseController.warehouse!.items
            .where(
              (element) =>
                  element.quantity / element.package <= global.alertQuantity &&
                  element.quantity > 0,
            )
            .toList();
        break;
      case "outOfStock":
        list = warehouseController.warehouse!.items
            .where(
              (element) => element.quantity == 0,
            )
            .toList();
        break;
      default:
        list = warehouseController.warehouse!.items;
    }
    return GestureDetector(
      onDoubleTap: () {
        warehouseController.UniteIsCaisse.value =
            !warehouseController.UniteIsCaisse.value;
      },
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          var item = list[index];
          var stockCh = warehouseController.adjustedStock
              .where((element) => element.variant_id == item.variant_id);

          return Obx(
            () => Container(
              decoration: BoxDecoration(
                color: warehouseController.adjusted
                        .where((el) => el == item.variant_id)
                        .isNotEmpty
                    ? warehouseController.outOfStock
                            .where((el) => el == item.variant_id)
                            .isNotEmpty
                        ? Color.fromARGB(255, 255, 212, 209)
                        : Color.fromARGB(255, 189, 248, 191)
                    : null,
              ),
              child: ListTile(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController quantityController =
                            TextEditingController();
                        bool changedStock = false;
                        bool changedPrice = false;
                        GlobalKey<FormState> frm = GlobalKey<FormState>();
                        return Form(
                          key: frm,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            titlePadding: EdgeInsets.zero,
                            title: Container(
                              width: Get.width,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.getShortDescription(
                                        Get.locale!.languageCode),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    item.getVariantName1(
                                            Get.locale!.languageCode) +
                                        " " +
                                        item.getVariantName2(
                                            Get.locale!.languageCode),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            content: Container(
                              width: Get.width,
                              height: 60 * (item.prices!.length + 1),
                              color: Colors.white,
                              child: Column(
                                children: List.generate(
                                  item.prices!.length + 1,
                                  (index) {
                                    if (index < item.prices!.length) {
                                      var el = item.prices![index];
                                      TextEditingController priceController =
                                          TextEditingController();
                                      var exist = warehouseController
                                          .adjustedPrice
                                          .where(
                                              (element) => element.id == el.id);
                                      priceController.text = exist.isNotEmpty
                                          ? exist.first.price.toString()
                                          : el.price.toString();
                                      return Container(
                                        height: 60,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("saleprice".tr),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              width: Get.width / 4,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == "" ||
                                                      double.parse(value!) ==
                                                          0) {
                                                    return "zero.not.allowed"
                                                        .tr;
                                                  }
                                                  if (double.parse(value)
                                                      is double) {
                                                    return null;
                                                  }
                                                  return "error".tr;
                                                },
                                                controller: priceController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  labelText: el.typepv_id !=
                                                          null
                                                      ? el.typepv_id.toString()
                                                      : "all".tr,
                                                ),
                                                onChanged: (value) {
                                                  changedPrice = true;
                                                },
                                                onSaved: (value) {
                                                  //
                                                  if (changedPrice) {
                                                    if (warehouseController
                                                        .adjustedPrice
                                                        .where((element) =>
                                                            element.id == el.id)
                                                        .isEmpty) {
                                                      warehouseController
                                                          .adjustedPrice
                                                          .add(PriceItem(
                                                              id: el.id,
                                                              variant_id:
                                                                  el.variant_id,
                                                              price: value != ""
                                                                  ? double.parse(
                                                                      value
                                                                          .toString())
                                                                  : 0,
                                                              typepv_id: el
                                                                  .typepv_id));
                                                    } else {
                                                      warehouseController
                                                          .adjustedPrice
                                                          .where((element) =>
                                                              element.id ==
                                                              el.id)
                                                          .first
                                                          .updatePrice(value !=
                                                                  ""
                                                              ? double.parse(value
                                                                  .toString())
                                                              : 0);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      var exist = warehouseController
                                          .adjustedStock
                                          .where((element) =>
                                              element.variant_id ==
                                              item.variant_id);
                                      quantityController.text = exist.isNotEmpty
                                          ? exist.first.quantity
                                              .toStringAsFixed(0)
                                          : item.quantity.toStringAsFixed(0);
                                      return Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        height: 60,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("quantity".tr),
                                            Container(
                                              width: Get.width / 4,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == "" ||
                                                      double.parse(value!) ==
                                                          0) {
                                                    return "zero.not.allowed"
                                                        .tr;
                                                  }
                                                  if (double.parse(value)
                                                      is double) {
                                                    return null;
                                                  }
                                                  return "error".tr;
                                                },
                                                controller: quantityController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  labelText: "Pcs".tr,
                                                ),
                                                onChanged: (value) {
                                                  changedStock = true;
                                                },
                                                onSaved: (value) {
                                                  if (changedStock) {
                                                    var toAdjust =
                                                        warehouseController
                                                            .adjustedStock
                                                            .where((element) =>
                                                                element
                                                                    .variant_id ==
                                                                item.variant_id);
                                                    if (toAdjust.isEmpty) {
                                                      warehouseController
                                                          .adjustedStock
                                                          .add(AdjutStockItem(
                                                              variant_id: item
                                                                  .variant_id,
                                                              quantity: value !=
                                                                      ""
                                                                  ? double.parse(
                                                                      value
                                                                          .toString())
                                                                  : 0));
                                                    } else {
                                                      toAdjust.first
                                                          .updateStock(value !=
                                                                  ""
                                                              ? double.parse(value
                                                                  .toString())
                                                              : 0);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            actions: [
                              MaterialButton(
                                color: Colors.blue,
                                height: 50,
                                minWidth: double.infinity,
                                onPressed: () {
                                  if (changedPrice || changedStock) {
                                    var currentState = frm.currentState;
                                    if (currentState!.validate()) {
                                      currentState.save();
                                      warehouseController.adjusted
                                          .add(item.variant_id);
                                      Get.back();
                                    } else {}
                                  } else {
                                    Get.back();
                                  }
                                },
                                shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                                child: Text(
                                  "adjust".tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        );
                      });
                },
                title: Text(item.getShortDescription(Get.locale!.languageCode),
                    style: TextStyle(
                        color: item.quantity == 0
                            ? Color.fromARGB(255, 173, 173, 173)
                            : (item.quantity / item.package) <=
                                    global.alertQuantity
                                ? Colors.red
                                : null)),
                leading: Container(
                  width: 40,
                  height: 40,
                  child: CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config(
                        item.image,
                        stalePeriod: const Duration(days: 7),
                      ),
                    ),
                    imageUrl: item.image,
                    placeholder: (context, url) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                subtitle: Text(
                  item.getVariantName1(Get.locale!.languageCode) +
                      " " +
                      item.getVariantName2(Get.locale!.languageCode),
                  style: TextStyle(
                      color: item.quantity == 0
                          ? Color.fromARGB(255, 204, 204, 204)
                          : (item.quantity / item.package) <= 5
                              ? Color.fromARGB(255, 255, 157, 150)
                              : null),
                ),
                trailing: Container(
                  width: Get.locale!.languageCode == "ar" ? 120 : 100,
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          formatter.format(
                              warehouseController.UniteIsCaisse.value
                                  ? item.stock_price
                                  : item.stock_price * item.quantity),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.quantity == 0
                                  ? Color.fromARGB(255, 204, 204, 204)
                                  : (item.quantity / item.package) <=
                                          global.alertQuantity
                                      ? Colors.red
                                      : null)),
                      Text(
                        "${warehouseController.UniteIsCaisse.value ? (item.quantity / item.package).ceil().toString() : item.quantity.ceil().toString()}" +
                            (stockCh.isNotEmpty
                                ? (Get.locale!.languageCode != "ar"
                                        ? " → "
                                        : " ← ") +
                                    (warehouseController.UniteIsCaisse.value
                                            ? (stockCh.first.quantity /
                                                    item.package)
                                                .ceil()
                                            : stockCh.first.quantity)
                                        .toStringAsFixed(0)
                                : "") +
                            (warehouseController.UniteIsCaisse.value
                                ? " " + "Cart".tr
                                : " " + "Pcs".tr),
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: item.quantity == 0
                                ? Color.fromARGB(255, 223, 223, 223)
                                : (item.quantity / item.package) <= 5
                                    ? Color.fromARGB(255, 255, 157, 150)
                                    : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
