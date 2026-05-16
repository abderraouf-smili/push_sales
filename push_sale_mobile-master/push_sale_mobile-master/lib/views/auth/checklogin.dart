import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

CheckLoginSign(Map<String, dynamic> result) {
  switch (result["response"]) {
    //{response: create, provider: email, hasactor: false, fullname: Smail Meziane, email: shini20fr@gmail.com}
    //{response: create, provider: gmail, hasactor: false, fullname: Smail Meziane, email: shini20fr@gmail.com}
    case "create":
      {
        if (result["provider"] == "email") {
          AwesomeDialog(
              btnOkOnPress: () {
                FocusScope.of(Get.context!).requestFocus(new FocusNode());
                Get.offAllNamed("/LoginPage",
                    arguments: {"mail": result["email"]});
              },
              context: Get.context!,
              dialogType: DialogType.success,
              title: "success".tr,
              desc: "registred.email".tr)
            ..show();
        } else {
          AwesomeDialog(
              btnOkOnPress: () {
                Get.offAllNamed("/SettingsProfilePage");
              },
              context: Get.context!,
              dialogType: DialogType.success,
              title: "success".tr,
              desc: "registred.social".tr)
            ..show();
        }
      }
      break;

    //{response: logged, provider: gmail, hasactor: false, fullname: Smail Meziane, email: shini20fr@gmail.com}
    case 'logged':
      {
        if (result["hasactor"]) {
          Get.offAllNamed("/HomePage");
        } else {
          Get.offAllNamed("/SettingsProfilePage");
        }
      }
      break;

    //{response: error, code: wrong-password, message: Password does not matched}
    case 'error':
      {
        switch (result["code"]) {
          case "wrong-password":
            {
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.error,
                  title: "error".tr,
                  desc: "wrongpassword".tr)
                ..show();
            }
            break;

          case "email-not-found":
            {
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.warning,
                  title: "error".tr,
                  desc: "nouserfound".tr)
                ..show();
            }
            break;

          case "email-in-use":
            {
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.warning,
                  title: "error".tr,
                  desc: "email.used".tr)
                ..show();
            }
            break;
          case "user-disabled":
            {
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.error,
                  title: "error".tr,
                  desc: "userdisabled".tr)
                ..show();
            }
            break;

          case "unknown-error":
            {
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.error,
                  title: "error".tr,
                  desc: "unknown.error".tr)
                ..show();
            }
            break;

          case "selection-account-error":
            {
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.error,
                  title: "error".tr,
                  desc: "selection.error".tr)
                ..show();
            }
            break;
          case "mail-not-verified":
            {
              print("${result["code"]}");
              AwesomeDialog(
                  btnOkOnPress: () {},
                  context: Get.context!,
                  dialogType: DialogType.error,
                  title: "error".tr,
                  desc: "mail.not.verified".tr)
                ..show();
            }
            break;
        }
      }
      break;
  }
}
