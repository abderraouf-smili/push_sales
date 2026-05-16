import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/actor_profile.dart';
import 'package:push_sale/models/city.dart';
import 'package:push_sale/models/type_point_vente.dart';
import 'package:push_sale/models/wilaya.dart';

class DropDownController extends GetxController {
  final String tag;
  final dropdownStateTPV = GlobalKey<FormFieldState>();
  final dropdownStateWilaya = GlobalKey<FormFieldState>();
  final dropdownStateCity = GlobalKey<FormFieldState>();
  final dropdownStateProfile = GlobalKey<FormFieldState>();
  DropDownController(this.tag);

  RxInt stateId = 0.obs;
  String token = "";
  RxBool wilayaready = false.obs;
  RxBool cityready = false.obs;
  RxBool listTPVready = false.obs;
  RxBool listAPready = false.obs;

  List<Wilaya> wilayat = [];
  List<City> dairat = [];
  List<TypePointVente> listTPV = [];
  List<ActorProfile> listAP = [];

  int? ActProID;
  int? WilayaID;
  int? DairaID;
  int? TpvID;

  int? initialTPV;
  int? initialWilaya;
  int? initialCity;
  int? initialAP;

  Future<void> getWilaya() async {
    wilayaready.value = false;
    wilayat = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(global.wilayas);
    if (response.status == "SUCCESS") {
      var states = response.data;

      // print(states.length);
      for (Map<String, dynamic> state in states) {
        wilayat.add(Wilaya.fromMap(state));
      }
    }
    wilayaready.value = true;
  }

  Future<void> getCities() async {
    dairat = [];
    cityready.value = false;

    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.cities,
      data: {"state_id": stateId.value},
    );
    if (response.status == "SUCCESS") {
      var states = response.data;

      // print(states.length);
      for (Map<String, dynamic> state in states) {
        dairat.add(City.fromMap(state));
      }
    }
    cityready.value = true;
  }

  Future<void> getTypes() async {
    listTPVready.value = false;
    listTPV = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.typePointVente);
    if (response.status == "SUCCESS") {
      for (var element in response.data) {
        listTPV.add(TypePointVente.fromMap(element));
      }
    }
    listTPVready.value = true;
  }

  Future<void> getActorProfiles() async {
    listAP = [];
    listAPready.value = false;
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.profileActor);
    if (response.status == "SUCCESS") {
      var states = response.data;
      for (Map<String, dynamic> state in states) {
        listAP.add(ActorProfile.fromMap(state));
      }
    }
    listAPready.value = true;
  }

  @override
  void onInit() async {
    if (tag == "settingProfile") {
      await getActorProfiles();
      await getWilaya();
    }

    if (tag == "clientEdition") {
      await getTypes();
      await getWilaya();
    }
    if (tag == "typePV") {
      await getTypes();
    }

    super.onInit();
  }

  @override
  void onReady() {
    if (tag == "typePV" && initialTPV != null) {
      dropdownStateTPV.currentState!.didChange(initialTPV);
    }
    super.onReady();
  }
}
