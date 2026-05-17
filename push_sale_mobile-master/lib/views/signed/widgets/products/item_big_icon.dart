import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/models/variant.dart';

class ItemBigIcon extends StatelessWidget {
  Variant item;
  ItemBigIcon(this.item, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 246, 251, 255)),
      child: Column(
        children: [
          SizedBox(
            width: Get.width / 2.5,
            height: Get.width / 2.5,
            child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config(
                  item.image,
                  stalePeriod: const Duration(days: 7),
                ),
              ),
              imageUrl: item.image,
              placeholder: (context, url) => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width / 3 - 25,
                      vertical: (Get.height / 4.2) / 2 - 25),
                  child: const CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          SizedBox(
            width: Get.width / 2.2,
            height: 50,
            child: Column(
              children: [
                Text(
                  item.product!
                      .getLongDescription(Get.deviceLocale!.languageCode),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 138, 138, 138), fontSize: 12),
                ),
                Text(
                  "${item.getVariantName1(Get.deviceLocale!.languageCode)} ${item.getVariantName2(Get.deviceLocale!.languageCode)}",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 138, 138, 138), fontSize: 12),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
