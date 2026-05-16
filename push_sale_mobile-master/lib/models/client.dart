import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/address.dart';
import 'package:push_sale/models/reason_no_delivery_sale.dart';
import 'package:push_sale/models/type_point_vente.dart';
import 'package:push_sale/models/visit_day.dart';

class Client {
  final String id;
  final String code;
  final String name;
  final String image;
  final String mobile;
  final Address? address;
  final TypePointVente? typepv;
  final double? solde;
  final int? sales;
  List<VisitDay>? visitdays;
  List<ReasonNoDeliverySale>? visits;
  bool hasImage;

  Client({
    required this.id,
    required this.code,
    required this.solde,
    required this.sales,
    required this.name,
    required this.image,
    required this.mobile,
    required this.address,
    required this.typepv,
    required this.hasImage,
    this.visitdays,
    this.visits,
  });

  static fromMap(Map<String, dynamic> value) {
    return Client(
      id: value["id"],
      code: value["code"],
      solde: value["solde"] != null
          ? double.parse(value["solde"].toString())
          : null,
      sales:
          value["sales"] != null ? int.parse(value["sales"].toString()) : null,
      name: value["name"],
      mobile: value["mobile"] ?? "",
      image:
          "${global.urlAPI}${value["image"] == null || value["image"] == "" ? "/storage/clients/no_image.png" : value["image"]}",
      address:
          value["address"] != null ? Address.fromMap(value["address"]) : null,
      typepv: value["type_p_v"] != null
          ? TypePointVente.fromMap(value["type_p_v"])
          : null,
      hasImage: value["image"] != null && value["image"] != "",
      visitdays: value["visit_days"] == null
          ? []
          : VisitDay.fromListMapMap(value["visit_days"]),
      visits: value["visits"] == null || value["visits"].isEmpty
          ? null
          : ReasonNoDeliverySale.fromListMapMap(value["visits"]),
    );
  }
}
