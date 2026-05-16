import 'package:push_sale/models/city.dart';
import 'package:push_sale/models/country.dart';
import 'package:push_sale/models/wilaya.dart';

class Address {
  final String id;
  final String street;
  final String commune;
  final String zipcode;
  final double latitude;
  final double longitude;
  final City city;
  final Wilaya wilaya;
  final Country? country;

  Address({
    required this.id,
    required this.street,
    required this.commune,
    required this.zipcode,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.wilaya,
    this.country,
  });

  static Address fromMap(Map<String, dynamic> value) {
    return Address(
      id: value["id"],
      street: value["street"] == null ? "" : value["street"],
      commune: value["commune"] == null ? "" : value["commune"],
      zipcode: value["zipcode"] == null ? "" : value["zipcode"],
      latitude: double.parse((value["latitude"] ?? "0").toString()),
      longitude: double.parse((value["longitude"] ?? "0").toString()),
      city: City.fromMap(value["city"]),
      wilaya: Wilaya.fromMap(value["state"]),
      country:
          value["country"] != null ? Country.fromMap(value["country"]) : null,
    );
  }
}
