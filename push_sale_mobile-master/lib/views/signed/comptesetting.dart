import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/compte_menu_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/services/session_service.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/menu/commercial_menu.dart';
import 'package:push_sale/views/signed/menu/my_warehouses.dart';
import 'package:push_sale/views/signed/widgets/account/edit_personal_data.dart';
import 'package:push_sale/views/signed/widgets/account/message_chat.dart';
import 'package:push_sale/views/signed/widgets/settings/printer_config.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_list_tile.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';
import 'package:push_sale/const/globals.dart' as global;

class CompteSetting extends StatelessWidget {
  final CompteMenuController compteController =
      Get.isRegistered<CompteMenuController>()
          ? Get.find<CompteMenuController>()
          : Get.put(CompteMenuController());
  final PermissionsController perm = Get.find();

  CompteSetting({super.key});

  @override
  Widget build(BuildContext context) {
    if (compteController.actor == null) {
      compteController.ready.value = false;
      compteController.getAccountInfo();
    }
    List<dynamic> menu = [
      {
        "title": "Language".tr,
        "subtitle": "Language_system".tr,
        "icon": Icons.language,
        "color": const Color.fromARGB(255, 102, 28, 124),
        "onTap": () {
          showDialogueLanguages(context);
        }
      },
      {
        "title": "Notifications".tr,
        "subtitle": "notifications_alert".tr,
        "icon": Icons.notifications,
        "color": Colors.red,
        "onTap": () {
          showNotificationsSheet(context);
        }
      },
      {
        "title": "Messages".tr,
        "subtitle": "discussion_message".tr,
        "icon": Icons.message,
        "color": Colors.blue,
        "onTap": () {
          Get.to(() => const MessageChat());
        }
      },
      {
        "divider": true,
      },
      {
        "title": "commercial".tr,
        "subtitle": "commercial.sub".tr,
        "icon": Icons.groups_rounded,
        "color": const Color.fromARGB(255, 224, 89, 202),
        "onTap": () {
          Get.to(() => CommercialMenu());
        }
      },
      perm.check(null, "admin")
          ? {
              "title": "mywarehouses".tr,
              "subtitle": "your_warehouse".tr,
              "icon": Icons.store,
              "color": Colors.green,
              "onTap": () {
                Get.to(() => MyWarehouses());
              }
            }
          : null,
      perm.check(null, "admin")
          ? {
              "divider": true,
            }
          : null,
      {
        "title": "Theme".tr,
        "subtitle": "theme_system".tr,
        "icon": Icons.draw,
        "color": Colors.orange,
        "onTap": () {
          showThemeSheet(context);
        }
      },
      {
        "title": "printer.settings".tr,
        "subtitle": "bluetooth".tr,
        "icon": Icons.print,
        "color": const Color.fromARGB(255, 116, 116, 116),
        "onTap": () {
          ShowButtomSheetPrinterConfig(context: context);
        }
      },
      {
        "title": "about".tr,
        "subtitle": "current_version".tr,
        "icon": Icons.new_releases,
        "color": Colors.pink,
        "onTap": () {
          ShowButtomSheetVersion(context: context);
        }
      },
      {
        "title": "disconnect".tr,
        "subtitle": "disconnect_account".tr,
        "icon": Icons.exit_to_app,
        "color": Colors.black,
        "onTap": () async {
          await SessionService.logout();
        }
      }
    ];
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(children: [
          AppPageHeader(
            title: "settings".tr,
            subtitle: "current_version".tr,
            icon: Icons.manage_accounts_outlined,
          ),
          Obx(
            () => compteController.ready.value
                ? AppCard(
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(width: 1, color: AppColors.line),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    compteController.actor!.image)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => EditPerosnalData());
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "${compteController.actor!.firstname} ${compteController.actor!.lastname}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Edit personal details",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Get.to(() => EditPerosnalData());
                            },
                            icon: const Icon(Icons.arrow_forward_ios_outlined))
                      ],
                    ),
                  )
                : AppCard(
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(width: 1, color: AppColors.line),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Text(
                            "Edit personal details",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_outlined)
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                physics: const BouncingScrollPhysics(),
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  return menu[index] != null
                      ? menu[index]["divider"] != null
                          ? const Divider(
                              height: 10,
                              thickness: 1,
                              endIndent: 50,
                            )
                          : AppListTile(
                              onTap: menu[index]["onTap"],
                              icon: menu[index]["icon"],
                              color: menu[index]["color"],
                              title: menu[index]["title"],
                              subtitle: menu[index]["subtitle"],
                            )
                      : const SizedBox.shrink();
                }),
          )
        ]),
      ),
    );
  }

  void showNotificationsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notifications".tr, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  "Les alertes Push Sales utilisent Firebase cote serveur. Si aucune alerte ne s'affiche, verifier la cle serveur, les permissions Android et la connexion reseau.",
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppListTile(
                  icon: Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  title: "Etat",
                  subtitle: "Notifications applicatives disponibles",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showThemeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Theme".tr, style: AppTextStyles.title),
                ),
                const SizedBox(height: AppSpacing.md),
                AppListTile(
                  icon: Icons.brightness_auto_outlined,
                  color: AppColors.primary,
                  title: "Systeme",
                  subtitle: "Suivre le theme du telephone",
                  onTap: () {
                    Get.changeThemeMode(ThemeMode.system);
                    Get.back();
                  },
                ),
                AppListTile(
                  icon: Icons.light_mode_outlined,
                  color: Colors.orange,
                  title: "Clair",
                  subtitle: "Interface lumineuse",
                  onTap: () {
                    Get.changeThemeMode(ThemeMode.light);
                    Get.back();
                  },
                ),
                AppListTile(
                  icon: Icons.dark_mode_outlined,
                  color: AppColors.ink,
                  title: "Sombre",
                  subtitle: "Interface sombre",
                  onTap: () {
                    Get.changeThemeMode(ThemeMode.dark);
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDialogueLanguages(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 43, 87, 124),
            ),
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                'Language'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          content: SizedBox(
              width: Get.width,
              height: Get.height / 4,
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.only(top: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: (() {
                        compteController.changeLanguage("ar");
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: Get.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: compteController.currentLangue.value == "ar"
                              ? Colors.green.withOpacity(0.3)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("العربية"),
                            Image.asset(
                              "assets/images/lang_ar.png",
                              width: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (() {
                        compteController.changeLanguage("fr");
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: Get.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: compteController.currentLangue.value == "fr"
                              ? Colors.green.withOpacity(0.3)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Français"),
                            Image.asset(
                              "assets/images/lang_fr.png",
                              width: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (() {
                        compteController.changeLanguage("en");
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: Get.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: compteController.currentLangue.value == "en"
                              ? Colors.green.withOpacity(0.3)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("English"),
                            Image.asset(
                              "assets/images/lang_en.png",
                              width: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )),
          actions: <Widget>[
            MaterialButton(
              height: 50,
              minWidth: double.infinity,
              color: Colors.blue,
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await compteController.changeLocale();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void ShowButtomSheetVersion({required BuildContext context}) {
  showModalBottomSheet<void>(
      isScrollControlled: true,
      anchorPoint: const Offset(10, 1),
      backgroundColor: Colors.black.withOpacity(0.60),
      context: context,
      builder: (context) {
        return Container(
          height: Get.height / 3,
          width: double.infinity,
          color: const Color.fromARGB(255, 250, 254, 255),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: 40,
                  color: const Color.fromARGB(255, 230, 230, 230),
                  child: Center(
                      child: Text(
                    "about".tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ))),
              Image.asset(
                "assets/images/icon_transp.png",
                height: 120,
                width: 120,
              ),
              Container(
                child: Text(
                  "Version ${global.version}",
                  style: const TextStyle(
                      fontFamily: "alata",
                      fontSize: 20,
                      color: Color.fromARGB(255, 107, 107, 107)),
                ),
              ),
              Container(
                child: Text(
                  "build ${global.build} serv : ${global.urlAPI.replaceAll("https://", "").replaceAll("http://", "").replaceAll("/push_sale", "").replaceAll("/api", "").replaceAll("/public", "")}",
                  style: const TextStyle(
                    fontFamily: "alata",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                child: Text(global.team,
                    style: const TextStyle(
                      fontFamily: "kodchasan",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 15, 69, 114),
                    )),
              )
            ],
          ),
        );
      });
}
