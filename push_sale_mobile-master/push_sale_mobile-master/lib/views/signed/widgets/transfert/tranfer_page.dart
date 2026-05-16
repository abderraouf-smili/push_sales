import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/stock_operation_controller.dart';
import 'package:push_sale/views/signed/widgets/transfert/show_detail_transfer.dart';

class TransferPage extends StatelessWidget {
  StockOperationController stockController = Get.find();
  PageController pageController;

  TransferPage(this.pageController);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: stockController.getBonChargement,
      child: Obx(
        () => ListView.builder(
          itemCount: stockController.bonschargement.length *
              (stockController.opLoaded.value ? 1 : 1),
          itemBuilder: (context, index) {
            var item = stockController.bonschargement[index];
            return GestureDetector(
              onTap: () {
                stockController.itemSelected = item;
                pageController.jumpToPage(3);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 244, 248, 255),
                  border: Border.all(
                    width: 1,
                    color: Color.fromARGB(255, 199, 201, 228),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(item.code!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.category,
                            size: 18,
                            color: Colors.amber,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(item.items.length.toString()),
                        ],
                      ),
                      Text(DateFormat('dd/MM/y').format(item.operation_date))
                    ],
                  ),
                  leading: Icon(
                    Icons.receipt_long_rounded,
                    color: item.state == "new" ? Colors.green : Colors.grey,
                    size: 35,
                  ),
                  trailing: Icon(
                    item.state == "new"
                        ? Icons.fiber_new_rounded
                        : Icons.local_shipping_rounded,
                    size: 35,
                    color: item.state == "new" ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
