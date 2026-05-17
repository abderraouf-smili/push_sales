import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height - 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/under_construction.png"),
        ),
      ),
    );
  }
}
