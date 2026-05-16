import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/views/signed/widgets/clients/ficheclient.dart';

class ListingList extends StatelessWidget {
  final List<Client> listing;
  String? posted_id;
  ClientController clientController = Get.find();
  ListingList(this.listing, {this.posted_id});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 180,
          onRefresh: () => clientController.getClients(),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: Get.height * 2.15 / Get.width),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                itemClient(listing[index], posted_id: posted_id),
            childCount: listing.length,
          ),
        ),
      ],
    );
  }
}

class itemClient extends StatelessWidget {
  Client client;
  String? posted_id;
  itemClient(this.client, {this.posted_id});

  @override
  Widget build(BuildContext context) {
    var _color = posted_id != 0 && posted_id == client.id
        ? Color.fromARGB(255, 255, 235, 235)
        : Colors.white;
    return GestureDetector(
      onTap: () => Get.to(() => FicheClient(client)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _color,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 173, 218, 255),
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              width: Get.width / 4.5,
              child: Container(
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
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              width: Get.width / 1.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: TextStyle(fontFamily: "alata", fontSize: 18),
                  ),
                  Text(client.typepv!.getName(Get.deviceLocale!.languageCode),
                      style: TextStyle(
                          fontFamily: "alata",
                          fontSize: 12,
                          color: Colors.grey)),
                  Text(
                      client.address!.city
                              .getName(Get.deviceLocale!.languageCode) +
                          ", " +
                          client.address!.wilaya
                              .getName(Get.deviceLocale!.languageCode),
                      style: TextStyle(
                          fontFamily: "alata",
                          fontSize: 14,
                          color: Colors.grey)),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              width: Get.width / 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_grocery_store_rounded,
                    color: client.sales != 0
                        ? Color.fromARGB(255, 100, 173, 103)
                        : Color.fromARGB(255, 231, 231, 231),
                    size: Get.width / 20,
                  ),
                  Icon(
                    Icons.remove_red_eye,
                    color: client.sales != 0 || client.visits != null
                        ? Color.fromARGB(255, 134, 162, 238)
                        : Color.fromARGB(255, 231, 231, 231),
                    size: Get.width / 20,
                  ),
                  Icon(
                    Icons.restart_alt,
                    color: client.visits != null &&
                            client.visits!
                                .where((element) => element.revisit)
                                .isNotEmpty
                        ? Color.fromARGB(255, 228, 159, 113)
                        : Color.fromARGB(255, 231, 231, 231),
                    size: Get.width / 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
