import 'package:push_sale/const/globals.dart' as global;

import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/item_stock.dart';
import 'package:push_sale/models/line_text_printer.dart';
import 'package:push_sale/models/warehouse.dart';

class WarehouseController extends GetxController {
  RxInt page = 0.obs;
  RxBool UniteIsCaisse = true.obs;
  RxBool ready = false.obs;
  List<Warehouse> warehouses = [];
  Warehouse? warehouse;

  /* Delivery */
  String? tag;
  RxBool QtymustConfirm = false.obs;
  RxBool confirmed = false.obs;
  List<LineTextPrinter> textPrint = [];
  /* Delivery */

  WarehouseController({this.tag});

  /*  for delivery transfer  */

  RxBool currentStockLoaded = false.obs;
  List<ItemStock> currentStock = [];

  /* to adjust stock and price */
  List<PriceItem> adjustedPrice = [];
  List<AdjutStockItem> adjustedStock = [];
  RxList<int> adjusted = <int>[].obs;
  RxList<int> outOfStock = <int>[].obs;

  /* ----------- */

  Future<ResponseHttpRequest> adjustPriceStock() async {
    outOfStock.value = [];
    List<int> list = [];
    Map<String, dynamic> data = {
      "prices": adjustedPrice.map((e) => e.toMap()).toList(),
      "stock": adjustedStock.map((e) => e.toMap()).toList(),
      "warehouse_id": warehouse!.id,
    };
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.adjustement, data: data);
    if (response.status == "SUCCESS") {
    } else {
      for (var item in response.data) {
        list.add(item);
      }
      outOfStock.value = list;
      print(response.message);
      print(response.data);
    }
    return response;
  }

  Future<void> getWarehouses() async {
    warehouses = [];
    ready.value = false;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.listWarehouses);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        warehouses.add(Warehouse.fromMap(item));
      }
      ready.value = true;
    } else {
      print(response.message);
    }
  }

  Future<void> getCurrentStockMobile() async {
    currentStock = [];
    currentStockLoaded.value = false;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.currentStock);
    if (response.status == "SUCCESS") {
      currentStock = ItemStock.fromListMapToList(response.data);
      if (currentStock.isEmpty) {
        QtymustConfirm.value = false;
      } else {
        QtymustConfirm.value = currentStock
            .where((element) => element.previsionnel != element.quantity)
            .isNotEmpty;
      }
      currentStockLoaded.value = true;
    } else {
      print(response.message);
    }
  }

  prepareToPrintStock() {
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
        align: LineTextPrinter.CENTER,
        text1: "Etat du Stock",
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Date",
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
        text2: "Quantite",
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
    for (var item in currentStock) {
      if (item.quantity != 0) {
        textPrint.add(
          LineTextPrinter(
            type: LineTextPrinter.TYPE_TEXT,
            text1: item.short_description_fr
                .replaceAll("é", "e")
                .replaceAll("è", "e")
                .replaceAll("à", "a"),
            text2: item.quantity ~/ item.package != 0
                ? "${(item.quantity ~/ item.package).toStringAsFixed(0)} Cart"
                : "",
            size: 1,
            format: '%-30s %16s %n',
          ),
        );
        textPrint.add(
          LineTextPrinter(
            type: LineTextPrinter.TYPE_TEXT,
            text1:
                "  ${item.variant1_fr.replaceAll("é", "e").replaceAll("è", "e").replaceAll("à", "a")} ${item.variant2_fr.replaceAll("é", "e").replaceAll("è", "e").replaceAll("à", "a")}",
            text2: item.quantity % item.package != 0
                ? "${(item.quantity % item.package).toStringAsFixed(0)} Pcs "
                : "",
            size: 0,
            isSubTitle: true,
            format: '%-36s %10s %n',
          ),
        );
        textPrint.add(
          LineTextPrinter(
            type: LineTextPrinter.TYPE_TEXT,
            text1: "",
            size: 0,
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
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    if (tag != null && tag == "delivery") {
      await getCurrentStockMobile();
    }
    super.onInit();
  }
}
