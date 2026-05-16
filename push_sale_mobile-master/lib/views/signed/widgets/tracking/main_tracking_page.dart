import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/views/signed/widgets/tracking/orders_to_track.dart';
import 'package:push_sale/views/signed/widgets/tracking/tracking_detail.dart';

class MainTrackingOrder extends StatelessWidget {
  PageController pageController = PageController();
  OrderController orderController = Get.put(OrderController(tag: "tracking"));
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (orderController.page.value != 0) {
          orderController.page.value = orderController.page.value - 1;
          pageController.animateToPage(orderController.page.value,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        }
        return false;
      },
      child: Container(
        width: Get.width,
        height: Get.height - 80,
        child: Column(
          children: [
            Container(
              width: Get.width,
              height: Get.height - 80,
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: (value) {
                  orderController.page.value = value;
                },
                children: [
                  OrderToTrack(pageController),
                  TrackingDetail(pageController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
