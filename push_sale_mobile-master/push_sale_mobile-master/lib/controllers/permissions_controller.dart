import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/permissions.dart';
import 'package:push_sale/const/globals.dart' as global;

class PermissionsController extends GetxController {
  //
  List<Permissions> localPermissions = [];
  RxBool PermissionLoaded = false.obs;

  void getInitialPermissions() async {
    PermissionLoaded.value = false;
    localPermissions = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.Permissions);
    if (response.status == "SUCCESS") {
      for (var item in response.data["permission"]) {
        localPermissions.add(Permissions.fromMap(item));
      }
      localPermissions.add(
        Permissions(
            id: -1,
            permission: "admin",
            value: response.data["type_actor"] == "admin"),
      );
      PermissionLoaded.value = true;
    } else {
      print(response.message);
    }
  }

  dynamic check(dynamic? func, String function) {
    if (func != null) {
      Widget ret = SizedBox.shrink();

      if (localPermissions
              .where((element) => element.permission == function)
              .isNotEmpty &&
          localPermissions
              .where((element) => element.permission == function)
              .first
              .value) {
        return func;
      }
      return ret;
    } else {
      if (localPermissions
              .where((element) => element.permission == function)
              .isNotEmpty &&
          localPermissions
              .where((element) => element.permission == function)
              .first
              .value) {
        return true;
      }
      return false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getInitialPermissions();
    super.onInit();
  }
}
