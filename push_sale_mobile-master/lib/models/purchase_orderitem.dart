class PurchaseOrderitem {
  final String id;
  final String purchaseorder_id;
  final int variant_id;
  final String? warehouse_id;
  final String image;
  String unite;
  final String sku;
  final double discount;
  double quantity;
  double? confirmed_quantity;
  double? cancelled_quantity;
  double restant = 0.0;
  final int package;
  final double total;
  double price;
  final String product_name;
  final String variant_name_1;
  final String option_1;
  final String? variant_name_2;
  final String? option_2;
  bool modified = false;
  PurchaseOrderitem({
    required this.id,
    required this.purchaseorder_id,
    required this.variant_id,
    this.warehouse_id,
    required this.image,
    required this.unite,
    required this.sku,
    required this.discount,
    required this.quantity,
    this.confirmed_quantity,
    this.cancelled_quantity,
    required this.package,
    required this.total,
    required this.price,
    required this.product_name,
    required this.variant_name_1,
    required this.option_1,
    required this.variant_name_2,
    required this.option_2,
  });
  static PurchaseOrderitem fromMap(Map<String, dynamic> value) {
    return PurchaseOrderitem(
      id: value["id"],
      purchaseorder_id: value["purchaseorder_id"],
      variant_id: int.parse(value["variant_id"].toString()),
      warehouse_id: value["warehouse_id"],
      image: value["image"],
      unite: value["unite"],
      discount: value["discount"] != null
          ? double.parse(value["discount"].toString())
          : 0,
      sku: value["sku"],
      quantity: double.parse(value["quantity"].toString()),
      confirmed_quantity: value["confirmed_quantity"] != null
          ? double.parse(value["confirmed_quantity"].toString())
          : null,
      cancelled_quantity: value["cancelled_quantity"] != null
          ? double.parse(value["cancelled_quantity"].toString())
          : null,
      price: double.parse(value["price"].toString()),
      package: int.parse(value["package"].toString()),
      total: double.parse(value["price"].toString()),
      product_name: value["product_name"],
      variant_name_1: value["variant_name_1"],
      option_1: value["option_1"] ?? "",
      variant_name_2: value["variant_name_2"],
      option_2: value["option_2"] ?? "",
    );
  }

  toMap() {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["purchaseorder_id"] = purchaseorder_id;
    ret["image"] = image;
    ret["unite"] = unite;
    ret["discount"] = discount;
    ret["sku"] = sku;
    ret["product_name"] = product_name;
    ret["variant_name_1"] = variant_name_1;
    ret["option_1"] = option_1;
    ret["variant_name_2"] = variant_name_2;
    ret["option_2"] = option_2;
    ret["variant_id"] = variant_id;
    ret["warehouse_id"] = warehouse_id;
    ret["quantity"] = quantity;
    ret["confirmed_quantity"] = confirmed_quantity;
    ret["cancelled_quantity"] = cancelled_quantity;
    ret["price"] = price;
    ret["package"] = package;
    return ret;
  }

  static List<PurchaseOrderitem> fromListMapToList(List<dynamic> value) {
    List<PurchaseOrderitem> list = [];
    for (var item in value) {
      list.add(PurchaseOrderitem.fromMap(item));
    }
    return list;
  }

  confirmQuantity() {
    confirmed_quantity = quantity;
    cancelled_quantity = 0;
    modified = true;
  }

  cancelQuantity() {
    confirmed_quantity = 0;
    cancelled_quantity = quantity;
    modified = true;
  }

  setConfirmQuantity(quantity) {
    if (quantity == 0) {
      cancelQuantity();
    } else if (quantity == quantity) {
      confirmQuantity();
    } else {
      confirmed_quantity = quantity;
      modified = true;
    }
  }

  addRestant(double quantity) {
    restant = restant + quantity;
  }

  resetRestant() {
    restant = 0;
  }

  setUnite(String unite) {
    if (unite == "Cart") {
      quantity = quantity * package;
      price = price / package;
    } else {
      quantity = quantity / package;
      price = price * package;
    }
    unite = unite;
  }
}
