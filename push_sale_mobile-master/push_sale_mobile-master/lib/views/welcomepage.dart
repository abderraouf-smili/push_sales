import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/loginpage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> background = [
      "assets/images/background-1.jpg",
      "assets/images/background-2.png",
      "assets/images/background-3.jpg",
      "assets/images/background-4.png",
    ];
    int index = Random().nextInt(background.length);
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                background[index],
              ),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 7,
                child: SizedBox.shrink(),
              ),
              Expanded(
                flex: 3,
                child: Image.asset(
                  "assets/images/icon_white.png",
                  width: 250,
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Text(
                      "welcome".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontFamily: "kodchasan",
                      ),
                    ),
                    Text(
                      "to_our_service".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontFamily: "kodchasan",
                      ),
                    ),
                    Text(
                      "slogan".tr,
                      style: TextStyle(
                        color: Color.fromARGB(255, 173, 173, 173),
                        fontSize: 16,
                        fontFamily: "kodchasan",
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: MaterialButton(
                    minWidth: double.infinity,
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    color: Color.fromARGB(255, 83, 177, 117),
                    onPressed: () {
                      Get.to(() => LoginPage());
                    },
                    child: Text(
                      "get_started".tr,
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
