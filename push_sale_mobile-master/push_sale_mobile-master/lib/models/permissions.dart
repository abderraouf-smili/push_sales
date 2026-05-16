class Permissions {
  final int id;
  final String permission;
  final bool value;
  Permissions({
    required this.id,
    required this.permission,
    required this.value,
  });
  static fromMap(Map<String, dynamic> value) {
    return Permissions(
      id: int.parse(value["id"].toString()),
      permission: value["permission"],
      value: value["value"].toString() == "1" ? true : false,
    );
  }
}
