import 'package:flutter/material.dart';
import 'package:push_sale/models/actor.dart';
import 'package:push_sale/const/globals.dart' as global;

class TrackingOrder {
  final Actor actor;
  final String order_id;
  final String purchaseorder_id;
  final String state;
  final double? amount;
  final bool is_last;
  final DateTime date;
  final String? image;
  TrackingOrder({
    required this.actor,
    required this.order_id,
    required this.purchaseorder_id,
    required this.state,
    this.amount,
    required this.is_last,
    required this.date,
    this.image,
  });
  Icon getIcon() {
    switch (state) {
      case "new":
        return Icon(
          Icons.shopping_cart_outlined,
          color: Color.fromARGB(255, 208, 211, 41),
        );
      case "taken":
        return Icon(
          Icons.delivery_dining_sharp,
          color: Colors.orange,
        );

      case "taken_partial":
        return Icon(
          Icons.delivery_dining_sharp,
          color: Colors.orange,
        );
      case "in_way":
        return Icon(
          Icons.local_shipping_outlined,
          color: Colors.blue,
        );
      case "shipped":
        return Icon(
          Icons.child_friendly_outlined,
          color: Color.fromARGB(255, 239, 133, 253),
        );
      case "paid":
        return Icon(
          Icons.check_circle,
          color: Colors.green,
        );
      case "partially_paid":
        return Icon(
          Icons.local_pharmacy_outlined,
          color: Color.fromARGB(255, 73, 151, 145),
        );
      default:
        return Icon(Icons.radio_button_unchecked_rounded);
    }
  }

  static TrackingOrder fromMap(Map<String, dynamic> value) {
    return TrackingOrder(
      actor: Actor.fromMap(value["actor"]),
      order_id: value["order_id"],
      purchaseorder_id: value["purchaseorder_id"],
      state: value["state"],
      amount: value["amount"] != null
          ? double.parse(value["amount"].toString())
          : null,
      is_last: int.parse(value["is_last"].toString()) == 1,
      date: DateTime.parse(value["created_at"]),
      image: value["image"] != null ? global.urlAPI + value["image"] : null,
    );
  }

  static List<TrackingOrder> fromListMapToList(List<dynamic> value) {
    List<TrackingOrder> _list = [];
    for (var item in value) {
      _list.add(TrackingOrder.fromMap(item));
    }
    return _list;
  }

  String getDescription() {
    switch (state) {
      case "new":
        return "new_order_placed";

      case "taken":
        return "order_inpreparing";

      case "taken_partial":
        return "order_inpreparing";

      case "in_way":
        return "order_inway";

      case "shipped":
        return "order_delivered";

      case "paid":
        return "order_cashed";

      case "partially_paid":
        return "order_cashed_partially";

      default:
        return "??";
    }
  }
}
