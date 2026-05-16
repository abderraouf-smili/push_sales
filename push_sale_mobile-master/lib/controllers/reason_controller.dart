import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/reason_no_delivery_sale.dart';
import 'package:uuid/uuid.dart';

class ReasoController extends GetxController {
  //
  RxBool loadReason = false.obs;
  RxInt selectedId = 0.obs;
  List<ReasonNoDeliverySale> tmp = [];
  RxString submittig = "new".obs;
  String? visit_id;
  // reason non sale
  List<ReasonNoDeliverySale> ReasonSale = [];
  // reason non delivery
  List<ReasonNoDeliverySale> ReasonDelivery = [];

  Future<void> getReasons() async {
    loadReason.value = false;
    ReasonSale = [];
    ReasonDelivery = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.reasonNoDeliverySale);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        tmp.add(ReasonNoDeliverySale.fromMap(item));
      }
      ReasonSale = List.from(tmp
          .where(
            (element) => element.type_reason == "order",
          )
          .toList());
      ReasonDelivery = List.from(tmp
          .where(
            (element) => element.type_reason == "delivery",
          )
          .toList());
      loadReason.value = true;
    } else {
      //
      print(response.message);
    }
  }

  Future<void> submit(String client_id) async {
    submittig.value = "submit";
    if (visit_id == null) {
      generateId();
    }
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.saveVisit, data: {
      "visit_id": visit_id,
      "client_id": client_id,
      "reason_id": selectedId.value,
    });
    if (response.status == "SUCCESS") {
      await Future.delayed(Duration(milliseconds: 500));
      submittig.value = "success";
    } else {
      print(response.message);
      submittig.value = "error";
    }
  }

  generateId() {
    Uuid uuid = const Uuid();
    visit_id = uuid.v1();
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    await getReasons();
    super.onInit();
  }
}
