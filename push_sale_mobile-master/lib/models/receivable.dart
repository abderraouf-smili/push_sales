import 'package:push_sale/const/globals.dart' as global;

class Receivale {
  final String client_id;
  final String image;
  final String client_name;
  final String actor_name;
  final String state_code;
  final String city_name;
  final double total_paye;
  final double total_vendu;
  Receivale({
    required this.client_id,
    required this.image,
    required this.client_name,
    required this.actor_name,
    required this.state_code,
    required this.city_name,
    required this.total_paye,
    required this.total_vendu,
  });

  static Receivale fromMap(Map<String, dynamic> value) {
    return Receivale(
      client_id: value["client_id"],
      image:
          "${global.urlAPI}${value["image"] == "" || value["image"] == null ? "/storage/clients/no_image.png" : value["image"]}",
      client_name: value["client_name"],
      actor_name: value["actor_name"],
      state_code: value["state_code"],
      city_name: value["city_name"],
      total_paye: double.parse(value["total_paye"].toString()),
      total_vendu: double.parse(value["total_vendu"].toString()),
    );
  }
}

class ReceivaleLine {
  final String purchaseorder_id;
  final DateTime purchase_date;
  final String code;
  final double total_amount;
  final double solde;
  double? cashed;

  ReceivaleLine({
    required this.purchaseorder_id,
    required this.purchase_date,
    required this.code,
    required this.total_amount,
    required this.solde,
  });

  static ReceivaleLine fromMap(Map<String, dynamic> value) {
    return ReceivaleLine(
      purchaseorder_id: value["purchaseorder_id"],
      purchase_date: DateTime.parse(value["purchase_date"]),
      code: value["code"],
      total_amount: double.parse(value["total_amount"].toString()),
      solde: double.parse(value["solde"].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {};
    ret["purchaseorder_id"] = purchaseorder_id;
    ret["cashed"] = cashed ?? 0;
    ret["paid"] = ((cashed ?? 0) == solde);
    return ret;
  }
}
