// ignore_for_file: prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/line_text_printer.dart';
import 'package:push_sale/models/purchase_order.dart';
import 'package:push_sale/models/purchase_orderitem.dart';
import 'package:push_sale/models/purchase_variant.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/stock_operation.dart';
import 'package:push_sale/models/stock_operation_items.dart';
import 'package:uuid/uuid.dart';

class PurchaseOrderController extends GetxController {
  String? tag;
  PurchaseOrderController({this.tag});
  RxBool saved = false.obs;
  RxString uniteItem = "".obs;

  GlobalKey<FormFieldState<dynamic>>? keyUnite = GlobalKey<FormFieldState>();

  //for delivery part
  List<PurchaseOrder> ordersReadyToShip = [];
  RxBool orts_loaded = false.obs;
  RxList<String> BLs = <String>[].obs;
  List<PurchaseOrder> selectedOrders = [];
  List<StockOperationItems> productsTransfer = [];
  StockOperation? BonTransfert;
  String? Transert_id;
  String? trackId;

  //*****/

  String? purchaseorderId;
  String? warehouse_id;
  String? OrderCode;
  int nb_lines = 0;
  RxDouble total = 0.0.obs;
  RxDouble quantityItem = 1.0.obs;
  RxDouble priceItem = 0.0.obs;
  RxInt hasChanged = 0.obs;
  bool isSaved = false;
  List<PurchaseOrderitem> orderitems = [];

  List<LineTextPrinter> textPrint = [];

  PurchaseOrder? purchaseOrder;

  DateTime? planned_delivery_date;
  RxBool deliverySet = false.obs;

  generateId() {
    Uuid uuid = const Uuid();
    purchaseorderId = uuid.v1();
  }

  generateTrackId() {
    Uuid uuid = const Uuid();
    trackId = uuid.v1();
  }

  addItem(
      {required PurchaseVariant variant,
      required String product_name,
      required String unite,
      required double quantity,
      required double price,
      required String warehouse_id}) {
    this.warehouse_id = warehouse_id;
    orderitems.add(PurchaseOrderitem(
      id: getItemId(),
      purchaseorder_id: purchaseorderId!,
      variant_id: variant.id,
      discount: variant.discount,
      warehouse_id: warehouse_id,
      image: variant.image,
      sku: variant.sku,
      unite: unite == "Cart" ? "Cart" : "Pcs",
      quantity: quantity,
      package: variant.package,
      total: quantity * (unite == "Cart" ? variant.package : 1) * price,
      price: price,
      product_name: product_name,
      variant_name_1: variant.variant1_fr,
      option_1: variant.option1_fr,
      variant_name_2: variant.variant2_fr,
      option_2: variant.option2_fr,
    ));
    hasChanged.value++;
    total.value = 0;
    for (var element in orderitems) {
      total.value = total.value + element.total;
    }
  }

  removeItem(PurchaseOrderitem item) {
    orderitems.removeWhere((element) => element.id == item.id);
    total.value = 0;
    for (var element in orderitems) {
      total.value = total.value + element.total;
    }
  }

  String getItemId() {
    Uuid uuid = const Uuid();
    return uuid.v1();
  }

  Future<void> getOrderReadyToPack() async {
    generateTrackId();
    orts_loaded.value = false;
    ordersReadyToShip = [];
    selectedOrders = [];
    productsTransfer = [];
    BLs.value = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.orderReadyToPack);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        ordersReadyToShip.add(PurchaseOrder.fromMap(item));
      }
      orts_loaded.value = true;
    } else {
      print(response.message);
    }
  }

  Future<dynamic> save() async {
    purchaseOrder = PurchaseOrder(
      id: purchaseorderId!,
      total_amount: total.value,
      warehouse_id: warehouse_id!,
      purchase_date: DateTime.now(),
      type: "invoice_in",
      state: "new",
      orderitems: orderitems,
      planned_delivery_date: DateTime.now(),
    );

    Map<String, dynamic> data = purchaseOrder!.toMap();
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.savePurchaseOrder, data: data);
    print(response.message);
    return response;
  }

  Future<ResponseHttpRequest> generateTransfer() async {
    productsTransfer = [];
    String warehouse_id = "";
    //prepare items for Transfert
    for (var order in selectedOrders) {
      warehouse_id = order.warehouse_id;
      for (var item in order.orderitems) {
        if (productsTransfer
            .where((element) => element.variant_id == item.variant_id)
            .isEmpty) {
          productsTransfer.add(
            StockOperationItems(
              id: getNewId(),
              variant_id: item.variant_id,
              image: item.image,
              product_name: item.product_name,
              variant_1: item.variant_name_1,
              variant_2: item.variant_name_2 ?? "",
              unite: "Pcs",
              package: item.package,
              quantity:
                  item.quantity * (item.unite == "Cart" ? item.package : 1),
              saleprice: item.price /
                  (item.unite == "Cart" ? item.package : 1) /
                  ((100 - item.discount) / 100),
              stockprice: 0,
            ),
          );
        } else {
          productsTransfer
              .where((element) => element.variant_id == item.variant_id)
              .first
              .addQuantity(
                  item.quantity * (item.unite == "Cart" ? item.package : 1));
        }
      }
    }
    if (global.PackingWithBox) {
      for (var element in productsTransfer) {
        if (element.quantity % element.package != 0) {
          element.quantity = element.quantity -
              (element.quantity % element.package) +
              element.package;
        }
      }
    }
    BonTransfert = StockOperation(
      id: Transert_id!,
      type: "chargement",
      warehouse_id: warehouse_id,
      operation_date: DateTime.now(),
      force_package: global.PackingWithBox,
      items: productsTransfer,
      purchase_ids: BLs.value,
    );
    var data = BonTransfert!.toMap();
    data["track_id"] = trackId!;
    print(data["track_id"]);

    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.saveTransfer,
      data: data,
    );
    if (response.status == "SUCCESS") {
      BLs.value = [];
      selectedOrders = [];
      productsTransfer = [];
      await getOrderReadyToPack();
      Transert_id = getNewId();
    } else {
      print(response.message);
    }
    return response;
  }

  String getNewId() {
    Uuid uuid = const Uuid();
    return uuid.v1();
  }

  PrepareToPrint() {
    textPrint = [];
    var formatter = NumberFormat("#,##0.00", "fr_FR");

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
        text1: "Commande N°: ",
        text2: OrderCode,
        format: '%-18s %28s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Date et Heure ",
        text2: FormatDateTime(DateTime.now()),
        format: '%-20s %26s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        align: LineTextPrinter.RIGHT,
        text1: "Livraison prevu ",
        text2: FormatDateTime(planned_delivery_date!),
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
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Produit",
        text2: "Qtte",
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
    for (var item in orderitems) {
      p_total += item.total;
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: item.product_name
              .replaceAll("é", "e")
              .replaceAll("è", "e")
              .replaceAll("à", "a"),
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
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Total",
        text2: p_total.toStringAsFixed(2),
        format: '%-10s %13s %n',
        size: 2,
      ),
    );

    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_CODE_QR,
        text1: purchaseorderId!,
        size: 150,
        align: LineTextPrinter.CENTER,
      ),
    );
  }

  @override
  void onInit() async {
    if (tag != null && tag == "delivery") {
      Transert_id = getNewId();
      await getOrderReadyToPack();
    }
    super.onInit();
  }
}
