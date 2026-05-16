import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/controllers/product_controller.dart';
import 'package:push_sale/controllers/purchaseorder_controller.dart';
import 'package:push_sale/views/signed/widgets/warehouses/fiche_purchase_product.dart';
import 'package:push_sale/views/signed/widgets/warehouses/product_purchase_list.dart';
import 'package:push_sale/views/signed/widgets/warehouses/purchase_items_list.dart';

class ProductReception extends StatelessWidget {
  PrinterController printerController = Get.put(PrinterController());

  PurchaseOrderController purchaseController =
      Get.put(PurchaseOrderController());
  ProductController productController = Get.put(ProductController());
  PageController pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    productController.client = null;
    productController.getProducts();
    productController.page.value = 1;
    productController.filter = "";
    purchaseController.orderitems = [];
    return SafeArea(
      child: WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                PurchaseItemsList(pageController),
                ProductPurchaseList(pageController),
                FichePurchaseProduct(pageController),
              ],
            ),
          )),
    );
  }
}
