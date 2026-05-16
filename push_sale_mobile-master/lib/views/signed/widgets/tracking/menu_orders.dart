import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderWidget extends StatelessWidget {
  int number;
  String state;
  OrderWidget({required this.number, required this.state});

  @override
  Widget build(BuildContext context) {
    Icon myIcon = getIcon(state);
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 252, 254, 255),
        border: Border.all(color: Color.fromARGB(255, 213, 221, 253), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            number.toStringAsFixed(0),
            style: TextStyle(
              fontSize: Get.height / 16 - (number / 100 > 1 ? 25 : 10),
              fontWeight: FontWeight.bold,
              color: myIcon.color,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ("state." + state).tr,
                  style: TextStyle(
                      fontFamily: "Xolonium",
                      fontSize: 14,
                      color: myIcon.color),
                ),
                myIcon
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Icon getIcon(String state) {
  switch (state) {
    case "new":
      return Icon(
        Icons.shopping_cart_outlined,
        color: Color.fromARGB(255, 55, 235, 39),
        size: 24,
      );
    case "taken":
      return Icon(
        Icons.delivery_dining_sharp,
        color: Colors.orange,
        size: 24,
      );

    case "taken_partial":
      return Icon(
        Icons.delivery_dining_sharp,
        color: Colors.orange,
        size: 24,
      );
    case "in_way":
      return Icon(
        Icons.local_shipping_outlined,
        color: Color.fromARGB(255, 53, 81, 243),
        size: 24,
      );
    case "shipped":
      return Icon(
        Icons.child_friendly_outlined,
        color: Color.fromARGB(255, 203, 67, 221),
        size: 24,
      );
    case "paid":
      return Icon(
        Icons.check_circle,
        color: Color.fromARGB(255, 5, 97, 17),
        size: 24,
      );
    case "partially_paid":
      return Icon(
        Icons.local_pharmacy_outlined,
        color: Color.fromARGB(255, 5, 97, 17),
        size: 24,
      );
    case "cancelled":
      return Icon(
        Icons.cancel_schedule_send_rounded,
        color: Color.fromARGB(255, 212, 55, 55),
        size: 24,
      );
    case "expired":
      return Icon(
        Icons.free_cancellation_rounded,
        color: Color.fromARGB(255, 212, 55, 55),
        size: 24,
      );
    default:
      return Icon(Icons.radio_button_unchecked_rounded);
  }
}

/*
          Container(
            height: Get.height - 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: (() {
                        pageController.animateToPage(1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInToLinear);
                      }),
                      child: Container(
                        width: Get.width / 3 - 20,
                        height: Get.width / 3 - 20,
                        color: Colors.grey,
                        margin: EdgeInsets.all(10),
                        child: Text("Track"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // pageController.jumpToPage(2);
                      },
                      child: Container(
                        width: Get.width / 3 - 20,
                        height: Get.width / 3 - 20,
                        color: Colors.grey,
                        margin: EdgeInsets.all(10),
                        child: Text("Commandes arrives"),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
 */
