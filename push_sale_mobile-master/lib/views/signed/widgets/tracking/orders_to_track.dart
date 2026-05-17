import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';

class OrderToTrack extends StatelessWidget {
  OrderController orderController = Get.find();

  OrderToTrack(this.pageController, {super.key});
  PageController pageController;
  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Column(
      children: [
        Container(
          width: Get.width,
          height: 55,
          color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(
                width: 50,
              ),
              SizedBox(
                width: Get.width - 100,
                child: Center(
                  child: Text(
                    "orders.to.track".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    var date = await showDatePicker(
                      locale: const Locale('fr'),
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date != null) {
                      orderController.selectedDate = date;
                      orderController.getOrdersToTrack(
                          date: orderController.selectedDate);
                    }
                  },
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white,
                  ))
            ],
          ),
        ),
        Obx(() {
          double total = 0.0;
          double amountShipped = 0.0;
          double amountCash = 0.0;
          double amountDiff = 122110.0;
          if (orderController.loadordersToTrack.value) {
            for (var element in orderController.ordersToTrack) {
              for (var item in element.tracking!) {
                total += item.state == "new" ? item.amount! : 0;
                amountShipped += item.state == "shipped" ? item.amount! : 0;
                amountCash +=
                    item.state == "paid" || item.state == "partially_paid"
                        ? item.amount!
                        : 0;
              }
            }
          }
          amountDiff = amountShipped - amountCash;
          return orderController.loadordersToTrack.value
              ? SizedBox(
                  width: Get.width,
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: Get.width / 4.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              size: 18,
                              Icons.local_grocery_store_rounded,
                              color: Color.fromARGB(255, 179, 180, 90),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              formatter.format(total),
                              style: const TextStyle(
                                  fontFamily: "alata", fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Get.width / 4.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              size: 18,
                              Icons.local_shipping,
                              color: Color.fromARGB(255, 221, 100, 205),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              formatter.format(amountShipped),
                              style: const TextStyle(
                                  fontFamily: "alata", fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Get.width / 4.25,
                        child: Row(children: [
                          const Icon(
                            size: 18,
                            Icons.real_estate_agent_outlined,
                            color: Colors.green,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(formatter.format(amountCash),
                              style: const TextStyle(
                                  fontFamily: "alata", fontSize: 13)),
                        ]),
                      ),
                      SizedBox(
                        width: Get.width / 4.25,
                        child: Row(children: [
                          const Icon(
                            size: 18,
                            Icons.money_rounded,
                            color: Color.fromARGB(255, 240, 170, 114),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(formatter.format(amountDiff),
                              style: const TextStyle(
                                  fontFamily: "alata", fontSize: 13)),
                        ]),
                      ),
                    ],
                  ),
                )
              : const SizedBox(
                  height: 45,
                );
        }),
        const Divider(
          height: 1,
          color: Colors.grey,
        ),
        SizedBox(
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
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                      },
                      child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          title: SizedBox(
                            width: Get.width / 2.5,
                            child: Text(
                              item.client!.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${item.client!.address!.city.name} (${item.client!.address!.wilaya.code})"),
                                  Text(DateFormat("dd/MM/y HH:mm")
                                      .format(item.planned_delivery_date))
                                ],
                              ),
                              item.tracking!.isNotEmpty
                                  ? item.tracking!.last.getIcon()
                                  : const SizedBox.shrink()
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
                          trailing: SizedBox(
                            width: Get.width / 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  formatter.format(item.delivery_amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  ("state.${item.tracking!.last.state}").tr,
                                  style: const TextStyle(fontSize: 11),
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
