import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/models/coupon.dart';

class CouponItem extends StatelessWidget {
  Coupon item;
  CouponItem(this.item);
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return Container(
      width: double.infinity,
      height: Get.height / 12,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
          border:
              Border.all(width: 1, color: Color.fromARGB(255, 206, 230, 255)),
          borderRadius: BorderRadius.circular(5),
          color: Color.fromARGB(255, 249, 252, 255)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: Get.width / 10,
            height: Get.width / 10,
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: item.is_pourcentage
                ? Icon(
                    Icons.percent,
                    size: Get.width / 10,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.monetization_on_outlined,
                    size: Get.width / 10,
                    color: Colors.green,
                  ),
          ),
          Container(
            width: Get.width / 2.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.code,
                  style: TextStyle(
                      color: Color.fromARGB(255, 151, 81, 75),
                      fontFamily: 'alata',
                      fontSize: Get.width / 25),
                ),
                Text(item.description,
                    style: TextStyle(
                        fontFamily: 'alata',
                        fontSize: Get.width / 30,
                        color: Color.fromARGB(255, 112, 112, 112))),
                Text("more.than".tr + " " + formatter.format(item.min_amount),
                    style: TextStyle(
                        fontFamily: 'alata',
                        fontSize: Get.width / 30,
                        color: Color.fromARGB(255, 112, 112, 112))),
              ],
            ),
          ),
          Container(
            width: Get.width / 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat("dd/MM/y").format(item.start_date),
                    style: TextStyle(
                        fontFamily: 'alata',
                        fontSize: Get.width / 30,
                        color: Color.fromARGB(255, 112, 112, 112))),
                Text(DateFormat("dd/MM/y").format(item.end_date),
                    style: TextStyle(
                        fontFamily: 'alata',
                        fontSize: Get.width / 30,
                        color: Color.fromARGB(255, 112, 112, 112))),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: Get.width -
                (Get.width / 12 + Get.width / 2.2 + Get.width / 4 + 34),
            child: Center(
              child: Text(
                item.count.toString(),
                style: TextStyle(
                    color: Color.fromARGB(255, 36, 111, 172),
                    fontSize: Get.width / 18,
                    fontFamily: 'kodchasan',
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
