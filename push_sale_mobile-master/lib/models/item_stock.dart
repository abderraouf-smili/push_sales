import 'package:push_sale/const/globals.dart' as global;

class ItemStock {
  final int variant_id;
  final String image;
  final String short_description_fr;
  final String short_description_ar;
  final String variant1_fr;
  final String variant1_ar;
  final String variant2_fr;
  final String variant2_ar;
  final int package;
  final double quantity;
  final double previsionnel;
  final double stock_price;
  List<PriceItem>? prices;
  ItemStock({
    required this.variant_id,
    required this.image,
    required this.short_description_fr,
    required this.short_description_ar,
    required this.variant1_fr,
    required this.variant1_ar,
    required this.variant2_fr,
    required this.variant2_ar,
    required this.quantity,
    required this.previsionnel,
    required this.package,
    required this.stock_price,
    this.prices,
  });

  static fromMap(Map<String, dynamic> value) {
    return ItemStock(
      variant_id: int.parse(value["variant_id"].toString()),
      image:
          "${global.urlAPI}${value["image"] == null || value["image"] == "" ? "/storage/products/no_image.png" : value["image"]}",
      short_description_fr: value["short_description_fr"],
      short_description_ar: value["short_description_ar"],
      package: int.parse(value["package"].toString()),
      variant1_fr: value["variant1_fr"],
      variant1_ar: value["variant1_ar"],
      variant2_fr: value["variant2_fr"] ?? "",
      variant2_ar: value["variant2_ar"] ?? "",
      quantity: double.parse(value["quantity"].toString()),
      previsionnel: double.parse(value["previsionnel"].toString()),
      stock_price: double.parse(value["stock_price"].toString()),
      prices: value["prices"] != null
          ? PriceItem.fromListMapToList(value["prices"])
          : null,
    );
  }

  static fromListMapToList(List<dynamic> value) {
    List<ItemStock> list = [];
    for (var item in value) {
      if (double.parse(item["quantity"].toString()) != 0 ||
          double.parse(item["previsionnel"].toString()) != 0) {
        list.add(fromMap(item));
      }
    }
    return list;
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

class PriceItem {
  final int id;
  final int variant_id;
  double price;
  int? typepv_id;
  PriceItem({
    required this.id,
    required this.variant_id,
    required this.price,
    required this.typepv_id,
  });
  static PriceItem fromMap(Map<String, dynamic> value) {
    return PriceItem(
      id: int.parse(value["id"].toString()),
      variant_id: int.parse(value["var_id"].toString()),
      price: double.parse(value["price"].toString()),
      typepv_id: value["typepv_id"] != null
          ? int.parse(value["typepv_id"].toString())
          : null,
    );
  }

  static List<PriceItem> fromListMapToList(List<dynamic> value) {
    List<PriceItem> list = [];
    for (var item in value) {
      list.add(PriceItem.fromMap(item));
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "variant_id": variant_id,
      "price": price,
    };
  }

  updatePrice(double saleprice) {
    price = saleprice;
  }
}

class AdjutStockItem {
  final int variant_id;
  double quantity;
  AdjutStockItem({required this.variant_id, required this.quantity});
  updateStock(double stock) {
    quantity = stock;
  }

  Map<String, dynamic> toMap() {
    return {
      "variant_id": variant_id,
      "quantity": quantity,
    };
  }
}
