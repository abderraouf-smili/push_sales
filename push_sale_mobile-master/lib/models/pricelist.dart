import 'package:push_sale/models/pricelist_item.dart';
import 'package:push_sale/models/type_point_vente.dart';

class PriceList {
  final int id;
  final String name;
  final String description;
  int? typepv_id;
  DateTime? start_date;
  DateTime? end_date;
  final bool active;
  final int distributor_id;
  TypePointVente? typePv;
  List<PriceListItem> items;
  PriceList({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.distributor_id,
    this.start_date,
    this.end_date,
    this.typePv,
    required this.items,
  });

  static PriceList fromMap(Map<String, dynamic> value) {
    return PriceList(
      id: int.tryParse(value["id"]?.toString() ?? "0") ?? 0,
      name: value["name"]?.toString() ?? "",
      description: value["description"]?.toString() ?? "",
      active: value["active"] == true || value["active"].toString() == "1",
      distributor_id:
          int.tryParse(value["distributor_id"]?.toString() ?? "0") ?? 0,
      start_date: value["start_date"] != null
          ? DateTime.parse(value["start_date"])
          : null,
      end_date:
          value["end_date"] != null ? DateTime.parse(value["end_date"]) : null,
      typePv: value["typepv"] != null
          ? TypePointVente.fromMap(value["typepv"])
          : null,
      items: PriceListItem.fromListMap((value["items"] as List?) ?? const []),
    );
  }
}
