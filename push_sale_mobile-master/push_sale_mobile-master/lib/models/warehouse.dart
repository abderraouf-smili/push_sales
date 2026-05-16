import 'package:push_sale/models/address.dart';
import 'package:push_sale/models/item_stock.dart';

class Warehouse {
  final String id;
  final String name;
  final String code;
  final Address address;
  final double total;
  final List<ItemStock> items;

  Warehouse({
    required this.id,
    required this.name,
    required this.code,
    required this.total,
    required this.items,
    required this.address,
  });

  static Warehouse fromMap(Map<String, dynamic> value) {
    double _total = 0;
    List<ItemStock> itemlist = value["variants"] != null
        ? ItemStock.fromListMapToList(value["variants"])
        : [];
    itemlist.forEach(
      (element) => _total += element.quantity * element.stock_price,
    );
    return Warehouse(
      id: value["id"],
      name: value["name"],
      code: value["code"],
      total: _total,
      address: Address.fromMap(value["address"]),
      items: itemlist,
    );
  }
}
