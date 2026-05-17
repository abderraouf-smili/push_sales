import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/creaces_controller.dart';

class DetailsCreance extends StatelessWidget {
  PageController pageController;
  DetailsCreance(this.pageController, {super.key});
  CreancesController creancesController = Get.find();
  ClientController clientController = Get.find();
  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    creancesController.encaissement.value = 0;
    creancesController.regularisation.value = 0;
    creancesController.saved.value = "notyet";
    creancesController.getDetailCreance();
    creancesController.generateTrackId();
    return Column(
      children: [
        SizedBox(
          width: Get.width,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Text(creancesController.selectedClient!.client_name),
              showMenuCreanec(context, creancesController),
            ],
          ),
        ),
        const Divider(
          thickness: 1,
          height: 1,
        ),
        SizedBox(
          height: Get.height - 301,
          child: RefreshIndicator(
            onRefresh: creancesController.getDetailCreance,
            child: Obx(
              () => ListView.builder(
                itemCount: creancesController.creancesLines.length *
                    (creancesController.loadLines.value ? 1 : 0),
                itemBuilder: (context, index) {
                  var item = creancesController.creancesLines[index];
                  return Obx(
                    () => ListTile(
                      title: Text(item.code),
                      leading: Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: creancesController.regularisation.value > 0 &&
                                item.cashed != null
                            ? item.solde == item.cashed
                                ? const Icon(Icons.check_box_outlined,
                                    color: Colors.green)
                                : item.solde > item.cashed! && item.cashed! > 0
                                    ? const Icon(
                                        Icons.filter_center_focus_outlined,
                                        color: Colors.orange,
                                      )
                                    : const Icon(
                                        Icons.check_box_outline_blank_sharp)
                            : const Icon(Icons.check_box_outline_blank_sharp),
                      ),
                      subtitle: Text(DateFormat("dd/MM/y HH:mm")
                          .format(item.purchase_date)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: creancesController.showSoldeCash(item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 1,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Solde Precedent"),
              Text(
                  formatter.format(
                      creancesController.selectedClient!.total_vendu -
                          creancesController.selectedClient!.total_paye),
                  style: const TextStyle(fontFamily: 'alata'))
            ],
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total encaissé"),
                Text(
                  formatter.format(creancesController.encaissement.value),
                  style: const TextStyle(fontFamily: 'alata'),
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: Get.width / 4,
            child: const Divider(
              height: 1,
              thickness: 2,
            ),
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nouveau Solde"),
                Text(
                  formatter.format(
                      creancesController.selectedClient!.total_vendu -
                          creancesController.selectedClient!.total_paye -
                          creancesController.encaissement.value),
                  style: const TextStyle(fontFamily: 'alata'),
                )
              ],
            ),
          ),
        ),
        Obx(
          () => MaterialButton(
            onPressed: creancesController.encaissement.value > 0 &&
                    creancesController.saved.value == "notyet"
                ? () async {
                    await creancesController.sendCashForAll(
                        pageController, clientController);
                  }
                : null,
            color: creancesController.encaissement.value == 0
                ? Colors.grey
                : Colors.blue,
            height: 45,
            minWidth: 250,
            elevation: 10,
            child: creancesController.saved.value == "success"
                ? const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  )
                : creancesController.saved.value == "notyet"
                    ? Text(
                        "save".tr,
                        style: const TextStyle(color: Colors.white),
                      )
                    : creancesController.saved.value == "error"
                        ? const Icon(
                            Icons.error,
                            color: Colors.red,
                          )
                        : const CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

showEncaissementWindow(
    BuildContext context, CreancesController creanceController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController moneyTextController = TextEditingController();
      var formatter = NumberFormat("#,##0.00", "fr_FR");
      return AlertDialog(
        contentPadding: const EdgeInsets.only(left: 30, right: 30, top: 40),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: const BoxDecoration(
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
                  style: const TextStyle(color: Colors.white, fontSize: 18),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    height: 90,
                    child: Form(
                      key: creanceController.formKey,
                      child: SizedBox(
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
                            if (double.parse(value) >
                                (creanceController.selectedClient!.total_vendu -
                                    creanceController
                                        .selectedClient!.total_paye)) {
                              return "amount.must.be.bellow.to".tr +
                                  formatter.format((creanceController
                                          .selectedClient!.total_vendu -
                                      creanceController
                                          .selectedClient!.total_paye));
                            }
                            return null;
                          },
                          controller: moneyTextController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            labelText: "cash.money".tr,
                          ),
                          onSaved: (value) {
                            creanceController.encaissement.value =
                                double.parse(value!);
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                  child: const Text(
                "L'encaissement du montant revient à encaisser chaque commande ouverte en commençant par la plus ancienne",
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
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              var formdata = creanceController.formKey.currentState;
              if (formdata!.validate()) {
                formdata.save();
                creanceController.encaissement.value = double.parse(
                    moneyTextController.text == ""
                        ? "0"
                        : moneyTextController.text);
                creanceController.CashOrder();
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

PopupMenuButton showMenuCreanec(
    BuildContext context, CreancesController creanceController) {
  return PopupMenuButton(
    onSelected: (value) {
      switch (value) {
        case 0: // show Encaisser window
          showEncaissementWindow(context, creanceController);
          break;
        case 1:
          creanceController.encaissement.value =
              creanceController.selectedClient!.total_vendu -
                  creanceController.selectedClient!.total_paye;
          creanceController.CashOrder();
      }
    },
    elevation: 5,
    icon: const Icon(Icons.menu),
    itemBuilder: (context) {
      return [
        PopupMenuItem(
          value: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("client.cash".tr),
              const Icon(Icons.monetization_on_outlined, color: Colors.blue),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("client.cash.all".tr),
              const Icon(Icons.calculate_rounded, color: Colors.blue),
            ],
          ),
        ),
      ];
    },
  );
}
