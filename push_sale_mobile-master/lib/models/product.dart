// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:intl/intl.dart';
import 'package:push_sale/models/purchase_variant.dart';
import 'package:push_sale/models/variant.dart';
import 'package:push_sale/const/globals.dart' as global;

class Product {
  final int id;
  final String ssin;
  final String short_description_ar;
  final String long_description_ar;
  final String short_description_fr;
  final String long_description_fr;
  final String image;
  final int category_id;
  String? showPrice;
  List<Variant>? variants;
  List<PurchaseVariant>? purchasevariants;
  Product({
    required this.id,
    required this.ssin,
    required this.short_description_ar,
    required this.long_description_ar,
    required this.short_description_fr,
    required this.long_description_fr,
    required this.image,
    required this.category_id,
    required this.variants,
    required this.purchasevariants,
    required this.showPrice,
  });

  static Product fromMap(Map<String, dynamic> value) {
    var formatter = NumberFormat("#,##0.00", "fr_FR");
    String _showPrice = "-";
    List<Variant>? _variants;

    if (value["variants"] != null) {
      _variants = Variant.fromListMapToList(value["variants"]);
      if (_variants.isNotEmpty) {
        double min = _variants[0].original_price;
        double max = min;

        for (var element in _variants) {
          if (element.original_price > 0) {
            if (min > element.original_price) {
              min = element.original_price;
            }
            if (max < element.original_price) {
              max = element.original_price;
            }
          }
        }
        _showPrice = min == max
            ? formatter.format(min)
            : formatter.format(min) + " - " + formatter.format(max);
      }
    }

    return Product(
        id: value["id"],
        ssin: value["ssin"],
        short_description_ar: value["short_description_ar"],
        long_description_ar: value["long_description_ar"],
        short_description_fr: value["short_description_fr"],
        long_description_fr: value["long_description_fr"],
        image:
            "${global.urlAPI}${value["image"] == null || value["image"] == "" ? "/storage/products/no_image.png" : value["image"]}",
        category_id: int.parse(value["category_id"].toString()),
        variants: value["variants"] != null
            ? Variant.fromListMapToList(value["variants"])
            : null,
        purchasevariants: value["purchasevariants"] != null
            ? PurchaseVariant.fromListMapToList(value["purchasevariants"])
            : null,
        showPrice: _showPrice);
  }

  static List<Product> fromListMapToList(List<Map<String, dynamic>> value) {
    List<Product> _list = [];
    for (var item in value) {
      _list.add(Product.fromMap(item));
    }

    return _list;
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
