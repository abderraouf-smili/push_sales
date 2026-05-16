import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/city.dart';
import 'package:push_sale/models/type_point_vente.dart';
import 'package:push_sale/const/globals.dart' as global;

class FilterController extends GetxController {
  var searchKeyTPV = GlobalKey<FormFieldState>();
  var searchKeyCity = GlobalKey<FormFieldState>();

  RxBool filter_button = false.obs;
  RxBool listTPVready = false.obs;
  RxBool cityready = false.obs;

  RxInt selectedTPV = 0.obs;
  RxInt selectedCity = 0.obs;
  //
  List<TypePointVente> listTPV = [];
  List<City> listCities = [];

  Future<void> getCities() async {
    cityready.value = false;
    listCities = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.cities,
    );
    if (response.status == "SUCCESS") {
      var states = response.data;
      for (Map<String, dynamic> state in states) {
        listCities.add(City.fromMap(state));
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

  @override
  void onInit() {
    getTypes();
    getCities();
    super.onInit();
  }
}
