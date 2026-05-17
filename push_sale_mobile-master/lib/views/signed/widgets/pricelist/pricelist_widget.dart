import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/models/pricelist.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/views/signed/widgets/pricelist/product_to_print.dart';

class PricelistWidget extends StatelessWidget {
  PricelistWidget(this.pricelist, {super.key});
  PriceList pricelist;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductToPrint(pricelist));
      },
      child: ListTile(
        title: Text(
          pricelist.description,
          style: const TextStyle(fontSize: 16),
        ),
        leading: pricelist.active
            ? const Icon(
                Icons.check_circle_outline_sharp,
                color: Colors.green,
              )
            : const Icon(
                Icons.stop_circle_outlined,
                color: Colors.red,
              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pricelist.start_date != null
                    ? DateFormat("dd/MM/y").format(pricelist.start_date!)
                    : "-"),
                const SizedBox(
                  width: 10,
                ),
                Text(pricelist.start_date != null
                    ? DateFormat("dd/MM/y").format(pricelist.end_date!)
                    : "-"),
              ],
            ),
            Text(
              pricelist.typePv != null ? pricelist.typePv!.name : "all".tr,
              style: const TextStyle(fontSize: 13),
            )
          ],
        ),
        trailing: Text("${pricelist.items.length} elements",
            style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
