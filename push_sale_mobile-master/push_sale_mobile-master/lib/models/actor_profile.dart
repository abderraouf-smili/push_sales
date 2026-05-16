class ActorProfile {
  final int id;
  final String code;
  final String name;
  final String name_ar;
  final bool has_stock_mobile;
  ActorProfile({
    required this.id,
    required this.code,
    required this.name,
    required this.name_ar,
    required this.has_stock_mobile,
  });

  static ActorProfile fromMap(Map<String, dynamic> value) {
    return ActorProfile(
      id: value["id"],
      code: value["code"],
      name: value["name"],
      name_ar: value["name_ar"],
      has_stock_mobile: value["has_stock_mobile"] == 1,
    );
  }

  String getName(String lang) {
    switch (lang) {
      case "ar":
        return name_ar;
      default:
        return name;
    }
  }
}
