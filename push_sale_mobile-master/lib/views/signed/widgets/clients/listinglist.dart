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
  ListingList(this.listing, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 180,
          onRefresh: () => clientController.getClients(),
        ),
        SliverFixedExtentList(
          itemExtent: 112,
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
  itemClient(this.client, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    var color = posted_id != null && posted_id == client.id
        ? const Color.fromARGB(255, 255, 235, 235)
        : Colors.white;
    return GestureDetector(
      onTap: () => Get.to(() => FicheClient(client)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
          boxShadow: const [
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
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              width: Get.width / 4.5,
              height: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: "alata",
                        fontSize: 18,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(client.typepv!.getName(Get.deviceLocale!.languageCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: "alata",
                            fontSize: 12,
                            height: 1.15,
                            color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                        "${client.address!.city.getName(Get.deviceLocale!.languageCode)}, ${client.address!.wilaya.getName(Get.deviceLocale!.languageCode)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: "alata",
                            fontSize: 14,
                            height: 1.15,
                            color: Colors.grey)),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              width: 34,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_grocery_store_rounded,
                    color: client.sales != 0
                        ? const Color.fromARGB(255, 100, 173, 103)
                        : const Color.fromARGB(255, 231, 231, 231),
                    size: Get.width / 20,
                  ),
                  Icon(
                    Icons.remove_red_eye,
                    color: client.sales != 0 || client.visits != null
                        ? const Color.fromARGB(255, 134, 162, 238)
                        : const Color.fromARGB(255, 231, 231, 231),
                    size: Get.width / 20,
                  ),
                  Icon(
                    Icons.restart_alt,
                    color: client.visits != null &&
                            client.visits!
                                .where((element) => element.revisit)
                                .isNotEmpty
                        ? const Color.fromARGB(255, 228, 159, 113)
                        : const Color.fromARGB(255, 231, 231, 231),
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
