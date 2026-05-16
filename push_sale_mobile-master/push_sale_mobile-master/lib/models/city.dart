class City {
  final int id;
  final String name;
  final String name_ar;
  City({
    required this.id,
    required this.name,
    required this.name_ar,
  });

  static City fromMap(Map<String, dynamic> value) {
    return City(
      id: int.parse(value["id"].toString()),
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
