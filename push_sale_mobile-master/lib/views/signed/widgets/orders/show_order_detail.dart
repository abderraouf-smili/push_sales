import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';

class ShowOrderDetail extends StatelessWidget {
  PrinterController printerController = Get.put(PrinterController());
  OrderController orderController = Get.put(OrderController());
  Order order;
  ShowOrderDetail(this.order);

  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(order.code),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case 0:
                  {
                    if (printerController.isSaved) {
                      //   // printer is saved and ready to check if it is online or no

                      orderController.PrepareToPrintOrder(MyOrder: order);
                      String response = await printerController.StartPrinting(
                          orderController.textPrint);
                      switch (response) {
                        case "ok":
                          Flushbar(
                            title: "print".tr,
                            message: "printing".tr,
                            titleColor: Color.fromARGB(255, 255, 255, 255),
                            messageColor: Color.fromARGB(255, 253, 254, 255),
                            duration: Duration(seconds: 3),
                            icon: Icon(Icons.check,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            backgroundColor: Color.fromARGB(255, 122, 122, 122),
                            flushbarPosition: FlushbarPosition.TOP,
                            borderRadius: BorderRadius.circular(10),
                            // borderColor: Color.fromARGB(255, 186, 224, 255),
                          )..show(context);
                          break;
                        case "not_available":
                          Flushbar(
                            title: "print".tr,
                            message: "print.not_available".tr,
                            titleColor: Color.fromARGB(255, 255, 255, 255),
                            messageColor: Color.fromARGB(255, 253, 254, 255),
                            duration: Duration(seconds: 3),
                            icon: Icon(Icons.check,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            backgroundColor: Color.fromARGB(255, 122, 122, 122),
                            flushbarPosition: FlushbarPosition.TOP,
                            borderRadius: BorderRadius.circular(10),
                            // borderColor: Color.fromARGB(255, 186, 224, 255),
                          )..show(context);
                          break;
                        case "bluetooth_pb":
                          Flushbar(
                            title: "print".tr,
                            message: "bluetooth.problem".tr,
                            titleColor: Color.fromARGB(255, 255, 255, 255),
                            messageColor: Color.fromARGB(255, 253, 254, 255),
                            duration: Duration(seconds: 3),
                            icon: Icon(Icons.check,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            backgroundColor: Color.fromARGB(255, 122, 122, 122),
                            flushbarPosition: FlushbarPosition.TOP,
                            borderRadius: BorderRadius.circular(10),
                            // borderColor: Color.fromARGB(255, 186, 224, 255),
                          )..show(context);

                          break;
                        case "unknown":
                          Flushbar(
                            title: "print".tr,
                            message: "printer.pb.link".tr,
                            titleColor: Color.fromARGB(255, 255, 255, 255),
                            messageColor: Color.fromARGB(255, 253, 254, 255),
                            duration: Duration(seconds: 3),
                            icon: Icon(Icons.check,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            backgroundColor: Color.fromARGB(255, 122, 122, 122),
                            flushbarPosition: FlushbarPosition.TOP,
                            borderRadius: BorderRadius.circular(10),
                            // borderColor: Color.fromARGB(255, 186, 224, 255),
                          )..show(context);

                          break;
                        default:
                      }
                    } else {
                      // printer is not configured
                      ShowButtomSheetPrinterConfig(context: context);
                    }
                  }
                  break;
                case 1:
                  ShowButtomSheetPrinterConfig(context: context);
                  break;
              }
            },
            elevation: 5,
            icon: Icon(Icons.menu),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  enabled: true,
                  value: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("print".tr, style: TextStyle(color: Colors.black)),
                      Icon(Icons.print, color: Colors.blue),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: true,
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("printer.settings".tr,
                          style: TextStyle(color: Colors.black)),
                      Icon(Icons.bluetooth, color: Colors.blue),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: false,
                  value: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "export".tr,
                        style: TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                      Icon(Icons.picture_as_pdf_sharp, color: Colors.blue),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: false,
                  value: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "send".tr,
                        style: TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                      Icon(Icons.send, color: Colors.blue),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: Get.height * 3 / 4,
            child: ListView.builder(
                itemCount: order.orderitems.length,
                itemBuilder: (context, index) {
                  var item = order.orderitems[index];
                  return ListTile(
                    title: Text(item.product_name +
                        (item.discount != 0
                            ? " (-" + item.discount.toStringAsFixed(0) + "%)"
                            : "")),
                    subtitle: Text(item.variant_name_1 +
                        " " +
                        (item.variant_name_2 ?? "")),
                    leading: CachedNetworkImage(
                      cacheManager: CacheManager(
                        Config(
                          item.image,
                          stalePeriod: const Duration(days: 7),
                        ),
                      ),
                      imageUrl: item.image,
                      placeholder: (context, url) =>
                          Container(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(formatter.format(item.total)),
                        Text(
                            item.quantity.toStringAsFixed(0) + " " + item.unite)
                      ],
                    ),
                  );
                }),
          ),
          Container(
            width: double.infinity,
            height: Get.height * 0.10,
          ),
        ],
      ),
    ));
  }
}
