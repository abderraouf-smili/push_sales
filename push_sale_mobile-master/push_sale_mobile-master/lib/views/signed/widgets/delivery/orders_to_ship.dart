import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/purchase_orderitem.dart';
import 'package:push_sale/models/variant.dart';

class OrdersToShip extends StatelessWidget {
  PageController pageController;
  OrderController orderController = Get.find();
  OrdersToShip(this.pageController);
  @override
  Widget build(BuildContext context) {
    orderController.pageController = pageController;
    return Column(children: [
      Container(
        width: double.infinity,
        height: 50,
        color: Colors.blue,
        child: Row(
          children: [
            SizedBox.shrink(),
            Container(
              width: Get.width - 50,
              child: Center(
                child: Text(
                  "orders.to.ship".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      orderController.getOptimizedRoute();
                      // print(orderController.waypoints);
                      break;
                    default:
                  }
                },
                elevation: 5,
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      enabled: true,
                      value: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("optimize.route".tr,
                              style: TextStyle(
                                  color: !true ? Colors.grey : Colors.black)),
                          Icon(Icons.share_location_outlined,
                              color: !true ? Colors.grey : Colors.blue),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "maps.route".tr,
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(Icons.map_sharp, color: Colors.blue),
                        ],
                      ),
                    ),
                  ];
                })
          ],
        ),
      ),
      Obx(
        () => Container(
          height: orderController.statusLoadRoute.value != "none" ? 70 : 0,
          child: Column(
            children: [
              Container(
                width: Get.width,
                height: 69,
                child: orderController.statusLoadRoute.value == "success"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              orderController.route_position.value =
                                  orderController.route_position.value == 0
                                      ? 0
                                      : orderController.route_position.value -
                                          1;
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.red,
                            ),
                          ),
                          Container(
                            width: Get.width / 1.8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.place),
                                    Text(
                                      orderController.route_maps[orderController
                                              .route_position.value]
                                          .getStartAdress(),
                                      style: TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.flag),
                                    Text(
                                      orderController.route_maps[orderController
                                              .route_position.value]
                                          .getEndAdress(),
                                      style: TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: Get.width / 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.timeline_sharp),
                                    Text((orderController
                                                    .route_maps[orderController
                                                        .route_position.value]
                                                    .distance /
                                                1000)
                                            .toStringAsFixed(0) +
                                        " " +
                                        "km".tr),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.timer_sharp),
                                    Text((orderController
                                                    .route_maps[orderController
                                                        .route_position.value]
                                                    .time /
                                                60)
                                            .toStringAsFixed(0) +
                                        " " +
                                        "min".tr),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              orderController
                                  .route_position.value = orderController
                                          .route_position.value ==
                                      (orderController.route_maps.length - 1)
                                  ? (orderController.route_maps.length - 1)
                                  : orderController.route_position.value + 1;
                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )
                    : orderController.statusLoadRoute.value == "error"
                        ? Container(
                            child: Center(
                              child: Icon(
                                Icons.error_outlined,
                                color: Colors.red,
                              ),
                            ),
                          )
                        : orderController.statusLoadRoute.value == "loading"
                            ? Container(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : SizedBox.shrink(),
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),
            ],
          ),
        ),
      ),
      Container(
        height: 40,
        width: double.infinity,
        child: TabBar(
          controller: orderController.tabController,
          isScrollable: true,
          tabs: [
            Container(
              width: Get.width / 3 - 32,
              child: Tab(
                icon: Icon(
                  Icons.local_grocery_store_outlined,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              width: Get.width / 3 - 32,
              child: Tab(
                icon: Icon(
                  Icons.directions_car_filled_outlined,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              width: Get.width / 3 - 32,
              child: Tab(
                icon: Icon(
                  Icons.settings_backup_restore_outlined,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
      Obx(
        () => Container(
          height: Get.height -
              143 -
              40 -
              (orderController.statusLoadRoute.value != "none" ? 71 : 0),
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: orderController.tabController,
            children: [
              ListPurchaseOrders(pageController),
              ListPurchaseOrdersOnMap(),
              ReturnGoods(),
            ],
          ),
        ),
      ),
    ]);
  }
}

class ListPurchaseOrders extends StatelessWidget {
  ListPurchaseOrders(this.pageController);
  PageController pageController;
  OrderController orderController = Get.find();
  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return Container(
      width: Get.width,
      height: Get.height - 143 - 81,
      child: Obx(
        () => RefreshIndicator(
          onRefresh: orderController.getPurchaseOrdersToShip,
          child: ListView.builder(
            itemCount: orderController.shippingOrders.length *
                (orderController.loadshippingOrders.value ? 1 : 0),
            itemBuilder: (context, index) {
              var item = orderController.shippingOrders[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromARGB(255, 209, 209, 209),
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromARGB(255, 255, 255, 255)),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  onTap: () {
                    orderController.selectedPO = item;
                    pageController.animateToPage(1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.linear);
                  },
                  title: Container(child: Text(item.client!.name)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.client!.address!.city.name +
                                " - " +
                                item.client!.address!.wilaya.name,
                          ),
                          item.state == "paid"
                              ? Icon(
                                  Icons.check_box,
                                  color: Colors.green,
                                )
                              : item.state == "shipped"
                                  ? Icon(
                                      Icons.child_friendly_outlined,
                                      color: Color.fromARGB(255, 239, 133, 253),
                                    )
                                  : SizedBox.shrink()
                        ],
                      ),
                      Container(child: Text(item.code)),
                    ],
                  ),
                  leading: Container(
                    // margin: EdgeInsets.symmetric(horizontal: 5),
                    width: Get.width / 5,
                    // height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          item.client!.image,
                          cacheKey: item.client!.image,
                        ),
                      ),
                    ),
                  ),
                  trailing: Container(
                    width: 90,
                    height: 45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatter.format(item.total_amount),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'alata')),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 16,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                item.orderitems.length.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ListPurchaseOrdersOnMap extends StatelessWidget {
  OrderController orderController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GoogleMap(
        myLocationEnabled:
            orderController.points_delivery_loaded.value ? true : true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {},
        polylines: orderController.statusLoadRoute.value == "success"
            ? orderController
                .route_maps[orderController.route_position.value].Polylines
            : <Polyline>{},
        initialCameraPosition: orderController.MyCurrentPosition != null
            ? CameraPosition(
                target: LatLng(orderController.MyCurrentPosition!.latitude,
                    orderController.MyCurrentPosition!.longitude),
                zoom: 11,
              )
            : CameraPosition(
                target: LatLng(0, 0),
                zoom: 11,
              ),
        markers: orderController.points_delivery,
        circles: Set.from(
          [
            Circle(
              circleId: CircleId("myposition"),
              center: LatLng(
                  orderController.MyCurrentPosition == null
                      ? 36.693672548327164
                      : orderController.MyCurrentPosition!.latitude,
                  orderController.MyCurrentPosition == null
                      ? 3.073091941698789
                      : orderController.MyCurrentPosition!.longitude),
              radius: 500,
              strokeWidth: 1,
              strokeColor: Colors.blue,
              fillColor: Colors.blue.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class ReturnGoods extends StatelessWidget {
  ReturnGoods({Key? key}) : super(key: key);
  OrderController orderController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height - 143 - 81,
      child: ListView.builder(
          itemCount: orderController.restant.length,
          itemBuilder: (context, index) {
            var item = orderController.restant[index];
            return ListTile(
              title: Text(item.product_name),
              leading: CachedNetworkImage(
                cacheManager: CacheManager(
                  Config(
                    item.image,
                    stalePeriod: const Duration(days: 7),
                  ),
                ),
                imageUrl: item.image,
                placeholder: (context, url) => Container(
                    width: 30, height: 30, child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              subtitle: Text(item.variant_name_1 + " " + item.variant_name_2!),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.restant ~/ item.package != 0
                      ? (item.restant ~/ item.package).toStringAsFixed(0) +
                          " Cart"
                      : ""),
                  Text(item.restant % item.package != 0
                      ? (item.restant % item.package).toStringAsFixed(0) +
                          " Pcs"
                      : ""),
                ],
              ),
            );
          }),
    );
  }
}
