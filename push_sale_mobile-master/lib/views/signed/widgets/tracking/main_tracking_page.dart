import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/views/signed/widgets/tracking/orders_to_track.dart';
import 'package:push_sale/views/signed/widgets/tracking/tracking_detail.dart';

class MainTrackingOrder extends StatelessWidget {
  final PageController pageController = PageController();
  final OrderController orderController =
      Get.put(OrderController(tag: "tracking"));

  MainTrackingOrder({super.key});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (orderController.page.value != 0) {
          orderController.page.value = orderController.page.value - 1;
          if (pageController.hasClients) {
            pageController.animateToPage(orderController.page.value,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        }
        return false;
      },
      child: SizedBox.expand(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
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
    );
  }
}
