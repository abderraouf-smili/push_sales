import 'package:push_sale/models/category.dart';
import 'package:push_sale/models/product.dart';
import 'package:push_sale/models/variant.dart';

class PromotionLines {
  final String id;
  final double discount;
  final double minimum;
  final String unite;
  final Category? category;
  final Product? product;
  final Variant? variant;

  PromotionLines({
    required this.id,
    required this.discount,
    required this.minimum,
    required this.unite,
    required this.category,
    required this.product,
    required this.variant,
  });

  static PromotionLines fromMap(Map<String, dynamic> value) {
    return PromotionLines(
      id: value["id"].toString(),
      discount: double.parse(value["discount"].toString()),
      minimum: double.parse(value["minimum"].toString()),
      unite: value["unite"],
      category: value["category"] != null
          ? Category.fromMap(value["category"])
          : null,
      product:
          value["product"] != null ? Product.fromMap(value["product"]) : null,
      variant:
          value["variant"] != null ? Variant.fromMap(value["variant"]) : null,
    );
  }

  static List<PromotionLines> fromMapToList(List<dynamic> list) {
    List<PromotionLines> _list = [];
    if (list.isNotEmpty) {
      for (var value in list) {
        _list.add(PromotionLines.fromMap(value));
      }
    }
    return _list;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      "id": id,
      "discount": discount,
      "minimum": minimum,
      "unite": unite,
      "category_id": category != null ? category!.id : null,
      "product_id": product != null ? product!.id : null,
      "variant_id": variant != null ? variant!.id : null,
    };
    return ret;
  }
}
