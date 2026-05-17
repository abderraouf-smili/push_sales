import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/creaces_controller.dart';
import 'package:push_sale/views/signed/widgets/creances/client_creance.dart';

class ListCreances extends StatelessWidget {
  PageController pageController;
  ListCreances(this.pageController, {super.key});
  CreancesController creancesController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: RefreshIndicator(
      onRefresh: creancesController.getCreances,
      child: Obx(() => ListView.builder(
          itemCount: creancesController.creances.length *
              (creancesController.loadGlobalCreance.value ? 1 : 0),
          itemBuilder: (context, index) {
            var item = creancesController.creances[index];
            return GestureDetector(
              onTap: () {
                // TODO:
                creancesController.selectedClient = item;
                pageController.animateToPage(
                  1,
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 200),
                );
              },
              child: ClientCreance(item),
            );
          })),
    ));
  }
}
