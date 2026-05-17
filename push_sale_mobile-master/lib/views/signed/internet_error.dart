import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';

class InternetError extends StatelessWidget {
  const InternetError({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text("you.are.disconnected".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: "kodchasan",
                      fontSize: 30,
                      color: Color.fromARGB(255, 35, 109, 170))),
            ),
            Center(child: Image.asset("assets/images/error_500.png")),
            GestureDetector(
              onTap: () async {
                // print("=====================>");
                String page = await AuthentificationController.checkInternet();
                print(page);
                // print("=====================>");
                Get.offAllNamed(page);
              },
              child: Center(
                  child: Image.asset(
                "assets/images/refresh.png",
                width: 80,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
