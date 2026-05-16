class Coupon {
  final String id;
  final String description;
  final String code;
  final bool is_pourcentage;
  final double discount;
  final int count;
  final DateTime start_date;
  final DateTime end_date;
  final double min_amount;
  final List<String> warehouse_ids;
  Coupon({
    required this.id,
    required this.description,
    required this.code,
    required this.is_pourcentage,
    required this.discount,
    required this.count,
    required this.start_date,
    required this.end_date,
    required this.min_amount,
    required this.warehouse_ids,
  });

  static Coupon fromMap(Map<String, dynamic> value) {
    return Coupon(
      id: value["id"],
      description: value["description"],
      code: value["code"],
      is_pourcentage: value["is_pourcentage"].toString() == "1" ? true : false,
      discount: double.parse(value["discount"].toString()),
      count: int.parse(value["count"].toString()),
      start_date: DateTime.parse(value["start_date"].toString()),
      end_date: DateTime.parse(value["end_date"].toString()),
      min_amount: double.parse(value["min_amount"].toString()),
      warehouse_ids: [] /* value["warehouse_ids"].toString() */,
    );
  }
}
