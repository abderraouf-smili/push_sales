import 'package:intl/intl.dart';
import 'package:push_sale/models/actor.dart';
import 'package:push_sale/models/distributor.dart';
import 'package:push_sale/models/stock_location.dart';
import 'package:push_sale/models/stock_operation_items.dart';

class StockOperation {
  final String id;
  final String type;
  final String? code;
  final DateTime operation_date;
  final bool force_package;
  final List<String> purchase_ids;
  final String? state;
  final StockLocation? location;
  final Actor? actor;
  final String warehouse_id;
  final Distributor? distributor;
  final List<StockOperationItems> items;

  StockOperation({
    required this.id,
    required this.type,
    this.code,
    required this.operation_date,
    required this.force_package,
    required this.purchase_ids,
    this.state,
    this.location,
    this.actor,
    this.distributor,
    required this.warehouse_id,
    required this.items,
  });

  static StockOperation fromMap(Map<String, dynamic> value) {
    return StockOperation(
      id: value["id"],
      type: value["type"],
      operation_date: DateTime.parse(value["operation_date"]),
      force_package: value["force_package"].toString() == "0" ? false : true,
      code: value["code"],
      state: value["state"],
      purchase_ids: [],
      warehouse_id: value["warehouse_id"],
      items: StockOperationItems.fromListMapToList(value["items"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "warehouse_id": warehouse_id,
      "force_package": force_package,
      "purchase_ids": purchase_ids.map((e) => e).toList(),
      "operation_date": DateFormat('y/MM/dd HH:mm:ss').format(operation_date),
      "items": items.map((e) => e.toMap()).toList(),
    };
  }
}
