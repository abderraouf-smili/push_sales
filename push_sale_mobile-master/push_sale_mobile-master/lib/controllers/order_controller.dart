// ignore_for_file: prefer_interpolation_to_compose_strings, non_constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/api/my_localisation.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/coupon.dart';
import 'package:push_sale/models/line_text_printer.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/models/orderitem.dart';
import 'package:push_sale/models/purchase_order.dart';
import 'package:push_sale/models/purchase_orderitem.dart';
import 'package:push_sale/models/route_maps.dart';
import 'package:push_sale/models/stats_order.dart';
import 'package:push_sale/models/variant.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:uuid/uuid.dart';

class OrderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  String? tag;
  OrderController({this.tag});
  RxBool saved = false.obs;
  GlobalKey<FormFieldState<dynamic>>? keyUnite = GlobalKey<FormFieldState>();

//******************* */
//to show list order today and all
  List<Order> orders = [];
  RxBool loadOrdersReady = false.obs;

//*********************** */
  Client? client;
  RxList out_of_stock = [].obs;
  RxString uniteItem = "".obs;
  String? orderId;

  String? OrderCode;
  String? clientId;
  int nb_lines = 0;
  RxDouble total = 0.0.obs;
  RxDouble quantityItem = 1.0.obs;
  RxInt hasChanged = 0.obs;
  List<Orderitem> orderitems = [];

  List<LineTextPrinter> textPrint = [];

  Order? order;

  DateTime? planned_delivery_date;
  RxBool deliverySet = false.obs;

  /* For tracking orders */
  DateTime selectedDate = DateTime.now();
  DateTime? finalDate;
  RxInt page = 0.obs;
  List<Order> ordersToTrack = [];
  RxBool loadordersToTrack = false.obs;
  Order? orderToTrack;
  String? trackId;
  String? Cash_trackId;

  /* --------------- */

/* for shipping Orders */
  RxBool loadshippingOrders = false.obs;
  List<PurchaseOrder> shippingOrders = [];
  PurchaseOrder? selectedPO;
  RxBool deliveredOrder = false.obs;
  List<PurchaseOrderitem> deliveryItems = [];
  RxDouble encaissement = 0.0.obs;
  RxInt encaissement_type = 0.obs;
  List<dynamic>? DeliveryProofImage;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxString cash_sent = "to_send".obs;
  RxDouble amount_total = 0.0.obs;
  RxList<Map<String, String>> isDismissed = <Map<String, String>>[].obs;
/*------------*/

/* Used for coupon */
  GlobalKey<FormState> formKeyCoupon = GlobalKey<FormState>();
  String? coupon_code;
  Coupon? coupon;
  RxInt couponLoaded = 0.obs;
/*-----------*/

