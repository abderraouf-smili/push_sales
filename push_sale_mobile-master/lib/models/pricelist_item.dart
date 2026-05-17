import 'package:push_sale/models/variant_original.dart';

class PriceListItem {
  final int id;
  final int pricelist_id;
  final Variant? variant;
  String sku;
  double price;
  bool updated = false;
  PriceListItem({
    required this.id,
    required this.pricelist_id,
    required this.variant,
    required this.sku,
    required this.price,
  });

  static PriceListItem fromMap(Map<String, dynamic> value) {
    return PriceListItem(
      id: int.tryParse(value["id"]?.toString() ?? "0") ?? 0,
      pricelist_id: int.tryParse(value["pricelist_id"]?.toString() ?? "0") ?? 0,
      variant:
          value["variant"] != null ? Variant.fromMap(value["variant"]) : null,
      sku: value["sku"]?.toString() ?? "",
      price: double.tryParse(value["price"]?.toString() ?? "0") ?? 0,
    );
  }

  static List<PriceListItem> fromListMap(List<dynamic> value) {
    List<PriceListItem> list = [];
    for (var item in value) {
      PriceListItem price = PriceListItem.fromMap(item);
      list.add(price);
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sku": sku,
      // "variant_id": variant.id,
      "price": price,
      // "pricelist_id": pricelist_id,
    };
  }
}
