import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/models/product.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';

class ProductPurchaseList extends StatelessWidget {
  final PurchaseOrderController purchaseController =
      Get.put(PurchaseOrderController());
  final ProductController productController = Get.find();
  final TextEditingController searchController = TextEditingController();
  final PageController pageController;

  ProductPurchaseList(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () => _handleBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              _PurchaseProductHeader(
                searchController: searchController,
                pageController: pageController,
                productController: productController,
              ),
              Expanded(
                child: Obx(() {
                  if (!productController.loadProductReady.value) {
                    return const AppLoadingState(
                      message: "Chargement des produits...",
                    );
                  }

                  final products = _filteredProducts();
                  if (products.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        AppEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: "Aucun produit",
                          message:
                              "Aucun produit ne correspond a votre recherche.",
                          action: OutlinedButton.icon(
                            onPressed: () async {
                              productController.ready.value = false;
                              await productController.getProducts();
                              productController.ready.value = true;
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Recharger"),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return PurchaseProductListWidget(
                        products[index],
                        pageController,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Product> _filteredProducts() {
    final filter = productController.filter.trim().toUpperCase();
    if (!productController.ready.value || filter.isEmpty) {
      return productController.listProducts;
    }
    return productController.listProducts
        .where((element) =>
            element.long_description_fr.toUpperCase().contains(filter))
        .toList();
  }

  Future<bool> _handleBack(BuildContext context) async {
    switch (productController.page.value) {
      case 2:
        pageController.jumpToPage(1);
        break;
      case 1:
        pageController.jumpToPage(0);
        break;
      default:
        if (purchaseController.orderitems.isNotEmpty) {
          _confirmExit(context);
        } else {
          purchaseController.saved.value = false;
          Get.back();
        }
    }
    return false;
  }

  void _confirmExit(BuildContext context) {
    AwesomeDialog(
      dialogType: DialogType.question,
      title: "sure".tr,
      body: Text(
        purchaseController.saved.value
            ? "are.you.sure.to.quit.order".tr
            : "are.you.sure.to.ignore".tr,
      ),
      context: context,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        purchaseController.saved.value = false;
        Get.back();
      },
    ).show();
  }
}

class _PurchaseProductHeader extends StatelessWidget {
  final TextEditingController searchController;
  final PageController pageController;
  final ProductController productController;

  const _PurchaseProductHeader({
    required this.searchController,
    required this.pageController,
    required this.productController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: searchController,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: "search".tr,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  productController.ready.value = false;
                  productController.filter = "";
                  searchController.clear();
                  productController.ready.value = true;
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
            onChanged: (value) {
              productController.ready.value = false;
              productController.filter = value;
              productController.ready.value = true;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  pageController.jumpToPage(
                    productController.page.value == 2 ? 1 : 0,
                  );
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: [
                        _ModeChip(
                          label: "Liste",
                          icon: Icons.view_headline_rounded,
                          selected: productController.page.value == 0,
                          onTap: () {
                            productController.page.value = 0;
                            pageController.jumpToPage(0);
                          },
                        ),
                        _ModeChip(
                          label: "Grille",
                          icon: Icons.grid_view_rounded,
                          selected: productController.page.value == 1,
                          onTap: () {
                            productController.page.value = 1;
                            pageController.jumpToPage(1);
                          },
                        ),
                        _ModeChip(
                          label: "Variantes",
                          icon: Icons.apps_rounded,
                          selected: productController.page.value == 2,
                          onTap: () {
                            productController.page.value = 2;
                            pageController.jumpToPage(2);
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            productController.ready.value = false;
                            await productController.getProducts();
                            productController.ready.value = true;
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.muted,
        ),
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.softBlue,
        labelStyle: AppTextStyles.caption.copyWith(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class PurchaseProductListWidget extends StatelessWidget {
  final ProductController productController = Get.find();
  final Product product;
  final PageController pageController;

  PurchaseProductListWidget(this.product, this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        productController.productSelected = product;
        productController.isProSelected.value = true;
        productController.page.value = 2;
        pageController.jumpToPage(2);
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: SizedBox(
              width: 52,
              height: 52,
              child: CachedNetworkImage(
                cacheManager: CacheManager(
                  Config(product.image, stalePeriod: const Duration(days: 7)),
                ),
                imageUrl: product.image,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: AppColors.softBlue,
                  child: Icon(Icons.inventory_2_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.getShortDescription(Get.locale!.languageCode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "${product.purchasevariants?.length ?? 0} variantes",
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
