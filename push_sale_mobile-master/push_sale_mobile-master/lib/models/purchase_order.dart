// ignore_for_file: empty_constructor_bodies, non_constant_identifier_names
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/purchase_orderitem.dart';
import 'package:push_sale/models/warehouse.dart';
import 'package:push_sale/const/globals.dart' as global;

class PurchaseOrder {
  final String id;
  final String warehouse_id;
  final String type;
  double total_amount;
  double? delivery_amount;
  double? residual;
  final DateTime purchase_date;
  final DateTime planned_delivery_date;
  String code;
  final String state;
  int? delivery_position;
  List<PurchaseOrderitem> orderitems;
  final Client? client;
  final Warehouse? warehouse;
  final double? cash;
  String? delivery_proof;
  DateTime? delivery_date;
  PurchaseOrder({
    required this.id,
    this.code = "",
    required this.type,
    required this.total_amount,
    this.delivery_amount,
    this.residual,
    required this.warehouse_id,
    required this.purchase_date,
    required this.state,
    this.delivery_position,
    required this.orderitems,
    required this.planned_delivery_date,
    this.client,
    this.warehouse,
    this.cash,
    this.delivery_proof,
    this.delivery_date,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["purchase_date"] = purchase_date.toString();
    ret["state"] = state;
    ret["total_amount"] = total_amount;
    ret["delivery_amount"] = delivery_amount;
    ret["warehouse_id"] = warehouse_id;
    ret["type"] = type;
    ret["orderitems"] = orderitems.map((e) => e.toMap()).toList();
    ret["delivery_proof"] = delivery_proof;
    return ret;
  }

  Map<String, dynamic> toDeliveryPositionMap() {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["delivery_position"] = delivery_position;
    return ret;
  }

  static PurchaseOrder fromMap(Map<String, dynamic> value) {
    return PurchaseOrder(
      id: value["id"],
      total_amount: double.parse(value["total_amount"].toString()),
      delivery_amount: value["delivery_amount"] != null
          ? double.parse(value["delivery_amount"].toString())
          : 0.0,
      residual: value["residual"] != null
          ? double.parse(value["residual"].toString())
          : null,
      code: value["code"],
      type: value["type"],
      warehouse_id: value["warehouse_id"],
      purchase_date: DateTime.parse(value["purchase_date"]),
      state: value["state"],
      orderitems: PurchaseOrderitem.fromListMapToList(value["orderitem"] ?? []),
      client: value["client"] != null ? Client.fromMap(value["client"]) : null,
      warehouse: value["warehouse"] != null
          ? Warehouse.fromMap(value["warehouse"])
          : null,
      cash: value["cash_sum_debit"] != null
          ? double.parse(value["cash_sum_debit"].toString())
          : null,
      delivery_proof: value["delivery_proof"] != null
          ? global.urlAPI + value["delivery_proof"]["image"]
          : null,
      delivery_date: value["delivery_date"] != null
          ? DateTime.parse(value["delivery_date"])
          : null,
      planned_delivery_date: DateTime.parse(value["planned_delivery_date"]),
    );
  }

  static fromListMapToList(List<dynamic> value) {
    List<PurchaseOrder> _list = [];
    for (var item in value) {
      _list.add(PurchaseOrder.fromMap(item));
    }
    return _list;
  }

  recalculateAmount() {
    double _amount = 0.0;
    if (state == "shipped" || state == "paid") {
      orderitems.forEach((element) {
        _amount += element.confirmed_quantity! * element.price;
      });
      total_amount = _amount;
    }
  }
}
