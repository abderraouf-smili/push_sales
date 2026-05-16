import 'package:push_sale/const/globals.dart' as global;

class PurchaseVariant {
  final int id;
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
  final String sku;
  final double discount;
  final double lastpurchaseprice;
  PurchaseVariant({
    required this.id,
    required this.barcode,
    required this.image,
    required this.package,
    required this.sku,
    required this.discount,
    required this.option1_ar,
    required this.option1_fr,
    required this.variant1_ar,
    required this.variant1_fr,
    required this.option2_ar,
    required this.option2_fr,
    required this.variant2_ar,
    required this.variant2_fr,
    required this.product_id,
    required this.lastpurchaseprice,
  });

  static PurchaseVariant fromMap(Map<String, dynamic> value) {
    return PurchaseVariant(
      id: value["id"],
      barcode: value["barcode"],
      image:
          "${global.urlAPI}${value["image"] == null || value["image"] == "" ? "/storage/products/no_image.png" : value["image"]}",
      package: int.parse(value["package"].toString()),
      sku: value["sku"] ?? "",
      discount: value["discount"] == null
          ? 0
          : double.parse(value["discount"].toString()),
      option1_ar: value["option1_ar"] ?? "",
      option1_fr: value["option1_fr"] ?? "",
      variant1_ar: value["variant1_ar"] ?? "",
      variant1_fr: value["variant1_fr"] ?? "",
      option2_ar: value["option2_ar"] ?? "",
      option2_fr: value["option2_fr"] ?? "",
      variant2_ar: value["variant2_ar"] ?? "",
      variant2_fr: value["variant2_fr"] ?? "",
      product_id: int.parse(value["product_id"].toString()),
      lastpurchaseprice: double.parse(value["lastpurchaseprice"].toString()),
    );
  }

  static List<PurchaseVariant> fromListMapToList(List<dynamic> value) {
    List<PurchaseVariant> _list = [];
    for (var item in value) {
      _list.add(PurchaseVariant(
        id: item["id"],
        sku: item["sku"],
        barcode: item["barcode"],
        image:
            "${global.urlAPI}${item["image"] == null || item["image"] == "" ? "/storage/products/no_image.png" : item["image"]}",
        package: int.parse(item["package"].toString()),
        discount: item["discount"] == null
            ? 0
            : double.parse(item["discount"].toString()),
        option1_ar: item["option1_ar"] ?? "",
        option1_fr: item["option1_fr"] ?? "",
        variant1_ar: item["variant1_ar"] ?? "",
        variant1_fr: item["variant1_fr"] ?? "",
        option2_ar: item["option2_ar"] ?? "",
        option2_fr: item["option2_fr"] ?? "",
        variant2_ar: item["variant2_ar"] ?? "",
        variant2_fr: item["variant2_fr"] ?? "",
        product_id: int.parse(item["product_id"].toString()),
        lastpurchaseprice: item["lastpurchaseprice"] == null
            ? 0
            : double.parse(item["lastpurchaseprice"].toString()),
      ));
    }
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
