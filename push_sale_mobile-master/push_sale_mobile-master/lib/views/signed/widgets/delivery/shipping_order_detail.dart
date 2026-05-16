import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/my_image_picker.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/models/purchase_orderitem.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';
import 'package:push_sale/const/globals.dart' as global;

class ShippingOrderDetail extends StatelessWidget {
  PageController pageController;
  OrderController orderController = Get.find();
  PrinterController printerController = Get.put(PrinterController());
  ShippingOrderDetail(this.pageController);

  @override
  Widget build(BuildContext context) {
    var order = orderController.selectedPO;
    orderController.amount_total.value = order!.total_amount;
    orderController.generateTrackId();
    orderController.generateCashTrackId();
    orderController.encaissement.value = 0.0;
    orderController.cash_sent.value = "to_send";
    orderController.encaissement_type.value = 1;
    orderController.deliveredOrder.value = false;
    orderController.DeliveryProofImage = null;
    orderController.isDismissed.value = [];
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    bool showDeliveryProof = (order.state == "shipped" || order.state == "paid")
        ? order.delivery_proof != null
        : global.delivery_proof;
    return Column(children: [
      Container(
        width: Get.width,
        height: 50,
        color: Colors.blue,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                pageController.animateToPage(0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Container(
              width: Get.width - 100,
              child: Center(
                child: Text(
                  order.code,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 0: // Bouton de menu Livrer
                      if (orderController.encaissement.value == 0) {
                        AwesomeDialog(
                            dialogType: DialogType.question,
                            title: "sure".tr,
                            body: Text("delivery.without.cash".tr),
                            context: context,
                            btnOkOnPress: () async {
                              var response =
                                  await orderController.DeliverySave();
                              if (response.status == "SUCCESS") {
                                await orderController.getPurchaseOrdersToShip();
                                AwesomeDialog(
                                    dialogType: DialogType.success,
                                    title: "sure".tr,
                                    body: Text("succefully.saved".tr),
                                    context: context,
                                    btnOkOnPress: () {})
                                  ..show();
                              } else {
                                AwesomeDialog(
                                    dialogType: DialogType.error,
                                    title: "sure".tr,
                                    body: Text(response.message),
                                    context: context,
                                    btnOkOnPress: () {})
                                  ..show();
                              }
                            },
                            btnCancelOnPress: () {})
                          ..show();
                      } else {
                        var response = await orderController.DeliverySave();
                        if (response.status == "SUCCESS") {
                          await orderController.getPurchaseOrdersToShip();
                          AwesomeDialog(
                              dialogType: DialogType.success,
                              title: "sure".tr,
                              body: Text("succefully.saved".tr),
                              context: context,
                              btnOkOnPress: () {})
                            ..show();
                        } else {
                          AwesomeDialog(
                              dialogType: DialogType.error,
                              title: "sure".tr,
                              body: Text(response.message),
                              context: context,
                              btnOkOnPress: () {})
                            ..show();
                        }
                      }

                      break;
                    case 10: // Bouton de menu Livrer et Encaisser
                      if (orderController.encaissement.value != 0 &&
                          orderController.encaissement.value !=
                              order.total_amount) {
                        AwesomeDialog(
                            dialogType: DialogType.question,
                            title: "sure".tr,
                            body: Text("cash.erase.action".tr),
                            context: context,
                            btnOkOnPress: () async {
                              orderController.encaissement_type.value = 1;
                              orderController.encaissement.value =
                                  order.residual!;
                              if (order.state == "shipped" ||
                                  order.state == "partially_paid" ||
                                  order.state == "paid") {
                                await orderController.sendCash();
                              }
                              var response =
                                  await orderController.DeliverySave();
                              print(response.message);
                              if (response.status == "SUCCESS") {
                                await orderController.getPurchaseOrdersToShip();
                                AwesomeDialog(
                                    dialogType: DialogType.success,
                                    title: "sure".tr,
                                    body: Text("succefully.saved".tr),
                                    context: context,
                                    btnOkOnPress: () {})
                                  ..show();
                              } else {
                                AwesomeDialog(
                                    dialogType: DialogType.error,
                                    title: "sure".tr,
                                    body: Text(response.message),
                                    context: context,
                                    btnOkOnPress: () {})
                                  ..show();
                              }
                            },
                            btnCancelOnPress: () {})
                          ..show();
                      } else {
                        orderController.encaissement_type.value = 1;
                        orderController.encaissement.value = order.residual!;
                        if (order.state == "shipped" ||
                            order.state == "partially_paid" ||
                            order.state == "paid") {
                          await orderController.sendCash();
                        }
                        var response = await orderController.DeliverySave();
                        print(response.message);
                        if (response.status == "SUCCESS") {
                          await orderController.getPurchaseOrdersToShip();
                          AwesomeDialog(
                              dialogType: DialogType.success,
                              title: "sure".tr,
                              body: Text("succefully.saved".tr),
                              context: context,
                              btnOkOnPress: () {})
                            ..show();
                        } else {
                          AwesomeDialog(
                              dialogType: DialogType.error,
                              title: "sure".tr,
                              body: Text(response.message),
                              context: context,
                              btnOkOnPress: () {})
                            ..show();
                        }
                      }
                      break;
                    case 1:
                      showEncaissementWindow(context, orderController);
                      break;
                    case 2:
                      {
                        if (printerController.isSaved) {
                          //   // printer is saved and ready to check if it is online or no
                          orderController.PrepareToPrintDelivery(order);

                          await printerController.ScanPrinter();
                          String response =
                              await printerController.StartPrinting(
                                  orderController.textPrint);
                          switch (response) {
                            case "ok":
                              Flushbar(
                                title: "print".tr,
                                message: "printing".tr,
                                titleColor: Color.fromARGB(255, 255, 255, 255),
                                messageColor:
                                    Color.fromARGB(255, 253, 254, 255),
                                duration: Duration(seconds: 3),
                                icon: Icon(Icons.check,
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                                titleColor: Color.fromARGB(255, 255, 255, 255),
                                messageColor:
                                    Color.fromARGB(255, 253, 254, 255),
                                duration: Duration(seconds: 3),
                                icon: Icon(Icons.check,
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                                titleColor: Color.fromARGB(255, 255, 255, 255),
                                messageColor:
                                    Color.fromARGB(255, 253, 254, 255),
                                duration: Duration(seconds: 3),
                                icon: Icon(Icons.check,
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                                titleColor: Color.fromARGB(255, 255, 255, 255),
                                messageColor:
                                    Color.fromARGB(255, 253, 254, 255),
                                duration: Duration(seconds: 3),
                                icon: Icon(Icons.check,
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                    case 3:
                      await printerController.ScanPrinter();
                      ShowButtomSheetPrinterConfig(context: context);
                      break;
                    case 4:
                      if (orderController.deliveredOrder.value) {
                        Get.offAllNamed("/HomePage",
                            arguments: {"client_id": orderController.clientId});
                      }
                      break;
                  }
                },
                elevation: 5,
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      enabled: order.state != "shipped" &&
                          order.state != "paid" &&
                          !orderController.deliveredOrder.value,
                      value: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "client.delivery".tr,
                            style: TextStyle(
                                color: order.state != "shipped" &&
                                        order.state != "paid" &&
                                        !orderController.deliveredOrder.value
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                          Icon(Icons.delivery_dining_outlined,
                              color: Colors.blue),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      enabled: true,
                      value: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "client.cash".tr,
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            Icons.money,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      enabled: (order.state == "shipped" ||
                              order.state == "in_way") &&
                          !orderController.deliveredOrder.value,
                      value: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "client.cash.delivery".tr,
                            style: TextStyle(
                                color: (order.state == "shipped" ||
                                            order.state == "in_way") &&
                                        !orderController.deliveredOrder.value
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                          Icon(
                            Icons.playlist_add_check_circle_outlined,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      enabled: (order.state == "shipped" ||
                          order.state == "paid" ||
                          orderController.deliveredOrder.value),
                      value: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("print".tr,
                              style: TextStyle(
                                  color: !(order.state == "shipped" ||
                                          order.state == "paid" ||
                                          orderController.deliveredOrder.value)
                                      ? Colors.grey
                                      : Colors.black)),
                          Icon(Icons.print, color: Colors.blue),
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
                              style: TextStyle(color: Colors.black)),
                          Icon(Icons.bluetooth, color: Colors.blue),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
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
                    )
                  ];
                })
          ],
        ),
      ),
      Container(
        width: Get.width,
        height: Get.height - 138.5 - (showDeliveryProof ? 220 : 90),
        child: ListView.builder(
          itemCount: order.orderitems.length,
          itemBuilder: (context, index) {
            var item = order.orderitems[index];
            // orderController.isDismissed.add({item.id: "new"});
            return Obx(
              () => Slidable(
                // endActionPane: SlidableDrawerActionPane(),
                child: orderController.itemModify.value &&
                        item.confirmed_quantity == 0
                    ? SizedBox.shrink()
                    : BuildItem(item, orderController),
                endActionPane: orderController.deliveredOrder.value ||
                        orderController.selectedPO!.state == "shipped" ||
                        orderController.selectedPO!.state == "paid"
                    ? null
                    : ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (cnxt) {
                              showModificationWindow(
                                  context, item, orderController);
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            // label: 'Share',
                          ),
                          SlidableAction(
                            onPressed: (cnxt) {
                              orderController.cancelAllQuantity(item);
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            // label: 'Delete',
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
      Divider(
        height: 3,
      ),
      Obx(
        () => Container(
          width: Get.width + orderController.encaissement.value * 0,
          height: showDeliveryProof ? 220 : 90,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Container(
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("total".tr),
                    Text(formatter.format(orderController.amount_total.value),
                        style: TextStyle(fontSize: 16, fontFamily: 'alata')),
                  ],
                ),
              ),
              Container(
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("cash.collect".tr),
                        orderController.cash_sent.value == "to_send"
                            ? orderController.encaissement.value > 0 &&
                                    order.state == "shipped"
                                ? IconButton(
                                    icon:
                                        Icon(Icons.refresh, color: Colors.red),
                                    onPressed: () async {
                                      var response =
                                          await orderController.sendCash();
                                    },
                                  )
                                : SizedBox.shrink()
                            : orderController.cash_sent.value == "sending"
                                ? Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))
                                : Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          (order.cash ?? 1) == 0
                              ? ""
                              : formatter.format(order.cash ??
                                  orderController.encaissement.value),
                          style: TextStyle(fontSize: 16, fontFamily: 'alata'),
                        ),
                        Obx(
                          () => Text(
                            (orderController.encaissement.value > 0 &&
                                    (order.state == "shipped")
                                ? " + " +
                                    formatter.format(
                                        orderController.encaissement.value)
                                : ""),
                            style: TextStyle(
                                color: orderController.cash_sent.value != "sent"
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 16,
                                fontFamily: 'alata'),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              showDeliveryProof
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text("delivery.proof".tr)),
                        Container(
                          width: Get.width / 2,
                          height: 130,
                          child: MyImagePicker(
                            enabled: !orderController.deliveredOrder.value &&
                                order.state != "shipped" &&
                                order.state != "paid",
                            preferredCameraDevice: CameraDevice.rear,
                            initialValue: order.delivery_proof != null
                                ? [
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        // shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            order.delivery_proof!,
                                          ),
                                        ),
                                      ),
                                    )
                                  ]
                                : null,
                            maxImages: 1,
                            previewMargin: EdgeInsets.only(top: 1, left: 1),
                            previewWidth: 198,
                            previewHeight: 198,
                            // boxShape: BoxShape.circle,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            name: "Image",
                            onChanged: (value) {
                              orderController.DeliveryProofImage = value;
                            },
                            onSaved: (value) {},
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    ]);
  }
}

Widget BuildItem(PurchaseOrderitem item, OrderController orderController) {
  var formatter = new NumberFormat("#,##0.00", "fr_FR");
  return ListTile(
    title: Text(
      item.product_name, // <<======================= change color for no stock
      style: TextStyle(
        decoration: (orderController.itemModify.value ||
                    orderController.selectedPO!.state == "shipped" ||
                    orderController.selectedPO!.state == "paid") &&
                item.cancelled_quantity == item.quantity
            ? TextDecoration.lineThrough
            : null,
      ),
    ),
    subtitle: Text(
      "${item.variant_name_1}  ${item.variant_name_2} ",
      style: TextStyle(
        decoration: (orderController.itemModify.value ||
                    orderController.selectedPO!.state == "shipped" ||
                    orderController.selectedPO!.state == "paid") &&
                item.cancelled_quantity == item.quantity
            ? TextDecoration.lineThrough
            : null,
      ),
    ),
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
    trailing: Container(
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              item.discount != 0
                  ? Text(
                      "(-${item.discount}%)",
                      style: TextStyle(color: Colors.green[900], fontSize: 11),
                    )
                  : SizedBox.shrink(),
              Text(
                  formatter.format((item.modified &&
                              item.quantity != item.confirmed_quantity) ||
                          orderController.selectedPO!.state == "shipped" ||
                          orderController.selectedPO!.state == "paid"
                      ? item.price * item.confirmed_quantity!
                      : item.price * item.quantity),
                  style: TextStyle(
                    decoration: (orderController.itemModify.value ||
                                orderController.selectedPO!.state ==
                                    "shipped" ||
                                orderController.selectedPO!.state == "paid") &&
                            item.cancelled_quantity == item.quantity
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.modified &&
                            item.quantity != item.confirmed_quantity
                        ? Colors.green
                        : null,
                    fontFamily:
                        'alata', // <<======================= change color for no stock
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox.shrink(),
              Text(
                item.quantity.toStringAsFixed(0) +
                    " " +
                    (item.modified && item.quantity != item.confirmed_quantity
                        ? "➝ " +
                            ((item.modified &&
                                            item.quantity !=
                                                item.confirmed_quantity) ||
                                        orderController.selectedPO!.state ==
                                            "shipped" ||
                                        orderController.selectedPO!.state ==
                                            "paid"
                                    ? item.confirmed_quantity!
                                    : item.quantity)
                                .toStringAsFixed(0) +
                            " "
                        : "") +
                    item.unite,
                style: TextStyle(
                    decoration: (orderController.itemModify.value ||
                                orderController.selectedPO!.state ==
                                    "shipped" ||
                                orderController.selectedPO!.state == "paid") &&
                            item.cancelled_quantity == item.quantity
                        ? TextDecoration.lineThrough
                        : null,
                    // <<======================= change color for no stock
                    fontWeight: FontWeight.bold,
                    color: item.modified &&
                            item.quantity != item.confirmed_quantity
                        ? Colors.green
                        : null),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

showEncaissementWindow(BuildContext context, OrderController orderController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController moneyTextController = TextEditingController();
      moneyTextController.text = orderController.selectedPO!.state == "paid"
          ? ""
          : orderController.encaissement.value == 0
              ? orderController.selectedPO!.residual!.toStringAsFixed(2)
              : orderController.encaissement.value.toString();
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
            child: Container(
              width: Get.width,
              height: 50,
              color: Colors.blue,
              child: Center(
                child: Text(
                  "cash.window".tr,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        content: Container(
            height: Get.height / 3,
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Get.width,
                    height: Get.height / 3 - 50,
                    color: Colors.white,
                    child: Column(children: [
                      Container(
                        width: Get.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        height: 90,
                        child: Form(
                          key: orderController.formKey,
                          child: Container(
                            width: 100,
                            height: 50,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value == "") {
                                  return "empty.not.allowed".tr;
                                }
                                if (double.parse(value) == 0) {
                                  return "zero.not.allowed".tr;
                                }
                                if (orderController.encaissement_type.value ==
                                        1 &&
                                    double.parse(value) >
                                        orderController.selectedPO!.residual!) {
                                  return "amount.must.be.bellow.to".tr +
                                      orderController.selectedPO!.residual
                                          .toString();
                                }
                                return null;
                              },
                              controller: moneyTextController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                labelText: "cash.money".tr,
                              ),
                              onSaved: (value) {
                                orderController.encaissement.value =
                                    double.parse(value!);
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: Get.width / 1.5,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "this.order".tr,
                              style: TextStyle(
                                  color: orderController.selectedPO!.state ==
                                          "paid"
                                      ? Colors.grey
                                      : null),
                            ),
                            Radio(
                              value: orderController.selectedPO!.state != "paid"
                                  ? 1
                                  : 0,
                              groupValue:
                                  orderController.encaissement_type.value,
                              onChanged: orderController.selectedPO!.state !=
                                      "paid"
                                  ? (value) {
                                      orderController.encaissement_type.value =
                                          int.parse(value.toString());
                                    }
                                  : null,
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: Get.width / 1.5,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("other.solde".tr,
                                style: TextStyle(
                                    color: orderController.selectedPO!.state !=
                                            "paid"
                                        ? Colors.grey
                                        : null)),
                            Radio(
                              value: orderController.selectedPO!.state == "paid"
                                  ? 1
                                  : 0,
                              groupValue:
                                  orderController.encaissement_type.value,
                              onChanged: orderController.selectedPO!.state ==
                                      "paid"
                                  ? (value) {
                                      orderController.encaissement_type.value =
                                          int.parse(value.toString());
                                    }
                                  : null,
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            )),
        actions: <Widget>[
          MaterialButton(
            minWidth: double.infinity,
            color: Colors.blue,
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              var formdata = orderController.formKey.currentState;
              if (formdata!.validate()) {
                formdata.save();
                orderController.encaissement.value = double.parse(
                    moneyTextController.text == ""
                        ? "0"
                        : moneyTextController.text);
                Get.back();
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

showModificationWindow(BuildContext context, PurchaseOrderitem item,
    OrderController orderController) {
  print("price : " +
      item.price.toString() +
      " | quantity : " +
      item.confirmed_quantity.toString() +
      " | total : " +
      item.total.toString());
  showDialog(
    context: context,
    builder: (BuildContext context) {
      GlobalKey<FormState> keyForm = GlobalKey<FormState>();
      TextEditingController quantityCartTextController =
          TextEditingController();
      TextEditingController quantityPcsTextController = TextEditingController();
      double qtyCaisse = (item.confirmed_quantity ?? item.quantity) /
          (item.unite == "Cart" ? 1 : item.package);
      double qtyPcs = (item.confirmed_quantity ?? item.quantity) *
          (item.unite == "Pcs" ? 1 : item.package);
      quantityCartTextController.text = qtyCaisse.toStringAsFixed(0);
      quantityPcsTextController.text = qtyPcs.toStringAsFixed(0);
      orderController.uniteOption.value = item.unite;
      double _quantity = 0.0;
      String unite = item.unite;
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
            child: Container(
              width: Get.width,
              height: 50,
              color: Colors.blue,
              child: Center(
                child: Text(
                  "modification.window".tr,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        content: Container(
          height: Get.height / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                width: Get.width,
                height: Get.height / 5,
                color: Colors.white,
                child: Column(children: [
                  Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Form(
                      key: keyForm,
                      child: Container(
                        height: Get.height / 5,
                        child: Obx(() {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: Get.width / 1.5,
                                child: Row(
                                  children: [
                                    Radio(
                                      value: "Cart",
                                      groupValue:
                                          orderController.uniteOption.value,
                                      onChanged: (value) {
                                        orderController.uniteOption.value =
                                            value as String;
                                      },
                                    ),
                                    Container(
                                      width: Get.width / 3,
                                      child: TextFormField(
                                        enabled:
                                            orderController.uniteOption.value ==
                                                "Cart",
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (orderController
                                                  .uniteOption.value ==
                                              "Pcs") {
                                            return null;
                                          }
                                          if (value == null || value == "") {
                                            return "empty.not.allowed".tr;
                                          }
                                          if (value.contains(".")) {
                                            return "comma.not.allowed".tr;
                                          }
                                          if (int.parse(value) >
                                              (item.quantity /
                                                  (item.unite == "Cart"
                                                      ? 1
                                                      : item.package))) {
                                            return "max.value".tr +
                                                " " +
                                                item.quantity
                                                    .toStringAsFixed(0);
                                          }
                                          return null;
                                        },
                                        controller: quantityCartTextController,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.school_sharp),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          labelText: "Cart".tr,
                                        ),
                                        onSaved: (value) {
                                          _quantity = double.parse(value!);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: Get.width / 1.5,
                                child: Row(
                                  children: [
                                    Radio(
                                      value: "Pcs",
                                      groupValue:
                                          orderController.uniteOption.value,
                                      onChanged: (value) {
                                        orderController.uniteOption.value =
                                            value as String;
                                      },
                                    ),
                                    Container(
                                      width: Get.width / 3,
                                      child: TextFormField(
                                        enabled:
                                            orderController.uniteOption.value ==
                                                "Pcs",
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (orderController
                                                  .uniteOption.value ==
                                              "Cart") {
                                            return null;
                                          }
                                          if (value == null || value == "") {
                                            return "empty.not.allowed".tr;
                                          }
                                          if (value.contains(".")) {
                                            return "comma.not.allowed".tr;
                                          }
                                          if (int.parse(value) >
                                              (item.quantity *
                                                  (item.unite == "Pcs"
                                                      ? 1
                                                      : item.package))) {
                                            return "max.value".tr +
                                                " " +
                                                item.quantity
                                                    .toStringAsFixed(0);
                                          }
                                          return null;
                                        },
                                        controller: quantityPcsTextController,
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              Icon(Icons.category_rounded),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          labelText: "Pcs".tr,
                                        ),
                                        onSaved: (value) {
                                          _quantity = double.parse(value!);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ]),
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
            onPressed: () async {
              var formdata = keyForm.currentState;
              if (formdata!.validate()) {
                formdata.save();

                orderController.modifyQuantityItem(
                    item,
                    orderController.uniteOption.value == "Pcs"
                        ? double.parse(quantityPcsTextController.text)
                        : double.parse(quantityCartTextController.text));
                Get.back();
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
