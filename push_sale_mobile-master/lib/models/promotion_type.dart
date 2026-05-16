class PromotionType {
  final int id;
  final String description;
  final String type;
  PromotionType({
    required this.id,
    required this.description,
    required this.type,
  });
  static fromMap(Map<String, dynamic> value) {
    return PromotionType(
      id: int.parse(value["id"].toString()),
      description: value["description"],
      type: value["type"],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      "id": id,
      "description": description,
      "type": type
    };
    return ret;
  }
}
