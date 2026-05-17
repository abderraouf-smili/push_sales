import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/customer_homepage_controller.dart';

class PromotionSlide extends StatefulWidget {
  const PromotionSlide({super.key});

  @override
  State<PromotionSlide> createState() => _PromotionSlideState();
}

class _PromotionSlideState extends State<PromotionSlide> {
  final CustomerHomepageController customerController =
      Get.put(CustomerHomepageController());
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
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
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
