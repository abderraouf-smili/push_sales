import 'package:push_sale/models/stock_operation.dart';

class StockOperationItems {
  final String id;
  final int variant_id;
  final String product_name;
  final String variant_1;
  final String variant_2;
  final String unite;
  final String image;
  final int package;
  double quantity;
  double? previsionnel;
  final double saleprice;
  final double stockprice;

  StockOperationItems({
    required this.id,
    required this.variant_id,
    required this.product_name,
    required this.variant_1,
    required this.variant_2,
    required this.unite,
    required this.image,
    required this.package,
    required this.quantity,
    required this.saleprice,
    required this.stockprice,
  });
  addQuantity(double qty) {
    quantity += qty;
  }

  static StockOperationItems fromMap(Map<String, dynamic> value) {
    return StockOperationItems(
      id: value["id"],
      variant_id: int.parse(value["variant_id"].toString()),
      product_name: value["product_name"],
      variant_1: value["variant_1"],
      variant_2: value["variant_2"],
      unite: value["unite"] ?? "Pcs",
      image: value["image"],
      package: int.parse(value["package"].toString()),
      quantity: double.parse(value["quantity"].toString()),
      saleprice: double.parse(value["saleprice"].toString()),
      stockprice: double.parse(value["stockprice"].toString()),
    );
  }

  static List<StockOperationItems> fromListMapToList(List<dynamic> value) {
    List<StockOperationItems> _list = [];
    for (var item in value) {
      _list.add(StockOperationItems.fromMap(item));
    }
    return _list;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "variant_id": variant_id,
      "image": image,
      "product_name": product_name,
      "variant_1": variant_1,
      "variant_2": variant_2,
      "quantity": quantity,
      "package": package,
      "saleprice": saleprice,
    };
  }
}
