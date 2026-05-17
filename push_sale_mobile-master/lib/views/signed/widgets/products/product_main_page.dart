import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';
// import 'package:push_sale/views/signed/widgets/products/item_big_icon.dart';

class ProductMainPage extends StatelessWidget {
  ProductController productController = Get.put(ProductController());

  ProductMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    productController.client = null;
    productController.getProducts();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SizedBox(
        width: Get.width,
        height: Get.height - 89,
        child: Column(
          children: [
            AppPageHeader(
              title: "products".tr,
              subtitle: "Catalogue, variantes et disponibilite",
              icon: Icons.inventory_2_outlined,
            ),
            Expanded(
              child: Obx(
                () {
                  if (!productController.loadProductReady.value) {
                    return AppLoadingState(message: "loading".tr);
                  }
                  if (productController.listProducts.isEmpty) {
                    return AppEmptyState(
                      title: "Aucun produit",
                      message: "Le catalogue est vide pour ce profil.",
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      itemCount: productController.listProducts.length,
                      itemBuilder: (Context, index) {
                        var item = productController.listProducts[index];
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.getLongDescription(
                                          Get.deviceLocale!.languageCode),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.title
                                          .copyWith(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppColors.muted),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: Get.width,
                                height: 156,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: item.purchasevariants!.length,
                                    itemBuilder: (Context, index) {
                                      var element =
                                          item.purchasevariants![index];
                                      return Container(
                                        width: 132,
                                        margin: const EdgeInsets.only(
                                            right: AppSpacing.md),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSpacing.radiusMd),
                                                child: CachedNetworkImage(
                                                  cacheManager: CacheManager(
                                                    Config(
                                                      element.image,
                                                      stalePeriod:
                                                          const Duration(
                                                              days: 7),
                                                    ),
                                                  ),
                                                  imageUrl: element.image,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  placeholder: (context, url) =>
                                                      const AppLoadingState(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const ColoredBox(
                                                    color: AppColors.softBlue,
                                                    child: Center(
                                                      child: Icon(Icons
                                                          .image_not_supported_outlined),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.sm),
                                            Text(
                                              "${element.getVariantName1(Get.deviceLocale!.languageCode)} ${element.getVariantName2(Get.deviceLocale!.languageCode)}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.caption,
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              )
                            ],
                          ),
                        );
                      });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*
GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: productController.listCatalogue.length *
                    (productController.CatalogueReady.value ? 1 : 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.9),
                itemBuilder: (context, index) {
                  var item = productController.listCatalogue[index];
                  return ItemBigIcon(item);
                },
              )
*/
