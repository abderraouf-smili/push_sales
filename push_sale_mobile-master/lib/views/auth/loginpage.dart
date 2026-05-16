import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/views/auth/checklogin.dart';
import 'package:push_sale/views/auth/passwordforgetpage.dart';
import 'package:push_sale/views/auth/signuppage.dart';

class LoginPage extends StatelessWidget {
  TextEditingController mailController = TextEditingController();
  AuthentificationController authController =
      Get.put(AuthentificationController());
  bool showPassword = false;
  PageController loginPageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    mailController.text = Get.arguments != null ? Get.arguments["mail"] : "";
    return SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                //logo
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Image.asset(
                      "assets/images/icon_transp.png",
                      width: 160,
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: PageView(
                      controller: loginPageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Column(
                          children: [
                            Container(
                              child: Form(
                                key: authController.keyFormLogin,
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "login".tr,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontFamily: "kodchasan",
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("login_text".tr,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: "kodchasan",
                                              color: Color.fromARGB(
                                                  255, 121, 121, 121))),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      controller: mailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) => value!.length == 0
                                          ? "mailempty".tr
                                          : EmailValidator.validate(value)
                                              ? null
                                              : "wrongemailadress".tr,
                                      decoration: InputDecoration(
                                        fillColor: Colors.red,
                                        prefixIcon: Icon(Icons.mail),
                                        hintText: "example@softstarter.dz",
                                      ),
                                      onSaved: (value) {
                                        authController.email = value;
                                      },
                                    ),
                                    Obx(
                                      () => TextFormField(
                                        obscureText:
                                            !authController.showPassword.value,
                                        validator: (value) => value!.length == 0
                                            ? "emptypassword".tr
                                            : value.length < 6
                                                ? "shortpassword".tr
                                                : null,
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              Icon(Icons.vpn_key_rounded),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              authController
                                                      .showPassword.value =
                                                  !authController
                                                      .showPassword.value;
                                            },
                                            icon: Icon(authController
                                                    .showPassword.value
                                                ? Icons.visibility_off
                                                : Icons.visibility),
                                          ),
                                          hintText: "*********",
                                        ),
                                        onSaved: (value) {
                                          authController.password = value;
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(() => ForgotPasswordPage());
                                          },
                                          child: Text(
                                            "password_forgot".tr,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                height: 60,
                                color: Color.fromARGB(255, 83, 177, 117),
                                child: Text(
                                  "login".tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                onPressed: () async {
                                  var sign =
                                      await authController.SubmitFormLogin();
                                  CheckLoginSign(sign);
                                },
                              ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "otherway".tr,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "kodchasan",
                                        color:
                                            Color.fromARGB(255, 121, 121, 121)),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 60, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          loginPageController.jumpToPage(1);
                                          Map<String, dynamic> sign =
                                              await authController
                                                  .SignInWithGoogle();
                                          CheckLoginSign(sign);
                                        },
                                        child: Image.asset(
                                          "assets/images/google.png",
                                          width: 60,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          loginPageController.jumpToPage(2);
                                          Map<String, dynamic> sign =
                                              await authController
                                                  .SignInWithFacebook();
                                          CheckLoginSign(sign);
                                        },
                                        child: Image.asset(
                                          "assets/images/facebook.png",
                                          width: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "not_yet_user".tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => SignupPage());
                                        },
                                        child: Text("signup".tr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          child: Image.asset("assets/images/google.gif"),
                        ),
                        Container(
                          child: Image.asset(
                            "assets/images/facebook-2.gif",
                          ),
                        )
                      ]),
                ),

                // Expanded(
                //   flex: 3,
                //   child: ,
                // ),
              ],
            ),
          ),
        ));
  }
}
