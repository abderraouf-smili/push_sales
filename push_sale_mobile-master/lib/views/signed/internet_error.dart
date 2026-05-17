import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/widgets/common/app_button.dart';
import 'package:push_sale/widgets/common/app_error_state.dart';

class InternetError extends StatelessWidget {
  const InternetError({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: AppErrorState(
                  title: "you.are.disconnected".tr,
                  message:
                      "Verifiez la connexion reseau puis relancez la verification.",
                ),
              ),
              Image.asset("assets/images/error_500.png", height: 180),
              const SizedBox(height: 24),
              AppButton(
                label: "refresh".tr,
                icon: Icons.refresh_rounded,
                onPressed: () async {
                  String page =
                      await AuthentificationController.checkInternet();
                  Get.offAllNamed(page);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
