import 'package:push_sale/models/actor_profile.dart';
import 'package:push_sale/models/address.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/distributor.dart';

class Actor {
  final String id;
  final String firstname;
  final String lastname;
  final String mail;
  final String phone;
  final String image;
  final bool hasImage;
  final int rate;
  final ActorProfile? Profile;
  final Address? address;
  final Distributor? distributor;
  final Release? realisation;

  Actor({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.mail,
    required this.phone,
    required this.image,
    required this.hasImage,
    required this.rate,
    required this.Profile,
    required this.address,
    this.distributor,
    this.realisation,
  });

  static Actor fromMap(Map<String, dynamic> value) {
    return Actor(
        id: value["id"],
        firstname: value["firstname"],
        lastname: value["lastname"],
        mail: value["mail"],
        image:
            "${global.urlAPI}${value["image"] == "" || value["image"] == null ? "/storage/clients/no_image.jpg" : value["image"]}",
        hasImage: value["image"] != null && value["image"] != "",
        rate: int.parse(value["rate"].toString()),
        phone: value["phone"] ?? "",
        Profile: value["profile"] != null
            ? ActorProfile.fromMap(value["profile"])
            : null,
        address:
            value["address"] != null ? Address.fromMap(value["address"]) : null,
        distributor: value["distributor"] != null
            ? Distributor.fromMap(value["distributor"])
            : null,
        realisation: value["realisation"] != null
            ? Release.fromMap(value["realisation"])
            : null);
  }
}

class Release {
  final int orders_count;
  final double orders_amount;
  Release({
    required this.orders_count,
    required this.orders_amount,
  });

  static Release fromMap(Map<String, dynamic> value) {
    print(value);
    return Release(
      orders_count: int.parse(value["orders_count"].toString()),
      orders_amount: double.parse(value["orders_amount"].toString()),
    );
  }
}
