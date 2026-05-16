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

  static Map<String, dynamic> toMap(PushSaleUser _user) {
    Map<String, dynamic> u = {};
    u["fbuid"] = _user.id;
    u["email"] = _user.mail;
    u["name"] = _user.name;
    u["phone"] = _user.phone;
    u["device_id"] = _user.device_id;
    u["password"] = _user.password;
    u["fcmtoken"] = _user.fcmtoken;
    u["provider"] = _user.provider;
    return u;
  }
}
