import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/models/product.dart';

class productListWidget extends StatelessWidget {
  ProductController productController = Get.find();

  Product product;
  PageController pageController;
  productListWidget(this.product, this.pageController);

  @override
  Widget build(BuildContext context) {
    bool hasPromo = false;
    if (product.variants != null) {
      hasPromo = product.variants!.any(
        (element) => element.discount > 0,
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 0),
      height: 60,
      child: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          productController.productSelected = product;
          productController.isProSelected.value = true;
          pageController.jumpToPage(2);
        },
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config(
                  product.image,
                  stalePeriod: const Duration(days: 7),
                ),
              ),
              imageUrl: product.image,
              placeholder: (context, url) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          subtitle: Text(product.variants!.length.toString()),
          title: Container(
              width: Get.width / 3,
              child:
                  Text(product.getLongDescription(Get.locale!.languageCode))),
          trailing: Container(
            width: Get.width / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                hasPromo
                    ? Image.asset(
                        "assets/images/promo.png",
                        width: 30,
                      )
                    : SizedBox.shrink(),
                Text(
                  product.showPrice!,
                  style: TextStyle(
                    fontFamily: 'alata',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
