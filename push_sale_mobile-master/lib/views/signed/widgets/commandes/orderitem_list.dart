// ignore_for_file: prefer_const_constructors, duplicate_ignore, use_key_in_widget_constructors, unnecessary_string_interpolations, prefer_final_fields, avoid_single_cascade_in_expression_statements, no_leading_underscores_for_local_identifiers

import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/line_text_printer.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';
import 'package:push_sale/const/globals.dart' as global;

class OrderitemList extends StatelessWidget {
  Client _client;
  PageController pageController;
  var formatter = NumberFormat("#,##0.00", "fr_FR");
  OrderitemList(this._client, this.pageController);
  PrinterController printerController = Get.put(PrinterController());
  OrderController orderController = Get.find();
  ClientController clientController = Get.find();
  ProductController productController = Get.find();

  @override
  Widget build(BuildContext context) {
    int diff = 1;
    for (var element in global.weekend) {
      int i = 0;
      for (var item in global.weekend) {
        if (element ==
            DateFormat("EEEE")
                .format(DateTime.now().add(Duration(days: i + 1)))
                .toLowerCase()) {
          diff++;
        }
        i++;
      }
    }
    DateTime today = DateTime.now().add(Duration(days: diff));
    orderController.planned_delivery_date =
        DateTime(today.year, today.month, today.day, today.hour, today.minute);
    orderController.deliverySet.value = true;
    orderController.clientId = _client.id;
    productController.page.value = 0;

    if (orderController.orderitems.isEmpty) {
      orderController.coupon = null;
      orderController.couponLoaded.value = 0;
    } else {
      if (orderController.orderitems
          .where((element) => element.coupon_id != null)
          .isEmpty) {
        orderController.coupon = null;
        orderController.couponLoaded.value = 0;
      }
    }

    return Container(
      child: Column(children: [
        // ignore: prefer_const_constructors
        Expanded(
          flex: 2, //orderController.hasChanged.value > 0
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
                    },
                    icon: Icon(Icons.arrow_back)),
                Text(_client.name),
                PopupMenuButton(
                    onSelected: (value) async {
                      switch (value) {
                        case 0:
                          {
                            var response = await orderController.save();
                            if (response.status == "SUCCESS") {
                              // if (true) {
                              orderController.saved.value = true;
                              orderController.OrderCode = response.data["code"];
                              AwesomeDialog(
                                  dialogType: DialogType.success,
                                  title: "sure".tr,
                                  body: Text("succefully.saved".tr),
                                  context: context,
                                  btnOkOnPress: () {})
                                ..show();
                            } else if (response.data != null) {
                              AwesomeDialog(
                                  dialogType: DialogType.error,
                                  title: "sure".tr,
                                  body: Text("quantity.not.available".tr),
                                  context: context,
                                  btnOkOnPress: () {})
                                ..show();
                              orderController.out_of_stock.value = [];
                              for (var item in response.data) {
                                orderController.out_of_stock.add(item);
                              }
                              await productController.getProducts();
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
                            if (printerController.isSaved) {
                              //   // printer is saved and ready to check if it is online or no
                              orderController.PrepareToPrintOrder();

                              await printerController.ScanPrinter();
                              String response =
                                  await printerController.StartPrinting(
                                      orderController.textPrint);
                              switch (response) {
                                case "ok":
                                  Flushbar(
                                    title: "print".tr,
                                    message: "printing".tr,
                                    titleColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    messageColor:
                                        Color.fromARGB(255, 253, 254, 255),
                                    duration: Duration(seconds: 3),
                                    icon: Icon(Icons.check,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    backgroundColor:
                                        Color.fromARGB(255, 122, 122, 122),
                                    flushbarPosition: FlushbarPosition.TOP,
                                    borderRadius: BorderRadius.circular(10),
                                    // borderColor: Color.fromARGB(255, 186, 224, 255),
                                  )..show(context);
                                  break;
                                case "not_available":
                                  Flushbar(
                                    title: "print".tr,
                                    message: "print.not_available".tr,
                                    titleColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    messageColor:
                                        Color.fromARGB(255, 253, 254, 255),
                                    duration: Duration(seconds: 3),
                                    icon: Icon(Icons.check,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    backgroundColor:
                                        Color.fromARGB(255, 122, 122, 122),
                                    flushbarPosition: FlushbarPosition.TOP,
                                    borderRadius: BorderRadius.circular(10),
                                    // borderColor: Color.fromARGB(255, 186, 224, 255),
                                  )..show(context);
                                  break;
                                case "bluetooth_pb":
                                  Flushbar(
                                    title: "print".tr,
                                    message: "bluetooth.problem".tr,
                                    titleColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    messageColor:
                                        Color.fromARGB(255, 253, 254, 255),
                                    duration: Duration(seconds: 3),
                                    icon: Icon(Icons.check,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    backgroundColor:
                                        Color.fromARGB(255, 122, 122, 122),
                                    flushbarPosition: FlushbarPosition.TOP,
                                    borderRadius: BorderRadius.circular(10),
                                    // borderColor: Color.fromARGB(255, 186, 224, 255),
                                  )..show(context);

                                  break;
                                case "unknown":
                                  Flushbar(
                                    title: "print".tr,
                                    message: "printer.pb.link".tr,
                                    titleColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    messageColor:
                                        Color.fromARGB(255, 253, 254, 255),
                                    duration: Duration(seconds: 3),
                                    icon: Icon(Icons.check,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    backgroundColor:
                                        Color.fromARGB(255, 122, 122, 122),
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
                        case 2:
                          await printerController.ScanPrinter();
                          ShowButtomSheetPrinterConfig(context: context);
                          break;
                        case 3:
                          if (orderController.saved.value ||
                              orderController.orderitems.isEmpty) {
                            Get.offAllNamed("/HomePage", arguments: {
                              "client_id": orderController.clientId
                            });
                          }
                          break;
                        case 5:
                          showCouponWindow(context, orderController);
                          break;
                      }
                    },
                    elevation: 5,
                    icon: Icon(Icons.menu),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          enabled: !orderController.saved.value &&
                              orderController.orderitems.isNotEmpty,
                          value: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "save".tr,
                                style: TextStyle(
                                    color: orderController.saved.value ||
                                            orderController.orderitems.isEmpty
                                        ? Colors.grey
                                        : Colors.black),
                              ),
                              Icon(Icons.save_sharp,
                                  color: orderController.saved.value ||
                                          orderController.orderitems.isEmpty
                                      ? Colors.grey
                                      : Colors.blue),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          enabled: orderController.saved.value,
                          value: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("print".tr,
                                  style: TextStyle(
                                      color: !orderController.saved.value
                                          ? Colors.grey
                                          : Colors.black)),
                              Icon(Icons.print,
                                  color: !orderController.saved.value
                                      ? Colors.grey
                                      : Colors.blue),
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
                          enabled: !orderController.saved.value &&
                              orderController.orderitems.isNotEmpty,
                          value: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "use.coupon".tr,
                                style: TextStyle(color: Colors.black),
                              ),
                              Icon(Icons.redeem, color: Colors.blue),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "close".tr,
                                style: TextStyle(color: Colors.black),
                              ),
                              Icon(Icons.close, color: Colors.blue),
                            ],
                          ),
                        ),
                      ];
                    }),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 16,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.2),
            ),
            width: double.infinity,
            child: Obx(
              () => ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: orderController.orderitems.length *
                      (orderController.saved.value ? 1 : 1),
                  itemBuilder: (context, index) {
                    var _item = orderController.orderitems[index];
                    return Obx(
                      () => Dismissible(
                        direction: orderController.saved.value ||
                                (orderController.couponLoaded.value > 0 &&
                                    _item.coupon_id != null)
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
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
                            orderController.removeItem(_item);
                          }
                        },
                        key: UniqueKey(),
                        child: ListTile(
                          title: Text(
                            _item.product_name,
                            style: TextStyle(
                                color: orderController.out_of_stock.value
                                        .where((element) =>
                                            element["id"] == _item.variant_id)
                                        .isNotEmpty
                                    ? Colors.red
                                    : null), // <<======================= change color for no stock
                          ),
                          subtitle: Text(
                            "${_item.variant_name_1}  ${_item.variant_name_2} ",
                            style: TextStyle(
                                fontSize: 12,
                                color: orderController.out_of_stock.value
                                        .where((element) =>
                                            element["id"] == _item.variant_id)
                                        .isNotEmpty
                                    ? Colors.red
                                    : null), // <<======================= change color for no stock
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
                          trailing: SizedBox(
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    (_item.discount != 0 ||
                                                orderController
                                                        .couponLoaded.value >
                                                    0) &&
                                            _item.discount != 0
                                        ? Text(
                                            "(-${_item.discount}%)",
                                            style: TextStyle(
                                              color: Colors.green[900],
                                              fontSize: 11,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    Text(
                                        formatter.format(orderController
                                                .orderitems.isNotEmpty
                                            ? orderController
                                                .orderitems[index].total
                                            : 0),
                                        style: TextStyle(
                                          fontFamily: 'alata',
                                          color: orderController
                                                  .out_of_stock.value
                                                  .where((element) =>
                                                      element["id"] ==
                                                      _item.variant_id)
                                                  .isNotEmpty
                                              ? Colors.red
                                              : null, // <<======================= change color for no stock
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox.shrink(),
                                    Text(
                                      "${_item.quantity.toStringAsFixed(0)} ${_item.unite.tr}",
                                      style: TextStyle(
                                          color: orderController
                                                  .out_of_stock.value
                                                  .where((element) =>
                                                      element["id"] ==
                                                      _item.variant_id)
                                                  .isNotEmpty
                                              ? Colors.red
                                              : Color.fromARGB(255, 165, 165,
                                                  165), // <<======================= change color for no stock
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
        Obx(
          () => Expanded(
            flex: orderController.couponLoaded.value > 0
                ? 3
                : 2, //orderController.hasChanged.value > 0
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          var _date = await showDatePicker(
                            locale: Get.locale,
                            context: context,
                            initialDate:
                                DateTime.now().add(Duration(days: diff)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 8)),
                          );

                          if (_date != null) {
                            orderController.deliverySet.value = false;
                            orderController.planned_delivery_date = DateTime(
                                _date.year, _date.month, _date.day, 0, 0);
                            orderController.deliverySet.value = true;

                            var _time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: DateTime.now().hour,
                                  minute: DateTime.now().minute),
                              builder: (BuildContext context, Widget? child) {
                                return Localizations.override(
                                  context: context,
                                  locale: Get.locale,
                                  child: child!,
                                );
                              },
                            );
                            if (_time != null) {
                              orderController.deliverySet.value = false;
                              orderController.planned_delivery_date = DateTime(
                                  _date.year,
                                  _date.month,
                                  _date.day,
                                  _time.hour,
                                  _time.minute);

                              orderController.deliverySet.value = true;
                            }
                          }
                        },
                        child: Icon(Icons.date_range_rounded),
                      ),
                      Obx(
                        () => orderController.deliverySet.value
                            ? Text(FormatDateTime(
                                orderController.planned_delivery_date!))
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Obx(
                    () => orderController.couponLoaded.value > 0
                        ? Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "coupon".tr,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        orderController.removeCoupon();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "-${formatter.format(orderController.getCouponDiscount())}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'alata',
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  Container(
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("total".tr),
                          Text(
                            formatter.format(orderController.total.value),
                            style: TextStyle(fontSize: 16, fontFamily: 'alata'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Obx(
            () => productController.page.value == 0 &&
                    !orderController.saved.value
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
    );
  }
}

showCouponWindow(BuildContext context, OrderController orderController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController moneyTextController = TextEditingController();
      var formatter = NumberFormat("#,##0.00", "fr_FR");
      return AlertDialog(
        contentPadding: EdgeInsets.only(left: 30, right: 30, top: 40),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 43, 87, 124),
          ),
          width: double.infinity,
          height: 50,
          child: Center(
            child: Container(
              width: Get.width,
              height: 50,
              color: Colors.blue,
              child: Center(
                child: Text(
                  "coupon.window".tr,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        content: SizedBox(
          height: Get.height / 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width,
                height: Get.height / 6 - 50,
                color: Colors.white,
                child: Column(children: [
                  Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    height: 90,
                    child: Form(
                      key: orderController.formKeyCoupon,
                      child: SizedBox(
                        width: 100,
                        height: 50,
                        child: TextFormField(
                          keyboardType: TextInputType.streetAddress,
                          validator: (value) {
                            if (value == null || value == "") {
                              return "empty.not.allowed".tr;
                            }
                            return null;
                          },
                          controller: moneyTextController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.redeem),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            labelText: "ex.coupon".tr,
                          ),
                          onSaved: (value) {
                            orderController.coupon_code = value!;
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                  child: Text(
                "description.coupon".tr,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              )),
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
            onPressed: () async {
              var formdata = orderController.formKeyCoupon.currentState;
              if (formdata!.validate()) {
                formdata.save();
                orderController.coupon_code = moneyTextController.text;
                var response = await orderController.checkCouponCode();
                if (response != null) {
                  List<String> txt = response.split("@");
                  Flushbar(
                    title: "${"coupon".tr} ${"error".tr}",
                    message: txt[0].tr + (txt.length > 1 ? txt[1] : ""),
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
                } else {
                  Get.back();
                }
              } else {
                print("error validation");
              }
            },
          ),
        ],
      );
    },
  );
}
