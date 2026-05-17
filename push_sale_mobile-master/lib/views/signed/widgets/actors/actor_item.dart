import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/models/actor.dart';

class ActorItem extends StatelessWidget {
  Actor actor;
  ActorItem(this.actor, {super.key});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: Get.width / 5,
            child: Image.network(
              actor.image,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: Get.width / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${actor.lastname} ${actor.firstname}",
                  style: const TextStyle(fontFamily: 'kodchasan', fontSize: 16),
                ),
                Text(
                  actor.phone,
                  style: const TextStyle(fontFamily: 'kodchasan', fontSize: 12),
                ),
                Icon(
                  actor.Profile!.code == "LIV" || actor.Profile!.code == "VD"
                      ? Icons.local_shipping_outlined
                      : Icons.person_outline_sharp,
                  color: const Color.fromARGB(255, 165, 165, 165),
                  size: 20,
                ),
              ],
            ),
          ),
          SizedBox(
            width: Get.width - (Get.width / 5 + Get.width / 2 + 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.receipt,
                      size: 14,
                    ),
                    Text(
                      actor.realisation!.orders_count.toString(),
                      style: const TextStyle(fontFamily: 'alata'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.money,
                      size: 14,
                    ),
                    Text(
                      formatter.format(actor.realisation!.orders_amount),
                      style: const TextStyle(fontFamily: 'alata'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
