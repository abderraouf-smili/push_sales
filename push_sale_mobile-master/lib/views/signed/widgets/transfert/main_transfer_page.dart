import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/controllers/stock_operation_controller.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';
import 'package:push_sale/views/signed/widgets/transfert/orders_page.dart';
import 'package:push_sale/views/signed/widgets/transfert/show_detail_transfer.dart';
import 'package:push_sale/views/signed/widgets/transfert/stock_location_page.dart';
import 'package:push_sale/views/signed/widgets/transfert/tranfer_page.dart';

class MainTransferPage extends StatelessWidget {
  PurchaseOrderController purchaseController =
      Get.put(PurchaseOrderController(tag: "delivery"));
  StockOperationController stockController =
      Get.put(StockOperationController());
  PageController pageController = PageController();
  WarehouseController warehouseController =
      Get.put(WarehouseController(tag: "delivery"));
  PrinterController printerController = Get.put(PrinterController());

  MainTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    stockController.page.value = 0;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SizedBox(
        width: Get.width,
        height: Get.height - 80,
        child: Column(
          children: [
            Container(
              height: 50,
              width: Get.width,
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: Get.width - 50,
                    child: Center(
                      child: Text(
                        "orders.ready.toship".tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) async {
                      switch (value) {
                        case 0:
                          await purchaseController.getOrderReadyToPack();
                          break;
                        case 1:
                          {
                            var response =
                                await purchaseController.generateTransfer();
                            if (response.status == "SUCCESS") {
                              Flushbar(
                                title: "success".tr,
                                message: "transfer.is.ready.to.confirm".tr,
                                titleColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                messageColor:
                                    const Color.fromARGB(255, 253, 254, 255),
                                duration: const Duration(seconds: 3),
                                icon: const Icon(Icons.check,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                backgroundColor:
                                    const Color.fromARGB(255, 122, 122, 122),
                                flushbarPosition: FlushbarPosition.TOP,
                                borderRadius: BorderRadius.circular(10),
                                // borderColor: Color.fromARGB(255, 186, 224, 255),
                              ).show(context);
                              await stockController.getBonChargement();
                              await warehouseController.getCurrentStockMobile();
                            } else {
                              //
                            }
                          }
                          break;
                        case 2:
                          // print button
                          {
                            switch (stockController.page.value) {
                              case 0:
                                // Bons de livraison
                                break;
                              case 1:
                                // Bon de transferts
                                break;
                              case 2:
                                // stock actuel
                                warehouseController.prepareToPrintStock();
                                await printerController.ScanPrinter();
                                String response =
                                    await printerController.StartPrinting(
                                        warehouseController.textPrint);
                                break;
                              case 3:
                                // detail du bon de transfert
                                stockController.PrepareToTransferPrint();
                                await printerController.ScanPrinter();
                                String response =
                                    await printerController.StartPrinting(
                                        stockController.textPrint);
                                switch (response) {
                                  case "ok":
                                    Flushbar(
                                      title: "print".tr,
                                      message: "printing".tr,
                                      titleColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      messageColor: const Color.fromARGB(
                                          255, 253, 254, 255),
                                      duration: const Duration(seconds: 3),
                                      icon: const Icon(Icons.check,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      backgroundColor: const Color.fromARGB(
                                          255, 122, 122, 122),
                                      flushbarPosition: FlushbarPosition.TOP,
                                      borderRadius: BorderRadius.circular(10),
                                      // borderColor: Color.fromARGB(255, 186, 224, 255),
                                    ).show(context);
                                    break;
                                  case "not_available":
                                    AwesomeDialog(
                                            dialogType: DialogType.error,
                                            title: "print".tr,
                                            body:
                                                Text("print.not_available".tr),
                                            context: context,
                                            btnOkOnPress: () {})
                                        .show();
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
                                        }).show();

                                    break;
                                  case "unknown":
                                    AwesomeDialog(
                                        dialogType: DialogType.error,
                                        title: "print".tr,
                                        body: Text("printer.pb.link".tr),
                                        context: context,
                                        btnOkOnPress: () {
                                          ShowButtomSheetPrinterConfig(
                                            context: context,
                                          );
                                        }).show();

                                    break;
                                  default:
                                }
                                break;
                            }
                          }
                          break;
                        case 3:
                          {
                            await printerController.ScanPrinter();
                            ShowButtomSheetPrinterConfig(context: context);
                            break;
                          }
                        case 4:
                          // confirm transfer
                          var response = await stockController.confimTransfer();
                          if (response.status == "SUCCESS") {
                            stockController.stock_out.value = false;
                            stockController.unvalaibleProduct = [];
                            Flushbar(
                              title: "success".tr,
                              message: "transfer.confirmed".tr,
                              titleColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              messageColor:
                                  const Color.fromARGB(255, 253, 254, 255),
                              duration: const Duration(seconds: 3),
                              icon: const Icon(Icons.check,
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              backgroundColor:
                                  const Color.fromARGB(255, 122, 122, 122),
                              flushbarPosition: FlushbarPosition.TOP,
                              borderRadius: BorderRadius.circular(10),
                              // borderColor: Color.fromARGB(255, 186, 224, 255),
                            ).show(context);
                            await stockController.getBonChargement();
                            await warehouseController.getCurrentStockMobile();
                          } else {
                            Flushbar(
                              title: response.message,
                              message: "quantity.not.available".tr,
                              titleColor: Colors.red,
                              messageColor: Colors.red,
                              duration: const Duration(seconds: 3),
                              icon: const Icon(Icons.error, color: Colors.red),
                              backgroundColor:
                                  const Color.fromARGB(255, 206, 206, 206),
                              flushbarPosition: FlushbarPosition.TOP,
                              borderRadius: BorderRadius.circular(10),
                              // borderColor: Color.fromARGB(255, 186, 224, 255),
                            ).show(context);
                            stockController.unvalaibleProduct = response.data;
                            stockController.stock_out.value = true;
                            print(response.message);
                            print(response.data);
                          }
                          break;
                      }
                    },
                    elevation: 5,
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "refresh".tr,
                                style: const TextStyle(color: Colors.black),
                              ),
                              const Icon(Icons.refresh, color: Colors.blue),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          enabled: stockController.page.value == 0 &&
                              purchaseController.BLs.isNotEmpty,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "generate.bt".tr,
                                style: TextStyle(
                                    color: stockController.page.value == 0 &&
                                            purchaseController.BLs.isNotEmpty
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                              const Icon(Icons.precision_manufacturing_sharp,
                                  color: Colors.blue),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          enabled: (stockController.page.value == 3 &&
                                  stockController.itemSelected!.state !=
                                      "new") ||
                              stockController.page.value == 2 ||
                              stockController.confirmed.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "print".tr,
                                style: TextStyle(
                                    color: (stockController.page.value == 3 &&
                                                stockController
                                                        .itemSelected!.state !=
                                                    "new") ||
                                            stockController.page.value == 2 ||
                                            stockController.confirmed.value
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                              const Icon(Icons.print, color: Colors.blue),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          enabled: true,
                          value: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("printer.settings".tr,
                                  style: const TextStyle(color: Colors.black)),
                              const Icon(Icons.bluetooth, color: Colors.blue),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 4,
                          enabled: stockController.page.value == 3 &&
                              stockController.itemSelected!.state == "new",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "confirm.bt".tr,
                                style: TextStyle(
                                    color: stockController.page.value == 3 &&
                                            stockController
                                                    .itemSelected!.state ==
                                                "new"
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                              const Icon(Icons.check, color: Colors.green),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
                width: double.infinity,
                height: Get.height - 204,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (value) {
                    stockController.page.value = value;
                  },
                  children: [
                    OrdersPage(),
                    TransferPage(pageController),
                    StockLocationPage(),
                    ShowDetailTransfer(pageController),
                  ],
                )),
            SizedBox(
                width: Get.width,
                height: 65,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.linear);
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: Get.width / 3,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: bgColor(0, stockController.page.value),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  width: 1,
                                  color: borderColor(
                                      0, stockController.page.value),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "bl.ready".tr,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            (purchaseController.orts_loaded.value
                                        ? purchaseController
                                            .ordersReadyToShip.length
                                        : purchaseController
                                            .ordersReadyToShip.length) >
                                    0
                                ? Positioned(
                                    top: 0,
                                    left: Get.width / 6 - 15,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                          child: Text(
                                        (purchaseController.orts_loaded.value
                                                ? purchaseController
                                                    .ordersReadyToShip.length
                                                : purchaseController
                                                    .ordersReadyToShip.length)
                                            .toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.linear);
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: Get.width / 3,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: bgColor(1, stockController.page.value),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  width: 1,
                                  color: borderColor(
                                      1, stockController.page.value),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "bt.ready".tr,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            (stockController.opLoaded.value
                                        ? stockController.bonschargement
                                            .where((element) =>
                                                element.state == "new")
                                            .length
                                        : stockController.bonschargement
                                            .where((element) =>
                                                element.state == "new")
                                            .length) >
                                    0
                                ? Positioned(
                                    top: 0,
                                    left: Get.width / 6 - 15,
                                    child: Obx(
                                      () => Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                            child: Text(
                                          (stockController.opLoaded.value
                                                  ? stockController
                                                      .bonschargement
                                                      .where((element) =>
                                                          element.state ==
                                                          "new")
                                                      .length
                                                  : stockController
                                                      .bonschargement
                                                      .where((element) =>
                                                          element.state ==
                                                          "new")
                                                      .length)
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          pageController.animateToPage(2,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.linear);
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: Get.width / 3,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: bgColor(2, stockController.page.value),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  width: 1,
                                  color: borderColor(
                                      2, stockController.page.value),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "location.stock".tr,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Obx(() => warehouseController.QtymustConfirm.value
                                ? Positioned(
                                    top: 0,
                                    left: Get.width / 6 - 15,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                          child: Text(
                                        "!",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )),
                                    ),
                                  )
                                : const SizedBox.shrink())
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color borderColor(int current, int selected) {
    if (current == selected || (current == 1 && selected == 3)) {
      return const Color.fromARGB(255, 213, 212, 255);
    }
    return const Color.fromARGB(255, 249, 249, 255);
  }

  Color bgColor(int current, int selected) {
    if (current == selected || (current == 1 && selected == 3)) {
      return const Color.fromARGB(255, 232, 228, 255);
    }
    return const Color.fromARGB(255, 248, 248, 255);
  }
}
