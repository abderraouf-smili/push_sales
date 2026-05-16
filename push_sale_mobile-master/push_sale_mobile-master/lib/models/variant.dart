import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/product.dart';

class Variant {
  final int id;
  final String sku;
  final String barcode;
  final String image;
  final int package;
  final String option1_ar;
  final String option1_fr;
  final String variant1_ar;
  final String variant1_fr;
  final String option2_ar;
  final String option2_fr;
  final String variant2_ar;
  final String variant2_fr;
  final int product_id;
  final int promotion_typepv_id;
  final int pricelist_typepv_id;
  final String warehouse_id;
  final String? promotion_id;
  final String? promotionitem_id;
  final double price;
  final double original_price;
  final double quantity;
  final double previsionnel;
  final double discount;
  final double minimum;
  final String unite;
  final String promo_type;
  final Product? product;
  Variant({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.image,
    required this.package,
    required this.option1_ar,
    required this.option1_fr,
    required this.variant1_ar,
    required this.variant1_fr,
    required this.option2_ar,
    required this.option2_fr,
    required this.variant2_ar,
    required this.variant2_fr,
    required this.product_id,
    required this.promotion_typepv_id,
    required this.pricelist_typepv_id,
    required this.warehouse_id,
    required this.promotion_id,
    required this.promotionitem_id,
    required this.price,
    required this.original_price,
    required this.quantity,
    required this.previsionnel,
    required this.discount,
    required this.minimum,
    required this.unite,
    required this.promo_type,
    required this.product,
  });

  static Variant fromMap(Map<String, dynamic> value) {
    return Variant(
      id: value["id"],
      sku: value["sku"],
      barcode: value["barcode"],
      image:
          "${global.urlAPI}${value["image"] == null || value["image"] == "" ? "/storage/products/no_image.png" : value["image"]}",
      package: int.parse(value["package"].toString()),
      option1_ar: value["option1_ar"] ?? "",
      option1_fr: value["option1_fr"] ?? "",
      variant1_ar: value["variant1_ar"] ?? "",
      variant1_fr: value["variant1_fr"] ?? "",
      option2_ar: value["option2_ar"] ?? "",
      option2_fr: value["option2_fr"] ?? "",
      variant2_ar: value["variant2_ar"] ?? "",
      variant2_fr: value["variant2_fr"] ?? "",
      product_id: int.parse(value["product_id"].toString()),
      promotion_id: value["promotion_id"],
      promotionitem_id: value["promotionitem_id"],
      promotion_typepv_id: value["promotion_typepv_id"] != null
          ? int.parse(value["promotion_typepv_id"].toString())
          : 0,
      pricelist_typepv_id: value["pricelist_typepv_id"] != null
          ? int.parse(value["pricelist_typepv_id"].toString())
          : 0,
      price: value["price"] != null
          ? double.parse(value["price"].toString()) *
              (100 -
                  (value["discount"] != null
                      ? double.parse(value["discount"].toString())
                      : 0)) /
              100
          : 0,
      original_price:
          value["price"] != null ? double.parse(value["price"].toString()) : 0,
      quantity: value["quantity"] != null
          ? double.parse(value["quantity"].toString())
          : 0,
      previsionnel: value["previsionnel"] != null
          ? double.parse(value["previsionnel"].toString())
          : 0,
      discount: value["discount"] != null
          ? double.parse(value["discount"].toString())
          : 0,
      minimum: value["minimum"] != null
          ? double.parse(value["minimum"].toString()) *
              (value["unite"] == "Cart"
                  ? int.parse(value["package"].toString())
                  : 1)
          : 1,
      unite: value["unite"] ?? "",
      promo_type: value["promo_type"] ?? "",
      product:
          value["product"] != null ? Product.fromMap(value["product"]) : null,
      warehouse_id: value["warehouse_id"],
    );
  }

  static List<Variant> fromListMapToList(List<dynamic> value) {
    List<Variant> _list = [];
    for (var item in value) {
      _list.add(Variant.fromMap(item));
    }
    var a = _list
        .where(
          (element) => _list.any((all_element) =>
              all_element != element &&
              all_element.id == element.id &&
              all_element.warehouse_id == element.warehouse_id),
        )
        .toList();
    _list.removeWhere((element) => a.any(
          (doublon) =>
              element.id == doublon.id &&
              element.warehouse_id == doublon.warehouse_id &&
              element.promotion_id == null,
        ));
    return _list;
  }

  String getOptionName1(String locale) {
    switch (locale) {
      case "ar":
        return option1_ar;
      case "fr":
        return option1_fr;
      default:
        return option1_fr;
    }
  }

  String getOptionName2(String locale) {
    switch (locale) {
      case "ar":
        return option2_ar;
      case "fr":
        return option2_fr;
      default:
        return option2_fr;
    }
  }

  String getVariantName1(String locale) {
    switch (locale) {
      case "ar":
        return variant1_ar;
      case "fr":
        return variant1_fr;
      default:
        return variant1_fr;
    }
  }

  String getVariantName2(String locale) {
    switch (locale) {
      case "ar":
        return variant2_ar;
      case "fr":
        return variant2_fr;
      default:
        return variant2_fr;
    }
  }
}
