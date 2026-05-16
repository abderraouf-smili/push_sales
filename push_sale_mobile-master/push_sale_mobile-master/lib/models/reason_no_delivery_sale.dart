import 'package:flutter/material.dart';

class ReasonNoDeliverySale {
  final int id;
  final String type_reason;
  final String code;
  final bool revisit;
  final String description_ar;
  final String description_fr;

  ReasonNoDeliverySale({
    required this.id,
    required this.type_reason,
    required this.code,
    required this.revisit,
    required this.description_ar,
    required this.description_fr,
  });

  static fromMap(Map<String, dynamic> value) {
    return ReasonNoDeliverySale(
      id: int.parse(value["id"].toString()),
      type_reason: value["type_reason"] as String,
      code: value["code"] as String,
      revisit: int.parse(value["revisit"].toString()) == 1,
      description_ar: value["description_ar"] as String,
      description_fr: value["description_fr"] as String,
    );
  }

  static fromListMapMap(List<dynamic> value) {
    List<ReasonNoDeliverySale> _list = [];
    for (var item in value) {
      _list.add(ReasonNoDeliverySale.fromMap(item["reason"]));
    }
    return _list;
  }

  String getDescription(String locale) {
    switch (locale) {
      case "ar":
        return description_ar;
      case "fr":
        return description_fr;
      default:
        return description_fr;
    }
  }

  dynamic getIcon() {
    switch (code) {
      case "S.D":
        return Icon(
          Icons.category_outlined,
          color: Colors.green,
        );
      case "M.F":
        return Icon(
          Icons.browser_not_supported,
          color: Colors.orange,
        );
      case "G.A":
        return Icon(
          Icons.person_off_outlined,
          color: Colors.red,
        );
      case "M.O":
        return Icon(
          Icons.back_hand_outlined,
          color: Colors.blue,
        );
      case "N.C":
        return Icon(
          Icons.money_off,
          color: Colors.red,
        );
      default:
    }
  }
}
