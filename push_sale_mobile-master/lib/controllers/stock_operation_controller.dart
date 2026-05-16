import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/line_text_printer.dart';
import 'package:push_sale/models/stock_operation.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:uuid/uuid.dart';

class StockOperationController extends GetxController {
  //
  RxInt page = 0.obs;
  RxBool opLoaded = false.obs;
  RxBool confirmed = false.obs;
  StockOperation? itemSelected;
  List<LineTextPrinter> textPrint = [];
  String? trackId;

  List<StockOperation> bonschargement = [];
  var unvalaibleProduct = [];
  RxBool stock_out = false.obs;

  Future<void> getBonChargement() async {
    bonschargement = [];
    opLoaded.value = false;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.getTransfer);
    if (response.status == "SUCCESS") {
      for (var element in response.data) {
        bonschargement.add(StockOperation.fromMap(element));
      }
      opLoaded.value = true;
    } else {
      print(response.message);
    }
  }

  generateTrackId() {
    Uuid uuid = const Uuid();
    trackId = uuid.v1();
  }

  Future<dynamic> confimTransfer() async {
    generateTrackId();
    if (itemSelected != null) {
      ResponseHttpRequest response = await CallApi.RequestHttp(
          global.confirmTransfer,
          data: {"operation_id": itemSelected!.id, "track_id": trackId!});
      confirmed.value = response.status == "SUCCESS";
      return response;
    }
  }

  PrepareToTransferPrint() {
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
        text1: "Transfert Ref: ",
        text2: itemSelected!.code,
        format: '%-18s %28s %n',
        size: 1,
      ),
    );
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "Date",
        text2: FormatDateTime(itemSelected!.operation_date),
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

    for (var item in itemSelected!.items) {
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: item.product_name
              .replaceAll("é", "e")
              .replaceAll("è", "e")
              .replaceAll("à", "a"),
          text2: item.quantity ~/ item.package != 0
              ? (item.quantity ~/ item.package).toStringAsFixed(0) + " Cart"
              : "",
          size: 1,
          format: '%-30s %16s %n',
        ),
      );
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: "  " +
              item.variant_1
                  .replaceAll("é", "e")
                  .replaceAll("è", "e")
                  .replaceAll("à", "a") +
              " " +
              item.variant_2
                  .replaceAll("é", "e")
                  .replaceAll("è", "e")
                  .replaceAll("à", "a"),
          text2: item.quantity % item.package != 0
              ? (item.quantity % item.package).toStringAsFixed(0) + " Pcs "
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
    generateTrackId();
    await getBonChargement();
    super.onInit();
  }
}
