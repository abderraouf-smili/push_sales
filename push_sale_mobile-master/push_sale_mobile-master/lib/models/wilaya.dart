class Wilaya {
  final int id;
  final String code;
  final String name;
  final String name_ar;
  Wilaya({
    required this.id,
    required this.code,
    required this.name,
    required this.name_ar,
  });

  static Wilaya fromMap(Map<String, dynamic> value) {
    return Wilaya(
      id: value["id"],
      code: value["code"],
      name: value["name"],
      name_ar: value["name_ar"],
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
