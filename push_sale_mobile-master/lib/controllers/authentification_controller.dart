import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
// import 'package:platform_device_id/platform_device_id.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/push_sale_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:crypto/crypto.dart';

class AuthentificationController extends GetxController {
  String? email;
  String? password;
  String? name;
  GlobalKey<FormState> keyFormLogin = GlobalKey<FormState>();
  GlobalKey<FormState> keyFormCreate = GlobalKey<FormState>();

  UserCredential? userCredential;

  RxBool showPassword = false.obs;

// function to submit button for login

  Future<Map<String, dynamic>> SubmitFormLogin() async {
    var formdata = keyFormLogin.currentState;
    if (formdata!.validate()) {
      formdata.save();
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      //on success
      return await SigninWithMail();
    }
    return {
      "response": "error",
      "code": "validator-error",
      "message": "Validator Error",
    };
  }

  static Future<bool> checkDomain() async {
    try {
      final result = await InternetAddress.lookup('softstarter.dz');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<String> checkInternet() async {
    String initialPage = "/";
    SharedPreferences Prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userinfo = {};
    if (Prefs.getString("userToken") != null &&
        Prefs.getString("userToken") != "") {
      if (await checkDomain()) {
        print("====> Lookup is OK");
        print("Call API");
        ResponseHttpRequest response =
            await CallApi.RequestHttp(global.isActorProfiled);
        if (response.status == "SUCCESS") {
          if (response.data["userinfo"]["name"].split(" ").length > 1) {
            global.lastName = response.data["userinfo"]["name"].split(" ")[0];
            String tmpFirstname = "";
            for (int i = 1;
                i < response.data["userinfo"]["name"].split(" ").length;
                i++) {
              tmpFirstname = "$tmpFirstname " +
                  response.data["userinfo"]["name"].split(" ")[i];
            }
            global.firstName = tmpFirstname;
          } else {
            global.lastName = response.data["fullname"];
            global.firstName = "";
          }
          global.deviceId = response.data["userinfo"]["device_id"];

          if (response.data["hasactor"] == 1) {
            initialPage = "/HomePage";
          } else {
            initialPage = "/SettingsProfilePage";
          }
        } else {
          initialPage = "/InternetError";
        }
      } else {
        initialPage = "/InternetError";
      }
    }
    return initialPage;
  }

  // function to submit button for create user
  Future<Map<String, dynamic>> SubmitFormCreate() async {
    var formdata = keyFormCreate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      //on success
      return await CreateUserWithMail();
    }
    return {
      "response": "error",
      "code": "validator-error",
      "message": "Validator Error",
    };
  }

  Future<Map<String, dynamic>> CreateUserWithMail() async {
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
      // Utilisateur s'est bien enregistré, envoyer le mail de confirmation
      final fcmToken = await FirebaseMessaging.instance.getToken();
      String? deviceId = ""; // await PlatformDeviceId.getDeviceId;
      PushSaleUser user = PushSaleUser(
        id: userCredential!.user!.uid,
        mail: email!,
        name: name!,
        phone: '-',
        device_id: deviceId,
        password: password!,
        fcmtoken: fcmToken!,
        provider: "email",
      );

      ResponseHttpRequest responseUser = await CallApi.RequestHttp(
        global.registerUser,
        data: PushSaleUser.toMap(user),
      );
      if (responseUser.status == "SUCCESS") {
        if (!userCredential!.user!.emailVerified) {
          await userCredential!.user!.sendEmailVerification();
        }
        return {
          "response": "create",
          "provider": "email",
          "hasactor": false,
          "name": user.name,
          "email": user.mail,
        };
      } else {
        return {
          "response": responseUser.status,
          "code": responseUser.code,
          "message": responseUser.message,
        };
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {
          "response": "error",
          "code": "weak-password",
          "message": "Password is weak",
        };
      } else if (e.code == 'email-already-in-use') {
        return {
          "response": "error",
          "code": "email-in-use",
          "message": "Email has already account",
        };
      }
    } catch (e) {
      return {
        "response": "error",
        "code": "unknown-error",
        "message": e.toString(),
      };
    }
    return {
      "response": "error",
      "code": "unknown-error",
      "message": "Unknown Error",
    };
  }

