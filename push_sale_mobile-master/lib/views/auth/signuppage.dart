import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/views/auth/checklogin.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  AuthentificationController authController = Get.find();
  TextEditingController mailController = TextEditingController();
  final PageController _pageController = PageController();
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  "assets/images/icon_transp.png",
                  width: 160,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("signup".tr,
                        style: const TextStyle(
                            fontSize: 30,
                            fontFamily: "kodchasan",
                            fontWeight: FontWeight.bold)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("signup_text".tr,
                        style: const TextStyle(
                            fontSize: 12,
                            fontFamily: "kodchasan",
                            color: Color.fromARGB(255, 121, 121, 121))),
                  )
                ],
              ),
            ),
            SizedBox(
              height: Get.height * 4 / 7,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Form(
                            key: authController.keyFormCreate,
                            child: Column(
                              children: [
                                TextFormField(
                                  // controller: mailController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    hintText: "Benlemoufak Ahmed Reda",
                                  ),
                                  validator: (value) => value!.length <= 5
                                      ? "fullname_length_error".tr
                                      : null,
                                  onSaved: (value) {
                                    authController.name = value;
                                  },
                                ),
                                TextFormField(
                                  controller: mailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value!.isEmpty
                                      ? "mailempty".tr
                                      : EmailValidator.validate(value)
                                          ? null
                                          : "wrongemailadress".tr,
                                  onSaved: (value) {
                                    authController.email = value;
                                  },
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.mail),
                                    hintText: "a.beloumafek@softstarter.dz",
                                  ),
                                ),
                                TextFormField(
                                  obscureText: !showPassword,
                                  validator: (value) => value!.isEmpty
                                      ? "emptypassword".tr
                                      : value.length < 6
                                          ? "shortpassword".tr
                                          : null,
                                  onSaved: (value) {
                                    authController.password = value;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.key),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        showPassword = !showPassword;
                                        setState(() {});
                                      },
                                      icon: Icon(showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                    ),
                                    hintText: "*********",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: MaterialButton(
                              minWidth: double.infinity,
                              height: 60,
                              color: const Color.fromARGB(255, 83, 177, 117),
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              onPressed: () async {
                                Map<String, dynamic> sign =
                                    await authController.SubmitFormCreate();
                                CheckLoginSign(sign);
                              },
                              child: Text(
                                "create".tr,
                                style: const TextStyle(color: Colors.white),
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: const Divider(
                            height: 10,
                            thickness: 1,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "otherway".tr,
                            style: const TextStyle(
                                fontSize: 12,
                                fontFamily: "kodchasan",
                                color: Color.fromARGB(255, 121, 121, 121)),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 20),
                          child: GetPlatform.isIOS
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
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
                                        _pageController.jumpToPage(2);
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
                                    Image.asset(
                                      "assets/images/apple-id.png",
                                      width: 60,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        _pageController.jumpToPage(1);
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
                                        _pageController.jumpToPage(2);
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
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Image.asset("assets/images/google.gif"),
                  ),
                  Container(
                    child: Image.asset(
                      "assets/images/facebook-2.gif",
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    ));
  }
}
