import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/pricelist_controller.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/pricelist/pricelist_widget.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_error_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class PricelistPage extends StatefulWidget {
  const PricelistPage({super.key});

  @override
  State<PricelistPage> createState() => _PricelistPageState();
}

class _PricelistPageState extends State<PricelistPage> {
  final PricelistController priceController = Get.put(PricelistController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      priceController.getPricelist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my.pricelists".tr),
      ),
      body: RefreshIndicator(
        onRefresh: priceController.getPricelist,
        child: Obx(() {
          if (!priceController.loadPricelist.value) {
            return const AppLoadingState();
          }
          if (priceController.error.value.isNotEmpty) {
            return AppErrorState(
              title: "my.pricelists".tr,
              message: priceController.error.value,
              onRetry: priceController.getPricelist,
            );
          }
          if (priceController.pricelist.isEmpty) {
            return ListView(
              children: [
                AppPageHeader(
                  title: "my.pricelists".tr,
                  subtitle: "Tarifs actifs par segment client",
                  icon: Icons.price_change_outlined,
                ),
                const AppEmptyState(
                  icon: Icons.price_change_outlined,
                  title: "Aucune liste de prix",
                  message:
                      "Les tarifs de demonstration apparaitront ici lorsque le backend les fournit.",
                ),
              ],
            );
          }
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppPageHeader(
                  title: "my.pricelists".tr,
                  subtitle:
                      "${priceController.pricelist.length} listes disponibles",
                  icon: Icons.price_change_outlined,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            "Touchez une liste pour consulter et imprimer ses tarifs.",
                            style: AppTextStyles.subtitle
                                .copyWith(color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                sliver: SliverList.builder(
                  itemCount: priceController.pricelist.length,
                  itemBuilder: (context, index) {
                    return PricelistWidget(priceController.pricelist[index]);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