  Future<Map<String, dynamic>> SigninWithMail() async {
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      User firebaseUser = userCredential!.user!;
      if (!firebaseUser.emailVerified) {
        return {
          "response": "error",
          "code": "mail-not-verified",
          "Message": "Mail is not yet verified",
        };
      } else {
        // all ok for authentification go to Route Home in this section
        ResponseHttpRequest response = await CallApi.RequestHttp(
            global.checkUser,
            data: {"fbuid": userCredential!.user!.uid});
        if (response.status == "SUCCESS") {
          Map<String, dynamic> UserLogin = {
            "email": email!,
            "password": password!,
          };
          ResponseHttpRequest responseToken = await CallApi.RequestHttp(
            global.login,
            data: UserLogin,
          );

          if (responseToken.status == "SUCCESS") {
            String token = responseToken.data;
            SharedPreferences Prefs = await SharedPreferences.getInstance();
            await Prefs.setString("userToken", token);

            if (response.data["name"].split(" ").length > 1) {
              global.lastName = response.data["name"].split(" ")[0];
              for (int i = 1;
                  i < response.data["name"].split(" ").length;
                  i++) {
                global.firstName = "${global.firstName} " +
                    response.data["name"].split(" ")[i];
              }
            } else {
              global.lastName = response.data["name"];
              global.firstName = "";
            }
            return {
              "response": "logged",
              "provider": "gmail",
              "hasactor": response.data["hasactor"] == 1,
              "name": response.data["name"],
              "email": email,
            };
          } else {
            //error responseToken
            return {
              "response": responseToken.status,
              "code": responseToken.code,
              "message": responseToken.message,
            };
          }
        } else {
          // error response
          return {
            "response": response.status,
            "code": response.code,
            "message": response.message,
          };
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {
          "response": "error",
          "code": "email-not-found",
          "message": "Email has no account",
        };
      } else if (e.code == 'wrong-password') {
        return {
          "response": "error",
          "code": "wrong-password",
          "message": "Password does not matched",
        };
      } else if (e.code == "user-disabled") {
        return {
          "response": "error",
          "code": "user-disabled",
          "message": "User has been disabled",
        };
      }
    }
    return {
      "response": "error",
      "code": "unknown-error",
      "message": "Unknown Error",
    };
  }

