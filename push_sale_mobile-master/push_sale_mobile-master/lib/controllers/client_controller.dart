// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/api/my_localisation.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/order.dart';
import 'package:push_sale/models/visit_day.dart';
import 'package:push_sale/models/wilaya.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:uuid/uuid.dart';

// ignore: duplicate_ignore
class ClientController extends GetxController {
  String tag;
  ClientController(this.tag);
  List<Order> current_orders = [];
  RxBool current_orders_ready = false.obs;
  RxInt weekday_changed = 0.obs;

  RxInt progressLevel = 0.obs;
  int totalLevel = 0;

  int? filter_typeId;
  int? filter_cityId;

  RxString stepSave = "".obs;
  RxInt page = 0.obs;
  RxBool ready = false.obs;
  RxBool wilayaReady = false.obs;
  RxBool hasNoGPS = true.obs;
  RxBool isButtonClicked = false.obs;

  List<Wilaya> wilaya = [];
  List<Client> clientsList = [];
  List<VisitDay> visit_days = [];
  String token = "";
  String filter = "";
  Client? client;
  int state_id = 0;

  GlobalKey<FormState> FormKey = GlobalKey<FormState>();

  RxBool GPS_ready = false.obs;
  RxBool GPS_loading = false.obs;

  // ignore: non_constant_identifier_names
  String? client_id;
  String? Name;
  String? Mobile;
  int? TypePVID;
  List<dynamic>? ImageClient;
  String? Country_Text;
  String? CountryName;
  String? Wilaya_Text;
  String? City_Text;
  String? Commune_Text;
  String? Street_Text;
  String? Zipcode_Text;

  double? Latitude;
  double? Longitude;

  RxBool visit_day_only = true.obs;

  Future<void> getClients() async {
    ready.value = false;
    clientsList = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.listClient,
    );
    if (response.status == "SUCCESS") {
      for (var element in response.data) {
        clientsList.add(Client.fromMap(element));
      }
    }
    ready.value = true;
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    Map<String, dynamic> add = {
      "country": placemarks.first.isoCountryCode,
      "country_name": placemarks.first.country,
      "state": placemarks.first.administrativeArea!
          .replaceAll("Wilaya de ", "")
          .replaceAll("Province", ""),
      "daira": placemarks.first.locality,
      "commune": placemarks.first.subLocality,
      "street": placemarks.first.thoroughfare,
      "zipcode": placemarks.first.postalCode,
    };

    // print(position);
    Wilaya_Text = add["state"];
    City_Text = add["daira"];
    Commune_Text = add["commune"];
    Street_Text = add["street"];
    Zipcode_Text = add["zipcode"];
    Country_Text = add["country"];
    CountryName = add["country_name"];
    Latitude = position.latitude;
    Longitude = position.longitude;

    GPS_ready.value = true;
    hasNoGPS.value = false;
    GPS_loading.value = false;
  }

  Future<Position> getLocation() async {
    GPS_loading.value = true;
    return await MyLocalisation.getMyLocation();
  }

  Future<ResponseHttpRequest> save() async {
    isButtonClicked.value = true;
    var formdata = FormKey.currentState;
    if (formdata!.validate()) {
      if (!hasNoGPS.value) {
        formdata.save();
        stepSave.value = "start";
        if (client == null) {
          // nouveau client
          Map<String, dynamic> data = {
            "id": client_id,
            "name": Name,
            "mobile": Mobile,
            "typepv_id": TypePVID,
            "latitude": Latitude,
            "longitude": Longitude,
            "wilaya": Wilaya_Text,
            "city": City_Text,
            "commune": Commune_Text,
            "street": Street_Text,
            "zipcode": Zipcode_Text,
            "country_code": Country_Text,
            "country_name": CountryName,
            "visit_days": visit_days.map((e) => e.toMap()).toList()
          };
          if (ImageClient != null && ImageClient!.isNotEmpty) {
            if (ImageClient!.first is Image) {
              // print("No modification on image");
              data["image"] = "-1";
            }
            if (ImageClient!.first is XFile) {
              // New Image to upload
              data["image"] =
                  base64Encode(File(ImageClient!.first.path).readAsBytesSync());
            }
          } // else no image for client, delete current if exists

          ResponseHttpRequest response = await CallApi.RequestHttp(
            global.createClient,
            data: data,
            onsend: (a, b) {
              progressLevel.value = a;
              totalLevel = b;
            },
          );

          if (response.status == "SUCCESS") {
            stepSave.value = "finished.success";
          } else {
            stepSave.value = "finished.error";
          }
          isButtonClicked.value = false;
          return response;
        } else {
          // update client
          Map<String, dynamic> data = {
            "id": client!.id,
            "address_id": client!.address!.id,
            "name": Name,
            "mobile": Mobile,
            "typepv_id": TypePVID,
            "latitude": Latitude,
            "longitude": Longitude,
            "wilaya": Wilaya_Text,
            "city": City_Text,
            "commune": Commune_Text,
            "street": Street_Text,
            "zipcode": Zipcode_Text,
            "country_code": Country_Text,
            "country_name": CountryName,
            "visit_days": visit_days.map((e) => e.toMap()).toList(),
          };
          if (ImageClient != null && ImageClient!.isNotEmpty) {
            if (ImageClient!.first is Image) {
              // print("No modification on image");
              data["image"] = "-1";
            }
            if (ImageClient!.first is XFile) {
              // New Image to upload
              data["image"] =
                  base64Encode(File(ImageClient!.first.path).readAsBytesSync());
            }
          } // else no image for client, delete current if exists
          ResponseHttpRequest response = await CallApi.RequestHttp(
            global.updateClient,
            data: data,
            onsend: (a, b) {
              progressLevel.value = a;
              totalLevel = b;
            },
          );
          if (response.status == "SUCCESS") {
            stepSave.value = "finished.success";
          } else {
            stepSave.value = "finished.error";
          }
          isButtonClicked.value = false;
          // stepSave.value = "finished.error";
          return response;
        }
      } else {
        print("Has No GPS");
      }
    } else {
      print("ERROR VALIDATE");
    }
    return ResponseHttpRequest(
      code: "403",
      status: "error",
      message: "Validation Error",
    );
  }

  generateId() {
    Uuid uuid = Uuid();
    client_id = uuid.v1();
  }

  Future<void> getCurrentOrders(String _client_id) async {
    current_orders_ready.value = false;
    current_orders = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(
        global.getCurrentOrders,
        data: {"client_id": _client_id});
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        current_orders.add(Order.fromMap(item));
      }
    } else {
      print(response.message);
    }
    current_orders_ready.value = true;
  }

  @override
  void onInit() async {
    if (tag == "get") {
      await getClients();
    }
    // TODO: implement onInit
    super.onInit();
  }
}
