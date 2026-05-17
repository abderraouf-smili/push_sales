import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingsProfileController extends GetxController {
  String? actor_id;
  RxBool ready = false.obs;
  RxBool imageReady = false.obs;
  SharedPreferences? Prefs;
  String token = "";
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  String image = "";

  String lastname = "";

  String firstname = "";

  int state_id = 0;
  int city_id = 0;
  int profile_id = 0;

  String street = "";

  String zipcode = "";

  Future<dynamic> submit() async {
    Map<String, dynamic> data = {
      "id": actor_id,
      "state_id": state_id,
      "city_id": city_id,
      "profile_id": profile_id,
      "firstname": firstname,
      "lastname": lastname,
      "street": street,
      "zipcode": zipcode,
      "country_id": 1,
      "image": image,
    };

    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.createActor,
      data: data,
    );
    return response;
  }

  Future<bool> SubmitFormActorCreate() async {
    var formdata = keyForm.currentState;
    if (formdata!.validate()) {
      formdata.save();
      var ret = await submit();
      if (ret.status == "SUCCESS") {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  void generateId() {
    Uuid uuid = const Uuid();
    actor_id = uuid.v1();
  }
}
