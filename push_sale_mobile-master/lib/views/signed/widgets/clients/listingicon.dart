import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/views/signed/widgets/clients/ficheclient.dart';

class ListingIcon extends StatelessWidget {
  final List<Client> listing;
  String? posted_id;
  ClientController clientController = Get.find();
  ListingIcon(this.listing, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
      CupertinoSliverRefreshControl(
        refreshTriggerPullDistance: 180,
        onRefresh: () => clientController.getClients(),
      ),
      SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.95),
        delegate: SliverChildBuilderDelegate(
          (context, index) => iconClient(
            listing[index],
            posted_id: posted_id,
          ),
          childCount: listing.length,
        ),
      ),
    ]);
  }
}

class iconClient extends StatelessWidget {
  Client client;
  String? posted_id;
  iconClient(this.client, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    var color = posted_id != 0 && posted_id == client.id
        ? const Color.fromARGB(255, 241, 249, 255)
        : Colors.white;
    return GestureDetector(
      onTap: () => Get.to(() => FicheClient(client)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 173, 218, 255),
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ]),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: Get.height / 5.8,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    client.image,
                    cacheKey: client.image,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "${client.name.substring(
                          0,
                          client.name.length > 14 ? 14 : client.name.length,
                        )} ${client.name.length > 14 ? "..." : ""}",
                        style: const TextStyle(
                          fontFamily: "kodchasan",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        client.address!.city.getName(Get.locale!.languageCode),
                        style: const TextStyle(
                            fontSize: 11,
                            fontFamily: "kodchasan",
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    client.address!.wilaya.code,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: "kodchasan",
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(20),
              //     image: DecorationImage(
              //       fit: BoxFit.fill,
              //       image: NetworkImage(
              //         "http://192.168.1.100/push_sale${listing[index].image}",
              //       ),
              //     ),
              //   ),
              //   margin: EdgeInsets.all(10),
              // )