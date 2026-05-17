import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/creaces_controller.dart';
import 'package:push_sale/views/signed/widgets/creances/details_creance.dart';
import 'package:push_sale/views/signed/widgets/creances/list_creances.dart';

class MainCreancePage extends StatelessWidget {
  PageController pageController = PageController();
  CreancesController creancesController = Get.put(CreancesController());
  ClientController clientController = Get.put(ClientController(""));
  var formatter = NumberFormat("#,##0.00", "fr_FR");

  MainCreancePage({super.key});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (creancesController.page.value == 1) {
          pageController.animateToPage(
            0,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 200),
          );
        } else if (creancesController.page.value == 0) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "receivables".tr,
            style: const TextStyle(fontFamily: "kodchasan", fontSize: 16),
          ),
        ),
        body: SizedBox(
            width: Get.width,
            height: Get.height - 100,
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                height: Get.height - 100,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (value) {
                    creancesController.page.value = value;
                  },
                  children: [
                    ListCreances(pageController),
                    DetailsCreance(pageController),
                  ],
                ),
              ),
            ])),
      ),
    );
  }
}
