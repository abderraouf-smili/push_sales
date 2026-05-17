import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';

class PurchaseItemsList extends StatelessWidget {
  final PurchaseOrderController purchaseController =
      Get.put(PurchaseOrderController());
  final PrinterController printerController = Get.find();
  final ProductController productController = Get.find();
  final PageController pageController;
  final NumberFormat formatter = NumberFormat("#,##0.00", "fr_FR");

  PurchaseItemsList(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    productController.page.value = 0;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _handleExit(context),
        child: Scaffold(
          body: Column(
            children: [
              _ReceptionHeader(
                onBack: () => _handleExit(context),
                onPrinter: () async {
                  await printerController.ScanPrinter();
                  if (context.mounted) {
                    ShowButtomSheetPrinterConfig(context: context);
                  }
                },
              ),
              Expanded(
                child: Obx(() {
                  purchaseController.hasChanged.value;
                  purchaseController.total.value;
                  if (purchaseController.orderitems.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: const [
                        AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: "Bon de reception vide",
                          message:
                              "Ajoutez les produits recus pour preparer la reception.",
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: purchaseController.orderitems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = purchaseController.orderitems[index];
                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child:
                                Icon(Icons.delete_outline, color: Colors.white),
                          ),
                        ),
                        onDismissed: (_) {
                          purchaseController.removeItem(item);
                          purchaseController.hasChanged.value++;
                        },
                        key: Key(item.id.toString()),
                        child: AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: CachedNetworkImage(
                                    cacheManager: CacheManager(
                                      Config(
                                        item.image,
                                        stalePeriod: const Duration(days: 7),
                                      ),
                                    ),
                                    imageUrl: item.image,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const ColoredBox(
                                      color: AppColors.softBlue,
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                      ),
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
                                      item.product_name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      "${item.variant_name_1} ${item.variant_name_2 ?? ""}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatter.format(item.total),
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    "${item.quantity.toStringAsFixed(0)} ${item.unite.tr}",
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              _ReceptionSummary(
                formatter: formatter,
                total: purchaseController.total,
                saved: purchaseController.saved,
                hasItems: () => purchaseController.orderitems.isNotEmpty,
                onAdd: () {
                  pageController.jumpToPage(1);
                  productController.page.value = 1;
                },
                onSave: () => _save(context),
                onPrint: () => _print(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _handleExit(BuildContext context) async {
    if (purchaseController.orderitems.isNotEmpty) {
      AwesomeDialog(
        dialogType: DialogType.question,
        title: "sure".tr,
        body: Text(
          purchaseController.saved.value
              ? "are.you.sure.to.quit.purchaseorder".tr
              : "are.you.sure.to.ignore".tr,
        ),
        context: context,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          purchaseController.saved.value = false;
          Get.back();
        },
      ).show();
    } else {
      purchaseController.saved.value = false;
      Get.back();
    }
    return false;
  }

  Future<void> _save(BuildContext context) async {
    final response = await purchaseController.save();
    if (response.status == "SUCCESS") {
      purchaseController.saved.value = true;
      purchaseController.isSaved = true;
      purchaseController.OrderCode = response.data["code"];
      if (!context.mounted) return;
      AwesomeDialog(
        dialogType: DialogType.success,
        title: "sure".tr,
        body: Text("succefully.saved".tr),
        context: context,
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (!context.mounted) return;
    AwesomeDialog(
      dialogType: DialogType.error,
      title: "sure".tr,
      body: Text("error.saved".tr),
      context: context,
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _print(BuildContext context) async {
    if (!purchaseController.saved.value) {
      return;
    }
    purchaseController.PrepareToPrint();
    await printerController.ScanPrinter();
    final response =
        await printerController.StartPrinting(purchaseController.textPrint);
    if (!context.mounted) return;

    switch (response) {
      case "ok":
        AwesomeDialog(
          dialogType: DialogType.info,
          title: "sure".tr,
          body: Text("printing".tr),
          context: context,
          btnOkOnPress: () {},
        ).show();
        break;
      case "not_available":
        AwesomeDialog(
          dialogType: DialogType.error,
          title: "sure".tr,
          body: Text("print.not_available".tr),
          context: context,
          btnOkOnPress: () {},
        ).show();
        break;
      case "bluetooth_pb":
        AwesomeDialog(
          dialogType: DialogType.error,
          title: "sure".tr,
          body: Text("bluetooth.problem".tr),
          context: context,
          btnOkOnPress: () {
            ShowButtomSheetPrinterConfig(context: context);
          },
        ).show();
        break;
      default:
        AwesomeDialog(
          dialogType: DialogType.error,
          title: "sure".tr,
          body: Text("printer.pb.link".tr),
          context: context,
          btnOkOnPress: () {
            ShowButtomSheetPrinterConfig(context: context);
          },
        ).show();
    }
  }
}

class _ReceptionHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onPrinter;

  const _ReceptionHeader({
    required this.onBack,
    required this.onPrinter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bon de reception",
                  style: AppTextStyles.title,
                ),
                Text(
                  "Produits recus, total et impression",
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onPrinter,
            icon: const Icon(Icons.bluetooth_connected_rounded),
          ),
        ],
      ),
    );
  }
}

class _ReceptionSummary extends StatelessWidget {
  final NumberFormat formatter;
  final RxDouble total;
  final RxBool saved;
  final bool Function() hasItems;
  final VoidCallback onAdd;
  final VoidCallback onSave;
  final VoidCallback onPrint;

  const _ReceptionSummary({
    required this.formatter,
    required this.total,
    required this.saved,
    required this.hasItems,
    required this.onAdd,
    required this.onSave,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: AppTextStyles.subtitle),
                Text(
                  formatter.format(total.value),
                  style: AppTextStyles.title,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: saved.value ? null : onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("Ajouter"),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: !saved.value && hasItems() ? onSave : null,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text("Enregistrer"),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  onPressed: saved.value ? onPrint : null,
                  icon: const Icon(Icons.print_rounded),
                  tooltip: "print".tr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
