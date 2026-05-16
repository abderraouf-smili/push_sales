import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/receivable.dart';
import 'package:uuid/uuid.dart';

class CreancesController extends GetxController {
  //
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxInt page = 0.obs;
  List<Receivale> creances = [];
  RxInt regularisation = 0.obs;

  String? trackId;

  List<ReceivaleLine> creancesLines = [];
  RxBool loadLines = false.obs;

  RxBool loadGlobalCreance = false.obs;
  Receivale? selectedClient;

  RxDouble encaissement = 0.0.obs;

  RxString saved = "notyet".obs;

  Future<void> getCreances() async {
    creances = [];
    loadGlobalCreance.value = false;

    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.globalReceivable);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        creances.add(Receivale.fromMap(item));
      }
      loadGlobalCreance.value = true;
    } else {
      print(response.message);
    }
  }

  generateTrackId() {
    Uuid uuid = const Uuid();
    trackId = uuid.v1();
  }

  Future<void> getDetailCreance() async {
    creancesLines = [];
    loadLines.value = false;
    ResponseHttpRequest response = await CallApi.RequestHttp(
        global.detailReceivale,
        data: {"client_id": selectedClient!.client_id});
    print(response.code);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        creancesLines.add(ReceivaleLine.fromMap(item));
      }
      loadLines.value = true;
    } else {
      print(response.message);
    }
  }

  CashOrder() {
    regularisation.value = 0;
    double enc = encaissement.value;
    for (int i = creancesLines.length - 1; i >= 0; i--) {
      regularisation.value++;
      if (enc == creancesLines[i].solde) {
        //
        creancesLines[i].cashed = enc;
        break;
      } else if (enc > creancesLines[i].solde) {
        //
        creancesLines[i].cashed = creancesLines[i].solde;
        enc = enc - creancesLines[i].solde;
      } else {
        //
        creancesLines[i].cashed = enc;
        break;
      }
    }
  }

  List<Widget> showSoldeCash(ReceivaleLine item) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    List<Widget> reslut = [];
    if (item.cashed != null && item.cashed! > 0) {
      reslut.add(Text(formatter.format(item.solde),
          style: TextStyle(
              fontFamily: 'alata', decoration: TextDecoration.lineThrough)));
      if (item.solde != item.cashed!) {
        reslut.add(Text(formatter.format(item.solde - item.cashed!),
            style: TextStyle(fontFamily: 'alata')));
      }
    } else {
      reslut.add(Text(formatter.format(item.solde),
          style: TextStyle(fontFamily: 'alata')));
    }
    return reslut;
  }

  Future<void> sendCashForAll(
      dynamic pageController, dynamic clientController) async {
    saved.value = "clicked";
    var data = {
      "data": creancesLines.map((e) => e.toMap()).toList(),
      "track_id": trackId!
    };
    print(data);
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.sendCashForAll,
      data: data,
    );
    if (response.status == "SUCCESS") {
      await getCreances();
      await getDetailCreance();
      await clientController.getClients();
      pageController.animateToPage(
        0,
        curve: Curves.linear,
        duration: Duration(milliseconds: 200),
      );
      saved.value = "success";
    } else {
      saved.value = "error";
      print(response.message);
    }
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    await getCreances();
    super.onInit();
  }
}
