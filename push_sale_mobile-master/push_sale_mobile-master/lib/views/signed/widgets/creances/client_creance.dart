import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/models/receivable.dart';

class ClientCreance extends StatelessWidget {
  Receivale client;
  ClientCreance(this.client);
  @override
  Widget build(BuildContext context) {
    var formatter = new NumberFormat("#,##0.00", "fr_FR");
    return Container(
      width: double.infinity,
      height: Get.height / 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(3),
                width: Get.width / 6,
                height: Get.height / 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 165, 165, 165),
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                      client.image,
                      cacheKey: client.image,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                width: Get.width / 1.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      client.client_name,
                      style: TextStyle(
                          fontFamily: "alata",
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(client.city_name + " - " + client.state_code,
                        style: TextStyle(
                            fontFamily: "alata",
                            color: Color.fromARGB(255, 139, 139, 139))),
                    Text("Acteur : " + client.actor_name,
                        style: TextStyle(
                            fontFamily: "alata",
                            fontSize: 13,
                            color: Color.fromARGB(255, 83, 84, 134))),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              formatter.format(client.total_vendu - client.total_paye),
              style: TextStyle(fontFamily: 'alata', fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
