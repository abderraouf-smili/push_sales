import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/coupon_controller.dart';
import 'package:push_sale/views/signed/widgets/coupons/coupon_fiche.dart';
import 'package:push_sale/views/signed/widgets/coupons/coupon_item.dart';

class CouponsList extends StatelessWidget {
  CouponController couponController = Get.put(CouponController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CouponFiche(null));
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("my.coupons".tr),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: Get.height - 90,
        child: RefreshIndicator(
          onRefresh: couponController.getCouponns,
          child: Obx(
            () => ListView.builder(
                itemCount: couponController.coupons.length *
                    (couponController.loadList.value ? 1 : 0),
                itemBuilder: (context, index) {
                  var item = couponController.coupons[index];
                  return GestureDetector(
                    child: CouponItem(item),
                    onTap: () {
                      Get.to(() => CouponFiche(item));
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }
}
