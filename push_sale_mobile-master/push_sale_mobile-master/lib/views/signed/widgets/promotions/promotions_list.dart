import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/promotion_controller.dart';
import 'package:push_sale/views/signed/homepage.dart';
import 'package:push_sale/views/signed/widgets/promotions/edit_promotion.dart';
import 'package:push_sale/views/signed/widgets/promotions/fiche_promotion.dart';

class PromotionsList extends StatelessWidget {
  PromotionController promotionController = Get.put(PromotionController());
  @override
  Widget build(BuildContext context) {
    promotionController.getPromotions();
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("pormo.config".tr),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  bool canPop = Navigator.of(context).canPop();
                  if (canPop) {
                    Get.back();
                  } else {
                    Get.offAll(() => HomePage(index: 4));
                  }
                },
                icon: Icon(Icons.arrow_back)),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => EditPromotion());
            },
            child: const Icon(Icons.add),
          ),
          body: Obx(() => !promotionController.listIsReady.value
              ? Container(child: Center(child: CircularProgressIndicator()))
              : ListView.builder(
                  itemCount: promotionController.promotions.length,
                  itemBuilder: (context, index) {
                    var item = promotionController.promotions[index];
                    return ListTile(
                      onTap: () {
                        Get.to(() => FichePromotion(item));
                      },
                      title: Text(
                        item.description,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Icon(
                        Icons.online_prediction_outlined,
                        color: item.end_date
                                    .add(Duration(
                                        hours: 23, minutes: 59, seconds: 59))
                                    .compareTo(DateTime.now()) >=
                                0
                            ? Colors.green
                            : Colors.grey,
                      ),
                      subtitle: Container(
                        padding:
                            EdgeInsets.only(right: Get.width / 8, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/y').format(item.start_date)),
                            Text("to".tr),
                            Text(DateFormat('dd/MM/y').format(item.end_date)),
                          ],
                        ),
                      ),
                      trailing: Container(
                          width: 50,
                          child: Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 16,
                              ),
                              Text(item.lines.length.toString())
                            ],
                          )),
                    );
                  },
                )),
        ),
      ),
    );
  }
}
