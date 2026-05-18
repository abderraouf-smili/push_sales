import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/permissions.dart';
import 'package:push_sale/const/globals.dart' as global;

class PermissionsController extends GetxController {
  //
  List<Permissions> localPermissions = [];
  List<String> menus = [];
  List<String> legacyMenus = [];
  List<String> actions = [];
  RxString workspaceType = ''.obs;
  RxString actorType = ''.obs;
  RxBool PermissionLoaded = false.obs;

  void getInitialPermissions() async {
    PermissionLoaded.value = false;
    localPermissions = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.Permissions,
    );
    if (response.status == "SUCCESS") {
      final data = response.data ?? {};
      workspaceType.value = (data["workspace_type"] ?? '').toString();
      actorType.value = (data["type_actor"] ?? '').toString();
      menus = _stringList(data["menus"]);
      legacyMenus = _stringList(data["legacy_menus"]);
      actions = _stringList(data["actions"]);

      for (var item in data["permission"] ?? []) {
        localPermissions.add(Permissions.fromMap(item));
      }
      final isAdminLike = actorType.value == "admin" ||
          workspaceType.value == "superadmin" ||
          workspaceType.value == "distributeur";
      localPermissions.add(
        Permissions(
          id: -1,
          permission: "admin",
          value: isAdminLike,
        ),
      );
      PermissionLoaded.value = true;
    } else {
      print(response.message);
    }
  }

  bool hasAction(String action) => actions.contains(action);

  bool hasMenu(String menu) =>
      menus.contains(menu) || legacyMenus.contains(menu);

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  dynamic check(dynamic func, String function) {
    if (func != null) {
      Widget ret = const SizedBox.shrink();

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
