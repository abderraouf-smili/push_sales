// ignore_for_file: must_be_immutable, prefer_final_fields

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/reason_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/views/signed/widgets/clients/editclient.dart';
import 'package:push_sale/views/signed/widgets/orders/show_order_detail.dart';
import 'package:push_sale/views/signed/widgets/commandes/products.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:push_sale/const/globals.dart' as global;

class FicheClient extends StatelessWidget {
  Client _client;
  PermissionsController Perm = Get.find();
  ReasoController reasonController = Get.put(ReasoController());
  FicheClient(this._client, {super.key});
  ProductController productController = Get.put(ProductController());
  ClientController clientController = Get.find();

  @override
  Widget build(BuildContext context) {
    productController.client = _client;
    productController.getFullPromotion();
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    clientController.getCurrentOrders(_client.id);
    return SafeArea(
      bottom: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            _client.name,
            style: const TextStyle(fontFamily: "alata", fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.withOpacity(0.5),
          actions: [
            PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      {
                        Get.to(() => Products(_client));
                      }
                      break;
                    case 1:
                      {
                        Get.to(() => EditClient(client: _client));
                      }
                      break;

                    case 5:
                      {
                        //show window to select reason of non-sale
                        showVisitOption(context, reasonController, _client.id,
                            clientController);
                      }
                      break;
                  }
                },
                elevation: 5,
                icon: const Icon(Icons.menu),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        value: 0,
                        enabled: Perm.check(null, "Clients.sale"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("sale".tr),
                            const Icon(Icons.calculate_rounded,
                                color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                        value: 5,
                        enabled: Perm.check(null, "Clients.sale"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("visit".tr),
                            const Icon(Icons.local_taxi_outlined,
                                color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                        enabled: Perm.check(null, "Clients.update"),
                        value: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("edit".tr),
                            const Icon(Icons.edit, color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                        enabled:
                            Perm.check(null, "Clients.printhistorybalance"),
                        value: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("print.client.balance".tr),
                            const Icon(Icons.print, color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                      enabled: true,
                      value: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("printer.settings".tr,
                              style: const TextStyle(color: Colors.black)),
                          const Icon(Icons.bluetooth, color: Colors.blue),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                        enabled: false,
                        value: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Desactiver",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 250, 202, 198)),
                            ),
                            Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                          ],
                        ))
                  ];
                })
          ],
        ),
        body: SlidingUpPanel(
            collapsed: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: Color.fromARGB(255, 41, 112, 148),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.arrow_upward_sharp,
                    color: Colors.white,
                  ),
                  Text(
                    "client.more.infos".tr,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ),
            isDraggable: true,
            maxHeight: Get.height / 1.8,
            minHeight: Get.height / 12,
            parallaxEnabled: true,
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      padding: EdgeInsets.zero,
                      width: double.infinity,
                      height: Get.height / 2,
                      decoration: BoxDecoration(
                        // color: Colors.red,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            _client.image,
                            cacheKey: _client.image,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _client.mobile == ""
                      ? const SizedBox.shrink()
                      : Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.phone_iphone,
                                  size: 25,
                                  color: Colors.blue,
                                ),
                                Text(
                                  " ${_client.mobile}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Perm.check(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    "assets/images/solde.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  Container(
                                    child: Text(
                                      formatter.format(_client.solde),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              "Clients.solde"))),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: Get.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 25,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: Get.width - 70,
                            child: ListView.builder(
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemCount: _client.visitdays!.length,
                                itemBuilder: (context, index) {
                                  var day = _client.visitdays![index].day;
                                  return Container(
                                    width: 125,
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          day.tr,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      // margin: EdgeInsets.symmetric(vertical: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MaterialButton(
                        color: Colors.green,
                        onPressed: Perm.check(null, "Clients.sale")
                            ? () {
                                Get.to(() => Products(_client));
                              }
                            : null,
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        child: Text(
                          "get_started".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: SizedBox.shrink(),
                  )
                ],
              ),
            ),
            panelBuilder: (scroll) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15))),
                height: Get.height / 1.5,
                child: Column(
                  children: [
                    Align(
                      alignment: Get.locale!.languageCode == "ar"
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          "others".tr,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    Obx(
                      () {
                        if (productController.loadVariantReady.value) {
                          List<dynamic> list = productController.listPromo;
                          return SizedBox(
                            width: Get.width - 20,
                            height: 120 * (list.isNotEmpty ? 1 : 0),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return PromoItem(list[index]);
                                }),
                          );
                        } else {
                          return const SizedBox(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    Perm.check(
                        Container(
                          alignment: Alignment.centerLeft,
                          width: Get.width,
                          height: Get.height / 3,
                          child: Obx(
                            () => clientController.current_orders_ready.value
                                ? ListView.builder(
                                    itemCount:
                                        clientController.current_orders.length,
                                    itemBuilder: (context, index) {
                                      var item = clientController
                                          .current_orders[index];
                                      return ListTile(
                                        onTap: () {
                                          Get.to(() => ShowOrderDetail(
                                              clientController
                                                  .current_orders[index]));
                                        },
                                        title: Text(item.code),
                                        leading: Container(
                                          child: item.state == "paid"
                                              ? Image.asset(
                                                  "assets/images/paid.png",
                                                  width: 40,
                                                  height: 40,
                                                )
                                              : item.state == "shipped"
                                                  ? const Icon(
                                                      Icons
                                                          .child_friendly_outlined,
                                                      color: Color.fromARGB(
                                                          255, 239, 133, 253),
                                                      size: 35,
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .local_shipping_outlined,
                                                      color: Colors.blue,
                                                      size: 35,
                                                    ),
                                        ),
                                        subtitle: SizedBox(
                                          width: Get.width / 10,
                                          child: Text(
                                              DateFormat("dd-MM-yyyy HH:mm")
                                                  .format(item.order_date)),
                                        ),
                                        trailing: Text(
                                          formatter.format(item.total_amount),
                                          style: const TextStyle(
                                              fontFamily: "alata",
                                              fontSize: 18),
                                        ),
                                      );
                                    })
                                : const SizedBox(
                                    width: double.infinity,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                          ),
                        ),
                        "Clients.orders"),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class PromoItem extends StatelessWidget {
  var item;
  PromoItem(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: 100,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 5,
            child: Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage(
                  item.image,
                ),
              )),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 97, 89),
                border: Border.all(
                    width: 1, color: const Color.fromARGB(255, 255, 21, 0)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "-" + item.discount.toStringAsFixed(0) + "%",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 251, 0),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 10,
              child: SizedBox(
                width: 80,
                height: 30,
                // color: Colors.orange,
                child: Center(
                  child: Text(
                    item.product,
                    style: const TextStyle(fontSize: 8, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

void showVisitOption(BuildContext context, ReasoController reasoController,
    String clientId, ClientController clientController) {
  reasoController.submittig = "new".obs;
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 25),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 43, 87, 124),
          ),
          width: double.infinity,
          height: 50,
          child: Center(
            child: Text(
              "reason.no.sale".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
        content: SizedBox(
          height: reasoController.ReasonSale.length * 55,
          width: Get.width,
          child: Obx(
            () => reasoController.submittig.value == "new"
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: reasoController.ReasonSale.length,
                    itemBuilder: (context, index) {
                      var item = reasoController.ReasonSale[index];
                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            reasoController.selectedId.value = item.id;
                          },
                          child: AnimatedContainer(
                            curve: Curves.easeInOut,
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: reasoController.selectedId.value == item.id
                                  ? const Color.fromARGB(255, 225, 228, 255)
                                  : Colors.white,
                              border: Border.all(
                                width: 1,
                                color: reasoController.selectedId.value ==
                                        item.id
                                    ? const Color.fromARGB(255, 179, 182, 255)
                                    : const Color.fromARGB(255, 218, 220, 255),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: item.getIcon(),
                                    ),
                                    Text(
                                      item.getDescription(
                                          Get.deviceLocale!.languageCode),
                                    ),
                                  ],
                                ),
                                item.revisit
                                    ? Icon(
                                        Icons.restart_alt,
                                        color: Colors.green,
                                        size: Get.width / 20,
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : reasoController.submittig.value == "submit"
                    ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : reasoController.submittig.value == "success"
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
          ),
        ),
        actions: <Widget>[
          SizedBox(
            width: 300,
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  minWidth: 145,
                  height: 55,
                  color: Colors.red,
                  child: Text(
                    'cancel'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                MaterialButton(
                  minWidth: 145,
                  height: 55,
                  color: Colors.blue,
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (reasoController.selectedId.value > 0) {
                      await reasoController.submit(clientId);
                      await clientController.getClients();
                      Get.back();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