/* modified item */
  RxBool itemModify = false.obs;
  RxBool addRestantProducts = false.obs;
  RxString uniteOption = "".obs;

  /* itinéraire  */
  List<String> waypoints = [];
  List<String> PO_position = [];
  List<Client> clients_delivery = [];
  Position? MyCurrentPosition;
  late TabController tabController;
  Set<Marker> points_delivery = <Marker>{};
  RxBool points_delivery_loaded = false.obs;
  RxString statusLoadRoute = "none".obs;
  List<RouteMaps> route_maps = [];
  RxInt route_position = 0.obs;
  PageController? pageController;
  List<PurchaseOrderitem> restant = [];

  /* Status orders stats */
  List<Order> status_orders = [];
  RxBool status_orders_loaded = false.obs;

  removeCoupon() {
    couponLoaded.value = 0;
    total.value = 0;
    orderitems.forEach((element) {
      element.removeCoupon();
      total.value = total.value + element.total;
    });
    coupon = null;
  }

  Future<void> getOrdersByStatus(String statusOrder) async {
    status_orders = [];
    status_orders_loaded.value = false;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.statusOrder, data: {
      "status": statusOrder,
    });
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        status_orders.add(Order.fromMapStatus(item));
      }
      status_orders_loaded.value = true;
    } else {
      print(response.message);
    }
  }

  Future<void> getOptimizedRoute() async {
    statusLoadRoute.value = "loading";
    waypoints = [];
    PO_position = [];
    PO_position.add("0");
    waypoints
        .add("${MyCurrentPosition!.latitude},${MyCurrentPosition!.longitude}");
    clients_delivery.forEach((element) {
      waypoints
          .add("${element.address!.latitude},${element.address!.longitude}");
    });
    // waypoints
    //     .add("${MyCurrentPosition!.latitude},${MyCurrentPosition!.longitude}");
    // print(waypoints.sublist(1, waypoints.length - 1).join('|'));

    var response = await MyLocalisation.getRouteOptimale(waypoints);
    if (response != null) {
      route_maps = MyLocalisation.getRouteBetweenPoints(response);
      statusLoadRoute.value = "success";
    } else {
      statusLoadRoute.value = "error";
    }
  }

  double getCouponDiscount() {
    double _discount = 0.0;
    orderitems.forEach((element) {
      if (element.coupon_id != null) {
        _discount += (element.total * 100 / (100 - element.discount)) *
            (element.discount) /
            100;
      }
    });
    return _discount;
  }

  Future<dynamic> checkCouponCode() async {
    couponLoaded.value = 0;
    Map<String, double> warehouseAmounts =
        orderitems.fold({}, (Map<String, double> acc, orderitem) {
      String warehouseId = orderitem.warehouse_id;
      double amount = orderitem.total;

      if (acc.containsKey(warehouseId)) {
        acc[warehouseId] = acc[warehouseId]! + amount;
      } else {
        acc[warehouseId] = amount;
      }

      return acc;
    });

    ResponseHttpRequest response = await CallApi.RequestHttp(global.checkCoupon,
        data: {
          "coupon_code": coupon_code,
          "warehouses_amount": warehouseAmounts
        });
    switch (response.status) {
      case "SUCCESS":
        {
          coupon = Coupon.fromMap(response.data["coupon"]);
          if (coupon!.is_pourcentage) {
            for (var warehouseId in response.data["warehouse_ids"]) {
              for (var element in orderitems) {
                if (element.warehouse_id == warehouseId.toString()) {
                  element.setDiscount(coupon!.discount);
                  element.setCouponId(coupon!.id);
                  couponLoaded.value++;
                }
              }
            }
            total.value = 0;
            orderitems.forEach((element) {
              total.value = total.value + element.total;
            });
          } else {
            print("COUPON is amount discount");
          }
          return null;
        }
      case "FAIL":
        {
          return response.message;
        }
      case "error":
        {
          return response.message;
        }
    }
  }

  Future<dynamic> sendCash() async {
    generateCashTrackId();
    cash_sent.value = "to_send";
    cash_sent.value = "sending";
    var data = {
      "track_id": Cash_trackId!,
      "collected": encaissement.value,
      "attached": (encaissement_type.value == 1),
      "purchaseorder_id": selectedPO!.id,
      "client_id": selectedPO!.client!.id
    };

    var id = selectedPO!.id;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.cashOrder, data: data);
    if (response.status == "SUCCESS") {
      cash_sent.value = "sent";
      await getPurchaseOrdersToShip();
      selectedPO = shippingOrders.where((element) => element.id == id).first;
    } else {
      print(response.message);
    }
    return response;
  }

  RxString changeLoad = "nothing".obs;

  Future<void> changePlannedDate() async {
    changeLoad.value = "sent";
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.url_PlannedDate,
      data: {
        "date": DateFormat("y/MM/dd HH:mm").format(finalDate!),
        "order_id": orderToTrack!.id,
      },
    );
    if (response.status == "SUCCESS") {
      changeLoad.value = "success";
      await getOrdersToTrack(date: selectedDate);
    } else {
      changeLoad.value = "error";
    }
  }

  generateId() {
    Uuid uuid = const Uuid();
    orderId = uuid.v1();
  }

  generateTrackId() {
    Uuid uuid = const Uuid();
    trackId = uuid.v1();
  }

  generateCashTrackId() {
    Uuid uuid = const Uuid();
    Cash_trackId = uuid.v1();
  }

  addItem(
      {required Variant variant,
      required String product_name,
      required String unite,
      required double quantity,
      required String warehouse_id}) {
    double qty_pcs = quantity * (unite == "Cart" ? variant.package : 1);
    orderitems.add(Orderitem(
      id: getItemId(),
      order_id: orderId!,
      variant_id: variant.id,
      sku: variant.sku,
      warehouse_id: warehouse_id,
      promotion_id: variant.promotion_id,
      promotionitem_id: variant.promotionitem_id,
      image: variant.image,
      unite: unite == "Cart" ? "Cart" : "Pcs",
      quantity: quantity,
      package: variant.package,
      total: qty_pcs >= variant.minimum
          ? variant.price * qty_pcs
          : variant.original_price * qty_pcs,
      discount: qty_pcs >= variant.minimum ? variant.discount : 0,
      product_name: product_name,
      variant_name_1: variant.variant1_fr,
      option_1: variant.option1_fr,
      variant_name_2: variant.variant2_fr,
      option_2: variant.option2_fr,
      price: variant.original_price,
    ));
    out_of_stock.removeWhere((element) => element["id"] == variant.id);
    hasChanged.value++;
    total.value = 0;
    orderitems.forEach((element) {
      total.value = total.value + element.total;
    });
  }

  removeItem(Orderitem _item) {
    orderitems.removeWhere((element) => element.id == _item.id);
    total.value = 0;
    orderitems.forEach((element) {
      total.value = total.value + element.total;
    });
  }

  String getItemId() {
    Uuid uuid = Uuid();
    return uuid.v1();
  }

  Future<dynamic> save() async {
    order = Order(
        id: orderId!,
        client_id: clientId!,
        order_date: DateTime.now(),
        planned_delivery_date: planned_delivery_date!,
        delivery_date: null,
        state: "new",
        orderitems: orderitems);

    Map<String, dynamic> data = order!.toMap();
    data["track_id"] = trackId!;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.saveOrder, data: data);
    print(response.message);
    return response;
  }

  Future<void> getOrders() async {
    loadOrdersReady.value = false;
    orders = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.getOrders,
      data: {"date": DateFormat("y/MM/dd").format(DateTime.now())},
    );
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        orders.add(Order.fromMap(item));
      }
      loadOrdersReady.value = true;
    } else {
      print(response.message);
    }
  }

  Future<void> getOrdersToTrack({DateTime? date}) async {
    if (date != null) {
      selectedDate = date;
    }
    loadordersToTrack.value = false;
    ordersToTrack = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(global.getOrders,
        data: {"date": DateFormat("y/MM/dd").format(selectedDate)});
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        ordersToTrack.add(Order.fromMap(item));
      }
      loadordersToTrack.value = true;
    } else {
      print(response.message);
    }
  }

  Future<void> getPurchaseOrdersToShip() async {
    shippingOrders = [];
    clients_delivery = [];
    loadshippingOrders.value = false;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.PurchaseOrdersToShip);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        var element = PurchaseOrder.fromMap(item);
        //recuperer les clients pour la maps
        if (clients_delivery
            .where((item) => item.id == element.client!.id)
            .isEmpty) {
          clients_delivery.add(element.client!);
        }

        element.recalculateAmount();
        shippingOrders.add(element);
      }
      getRestatFromOrders();
      MyCurrentPosition = await MyLocalisation.getMyLocation();
      points_delivery = await MyLocalisation.loadPOS(clients_delivery, this);
      points_delivery_loaded.value = true;
      loadshippingOrders.value = true;
    } else {
      print("ERROR API : " + response.message);
    }
  }

  // Get difference between quantity-confirmed
  getRestatFromOrders() {
    addRestantProducts.value = false;
    restant = [];
    shippingOrders
        .where(
            (element) => element.state == "shipped" || element.state == "paid")
        .toList()
        .forEach((element) {
      element.orderitems.forEach((item) {
        if (item.quantity != item.confirmed_quantity) {
          addRestantProducts.value = true;
          var item_ = restant
              .where((_item) => _item.variant_id == item.variant_id)
              .toList();
          if (item_.isEmpty) {
            PurchaseOrderitem a = item;
            a.resetRestant();
            a.addRestant(item.quantity - item.confirmed_quantity!);
            restant.add(a);
          } else {
            if (item_.first.unite == item.unite) {
              item_.first.addRestant(item.quantity - item.confirmed_quantity!);
            } else {
              item_.first.restant =
                  (item_.first.unite == "Cart" ? item_.first.package : 1) *
                      item_.first.restant;
              item_.first.unite = "Pcs";
              item_.first.addRestant(
                  (item.quantity - item.confirmed_quantity!) *
                      (item.unite == "Cart" ? item.package : 1));
            }
          }
        }
      });
    });
  }

  // Future<ResponseHttpRequest> DeliverySave() async{
  Future<dynamic> DeliverySave() async {
    if (global.delivery_proof && DeliveryProofImage == null) {
      return ResponseHttpRequest(
          code: "404",
          status: "FAIL",
          message: "delivery.proof.is.required".tr);
    }
    deliveredOrder.value = false;
    // will be reviwed, confirm all orderitems
    for (var element in selectedPO!.orderitems) {
      if (!element.modified) {
        element.confirmQuantity();
      }
    }
    var data = selectedPO!.toMap();
    if (DeliveryProofImage != null && DeliveryProofImage!.isNotEmpty) {
      if (DeliveryProofImage!.first is XFile) {
        data["delivery_proof"] = base64Encode(
            File(DeliveryProofImage!.first.path).readAsBytesSync());
      }
    }
    if (encaissement.value != 0.0) {
      data["collected"] = encaissement.value;
      data["attached"] = (encaissement_type.value == 1);
    }
    data["track_id"] = trackId!;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.shipOrder, data: data);
    print(response.data);
    print(response.message);

    if (response.status == "SUCCESS") {
      deliveredOrder.value = true;
    } else {
      print(response.message);
    }
    return response;
  }

  PrepareToPrintDelivery(PurchaseOrder purchaseOrder) {
    textPrint = [];
    textPrint.add(LineTextPrinter(
      type: LineTextPrinter.TYPE_TEXT,
      align: LineTextPrinter.CENTER,
      text1: "Push Sale",
      size: 4,
    ));
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Commande Ref: ",
        text2: purchaseOrder.code,
        format: '%-18s %28s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Date et Heure ",
        text2: FormatDateTime(purchaseOrder.delivery_date ?? DateTime.now()),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );

    Client _client = purchaseOrder.client!;

    textPrint.add(
      LineTextPrinter(
        align: LineTextPrinter.LEFT,
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Client",
        text2: _client.name
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a") +
            (_client.mobile != "" ? " - Tel : ${_client.mobile} " : ""),
        format: '%-6s %40s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        align: LineTextPrinter.LEFT,
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Adresse",
        text2: _client.address!.city.name
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a") +
            "  " +
            _client.address!.wilaya.name
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a"),
        format: '%-7s %39s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Produit",
        text2: "Qte",
        text3: "Total",
        format: '%-27s %8s %10s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    double p_total = 0.0;
    double discount = 0.0;
    for (var item in purchaseOrder.orderitems) {
      if (item.confirmed_quantity! != 0) {
        if (item.discount != 0) {
          discount += (item.discount) *
              (item.total *
                  item.confirmed_quantity! *
                  100 /
                  (100 - item.discount)) /
              100;
        }
        p_total += item.total * item.confirmed_quantity!;
        textPrint.add(
          LineTextPrinter(
            type: LineTextPrinter.TYPE_TEXT,
            text1: item.product_name
                    .replaceAll("é", "e")
                    .replaceAll("è", "e")
                    .replaceAll("à", "a") +
                (item.discount != 0
                    ? " (-${item.discount.toStringAsFixed(0)}%)"
                    : ""),
            text2: (item.confirmed_quantity! *
                    (item.unite == 'Pcs' ? 1 : item.package))
                .toStringAsFixed(0),
            text3: (item.total * item.confirmed_quantity!).toStringAsFixed(2),
            size: 1,
            format: '%-27s %8s %10s %n',
          ),
        );
        textPrint.add(
          LineTextPrinter(
            type: LineTextPrinter.TYPE_TEXT,
            text1: item.variant_name_1
                    .replaceAll("é", "e")
                    .replaceAll("è", "e")
                    .replaceAll("à", "a") +
                " " +
                item.variant_name_2!
                    .replaceAll("é", "e")
                    .replaceAll("è", "e")
                    .replaceAll("à", "a"),
            text2: "PU : " +
                (item.price / (item.unite == "Cart" ? item.package : 1))
                    .toStringAsFixed(2),
            format: '%-30s %-30s %n',
            size: 0,
            isSubTitle: true,
          ),
        );
      }
    }
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    if (discount != 0) {
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: "Total Brut",
          text2: (discount + p_total).toStringAsFixed(2),
          format: '%-20s %26s %n',
          size: 1,
        ),
      );
    }
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Remise",
        text2: discount.toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Total" + (discount != 0 ? " Net" : ""),
        text2: p_total.toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Encaisse",
        text2: (selectedPO!.cash ?? encaissement.value).toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
  }

  PrepareToPrintOrder({Order? MyOrder}) {
    textPrint = [];
    textPrint.add(LineTextPrinter(
      type: LineTextPrinter.TYPE_TEXT,
      align: LineTextPrinter.CENTER,
      text1: "Push Sale",
      size: 4,
    ));
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Commande Ref: ",
        text2: MyOrder != null ? MyOrder.code : OrderCode,
        format: '%-18s %28s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Date et Heure ",
        text2: FormatDateTime(
            MyOrder != null ? MyOrder.order_date : DateTime.now()),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Livraison prevu ",
        text2: FormatDateTime(MyOrder != null
            ? MyOrder.planned_delivery_date
            : planned_delivery_date!),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );

    Client _client = MyOrder != null ? MyOrder.client! : client!;

    textPrint.add(
      LineTextPrinter(
        align: LineTextPrinter.LEFT,
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Client",
        text2: _client.name
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a") +
            (_client.mobile != "" ? " - Tel : ${_client.mobile} " : ""),
        format: '%-6s %40s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        align: LineTextPrinter.LEFT,
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Adresse",
        text2: _client.address!.city.name
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a") +
            "  " +
            _client.address!.wilaya.name
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a"),
        format: '%-7s %39s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Produit",
        text2: "Qte",
        text3: "Total",
        format: '%-27s %8s %10s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    double p_total = 0.0;
    double discount = 0.0;
    for (var item in (MyOrder != null ? MyOrder.orderitems : orderitems)) {
      if (item.discount != 0) {
        discount +=
            (item.discount) * (item.total * 100 / (100 - item.discount)) / 100;
      }
      p_total += item.total;
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: item.product_name
                  .replaceAll("é", "e")
                  .replaceAll("è", "e")
                  .replaceAll("à", "a") +
              (item.discount != 0
                  ? " (-${item.discount.toStringAsFixed(0)}%)"
                  : ""),
          text2: (item.quantity * (item.unite == 'Pcs' ? 1 : item.package))
              .toStringAsFixed(0),
          text3: item.total.toStringAsFixed(2),
          size: 1,
          format: '%-27s %8s %10s %n',
        ),
      );
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: item.variant_name_1
                  .replaceAll("é", "e")
                  .replaceAll("è", "e")
                  .replaceAll("à", "a") +
              " " +
              item.variant_name_2!
                  .replaceAll("é", "e")
                  .replaceAll("è", "e")
                  .replaceAll("à", "a"),
          text2: "PU : " +
              (item.total /
                      (item.quantity *
                          (item.unite == 'Pcs' ? 1 : item.package)))
                  .toStringAsFixed(2),
          format: '%-30s %-30s %n',
          size: 0,
          isSubTitle: true,
        ),
      );
    }
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    if (discount != 0) {
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: "Total Brut",
          text2: (discount + p_total).toStringAsFixed(2),
          format: '%-20s %26s %n',
          size: 1,
        ),
      );
    }
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Remise",
        text2: discount.toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Total" + (discount != 0 ? " Net" : ""),
        text2: p_total.toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_CODE_QR,
        text1: MyOrder != null ? MyOrder.id : orderId!,
        size: 150,
        align: LineTextPrinter.CENTER,
      ),
    );
  }

  PrepareRecapInvoice() {
    textPrint = [];
    textPrint.add(LineTextPrinter(
      type: LineTextPrinter.TYPE_TEXT,
      align: LineTextPrinter.CENTER,
      text1: "Push Sale",
      size: 4,
    ));
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Commandes Aujourd'hui",
        text2: FormatDateTime(DateTime.now()),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Commande",
        text2: "Client",
        text3: "Total",
        format: '%-17s %18s %10s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    double total = 0;
    for (var item in orders) {
      total += item.total_amount!;
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: item.code,
          text2: item.client!.name
              .replaceAll("é", "e")
              .replaceAll("è", "e")
              .replaceAll("à", "a"),
          text3: item.total_amount!.toStringAsFixed(2),
          format: '%-17s %18s %10s %n',
          size: 1,
        ),
      );
    }
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Total",
        text2: total.toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
  }

  PrepareRecapGoods() {
    List<QuantityVendue> pro_vendu = [];
    for (var order in orders) {
      for (var item in order.orderitems) {
        var search =
            pro_vendu.where((element) => element.id == item.variant_id);
        if (search.isEmpty) {
          pro_vendu.add(QuantityVendue(
              id: item.variant_id,
              ProductName: item.product_name,
              VariantName:
                  (item.variant_name_1 + " " + (item.variant_name_2 ?? "")),
              Quantity: int.parse(
                  (item.quantity * (item.unite == "Cart" ? item.package : 1))
                      .toStringAsFixed(0)),
              Total: item.total));
        } else {
          search.first.addQuantity(int.parse(item.quantity.toStringAsFixed(0)));
          search.first.addTotal(item.total);
        }
      }
    }

    textPrint = [];
    textPrint.add(LineTextPrinter(
      type: LineTextPrinter.TYPE_TEXT,
      align: LineTextPrinter.CENTER,
      text1: "Push Sale",
      size: 4,
    ));
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Quantites Vendues",
        text2: FormatDateTime(DateTime.now()),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Produit",
        text2: "Qte",
        text3: "Total",
        format: '%-27s %8s %10s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    double total = 0;
    for (var item in pro_vendu) {
      total += item.Total;
      textPrint.add(LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: item.ProductName.replaceAll("é", "e")
            .replaceAll("è", "e")
            .replaceAll("à", "a"),
        text2: item.Quantity.toString(),
        text3: item.Total.toStringAsFixed(2),
        format: '%-27s %8s %10s %n',
        size: 1,
      ));
      textPrint.add(LineTextPrinter(
          align: LineTextPrinter.LEFT,
          type: LineTextPrinter.TYPE_TEXT,
          text1: item.VariantName.replaceAll("é", "e")
              .replaceAll("è", "e")
              .replaceAll("à", "a"),
          size: 1,
          isSubTitle: true));
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: "",
          size: 0,
        ),
      );
    }
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Total",
        text2: total.toStringAsFixed(2),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
  }

  cancelAllQuantity(PurchaseOrderitem _item) {
    itemModify.value = false;
    _item.cancelQuantity();
    // isDismissed.value
    //     .where((element) => element[_item.id] != null)
    //     .first[_item.id] = "drop";
    double _total = 0;
    selectedPO!.orderitems.forEach((element) {
      _total +=
          (element.modified ? element.confirmed_quantity : element.quantity)! *
              element.price;
    });
    selectedPO!.residual =
        selectedPO!.residual! - (selectedPO!.total_amount - _total);
    selectedPO!.total_amount = _total;
    amount_total.value = _total;
    itemModify.value = true;
  }

  modifyQuantityItem(PurchaseOrderitem _item, double _quantity) {
    itemModify.value = false;
    if (_item.unite != uniteOption.value) {
      _item.setUnite(uniteOption.value);
    }
    _item.setConfirmQuantity(_quantity);
    double _total = 0;
    selectedPO!.orderitems.forEach((element) {
      print(element.variant_id.toString() +
          " : " +
          element.quantity.toString() +
          " x " +
          element.price.toString());
      _total +=
          (element.modified ? element.confirmed_quantity : element.quantity)! *
              element.price;
    });
    selectedPO!.residual =
        selectedPO!.residual! - (selectedPO!.total_amount - _total);
    selectedPO!.total_amount = _total;
    amount_total.value = _total;
    itemModify.value = true;
  }

  @override
  void onInit() async {
    if (tag != null && tag == "tracking") {
      await getOrdersToTrack();
    }
    if (tag != null && tag == "shipping") {
      tabController = TabController(
        length: 3,
        vsync: this,
      );
      points_delivery_loaded.value = false;
      await getPurchaseOrdersToShip();
    }

    super.onInit();
  }

  Future<ResponseHttpRequest> reNew(String id) async{
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.reNewOrder,data: {"order_id":id});
        return response;
  }
}

class QuantityVendue {
  final int id;
  final String ProductName;
  final String VariantName;
  int Quantity;
  double Total;
  QuantityVendue({
    required this.id,
    required this.ProductName,
    required this.VariantName,
    required this.Quantity,
    required this.Total,
  });

  addQuantity(int q) {
    Quantity += q;
  }

  addTotal(double t) {
    Total += t;
  }
}
