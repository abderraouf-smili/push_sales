import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/actor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompteMenuController extends GetxController {
  RxBool validate_lastname = false.obs;
  RxBool validate_firstname = false.obs;
  RxBool validate_phone = false.obs;
  RxInt sendingState = 0.obs;

  /* for Preference langauge  */
  RxString currentLangue = "fr".obs;
  /***************/

  SharedPreferences? Prefs;
  String token = "";
  RxBool ready = false.obs;
  Actor? actor;

  List<dynamic>? ImageActor;

  String? lastName;
  String? firstName;
  String? phoneNumber;
  int? stateId;
  int? cityId;

  GlobalKey<FormState> FormKey = GlobalKey<FormState>();

  changeLanguage(String lang) {
    currentLangue.value = lang;
  }

  changeLocale() async {
    Get.updateLocale(Locale(currentLangue.value));
  }

  Future<void> getAccountInfo() async {
    ResponseHttpRequest response = await CallApi.RequestHttp(global.infoActor);

    if (response.status == "SUCCESS") {
      var element = response.data;
      actor = Actor.fromMap(element);
      lastName = actor!.lastname;
      firstName = actor!.firstname;
      phoneNumber = actor!.phone;
      currentLangue.value = "fr"; //    <============ To be changed in future
      ready.value = true;
    } else {
      print("=====> ERROR: " + response.status);
      print(response.message);
    }
  }

  Future<ResponseHttpRequest> save() async {
    var formdata = FormKey.currentState;
    if (formdata!.validate()) {
      formdata.save();
      var img;
      if (ImageActor != null && ImageActor!.isNotEmpty) {
        if (ImageActor!.first is Image) {
          // print("No modification on image");
          img = "-1";
        }
        if (ImageActor!.first is XFile) {
          // New Image to upload
          img = base64Encode(File(ImageActor!.first.path).readAsBytesSync());
        }
      }
      Map<String, dynamic> data = {
        "image": img,
        "lastname": lastName,
        "firstname": firstName,
        "phone": phoneNumber,
        "state_id": stateId,
        "city_id": cityId,
      };
      ResponseHttpRequest response =
          await CallApi.RequestHttp(global.updateActor, data: data);
      sendingState.value = 1;
      print(response.message);
      return response;
    } else {
      sendingState.value = -1;
      print("ERROR VALIDATE");
      return ResponseHttpRequest(
        code: "403",
        status: "error",
        message: "Validation Error",
      );
    }
  }

  @override
  void onInit() async {
    Prefs = await SharedPreferences.getInstance();
    if (Prefs!.getString("userToken") != null) {
      token = Prefs!.getString("userToken")!;
      await getAccountInfo();
      ready.value = true;
    }
    super.onInit();
  }
}
