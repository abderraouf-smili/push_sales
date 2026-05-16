class TypePointVente {
  final int id;
  final String name;
  final String name_ar;
  TypePointVente({
    required this.id,
    required this.name,
    required this.name_ar,
  });
  static fromMap(Map<String, dynamic> value) {
    return TypePointVente(
      id: value["id"],
      name: value["name"],
      name_ar: value["name_ar"],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {"id": id, "name": name, "name_ar": name_ar};
    return ret;
  }

  String getName(String locale) {
    switch (locale) {
      case "ar":
        return name_ar;
      case "fr":
        return name;
      default:
        return name;
    }
  }
}
