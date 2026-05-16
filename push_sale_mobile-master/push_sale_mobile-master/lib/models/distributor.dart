import 'package:push_sale/models/address.dart';
import 'package:push_sale/models/warehouse.dart';

class Distributor {
  final String id;
  final String name;
  final String code;
  // final Address address;

  List<Warehouse>? warehouses;

  Distributor({
    required this.id,
    required this.name,
    required this.code,
    // required this.address,
  });

  static Distributor fromMap(Map<String, dynamic> value) {
    return Distributor(
      id: value["id"],
      name: value["name"],
      code: value["code"],
      // address: Address.fromMap(value["address"]),
    );
  }
}
