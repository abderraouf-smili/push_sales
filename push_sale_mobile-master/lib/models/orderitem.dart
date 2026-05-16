import 'package:push_sale/models/order.dart';

class Orderitem {
  final String id;
  final String order_id;
  final int variant_id;
  final String sku;
  final String? promotion_id;
  final String? promotionitem_id;
  String? coupon_id;
  final String warehouse_id;
  final String image;
  final String unite;
  final double quantity;
  final int package;
  final double price;
  double total;
  double discount;
  final String product_name;
  final String variant_name_1;
  final String option_1;
  final String? variant_name_2;
  final String? option_2;
  Orderitem({
    required this.id,
    required this.order_id,
    required this.variant_id,
    required this.sku,
    required this.promotion_id,
    required this.promotionitem_id,
    this.coupon_id,
    required this.warehouse_id,
    required this.image,
    required this.unite,
    required this.quantity,
    required this.package,
    required this.total,
    required this.discount,
    required this.product_name,
    required this.variant_name_1,
    required this.option_1,
    required this.variant_name_2,
    required this.option_2,
    required this.price,
  });
  static Orderitem fromMap(Map<String, dynamic> value) {
    return Orderitem(
      id: value["id"],
      order_id: value["order_id"],
      variant_id: int.parse(value["variant_id"].toString()),
      warehouse_id: value["warehouse_id"],
      sku: value["sku"],
      promotion_id: value["promotion_id"],
      promotionitem_id: value["promotionitem_id"],
      image: value["image"],
      unite: value["unite"],
      quantity: double.parse(value["quantity"].toString()),
      package: int.parse(value["package"].toString()),
      total: double.parse(value["price"].toString()) *
          double.parse(value["quantity"].toString()),
      discount: double.parse(value["discount"].toString()),
      product_name: value["product_name"],
      variant_name_1: value["variant_name_1"],
      option_1: value["option_1"] ?? "",
      variant_name_2: value["variant_name_2"],
      option_2: value["option_2"] ?? "",
      price: double.parse(value["price"].toString()),
    );
  }

  toMap() {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["order_id"] = order_id;
    ret["image"] = image;
    ret["unite"] = unite;
    ret["discount"] = discount;
    ret["product_name"] = product_name;
    ret["variant_name_1"] = variant_name_1;
    ret["option_1"] = option_1;
    ret["variant_name_2"] = variant_name_2;
    ret["option_2"] = option_2;
    ret["variant_id"] = variant_id;
    ret["sku"] = sku;
    ret["promotion_id"] = promotion_id;
    ret["promotionitem_id"] = promotionitem_id;
    ret["coupon_id"] = coupon_id;
    ret["warehouse_id"] = warehouse_id;
    ret["quantity"] = quantity;
    ret["package"] = package;
    ret["price"] = total / quantity;
    return ret;
  }

  static List<Orderitem> fromListMapToList(List<dynamic> value) {
    List<Orderitem> _list = [];
    for (var item in value) {
      _list.add(Orderitem.fromMap(item));
    }
    return _list;
  }

  setDiscount(double value) {
    discount = value;
    total = price *
        (unite == "Pcs" ? quantity : quantity * package) *
        ((100 - discount) / 100);
  }

  setCouponId(String value) {
    coupon_id = value;
  }

  removeCoupon() {
    coupon_id = null;
    total = total / ((100 - discount) / 100);
    discount = 0;
  }
}
