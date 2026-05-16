// ignore_for_file: empty_constructor_bodies, non_constant_identifier_names

import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/orderitem.dart';
import 'package:push_sale/models/purchase_order.dart';
import 'package:push_sale/models/tracking_order.dart';

class Order {
  final String id;
  String? actor_id;
  double? total_amount;
  double delivery_amount;
  final String client_id;
  final DateTime order_date;
  String code;
  final DateTime planned_delivery_date;
  DateTime? delivery_date;
  final String state;
  final List<Orderitem> orderitems;
  Client? client;
  List<TrackingOrder>? tracking;
  List<PurchaseOrder>? purchase_orders;
  Order(
      {required this.id,
      this.actor_id,
      this.code = "",
      this.total_amount,
      this.delivery_amount = 0,
      required this.client_id,
      required this.order_date,
      required this.planned_delivery_date,
      required this.delivery_date,
      required this.state,
      required this.orderitems,
      this.client,
      this.tracking,
      this.purchase_orders});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["client_id"] = client_id;
    ret["order_date"] = order_date.toString();
    ret["planned_delivery_date"] = planned_delivery_date.toString();
    ret["state"] = state;
    ret["orderitems"] = orderitems.map((e) => e.toMap()).toList();
    return ret;
  }

  static Order fromMap(Map<String, dynamic> value) {
    return Order(
      id: value["id"],
      client_id: value["client_id"],
      total_amount: double.parse(value["total_amount"].toString()),
      delivery_amount: value["purchase_orders_sum_total_amount"] != null
          ? double.parse(value["purchase_orders_sum_total_amount"].toString()) -
              double.parse(value["purchase_orders_sum_residual"].toString())
          : 0,
      code: value["code"],
      order_date: DateTime.parse(value["order_date"]),
      planned_delivery_date: DateTime.parse(value["planned_delivery_date"]),
      delivery_date: value["delivery_date"] != null
          ? DateTime.parse(value["delivery_date"])
          : null,
      state: value["state"],
      orderitems: Orderitem.fromListMapToList(value["orderitem"] ?? []),
      client: value["client"] != null ? Client.fromMap(value["client"]) : null,
      tracking: value["tracking"] != null
          ? TrackingOrder.fromListMapToList(value["tracking"])
          : null,
    );
  }

  static Order fromMapStatus(Map<String, dynamic> value) {
    return Order(
        id: value["id"],
        client_id: value["client_id"],
        total_amount: double.parse(value["total_amount"].toString()),
        delivery_amount: value["purchase_orders_sum_total_amount"] != null
            ? double.parse(
                    value["purchase_orders_sum_total_amount"].toString()) -
                double.parse(value["purchase_orders_sum_residual"].toString())
            : 0,
        code: value["code"],
        order_date: DateTime.parse(value["order_date"]),
        planned_delivery_date: DateTime.parse(value["planned_delivery_date"]),
        delivery_date: value["delivery_date"] != null
            ? DateTime.parse(value["delivery_date"])
            : null,
        state: value["state"],
        orderitems: Orderitem.fromListMapToList(value["orderitem"] ?? []),
        client:
            value["client"] != null ? Client.fromMap(value["client"]) : null,
        tracking: value["tracking"] != null
            ? TrackingOrder.fromListMapToList(value["tracking"])
            : null,
        purchase_orders:
            PurchaseOrder.fromListMapToList(value["purchase_orders"]));
  }
}
