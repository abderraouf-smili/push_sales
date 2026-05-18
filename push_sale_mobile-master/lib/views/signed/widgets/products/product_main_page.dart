import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/models/product.dart';
import 'package:push_sale/models/purchase_variant.dart';
import 'package:push_sale/models/variant.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';
// import 'package:push_sale/views/signed/widgets/products/item_big_icon.dart';

class ProductMainPage extends StatefulWidget {
  const ProductMainPage({super.key});

  @override
  State<ProductMainPage> createState() => _ProductMainPageState();
}

class _ProductMainPageState extends State<ProductMainPage> {
  final ProductController productController = Get.put(ProductController());
  String _productSearch = "";

  @override
  void initState() {
    super.initState();
    productController.client = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        productController.getProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        top: false,
        bottom: false,
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
                  final products = productController.listProducts.where((item) {
                    final locale = Get.deviceLocale?.languageCode ?? "fr";
                    final text =
                        item.getLongDescription(locale).toLowerCase().trim();
                    return _productSearch.isEmpty ||
                        text.contains(_productSearch.toLowerCase().trim());
                  }).toList();
                  if (productController.listProducts.isEmpty) {
                    return AppEmptyState(
                      title: "Aucun produit",
                      message: "Le catalogue est vide pour ce profil.",
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() => _productSearch = value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText:
                                        "Rechercher un produit, une reference...",
                                    prefixIcon: Icon(Icons.search_rounded),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton.filledTonal(
                                onPressed: productController.getProducts,
                                icon: const Icon(Icons.tune_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 54,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            scrollDirection: Axis.horizontal,
                            children: const [
                              _ProductCategoryChip(
                                label: "Tous",
                                icon: Icons.apps_rounded,
                                selected: true,
                              ),
                              _ProductCategoryChip(
                                label: "Boissons",
                                icon: Icons.local_drink_outlined,
                              ),
                              _ProductCategoryChip(
                                label: "Epicerie",
                                icon: Icons.shopping_bag_outlined,
                              ),
                              _ProductCategoryChip(
                                label: "Hygiene",
                                icon: Icons.clean_hands_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Text(
                                  "${products.length} produits",
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Trier par : Popularite",
                                  style: AppTextStyles.caption,
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (products.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState(
                            title: "Aucun resultat",
                            message:
                                "Essayez un autre nom ou rechargez le catalogue.",
                            icon: Icons.search_off_rounded,
                          ),
                        )
                      else
                        SliverList.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var item = products[index];
                            final variants = item.purchasevariants ?? [];
                            final firstImage =
                                variants.isNotEmpty ? variants.first.image : "";
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.md,
                              ),
                              child: AppCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                onTap: () => Get.to(
                                  () => CommercialProductDetailPage(
                                      product: item),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                      child: Container(
                                        width: 96,
                                        height: 112,
                                        color: AppColors.canvas,
                                        child: firstImage.isEmpty
                                            ? const Icon(
                                                Icons.inventory_2_outlined,
                                                color: AppColors.primary,
                                              )
                                            : CachedNetworkImage(
                                                cacheManager: CacheManager(
                                                  Config(
                                                    firstImage,
                                                    stalePeriod:
                                                        const Duration(days: 7),
                                                  ),
                                                ),
                                                imageUrl: firstImage,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const AppLoadingState(),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Icon(Icons
                                                        .image_not_supported_outlined),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.getLongDescription(
                                              Get.deviceLocale?.languageCode ??
                                                  "fr",
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.title
                                                .copyWith(fontSize: 17),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            variants.isEmpty
                                                ? "Aucune variante"
                                                : "${variants.length} variantes",
                                            style: AppTextStyles.subtitle,
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          Wrap(
                                            spacing: AppSpacing.sm,
                                            runSpacing: AppSpacing.xs,
                                            children: variants.take(3).map(
                                              (variant) {
                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: AppSpacing.sm,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.softBlue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                  child: Text(
                                                    "${variant.getVariantName1(Get.deviceLocale?.languageCode ?? "fr")} ${variant.getVariantName2(Get.deviceLocale?.languageCode ?? "fr")}",
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.softGreen,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            "En stock",
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        OutlinedButton.icon(
                                          onPressed: () => Get.to(
                                            () => CommercialProductDetailPage(
                                              product: item,
                                            ),
                                          ),
                                          icon: const Icon(
                                              Icons.shopping_cart_outlined),
                                          label: const Text("Voir"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                  /*return ListView.builder(
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
                      });*/
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CommercialProductDetailPage extends StatelessWidget {
  final Product product;

  const CommercialProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? "fr";
    final formatter = NumberFormat("#,##0.00", "fr_FR");
    final saleVariants = product.variants ?? [];
    final purchaseVariants = product.purchasevariants ?? [];
    final minPrice = saleVariants.isEmpty
        ? null
        : saleVariants
            .map((variant) => variant.price)
            .where((price) => price > 0)
            .fold<double?>(null, (min, price) {
            if (min == null || price < min) {
              return price;
            }
            return min;
          });
    final heroImage = saleVariants.isNotEmpty
        ? saleVariants.first.image
        : purchaseVariants.isNotEmpty
            ? purchaseVariants.first.image
            : product.image;
    final hasPromotion = saleVariants.any((variant) => variant.discount > 0) ||
        purchaseVariants.any((variant) => variant.discount > 0);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppPageHeader(
                title: "Detail produit",
                subtitle: "Variantes, prix, promotions et disponibilite",
                icon: Icons.arrow_back_rounded,
                actions: [
                  IconButton.filledTonal(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      _ProductVisual(image: heroImage, size: 104),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.getLongDescription(locale),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTextStyles.display.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              "Ref. ${product.ssin}",
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                if (hasPromotion)
                                  const _ProductBadge(
                                    label: "Promotion active",
                                    color: AppColors.warning,
                                  ),
                                const _ProductBadge(
                                  label: "Catalogue commercial",
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Prix des", style: AppTextStyles.caption),
                          Text(
                            minPrice == null
                                ? product.showPrice ?? "-"
                                : "${formatter.format(minPrice)} DH",
                            style: AppTextStyles.title.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  "Variantes disponibles",
                  style: AppTextStyles.display.copyWith(fontSize: 24),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            if (saleVariants.isNotEmpty)
              SliverList.separated(
                itemCount: saleVariants.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _SaleVariantTile(
                      variant: saleVariants[index],
                      formatter: formatter,
                      locale: locale,
                    ),
                  );
                },
              )
            else
              SliverList.separated(
                itemCount: purchaseVariants.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _PurchaseVariantTile(
                      variant: purchaseVariants[index],
                      formatter: formatter,
                      locale: locale,
                    ),
                  );
                },
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                110,
              ),
              sliver: SliverToBoxAdapter(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    "Regles commerciales\n\n"
                    "• Prix filtres selon le type de point de vente du client\n"
                    "• Promotions visibles si applicables au client\n"
                    "• Produits prives masques si non autorises\n"
                    "• Stock verifie avant validation de commande",
                    style: AppTextStyles.body.copyWith(height: 1.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleVariantTile extends StatelessWidget {
  final Variant variant;
  final NumberFormat formatter;
  final String locale;

  const _SaleVariantTile({
    required this.variant,
    required this.formatter,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final title = [
      variant.getVariantName1(locale),
      variant.getVariantName2(locale),
    ].where((part) => part.trim().isNotEmpty).join(" ");
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _ProductVisual(image: variant.image, size: 70),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? variant.sku : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 17),
                ),
                Text(
                  "${variant.unite} • ${variant.package} pcs",
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                _ProductBadge(
                  label: variant.discount > 0
                      ? "Promo -${variant.discount.toStringAsFixed(0)}%"
                      : "Stock ${variant.quantity.toStringAsFixed(0)}",
                  color: variant.discount > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${formatter.format(variant.price)} DH",
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () {},
                child: const Text("Ajouter"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurchaseVariantTile extends StatelessWidget {
  final PurchaseVariant variant;
  final NumberFormat formatter;
  final String locale;

  const _PurchaseVariantTile({
    required this.variant,
    required this.formatter,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final title = [
      variant.getVariantName1(locale),
      variant.getVariantName2(locale),
    ].where((part) => part.trim().isNotEmpty).join(" ");
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _ProductVisual(image: variant.image, size: 70),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? variant.sku : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 17),
                ),
                Text(
                  "Pack ${variant.package}",
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                _ProductBadge(
                  label: variant.discount > 0
                      ? "Promo -${variant.discount.toStringAsFixed(0)}%"
                      : "Reference ${variant.sku}",
                  color: variant.discount > 0
                      ? AppColors.warning
                      : AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${formatter.format(variant.lastpurchaseprice)} DH",
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () {},
                child: const Text("Voir"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductVisual extends StatelessWidget {
  final String image;
  final double size;

  const _ProductVisual({required this.image, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: size,
        height: size,
        child: image.isEmpty
            ? const ColoredBox(
                color: AppColors.softBlue,
                child: Icon(Icons.inventory_2_outlined),
              )
            : CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: AppColors.softBlue,
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
      ),
    );
  }
}

class _ProductBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ProductBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProductCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _ProductCategoryChip({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) {},
        avatar: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.primaryDark,
        ),
        label: Text(label),
        selectedColor: AppColors.softBlue,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.line),
        labelStyle: AppTextStyles.body.copyWith(
          color: selected ? AppColors.primary : AppColors.primaryDark,
          fontWeight: FontWeight.w800,
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
