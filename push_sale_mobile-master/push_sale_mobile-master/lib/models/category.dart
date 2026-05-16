import 'package:push_sale/models/product.dart';

class Category {
  final int id;
  final String code;
  final String image;
  final String short_description_ar;
  final String long_description_ar;
  final String short_description_fr;
  final String long_description_fr;
  final List<Product>? products;

// ignore: prefer_typing_uninitialized_variables
  Category({
    required this.id,
    required this.code,
    required this.image,
    required this.short_description_ar,
    required this.long_description_ar,
    required this.short_description_fr,
    required this.long_description_fr,
    required this.products,
  });

  static Category fromMap(Map<String, dynamic> value) {
    return Category(
      id: value["id"],
      code: value["code"],
      image: value["image"] == null || value["image"] == ""
          ? "/storage/products/no_image.png"
          : value["image"],
      short_description_ar: value["short_description_ar"],
      long_description_ar: value["long_description_ar"],
      short_description_fr: value["short_description_fr"],
      long_description_fr: value["long_description_fr"],
      products: value["products"] != null
          ? Product.fromListMapToList(value["products"])
          : null,
    );
  }

  String getLongDescription(String locale) {
    switch (locale) {
      case "ar":
        return long_description_ar;
      case "fr":
        return long_description_fr;
      default:
        return long_description_fr;
    }
  }

  String getShortDescription(String locale) {
    switch (locale) {
      case "ar":
        return short_description_ar;
      case "fr":
        return short_description_fr;
      default:
        return short_description_fr;
    }
  }
}
