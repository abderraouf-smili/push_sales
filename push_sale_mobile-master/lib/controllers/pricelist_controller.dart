import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/line_text_printer.dart';
import 'package:push_sale/models/pricelist.dart';

class PricelistController extends GetxController {
  RxBool loadPricelist = false.obs;
  RxString error = "".obs;
  List<PriceList> pricelist = [];
  List<LineTextPrinter> textPrint = [];

  Future<void> getPricelist() async {
    loadPricelist.value = false;
    error.value = "";
    final response = await CallApi.RequestHttp(global.pricelist);
    try {
      if (response.status == "SUCCESS") {
        final rows = (response.data as List?) ?? const [];
        pricelist = rows
            .whereType<Map>()
            .map((element) =>
                PriceList.fromMap(Map<String, dynamic>.from(element)))
            .toList();
      } else {
        error.value = response.message.toString();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loadPricelist.value = true;
    }
  }

  PrepareToPrintListing(String pro, Map<String, dynamic> lines) {
    textPrint = [];
    textPrint.add(LineTextPrinter(
      type: LineTextPrinter.TYPE_TEXT,
      align: LineTextPrinter.CENTER,
      text1: "Push Sale - Pricing",
      size: 4,
    ));
    textPrint.add(
      LineTextPrinter(
        type: LineTextPrinter.TYPE_TEXT,
        text1: "-",
        size: 0,
      ),
    );
    textPrint.add(LineTextPrinter(
      type: LineTextPrinter.TYPE_TEXT,
      align: LineTextPrinter.CENTER,
      text1: FormatDateTime(DateTime.now()),
      size: 2,
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
        text1: pro,
        text2: "Prix Unitaire",
        format: '%-34s %13s\n',
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
    int i = 1;
    lines.forEach((variant, prix) {
      textPrint.add(
        LineTextPrinter(
          type: LineTextPrinter.TYPE_TEXT,
          text1: "$i- $variant",
          text2: prix.toString(),
          format: '%-38s %9s\n',
          size: 1,
        ),
      );
      i++;
    });
  }
}
