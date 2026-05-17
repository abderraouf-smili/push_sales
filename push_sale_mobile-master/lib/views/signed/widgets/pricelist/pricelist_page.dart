import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/pricelist_controller.dart';
import 'package:push_sale/views/signed/widgets/pricelist/pricelist_widget.dart';

class PricelistPage extends StatelessWidget {
  PricelistController priceController = Get.put(PricelistController());

  PricelistPage({super.key});
  @override
  Widget build(BuildContext context) {
    priceController.getPricelist();
    return Scaffold(
      appBar: AppBar(
        title: Text("my.pricelists".tr),
        centerTitle: true,
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: priceController.getPricelist,
          child: Obx(
            () => priceController.loadPricelist.value
                ? ListView.builder(
                    itemCount: priceController.pricelist.length *
                        (priceController.loadPricelist.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      var item = priceController.pricelist[index];
                      return PricelistWidget(item);
                    })
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
