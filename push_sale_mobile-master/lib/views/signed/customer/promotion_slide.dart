import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/customer_homepage_controller.dart';

class PromotionSlide extends StatelessWidget {
  CustomerHomepageController customerController =
      Get.put(CustomerHomepageController());
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;

  PromotionSlide({super.key});

  void reload() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (customerController.currentPageIndex.value < 2) {
        customerController.currentPageIndex.value++;
      } else {
        customerController.currentPageIndex.value = 0;
      }
      _pageController.animateToPage(
        customerController.currentPageIndex.value,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    reload();
    return Center(
      child: SizedBox(
        height: 200,
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            // setState(() {
            customerController.currentPageIndex.value = index;
            // });
          },
          children: [
            Container(
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Page 1',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.red,
              child: const Center(
                child: Text(
                  'Page 2',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.green,
              child: const Center(
                child: Text(
                  'Page 3',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
