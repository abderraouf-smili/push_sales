import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height - 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/under_construction.png"),
        ),
      ),
    );
  }
}
