import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/warehouse_controller.dart';
import 'package:push_sale/models/item_stock.dart';
import 'package:push_sale/views/signed/widgets/warehouses/product_reception.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_snackbar.dart';
import 'package:push_sale/const/globals.dart' as global;

class ShowDetailWarehouse extends StatelessWidget {
  final WarehouseController warehouseController = Get.find();
  final PrinterController printerController = Get.put(PrinterController());
  final PageController pageController;
  final PageController _pageController = PageController();
  ShowDetailWarehouse(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    warehouseController.adjustedPrice = [];
    warehouseController.adjustedStock = [];
    warehouseController.adjusted.value = [];
    warehouseController.outOfStock.value = [];
    return WillPopScope(
      onWillPop: () async {
        pageController.jumpToPage(0);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(warehouseController.warehouse!.name),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  warehouseController.page.value = value;
                },
                children: [
                  PageVariantDetail(filter: "All"),
                  PageVariantDetail(filter: "AvailableOnly"),
                  PageVariantDetail(filter: "OnAlertOnly"),
                  PageVariantDetail(filter: "outOfStock"),
                ],
              ),
            ),
            Obx(
              () => _WarehouseActionBar(
                canApply: warehouseController.adjusted.isNotEmpty,
                onReception: () => Get.to(() => ProductReception()),
                onApply: () => _applyAdjustment(context),
                onPrint: () => _printStock(),
                onPrinter: () => ShowButtomSheetPrinterConfig(context: context),
              ),
            ),
            Obx(
              () => Container(
                margin: const EdgeInsets.fromLTRB(
                    AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.line),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: "all".tr,
                        selected: warehouseController.page.value == 0,
                        onTap: () => _pageController.jumpToPage(0),
                      ),
                      _FilterChip(
                        label: "dispo.only".tr,
                        selected: warehouseController.page.value == 1,
                        onTap: () => _pageController.jumpToPage(1),
                      ),
                      _FilterChip(
                        label: "alert.only".tr,
                        selected: warehouseController.page.value == 2,
                        onTap: () => _pageController.jumpToPage(2),
                      ),
                      _FilterChip(
                        label: "empty.only".tr,
                        selected: warehouseController.page.value == 3,
                        onTap: () => _pageController.jumpToPage(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyAdjustment(BuildContext context) async {
    var response = await warehouseController.adjustPriceStock();
    if (response.status == "SUCCESS") {
      AwesomeDialog(
        dialogType: DialogType.success,
        title: "sure".tr,
        body: Text("succefully.saved".tr),
        context: context,
        btnOkOnPress: () async {
          pageController.jumpToPage(0);
        },
      ).show();
      return;
    }

    if (warehouseController.adjustedPrice.isNotEmpty) {
      Flushbar(
        title: "info".tr,
        message: "price.is.updated.if.changed".tr,
        titleColor: Colors.white,
        messageColor: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 122, 122, 122),
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(10),
      ).show(context);
    }
    AwesomeDialog(
      dialogType: DialogType.error,
      title: "error".tr,
      body: Text("quantity.not.available".tr),
      context: context,
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _printStock() async {
    warehouseController.currentStock = warehouseController.warehouse!.items;
    warehouseController.prepareToPrintStock();
    if (!printerController.isSaved) {
      AppSnackbar.error("printer.settings".tr, "printer.pb.link".tr);
      return;
    }
    final result =
        await printerController.StartPrinting(warehouseController.textPrint);
    if (result == "ok") {
      AppSnackbar.success("print.stock".tr, "printing".tr);
    } else {
      AppSnackbar.error("print.stock".tr, "bluetooth.problem".tr);
    }
  }

  Color borderColor(int current, int selected) {
    if (current == selected) {
      return const Color.fromARGB(255, 213, 212, 255);
    }
    return const Color.fromARGB(255, 249, 249, 255);
  }

  Color bgColor(int current, int selected) {
    if (current == selected) {
      return const Color.fromARGB(255, 232, 228, 255);
    }
    return const Color.fromARGB(255, 248, 248, 255);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: ChoiceChip(
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.softBlue,
        labelStyle: AppTextStyles.caption.copyWith(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
      ),
    );
  }
}

class _WarehouseActionBar extends StatelessWidget {
  final bool canApply;
  final VoidCallback onReception;
  final VoidCallback onApply;
  final VoidCallback onPrint;
  final VoidCallback onPrinter;

  const _WarehouseActionBar({
    required this.canApply,
    required this.onReception,
    required this.onApply,
    required this.onPrint,
    required this.onPrinter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ActionPill(
              icon: Icons.inventory_2_outlined,
              label: "Reception",
              color: AppColors.primary,
              onTap: onReception,
            ),
            _ActionPill(
              icon: Icons.fact_check_outlined,
              label: "Ajuster",
              color: AppColors.secondary,
              onTap: canApply ? onApply : null,
            ),
            _ActionPill(
              icon: Icons.print_outlined,
              label: "Imprimer",
              color: AppColors.info,
              onTap: onPrint,
            ),
            _ActionPill(
              icon: Icons.bluetooth_connected_outlined,
              label: "Imprimante",
              color: AppColors.primaryDark,
              onTap: onPrinter,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: SizedBox(
        height: 44,
        child: FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: onTap == null ? AppColors.line : color,
            foregroundColor: onTap == null ? AppColors.muted : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button.copyWith(fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class PageVariantDetail extends StatelessWidget {
  final String filter;
  PageVariantDetail({super.key, required this.filter});
  final WarehouseController warehouseController = Get.find();
  final formatter = NumberFormat("#,##0.00", "fr_FR");
  @override
  Widget build(BuildContext context) {
    List<ItemStock> list = [];
    switch (filter) {
      case "AvailableOnly":
        list = warehouseController.warehouse!.items
            .where(
              (element) =>
                  element.quantity / element.package > global.alertQuantity,
            )
            .toList();
        break;
      case "OnAlertOnly":
        list = warehouseController.warehouse!.items
            .where(
              (element) =>
                  element.quantity / element.package <= global.alertQuantity &&
                  element.quantity > 0,
            )
            .toList();
        break;
      case "outOfStock":
        list = warehouseController.warehouse!.items
            .where((element) => element.quantity == 0)
            .toList();
        break;
      default:
        list = warehouseController.warehouse!.items;
    }
    if (list.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: "Aucun article",
            message: "Aucun stock ne correspond au filtre selectionne.",
          ),
        ],
      );
    }

    return GestureDetector(
      onDoubleTap: () {
        warehouseController.UniteIsCaisse.value =
            !warehouseController.UniteIsCaisse.value;
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          var item = list[index];
          var stockCh = warehouseController.adjustedStock.where(
            (element) => element.variant_id == item.variant_id,
          );

          return Obx(
            () => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    color: warehouseController.adjusted
                            .where((el) => el == item.variant_id)
                            .isNotEmpty
                        ? warehouseController.outOfStock
                                .where((el) => el == item.variant_id)
                                .isNotEmpty
                            ? AppColors.softRed
                            : AppColors.softGreen
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController quantityController =
                              TextEditingController();
                          bool changedStock = false;
                          bool changedPrice = false;
                          GlobalKey<FormState> frm = GlobalKey<FormState>();
                          return Form(
                            key: frm,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              titlePadding: EdgeInsets.zero,
                              title: Container(
                                width: Get.width,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.getShortDescription(
                                        Get.locale!.languageCode,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${item.getVariantName1(
                                        Get.locale!.languageCode,
                                      )} ${item.getVariantName2(
                                        Get.locale!.languageCode,
                                      )}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              content: Container(
                                width: Get.width,
                                height: 60 * (item.prices!.length + 1),
                                color: Colors.white,
                                child: Column(
                                  children:
                                      List.generate(item.prices!.length + 1, (
                                    index,
                                  ) {
                                    if (index < item.prices!.length) {
                                      var el = item.prices![index];
                                      TextEditingController priceController =
                                          TextEditingController();
                                      var exist = warehouseController
                                          .adjustedPrice
                                          .where(
                                              (element) => element.id == el.id);
                                      priceController.text = exist.isNotEmpty
                                          ? exist.first.price.toString()
                                          : el.price.toString();
                                      return SizedBox(
                                        height: 60,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("saleprice".tr),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 5,
                                              ),
                                              width: Get.width / 4,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == "" ||
                                                      double.parse(value!) ==
                                                          0) {
                                                    return "zero.not.allowed"
                                                        .tr;
                                                  }
                                                  return null;
                                                },
                                                controller: priceController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  labelText: el.typepv_id !=
                                                          null
                                                      ? el.typepv_id.toString()
                                                      : "all".tr,
                                                ),
                                                onChanged: (value) {
                                                  changedPrice = true;
                                                },
                                                onSaved: (value) {
                                                  //
                                                  if (changedPrice) {
                                                    if (warehouseController
                                                        .adjustedPrice
                                                        .where(
                                                          (element) =>
                                                              element.id ==
                                                              el.id,
                                                        )
                                                        .isEmpty) {
                                                      warehouseController
                                                          .adjustedPrice
                                                          .add(
                                                        PriceItem(
                                                          id: el.id,
                                                          variant_id:
                                                              el.variant_id,
                                                          price: value != ""
                                                              ? double.parse(
                                                                  value
                                                                      .toString(),
                                                                )
                                                              : 0,
                                                          typepv_id:
                                                              el.typepv_id,
                                                        ),
                                                      );
                                                    } else {
                                                      warehouseController
                                                          .adjustedPrice
                                                          .where(
                                                            (element) =>
                                                                element.id ==
                                                                el.id,
                                                          )
                                                          .first
                                                          .updatePrice(
                                                            value != ""
                                                                ? double.parse(
                                                                    value
                                                                        .toString(),
                                                                  )
                                                                : 0,
                                                          );
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      var exist = warehouseController
                                          .adjustedStock
                                          .where(
                                        (element) =>
                                            element.variant_id ==
                                            item.variant_id,
                                      );
                                      quantityController.text = exist.isNotEmpty
                                          ? exist.first.quantity
                                              .toStringAsFixed(0)
                                          : item.quantity.toStringAsFixed(0);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        height: 60,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("quantity".tr),
                                            SizedBox(
                                              width: Get.width / 4,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == "" ||
                                                      double.parse(value!) ==
                                                          0) {
                                                    return "zero.not.allowed"
                                                        .tr;
                                                  }
                                                  return null;
                                                },
                                                controller: quantityController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  labelText: "Pcs".tr,
                                                ),
                                                onChanged: (value) {
                                                  changedStock = true;
                                                },
                                                onSaved: (value) {
                                                  if (changedStock) {
                                                    var toAdjust =
                                                        warehouseController
                                                            .adjustedStock
                                                            .where(
                                                      (element) =>
                                                          element.variant_id ==
                                                          item.variant_id,
                                                    );
                                                    if (toAdjust.isEmpty) {
                                                      warehouseController
                                                          .adjustedStock
                                                          .add(
                                                        AdjutStockItem(
                                                          variant_id:
                                                              item.variant_id,
                                                          quantity: value != ""
                                                              ? double.parse(
                                                                  value
                                                                      .toString(),
                                                                )
                                                              : 0,
                                                        ),
                                                      );
                                                    } else {
                                                      toAdjust.first
                                                          .updateStock(
                                                        value != ""
                                                            ? double.parse(
                                                                value
                                                                    .toString(),
                                                              )
                                                            : 0,
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }),
                                ),
                              ),
                              actions: [
                                MaterialButton(
                                  color: Colors.blue,
                                  height: 50,
                                  minWidth: double.infinity,
                                  onPressed: () {
                                    if (changedPrice || changedStock) {
                                      var currentState = frm.currentState;
                                      if (currentState!.validate()) {
                                        currentState.save();
                                        warehouseController.adjusted.add(
                                          item.variant_id,
                                        );
                                        Get.back();
                                      } else {}
                                    } else {
                                      Get.back();
                                    }
                                  },
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  child: Text(
                                    "adjust".tr,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    title: Text(
                      item.getShortDescription(Get.locale!.languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: item.quantity == 0
                            ? const Color.fromARGB(255, 173, 173, 173)
                            : (item.quantity / item.package) <=
                                    global.alertQuantity
                                ? Colors.red
                                : null,
                      ),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CachedNetworkImage(
                          cacheManager: CacheManager(
                            Config(item.image,
                                stalePeriod: const Duration(days: 7)),
                          ),
                          imageUrl: item.image,
                          placeholder: (context, url) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            child: const CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    subtitle: Text(
                      "${item.getVariantName1(Get.locale!.languageCode)} ${item.getVariantName2(Get.locale!.languageCode)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.quantity == 0
                            ? const Color.fromARGB(255, 204, 204, 204)
                            : (item.quantity / item.package) <= 5
                                ? const Color.fromARGB(255, 255, 157, 150)
                                : null,
                      ),
                    ),
                    trailing: SizedBox(
                      width: Get.locale!.languageCode == "ar" ? 120 : 100,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formatter.format(
                              warehouseController.UniteIsCaisse.value
                                  ? item.stock_price
                                  : item.stock_price * item.quantity,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.quantity == 0
                                  ? const Color.fromARGB(255, 204, 204, 204)
                                  : (item.quantity / item.package) <=
                                          global.alertQuantity
                                      ? Colors.red
                                      : null,
                            ),
                          ),
                          Text(
                            "${warehouseController.UniteIsCaisse.value ? (item.quantity / item.package).ceil().toString() : item.quantity.ceil().toString()}${stockCh.isNotEmpty ? (Get.locale!.languageCode != "ar" ? " → " : " ← ") + (warehouseController.UniteIsCaisse.value ? (stockCh.first.quantity / item.package).ceil() : stockCh.first.quantity).toStringAsFixed(0) : ""}${warehouseController.UniteIsCaisse.value ? " ${"Cart".tr}" : " ${"Pcs".tr}"}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: item.quantity == 0
                                  ? const Color.fromARGB(255, 223, 223, 223)
                                  : (item.quantity / item.package) <= 5
                                      ? const Color.fromARGB(255, 255, 157, 150)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
