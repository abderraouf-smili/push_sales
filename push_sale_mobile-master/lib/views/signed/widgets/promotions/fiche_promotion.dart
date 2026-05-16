import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/models/promotion.dart';
import 'package:push_sale/views/signed/homepage.dart';
import 'package:push_sale/views/signed/widgets/promotions/edit_promotion.dart';

class FichePromotion extends StatelessWidget {
  Promotion _promotion;
  FichePromotion(this._promotion);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(_promotion.description),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      {
                        Get.to(() => EditPromotion());
                      }
                      break;
                    case 1:
                      {
                        Get.to(() => EditPromotion(promotion: _promotion));
                      }
                      break;
                    case 2:
                      {
                        Get.to(() => HomePage(
                              index: 4,
                            ));
                      }
                      break;
                  }
                },
                elevation: 5,
                icon: Icon(Icons.menu),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        value: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("new".tr),
                            Icon(Icons.add, color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("edit".tr),
                            Icon(Icons.edit, color: Colors.blue),
                          ],
                        )),
                    PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("close".tr),
                            Icon(Icons.close, color: Colors.blue),
                          ],
                        )),
                  ];
                })
          ],
        ),
        body: Container(
          width: double.infinity,
          // padding: EdgeInsets.symmetric(horizontal: 40),
          height: Get.height - 120,
          child: Column(
            children: [
              Container(
                width: Get.width - 20,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: Color.fromARGB(255, 122, 122, 122)),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: Color.fromARGB(255, 214, 214, 214))),
                      child: Text(
                          DateFormat('dd/MM/y').format(_promotion.start_date),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 122, 122, 122))),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: Color.fromARGB(255, 214, 214, 214))),
                      child: Text(
                          DateFormat('dd/MM/y').format(_promotion.end_date),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 122, 122, 122))),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 1),
              Container(
                width: double.infinity,
                height: Get.height / 1.4,
                child: ListView.builder(
                    itemCount: _promotion.lines.length,
                    itemBuilder: (context, index) {
                      var item = _promotion.lines[index];
                      switch (_promotion.type_promotion!.type) {
                        case "price_discount":
                          return ListTile(
                            title: Text(item.product != null
                                ? item.product!.short_description_fr
                                : item.variant!.product!.getShortDescription(
                                    Get.locale!.languageCode)),
                            subtitle: Text(item.product != null
                                ? item.product!.variants!.length.toString()
                                : item.variant!.getVariantName1(
                                        Get.locale!.languageCode) +
                                    " " +
                                    item.variant!.getVariantName2(
                                        Get.locale!.languageCode)),
                            trailing: Column(
                              children: [
                                Text("-" + item.discount.toString() + "%"),
                                Text("min " +
                                    item.minimum.toStringAsFixed(0) +
                                    " " +
                                    item.unite),
                              ],
                            ),
                            leading: Image.network(item.product != null
                                ? item.product!.image
                                : item.variant!.image),
                          );
                        default:
                          return SizedBox.shrink();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
