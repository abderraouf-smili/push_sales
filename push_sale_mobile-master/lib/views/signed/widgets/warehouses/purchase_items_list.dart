import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';

class PurchaseItemsList extends StatelessWidget {
  PurchaseOrderController purchaseController =
      Get.put(PurchaseOrderController());
  PrinterController printerController = Get.find();
  ProductController productController = Get.find();
  PageController pageController = PageController();
  var formatter = new NumberFormat("#,##0.00", "fr_FR");
  PurchaseItemsList(this.pageController);
  @override
  Widget build(BuildContext context) {
    productController.page.value = 0;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (purchaseController.orderitems.isNotEmpty) {
            if (purchaseController.saved.value) {
              AwesomeDialog(
                  dialogType: DialogType.question,
                  title: "sure".tr,
                  body: Text("are.you.sure.to.quit.purchaseorder".tr),
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
          return false;
        },
        child: Scaffold(
          body: Container(
            child: Column(children: [
              // ignore: prefer_const_constructors
              Expanded(
                flex: 1, //orderController.hasChanged.value > 0
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(5),
                  //   border: Border.all(width: 0.2),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            if (purchaseController.orderitems.isNotEmpty) {
                              if (purchaseController.saved.value) {
                                AwesomeDialog(
                                    dialogType: DialogType.question,
                                    title: "sure".tr,
                                    body: Text(
                                        "are.you.sure.to.quit.purchaseorder"
                                            .tr),
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
                          },
                          icon: Icon(Icons.arrow_back)),
                      Text(
                        "Bon de reception",
                        style: TextStyle(fontSize: 22),
                      ),
                      PopupMenuButton(
                          onSelected: (value) async {
                            switch (value) {
                              case 0:
                                {
                                  var response =
                                      await purchaseController.save();
                                  if (response.status == "SUCCESS") {
                                    purchaseController.saved.value = true;
                                    purchaseController.OrderCode =
                                        response.data["code"];
                                    AwesomeDialog(
                                        dialogType: DialogType.success,
                                        title: "sure".tr,
                                        body: Text("succefully.saved".tr),
                                        context: context,
                                        btnOkOnPress: () {})
                                      ..show();
                                  } else if (response.data != null) {
                                    // AwesomeDialog(
                                    //     dialogType: DialogType.error,
                                    //     title: "sure".tr,
                                    //     body: Text("quantity.not.available".tr),
                                    //     context: context,
                                    //     btnOkOnPress: () {})
                                    //   ..show();
                                    // purchaseController.out_of_stock.value = [];
                                    // for (var item in response.data) {
                                    //   orderController.out_of_stock.add(item);
                                    // }
                                    // await productController.getProducts();
                                  } else {
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
                                  if (purchaseController.isSaved) {
                                    //   // printer is saved and ready to check if it is online or no
                                    purchaseController.PrepareToPrint();
                                    await printerController.ScanPrinter();
                                    String response =
                                        await printerController.StartPrinting(
                                            purchaseController.textPrint);
                                    switch (response) {
                                      case "ok":
                                        AwesomeDialog(
                                            dialogType: DialogType.info,
                                            title: "sure".tr,
                                            body: Text("printing".tr),
                                            context: context,
                                            btnOkOnPress: () {})
                                          ..show();
                                        break;
                                      case "not_available":
                                        AwesomeDialog(
                                            dialogType: DialogType.error,
                                            title: "sure".tr,
                                            body:
                                                Text("print.not_available".tr),
                                            context: context,
                                            btnOkOnPress: () {})
                                          ..show();
                                        break;
                                      case "bluetooth_pb":
                                        AwesomeDialog(
                                            dialogType: DialogType.error,
                                            title: "sure".tr,
                                            body: Text("bluetooth.problem".tr),
                                            context: context,
                                            btnOkOnPress: () {
                                              ShowButtomSheetPrinterConfig(
                                                  context: context);
                                            })
                                          ..show();

                                        break;
                                      case "unknown":
                                        AwesomeDialog(
                                            dialogType: DialogType.error,
                                            title: "sure".tr,
                                            body: Text("printer.pb.link".tr),
                                            context: context,
                                            btnOkOnPress: () {
                                              ShowButtomSheetPrinterConfig(
                                                context: context,
                                              );
                                            })
                                          ..show();

                                        break;
                                      default:
                                    }
                                  } else {
                                    // printer is not configured
                                    ShowButtomSheetPrinterConfig(
                                        context: context);
                                  }
                                }
                                break;
                              case 2:
                                await printerController.ScanPrinter();
                                ShowButtomSheetPrinterConfig(context: context);
                                break;
                              case 3:
                                if (purchaseController.saved.value ||
                                    purchaseController.orderitems.isEmpty) {
                                  Get.offAllNamed("/HomePage");
                                }
                                break;
                            }
                          },
                          elevation: 5,
                          icon: Icon(Icons.menu),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                enabled: !purchaseController.saved.value &&
                                    purchaseController.orderitems.isNotEmpty,
                                value: 0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "save".tr,
                                      style: TextStyle(
                                          color:
                                              purchaseController.saved.value ||
                                                      purchaseController
                                                          .orderitems.isEmpty
                                                  ? Colors.grey
                                                  : Colors.black),
                                    ),
                                    Icon(Icons.save_sharp,
                                        color: purchaseController.saved.value ||
                                                purchaseController
                                                    .orderitems.isEmpty
                                            ? Colors.grey
                                            : Colors.blue),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                enabled: purchaseController.saved.value,
                                value: 1,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("print".tr,
                                        style: TextStyle(
                                            color:
                                                !purchaseController.saved.value
                                                    ? Colors.grey
                                                    : Colors.black)),
                                    Icon(Icons.print,
                                        color: !purchaseController.saved.value
                                            ? Colors.grey
                                            : Colors.blue),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                enabled: true,
                                value: 2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("printer.settings".tr,
                                        style: TextStyle(color: Colors.black)),
                                    Icon(Icons.bluetooth, color: Colors.blue),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "close".tr,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Icon(Icons.close, color: Colors.blue),
                                  ],
                                ),
                              )
                            ];
                          }),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 0.2),
                  ),
                  width: double.infinity,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: purchaseController.orderitems.length,
                      itemBuilder: (context, index) {
                        var _item = purchaseController.orderitems[index];
                        return Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              purchaseController.removeItem(_item);
                            }
                          },
                          key: Key(_item.id.toString()),
                          child: ListTile(
                            title: Text(
                              _item.product_name,
                              style:
                                  TextStyle(), // <<======================= change color for no stock
                            ),
                            subtitle: Text(
                              "${_item.variant_name_1}  ${_item.variant_name_2} ",
                              style: TextStyle(
                                fontSize: 12,
                              ), // <<======================= change color for no stock
                            ),
                            leading: CachedNetworkImage(
                              cacheManager: CacheManager(
                                Config(
                                  _item.image,
                                  stalePeriod: const Duration(days: 7),
                                ),
                              ),
                              imageUrl: _item.image,
                              placeholder: (context, url) =>
                                  Container(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            trailing: Container(
                              width: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      formatter.format(purchaseController
                                          .orderitems[index].total),
                                      style: TextStyle(
                                        fontFamily: 'alata',
                                        // <<======================= change color for no stock
                                      )),
                                  Text(
                                    "${_item.quantity.toStringAsFixed(0)} " +
                                        _item.unite.tr,
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 165, 165,
                                            165), // <<======================= change color for no stock
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Expanded(
                flex: 1, //orderController.hasChanged.value > 0
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 0.2),
                  ),
                  child: Column(
                    children: [
                      Container(
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total  "),
                              Text(
                                formatter
                                    .format(purchaseController.total.value),
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'alata'),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Obx(
                  () => productController.page.value == 0 &&
                          !purchaseController.saved.value
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: FloatingActionButton(
                            onPressed: () {
                              pageController.jumpToPage(1);
                              productController.page.value = 1;
                              print(productController.page.value);
                            },
                            child: const Icon(Icons.add),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
