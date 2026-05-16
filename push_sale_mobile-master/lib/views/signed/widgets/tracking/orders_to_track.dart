import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';

class OrderToTrack extends StatelessWidget {
  OrderController orderController = Get.find();

  OrderToTrack(this.pageController);
  PageController pageController;
  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return Column(
      children: [
        Container(
          width: Get.width,
          height: 55,
          color: Colors.blue,
          child: Row(
            children: [
              SizedBox(
                width: 50,
              ),
              Container(
                width: Get.width - 100,
                child: Center(
                  child: Text(
                    "orders.to.track".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    var _date = await showDatePicker(
                      locale: Locale('fr'),
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 90)),
                      lastDate: DateTime.now().add(Duration(days: 1)),
                    );
                    if (_date != null) {
                      orderController.selectedDate = _date;
                      orderController.getOrdersToTrack(
                          date: orderController.selectedDate);
                    }
                  },
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white,
                  ))
            ],
          ),
        ),
        Obx(() {
          double total = 0.0;
          double amount_shipped = 0.0;
          double amount_cash = 0.0;
          double amount_diff = 122110.0;
          if (orderController.loadordersToTrack.value) {
            orderController.ordersToTrack.forEach((element) {
              element.tracking!.forEach((item) {
                total += item.state == "new" ? item.amount! : 0;
                amount_shipped += item.state == "shipped" ? item.amount! : 0;
                amount_cash +=
                    item.state == "paid" || item.state == "partially_paid"
                        ? item.amount!
                        : 0;
              });
            });
          }
          amount_diff = amount_shipped - amount_cash;
          return orderController.loadordersToTrack.value
              ? Container(
                  width: Get.width,
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: Get.width / 4.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              size: 18,
                              Icons.local_grocery_store_rounded,
                              color: Color.fromARGB(255, 179, 180, 90),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              formatter.format(total),
                              style:
                                  TextStyle(fontFamily: "alata", fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: Get.width / 4.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              size: 18,
                              Icons.local_shipping,
                              color: Color.fromARGB(255, 221, 100, 205),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              formatter.format(amount_shipped),
                              style:
                                  TextStyle(fontFamily: "alata", fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: Get.width / 4.25,
                        child: Row(children: [
                          Icon(
                            size: 18,
                            Icons.real_estate_agent_outlined,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(formatter.format(amount_cash),
                              style:
                                  TextStyle(fontFamily: "alata", fontSize: 13)),
                        ]),
                      ),
                      Container(
                        width: Get.width / 4.25,
                        child: Row(children: [
                          Icon(
                            size: 18,
                            Icons.money_rounded,
                            color: Color.fromARGB(255, 240, 170, 114),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(formatter.format(amount_diff),
                              style:
                                  TextStyle(fontFamily: "alata", fontSize: 13)),
                        ]),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 45,
                );
        }),
        Divider(
          height: 1,
          color: Colors.grey,
        ),
        Container(
          width: Get.width,
          height: Get.height - 187,
          child: Obx(
            () => RefreshIndicator(
              onRefresh: orderController.getOrdersToTrack,
              child: ListView.builder(
                  itemCount: orderController.loadordersToTrack.value
                      ? orderController.ordersToTrack.length
                      : 0,
                  itemBuilder: (context, index) {
                    var item = orderController.ordersToTrack[index];
                    return GestureDetector(
                      onTap: () {
                        orderController.orderToTrack = item;
                        pageController.animateToPage(2,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                      },
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          title: Container(
                            width: Get.width / 2.5,
                            child: Text(
                              item.client!.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.client!.address!.city.name +
                                      " (" +
                                      item.client!.address!.wilaya.code +
                                      ")"),
                                  Text(DateFormat("dd/MM/y HH:mm")
                                      .format(item.planned_delivery_date))
                                ],
                              ),
                              item.tracking!.isNotEmpty
                                  ? item.tracking!.last.getIcon()
                                  : SizedBox.shrink()
                            ],
                          ),
                          leading: Container(
                            width: 70,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                    item.client!.image,
                                    cacheKey: item.client!.image,
                                  ),
                                )),
                          ),
                          trailing: Container(
                            width: Get.width / 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  formatter.format(item.delivery_amount),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  ("state." + item.tracking!.last.state).tr,
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          )),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
