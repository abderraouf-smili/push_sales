import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/auth/checklogin.dart';
import 'package:push_sale/views/auth/passwordforgetpage.dart';
import 'package:push_sale/views/auth/signuppage.dart';
import 'package:push_sale/widgets/common/app_button.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_text_field.dart';

class LoginPage extends StatelessWidget {
  TextEditingController mailController = TextEditingController();
  AuthentificationController authController =
      Get.put(AuthentificationController());
  bool showPassword = false;
  PageController loginPageController = PageController(initialPage: 0);

  LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    mailController.text = Get.arguments != null ? Get.arguments["mail"] : "";
    return SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: PageView(
            controller: loginPageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 116,
                        height: 116,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              blurRadius: 26,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset("assets/images/icon_transp.png"),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text("login".tr, style: AppTextStyles.display),
                    const SizedBox(height: AppSpacing.xs),
                    Text("login_text".tr, style: AppTextStyles.subtitle),
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: authController.keyFormLogin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: mailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                              hintText: "example@softstarter.dz",
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
                            Obx(
                              () => AppTextField(
                                obscureText: !authController.showPassword.value,
                                prefixIcon: Icons.lock_outline_rounded,
                                hintText: "*********",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    authController.showPassword.value =
                                        !authController.showPassword.value;
                                  },
                                  icon: Icon(authController.showPassword.value
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
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Get.to(() => ForgotPasswordPage());
                                },
                                child: Text("password_forgot".tr),
                              ),
                            ),
                            AppButton(
                              label: "login".tr,
                              icon: Icons.login_rounded,
                              onPressed: () async {
                                var sign =
                                    await authController.SubmitFormLogin();
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
                      children: [
                        Expanded(
                          child: _SocialLoginButton(
                            asset: "assets/images/google.png",
                            label: "Google",
                            onTap: () async {
                              loginPageController.jumpToPage(1);
                              Map<String, dynamic> sign =
                                  await authController.SignInWithGoogle();
                              CheckLoginSign(sign);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SocialLoginButton(
                            asset: "assets/images/facebook.png",
                            label: "Facebook",
                            onTap: () async {
                              loginPageController.jumpToPage(2);
                              Map<String, dynamic> sign =
                                  await authController.SignInWithFacebook();
                              CheckLoginSign(sign);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("not_yet_user".tr, style: AppTextStyles.body),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const SignupPage());
                          },
                          child: Text("signup".tr),
                        ),
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
        ));
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, width: 28, height: 28),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
