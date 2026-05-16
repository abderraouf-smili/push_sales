class Country {
  final int id;
  final String name;
  final String code;
  Country({
    required this.id,
    required this.name,
    required this.code,
  });

  static Country fromMap(Map<String, dynamic> value) {
    return Country(
      id: value["id"],
      name: value["name"],
      code: value["code"],
    );
  }
}
