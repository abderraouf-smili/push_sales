class StatsOrder {
  final String state;
  final int count;
  StatsOrder({required this.state, required this.count});

  static StatsOrder fromMap(Map<String, dynamic> value) {
    return StatsOrder(
      state: value["state"],
      count: value["total"] == null ? 0:int.parse(value["total"].toString()),
    );
  }
}
