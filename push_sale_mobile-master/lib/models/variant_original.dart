import 'package:push_sale/models/product.dart';
import 'package:push_sale/const/globals.dart' as global;

class Variant {
  final int id;
  final String barcode;
  String image;
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
  Map<String, dynamic> uploadImage = {};
  bool updated = false;
  Product? product;

  Variant({
    required this.id,
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
    this.product,
  });

  static Variant fromMap(Map<String, dynamic> value) {
    return Variant(
      id: value["id"],
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
      product:
          value["product"] != null ? Product.fromMap(value["product"]) : null,
    );
  }

  static List<Variant> fromListMapToList(List<dynamic> value) {
    List<Variant> _list = [];
    for (var item in value) {
      // print("================> ${item}");
      _list.add(Variant.fromMap(item));
    }
    return _list;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "barcode": barcode,
      "package": package,
      "option1_ar": option1_ar,
      "option1_fr": option1_fr,
      "variant1_ar": variant1_ar,
      "variant1_fr": variant1_fr,
      "option2_ar": option2_ar,
      "option2_fr": option2_fr,
      "variant2_ar": variant2_ar,
      "variant2_fr": variant2_fr,
      "product_id": product_id,
    };
  }
}
