import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/api/printer_controller.dart';
import 'package:push_sale/views/signed/widgets/orders/show_order_detail.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';

class SaleOrderList extends StatelessWidget {
  OrderController orderController = Get.put(OrderController());
  PrinterController printerController = Get.put(PrinterController());

  SaleOrderList({super.key});
  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    orderController.getOrders();
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("list.orders".tr),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case 0:
                    orderController.PrepareRecapInvoice();
                    String response = await printerController.StartPrinting(
                        orderController.textPrint);
                    break;
                  case 1:
                    orderController.PrepareRecapGoods();
                    String response = await printerController.StartPrinting(
                        orderController.textPrint);
                    break;
                  case 2:
                    ShowButtomSheetPrinterConfig(context: context);
                    break;
                }
              },
              elevation: 5,
              icon: const Icon(Icons.menu),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    enabled: true,
                    value: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("print.invoices.today".tr,
                            style: const TextStyle(color: Colors.black)),
                        const Icon(Icons.print, color: Colors.blue),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    enabled: true,
                    value: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("print.goods.today".tr,
                            style: const TextStyle(color: Colors.black)),
                        const Icon(Icons.print, color: Colors.blue),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    enabled: true,
                    value: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("printer.settings".tr,
                            style: const TextStyle(color: Colors.black)),
                        const Icon(Icons.bluetooth, color: Colors.blue),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    enabled: false,
                    value: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "export".tr,
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                        const Icon(Icons.picture_as_pdf_sharp,
                            color: Colors.blue),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    enabled: false,
                    value: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "send".tr,
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                        const Icon(Icons.send, color: Colors.blue),
                      ],
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: Container(
          child: Obx(() => orderController.loadOrdersReady.value
              ? ListView.builder(
                  itemCount: orderController.orders.length,
                  itemBuilder: (context, index) {
                    var item = orderController.orders[index];
                    return ListTile(
                      onTap: () {
                        Get.to(() => ShowOrderDetail(item));
                      },
                      title: Text(item.code),
                      subtitle: Text(item.client!.name),
                      trailing: Text(
                        formatter.format(item.total_amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  })
              : const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator()),
                  ),
                )),
        ),
      ),
    );
  }
}