  Future<Map<String, dynamic>> SignInWithGoogle() async {
    try {
      print("=====> entring login");
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ["email", "profile"],
      );
      // Trigger the authentication flow
      print("=====> Sign");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      // Obtain the auth details from the request
      print("=====> Auth");
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth!.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Se connecter à Firebase avec la crédential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      PushSaleUser user0 = PushSaleUser(
        id: user!.uid,
        mail: user.email!,
        name: user.displayName!,
        phone: '-',
        device_id: "",
        password: md5.convert(utf8.encode(user.uid)).toString(),
        fcmtoken: fcmToken ?? "",
        provider: "gmail",
      );

      // print("====================> FCM : " + fcmToken);
      // String token = "";

      ResponseHttpRequest response = await CallApi.RequestHttp(
        global.checkUser,
        data: {"fbuid": user.uid},
      );
      if (response.status == "SUCCESS") {
        print(response.data);
        // positive response internet is OK
        if (response.data != null) {
          // user exists, check if the same provider
          if (response.data["provider"] == "gmail") {
            // token = await PushSaleUser.getUserToken(_user.mail, _user.password);
            Map<String, dynamic> UserLogin = {
              "email": user0.mail,
              "password": user0.password,
            };
            ResponseHttpRequest responseToken = await CallApi.RequestHttp(
              global.login,
              data: UserLogin,
            );
            //
            if (responseToken.status == "SUCCESS") {
              SharedPreferences Prefs = await SharedPreferences.getInstance();
              await Prefs.setString("userToken", responseToken.data);

              if (response.data["name"].split(" ").length > 1) {
                global.lastName = response.data["name"].split(" ")[0];
                for (int i = 1;
                    i < response.data["name"].split(" ").length;
                    i++) {
                  global.firstName = "${global.firstName} " +
                      response.data["name"].split(" ")[i];
                }
              } else {
                global.lastName = response.data["name"];
                global.firstName = "";
              }
              return {
                "response": "logged",
                "provider": "gmail",
                "hasactor": response.data["hasactor"] == 1,
                "name": user0.name,
                "email": user0.mail,
              };
            } else {
              return {
                "response": responseToken.status,
                "code": responseToken.code,
                "message": responseToken.message,
              };
            }
          } else {
            // user exists, but with different provider, need to reconnect
            return {
              "response": "error",
              "code": "email-in-use",
              "message": "Gmail has already account",
            };
          }
        } else {
          // User does not exist, proceed to create it
          // var reponseUser = await _user.create();
          ResponseHttpRequest reponseUser = await CallApi.RequestHttp(
            global.registerUser,
            data: PushSaleUser.toMap(user0),
          );

          if (reponseUser.status == "SUCCESS") {
            // token = await PushSaleUser.getUserToken(_user.mail, _user.password);

            Map<String, dynamic> UserLogin = {
              "email": user0.mail,
              "password": user0.password,
            };
            ResponseHttpRequest responseToken = await CallApi.RequestHttp(
              global.login,
              data: UserLogin,
            );

            if (responseToken.status == "SUCCESS") {
              SharedPreferences Prefs = await SharedPreferences.getInstance();
              await Prefs.setString("userToken", responseToken.data);
              if (reponseUser.data["name"].split(" ").length > 1) {
                global.lastName = reponseUser.data["name"].split(" ")[0];
                String tmpFirstname = "";
                for (int i = 1;
                    i < reponseUser.data["name"].split(" ").length;
                    i++) {
                  tmpFirstname =
                      "$tmpFirstname " + reponseUser.data["name"].split(" ")[i];
                }
                global.firstName = tmpFirstname;
              } else {
                global.lastName = reponseUser.data["name"];
                global.firstName = "";
              }

              return {
                "response": "create",
                "provider": "gmail",
                "hasactor": false,
                "name": user0.name,
                "email": user0.mail,
              };
            } else {
              //error responseToken
              return {
                "response": responseToken.status,
                "code": responseToken.code,
                "message": responseToken.message,
              };
            }
          } else {
            return {
              //Error reponseUser
              "response": reponseUser.status,
              "code": reponseUser.code,
              "message": reponseUser.message,
            };
          }
        }
      }
      return {
        "reponse": "error",
        "code": "unknown-error",
        "message": "Internet error"
      };
    } catch (e) {
      return {
        "reponse": "error",
        "code": "internal-error",
        "message": e,
      };
    }
  }

  Future<Map<String, dynamic>> SignInWithFacebook() async {
    try {
      var con = await FacebookAuth.i.login();
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      FirebaseAuth auth = FirebaseAuth.instance;
      User user = auth.currentUser!;
      String? deviceId = ""; // await PlatformDeviceId.getDeviceId;
      final fcmToken = await FirebaseMessaging.instance.getToken();

      PushSaleUser user0 = PushSaleUser(
        id: user.uid,
        mail: userCredential!.user!.email!,
        name: userCredential!.user!.displayName!,
        phone: '-',
        device_id: deviceId,
        password: md5.convert(utf8.encode(user.uid)).toString(),
        fcmtoken: fcmToken!,
        provider: "facebook",
      );

      ResponseHttpRequest response = await CallApi.RequestHttp(
        global.checkUser,
        data: {"fbuid": user.uid},
      );

      if (response.status == "SUCCESS") {
        // positive response internet is OK
        if (response.data != null) {
          // user exists, check if the same provider
          if (response.data["provider"] == "facebook") {
            // token = await PushSaleUser.getUserToken(_user.mail, _user.password);
            Map<String, dynamic> UserLogin = {
              "email": user0.mail,
              "password": user0.password,
            };
            ResponseHttpRequest responseToken = await CallApi.RequestHttp(
              global.login,
              data: UserLogin,
            );
            if (responseToken.status == "SUCCESS") {
              SharedPreferences Prefs = await SharedPreferences.getInstance();
              await Prefs.setString("userToken", responseToken.data);

              if (response.data["name"].split(" ").length > 1) {
                global.lastName = response.data["name"].split(" ")[0];
                String tmpFirstname = "";
                for (int i = 1;
                    i < response.data["name"].split(" ").length;
                    i++) {
                  tmpFirstname =
                      "$tmpFirstname " + response.data["name"].split(" ")[i];
                }
                global.firstName = tmpFirstname;
              } else {
                global.lastName = response.data["name"];
                global.firstName = "";
              }

              return {
                "response": "logged",
                "provider": "facebook",
                "hasactor": response.data["hasactor"] == 1,
                "name": user0.name,
                "email": user0.mail,
              };
            } else {
              //error responseToken
              return {
                "response": responseToken.status,
                "code": responseToken.code,
                "message": responseToken.message,
              };
            }
          } else {
            // user exists, but with different provider, need to reconnect
            return {
              "response": "error",
              "code": "email-in-use",
              "message": "Email has already account",
            };
          }
        } else {
          // User does not exist, proceed to create it

          // var reponseUser = await _user.create();
          ResponseHttpRequest responseUser = await CallApi.RequestHttp(
            global.registerUser,
            data: PushSaleUser.toMap(user0),
          );

          if (responseUser.status == "SUCCESS") {
            Map<String, dynamic> UserLogin = {
              "email": user0.mail,
              "password": user0.password,
            };
            ResponseHttpRequest responseToken = await CallApi.RequestHttp(
              global.login,
              data: UserLogin,
            );
            if (responseToken.status == "SUCCESS") {
              SharedPreferences Prefs = await SharedPreferences.getInstance();
              await Prefs.setString("userToken", responseToken.data);
              global.lastName = user0.name.split(" ")[0];
              global.firstName = user0.name.split(" ").length > 1
                  ? user0.name.split(" ")[1]
                  : "";
              return {
                "response": "create",
                "provider": "facebook",
                "hasactor": false,
                "name": user0.name,
                "email": user0.mail,
              };
            } else {
              //error responseToken
              return {
                "response": responseToken.status,
                "code": responseToken.code,
                "message": responseToken.message,
              };
            }
          } else {
            return {
              "response": "error",
              "code": responseUser.code,
              "message": responseUser.message,
            };
          }
        }
      }
      return {
        "reponse": "error",
        "message": "Internet error",
      };
    } catch (e) {
      return {
        "reponse": "error",
        "code": "internal-error",
        "message": e,
      };
    }
  }
}
