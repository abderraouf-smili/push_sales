import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/coupon.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:uuid/uuid.dart';

class CouponController extends GetxController {
  //
  GlobalKey<FormState>? CouponFormKey;
  RxBool loadList = false.obs;
  List<Coupon> coupons = [];

  RxBool start_date_selected = false.obs;
  RxBool end_date_selected = false.obs;

  DateTime? start_date;
  DateTime? end_date;

  int? coupon_count;
  int? coupon_discount;
  String? coupon_code;
  double? coupon_minimum;
  String? coupon_description;
  String? coupon_id;
  String? sendMode;
  bool coupon_is_pourcentage = true;

  RxString send = "new".obs;

  setStartDate(DateTime date) {
    start_date_selected.value = false;
    start_date = date;
    start_date_selected.value = true;
  }

  setEndDate(DateTime date) {
    end_date_selected.value = false;
    end_date = date;
    end_date_selected.value = true;
  }

  Future<void> getCouponns() async {
    loadList.value = false;
    coupons = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.CouponsList);
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        coupons.add(Coupon.fromMap(item));
      }
      loadList.value = true;
    } else {
      print(response.message);
    }
  }

  Future<dynamic> save() async {
    //
    var formdata = CouponFormKey!.currentState;
    if (formdata!.validate()) {
      formdata.save();
      send.value = "sent";
      return await sendAPI();
    }
    send.value = "error";
    return "validation error";
  }

  Future<dynamic> sendAPI() async {
    if (coupon_id == null) {
      coupon_id = generateId();
    }
    Map<String, dynamic> data = {
      "id": coupon_id,
      "description": coupon_description,
      "code": coupon_code,
      "is_pourcentage": coupon_is_pourcentage,
      "discount": coupon_discount,
      "count": coupon_count,
      "min_amount": coupon_minimum,
      "start_date": DateFormat("y/MM/dd").format(start_date!),
      "end_date": DateFormat("y/MM/dd").format(end_date!),
      "operation": sendMode,
    };
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.CreateCoupon, data: data);
    if (response.status == "SUCCESS") {
      send.value = "success";
      return response.data;
    } else {
      send.value = "error";
      return response.message;
    }
  }

  String generateId() {
    Uuid uuid = Uuid();
    return uuid.v1();
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    await getCouponns();
    super.onInit();
  }
}
