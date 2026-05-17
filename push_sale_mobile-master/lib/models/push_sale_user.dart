class PushSaleUser {
  final String id;
  final String mail;
  final String phone;
  final String device_id;
  final String name;
  final String password;
  final String fcmtoken;
  final String provider;
  PushSaleUser({
    required this.id,
    required this.mail,
    required this.phone,
    required this.device_id,
    required this.name,
    required this.password,
    required this.fcmtoken,
    required this.provider,
  }) {
    //
  }

  static Map<String, dynamic> toMap(PushSaleUser user) {
    Map<String, dynamic> u = {};
    u["fbuid"] = user.id;
    u["email"] = user.mail;
    u["name"] = user.name;
    u["phone"] = user.phone;
    u["device_id"] = user.device_id;
    u["password"] = user.password;
    u["fcmtoken"] = user.fcmtoken;
    u["provider"] = user.provider;
    return u;
  }
}
