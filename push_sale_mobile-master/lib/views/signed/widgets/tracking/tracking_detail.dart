import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/tracking_order.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackingDetail extends StatelessWidget {
  PageController pageController;
  TrackingDetail(this.pageController, {super.key});
  OrderController orderController = Get.find();

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    orderController.changeLoad.value = "nothing";
    List<String> date0 = [];
    Map<String, List<TrackingOrder>> suiviParPO = {};
    bool isModifiable = true;
    for (var suivi in orderController.orderToTrack!.tracking!) {
      if (suivi.state == "shipped" ||
          suivi.state == "paid" ||
          suivi.state == "partially_paid") {
        isModifiable = false;
      }

      // Récupérer la valeur de purchase_order
      String po = suivi.purchaseorder_id;

      // Vérifier si la Map contient déjà une liste pour ce purchase_order
      if (!suiviParPO.containsKey(po)) {
        // Si non, créer une nouvelle liste pour ce purchase_order
        suiviParPO[po] = [];
        date0.add("");
      }

      // Ajouter l'information de suivi à la liste correspondante
      suiviParPO[po]!.add(suivi);
    }

    return Column(children: [
      Container(
        width: Get.width,
        height: 55,
        color: Colors.blue,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            SizedBox(
              width: Get.width - 100,
              child: Center(
                child: Text(
                  "track.order".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 70,
        width: Get.width,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(orderController.orderToTrack!.client!.name),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping_rounded),
                  const SizedBox(
                    width: 10,
                  ),
                  Text("delivery.planned.to".tr),
                  const SizedBox(
                    width: 10,
                  ),
                  Obx(
                    () => Text(
                      DateFormat("dd/MM/y HH:mm").format(
                          orderController.changeLoad.value != "success"
                              ? orderController
                                  .orderToTrack!.planned_delivery_date
                              : orderController.finalDate!),
                    ),
                  ),
                  isModifiable
                      ? Obx(
                          () => orderController.changeLoad.value == "nothing"
                              ? IconButton(
                                  onPressed: () async {
                                    var date = await showDatePicker(
                                      locale: Get.locale,
                                      context: context,
                                      initialDate: DateTime.now()
                                          .add(const Duration(days: 1)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 8)),
                                    );
                                    if (date != null) {
                                      var time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay(
                                            hour: DateTime.now().hour,
                                            minute: DateTime.now().minute),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Localizations.override(
                                            context: context,
                                            locale: Get.locale,
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (time != null) {
                                        orderController.finalDate = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          time.hour,
                                          time.minute,
                                        );
                                        orderController.changePlannedDate();
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.edit_calendar,
                                      color: Colors.red),
                                )
                              : orderController.changeLoad.value == "sent"
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                        )
                      : const SizedBox.square(),
                ],
              ),
            ],
          ),
        ),
      ),
      Container(
        height: Get.height - 210,
        color: Colors.white,
        child: SingleChildScrollView(
          child: SizedBox(
            height: Get.height - 210,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                suiviParPO.length,
                (i) {
                  var cle = suiviParPO.keys.elementAt(i);
                  var liste = suiviParPO[cle];
                  return SizedBox(
                    height: (Get.height - 210 - 10) / suiviParPO.length,
                    child: ListView.builder(
                      itemCount: liste!.length,
                      itemBuilder: (context, index) {
                        var item = liste[index];
                        bool showDate = true;
                        if (date0[i] !=
                            DateFormat("dd/MM/y").format(item.date)) {
                          date0[i] = DateFormat("dd/MM/y").format(item.date);
                        } else {
                          showDate = false;
                        }
                        return TimelineTile(
                          axis: TimelineAxis.vertical,
                          alignment: TimelineAlign.manual,
                          lineXY: 0.3,
                          isFirst: index == 0,
                          isLast: item.is_last,
                          indicatorStyle: IndicatorStyle(
                            width: 40,
                            color: item.getIcon().color!,
                            iconStyle: IconStyle(
                                color: Colors.white,
                                iconData: item.getIcon().icon!,
                                fontSize: 25),
                          ),
                          startChild: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                showDate
                                    ? Text(date0[i],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ))
                                    : const SizedBox.shrink(),
                                Text(
                                  DateFormat("HH:mm").format(item.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          endChild: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            height: 100,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: Get.width / 2.2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ("state.${item.state}").tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 20,
                                          ),
                                          Text(
                                            "${item.actor.firstname} ${item.actor.lastname}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Text(item.getDescription().tr),
                                      item.amount != null
                                          ? Text(formatter.format(item.amount))
                                          : const SizedBox.shrink()
                                    ],
                                  ),
                                ),
                                item.image != null
                                    ? Image.network(
                                        item.image!,
                                        width: Get.width / 10,
                                        height: Get.height / 15,
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
