import 'package:push_sale/models/actor.dart';

class StockLocation {
  final String id;
  final String name;
  final String code;
  final Actor? actor;
  StockLocation({
    required this.id,
    required this.name,
    required this.code,
    this.actor,
  });
}
