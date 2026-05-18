import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/config/app_config.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/controllers/compte_menu_controller.dart';
import 'package:push_sale/theme/app_theme.dart';
import 'package:push_sale/translate/local.dart';
import 'package:push_sale/views/auth/loginpage.dart';
import 'package:push_sale/views/auth/passwordforgetpage.dart';
import 'package:push_sale/views/auth/signuppage.dart';
import 'package:push_sale/views/signed/homepage.dart';
import 'package:push_sale/views/signed/internet_error.dart';
import 'package:push_sale/views/signed/menu/clients.dart';
import 'package:push_sale/views/signed/settings_profile_page.dart';
import 'package:push_sale/views/welcomepage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // testDomainAccess();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket,
      ),
    );
    await _configureFirebaseMessaging();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase non configure: $e');
    }
  }
  String initialPage = await AuthentificationController.checkInternet();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.top]);
  runApp(PushSaleApp(initialPage));
}

Future<void> _configureFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

class PushSaleApp extends StatelessWidget {
  final CompteMenuController compteController = Get.put(CompteMenuController());
  final String initialPage;

  PushSaleApp(this.initialPage, {super.key});
  @override
  Widget build(BuildContext context) {
    List<String> supportedLocales = ['ar', 'en', 'fr'];
    return GetMaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales:
          supportedLocales.map((locale) => Locale(locale)).toList(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: initialPage,

      getPages: [
        GetPage(name: "/", page: () => const WelcomePage()),
        GetPage(name: "/LoginPage", page: () => LoginPage()),
        GetPage(
            name: "/SettingsProfilePage", page: () => SettingsProfilePage()),
        GetPage(name: "/ForgotPasswordPage", page: () => ForgotPasswordPage()),
        GetPage(name: "/SignupPage", page: () => const SignupPage()),
        GetPage(
            name: "/HomePage",
            page: () => HomePage(
                  index: 0,
                )),
        GetPage(
            name: "/Clients",
            page: () => Clients(
                Get.arguments != null ? Get.arguments["client_id"] : "0")),
        GetPage(name: "/InternetError", page: () => const InternetError()),
      ],
      locale: Locale(compteController.currentLangue.value),
      translations: SoftStarterLocale(),
      debugShowCheckedModeBanner: false,
      title: 'Push Sale',
      // home: WelcomePage(),
    );
  }
}
