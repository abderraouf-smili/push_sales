import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/auth/checklogin.dart';
import 'package:push_sale/widgets/common/app_button.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_text_field.dart';

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/icon_transp.png",
                      width: 118,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text("signup".tr, style: AppTextStyles.display),
                  const SizedBox(height: AppSpacing.xs),
                  Text("signup_text".tr, style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    child: Form(
                      key: authController.keyFormCreate,
                      child: Column(
                        children: [
                          AppTextField(
                            prefixIcon: Icons.person_outline_rounded,
                            hintText: "Benlemoufak Ahmed Reda",
                            validator: (value) => value!.length <= 5
                                ? "fullname_length_error".tr
                                : null,
                            onSaved: (value) {
                              authController.name = value;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: mailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                            hintText: "a.beloumafek@softstarter.dz",
                            validator: (value) => value!.isEmpty
                                ? "mailempty".tr
                                : EmailValidator.validate(value)
                                    ? null
                                    : "wrongemailadress".tr,
                            onSaved: (value) {
                              authController.email = value;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            obscureText: !showPassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            hintText: "*********",
                            suffixIcon: IconButton(
                              onPressed: () {
                                showPassword = !showPassword;
                                setState(() {});
                              },
                              icon: Icon(showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                            ),
                            validator: (value) => value!.isEmpty
                                ? "emptypassword".tr
                                : value.length < 6
                                    ? "shortpassword".tr
                                    : null,
                            onSaved: (value) {
                              authController.password = value;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            label: "create".tr,
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: () async {
                              Map<String, dynamic> sign =
                                  await authController.SubmitFormCreate();
                              CheckLoginSign(sign);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text("otherway".tr, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SignupSocialButton(
                        asset: "assets/images/google.png",
                        onTap: () async {
                          _pageController.jumpToPage(1);
                          Map<String, dynamic> sign =
                              await authController.SignInWithGoogle();
                          CheckLoginSign(sign);
                        },
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _SignupSocialButton(
                        asset: "assets/images/facebook.png",
                        onTap: () async {
                          _pageController.jumpToPage(2);
                          Map<String, dynamic> sign =
                              await authController.SignInWithFacebook();
                          CheckLoginSign(sign);
                        },
                      ),
                      if (GetPlatform.isIOS) ...[
                        const SizedBox(width: AppSpacing.lg),
                        Image.asset("assets/images/apple-id.png", width: 52),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Image.asset("assets/images/google.gif"),
            ),
            SizedBox(
              width: double.infinity,
              child: Image.asset("assets/images/facebook-2.gif"),
            )
          ],
        ),
      ),
    );
  }
}

class _SignupSocialButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _SignupSocialButton({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Image.asset(asset, width: 34, height: 34),
    );
  }
}
