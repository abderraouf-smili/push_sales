import 'package:intl/intl.dart';
import 'package:push_sale/models/promotion_lines.dart';
import 'package:push_sale/models/promotion_type.dart';
import 'package:push_sale/models/type_point_vente.dart';
import 'package:push_sale/const/globals.dart' as global;

class Promotion {
  final String id;
  final String description;
  final DateTime start_date;
  final DateTime end_date;
  final String? image;
  final PromotionType? type_promotion;
  int? type_promotion_id;
  final TypePointVente? typepv;
  final List<PromotionLines> lines;

  Promotion({
    required this.id,
    required this.description,
    required this.start_date,
    required this.end_date,
    required this.image,
    required this.type_promotion,
    required this.typepv,
    required this.lines,
    this.type_promotion_id,
  });

  static Promotion fromMap(Map<String, dynamic> value) {
    return Promotion(
      id: value["id"].toString(),
      description: value["description"],
      start_date: DateTime.parse(value["start_date"].toString()),
      end_date: DateTime.parse(value["end_date"].toString()),
      image:
          "${global.urlAPI}${value["image"] == null || value["image"] == "" ? "/storage/products/no_image.png" : value["image"]}",
      typepv: value["typepv"] != null
          ? TypePointVente.fromMap(value["typepv"])
          : null,
      type_promotion: PromotionType.fromMap(value["type"]),
      lines: PromotionLines.fromMapToList(value["lines"]),
    );
  }

  String formatDate(DateTime d) {
    return "${d.day} / ${d.month} / ${d.year}";
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      "id": id,
      "description": description,
      "start_date": DateFormat('y/MM/dd').format(start_date),
      "end_date": DateFormat('y/MM/dd').format(end_date),
      "image": null,
      "typepv": typepv?.toMap(),
      "type_promotion_id": type_promotion_id,
      "lines": lines.map((e) => e.toMap()).toList(),
    };
    return ret;
  }
}
