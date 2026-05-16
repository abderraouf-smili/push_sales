import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/authentification_controller.dart';
import 'package:push_sale/controllers/compte_menu_controller.dart';
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
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCVRFwJ9fko-vJ9VhYg6TWQ96xU1K7Rraw",
      appId: "1:908812739457:android:b40dbd59692694c9d77e80",
      messagingSenderId: "908812739457",
      projectId: "pushsale-2ed49",
      storageBucket: "pushsale-2ed49.firebasestorage.app",
    ),
  );
  String initialPage = await AuthentificationController.checkInternet();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.top]);
  runApp(PushSaleApp(initialPage));
}

void testDomainAccess() async {
  Dio dio = Dio();

  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  var response =
      await dio.post("https://softstarter.dz/api/push_sale/public/api/login");

  print(response.data);
}

class PushSaleApp extends StatelessWidget {
  CompteMenuController compteController = Get.put(CompteMenuController());
  final String initialPage;

  PushSaleApp(this.initialPage);
  @override
  Widget build(BuildContext context) {
    List<String> supportedLocales = ['ar', 'en', 'fr'];
    return GetMaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // ajoutez vos délégués de localisation ici
      ],
      supportedLocales:
          supportedLocales.map((locale) => Locale(locale)).toList(),

      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   textTheme: TextTheme(
      //     bodySmall: TextStyle(
      //       fontFamily: "alata",
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //     ),
      //     labelSmall: TextStyle(
      //         color: Color.fromARGB(255, 83, 177, 117),
      //         fontWeight: FontWeight.bold,
      //         fontSize: 14),
      //   ),
      // ),
      // darkTheme: ThemeData.dark(),
      initialRoute: initialPage,

      getPages: [
        GetPage(name: "/", page: () => WelcomePage()),
        GetPage(name: "/LoginPage", page: () => LoginPage()),
        GetPage(
            name: "/SettingsProfilePage", page: () => SettingsProfilePage()),
        GetPage(name: "/ForgotPasswordPage", page: () => ForgotPasswordPage()),
        GetPage(name: "/SignupPage", page: () => SignupPage()),
        GetPage(
            name: "/HomePage",
            page: () => HomePage(
                  index: 0,
                )),
        GetPage(
            name: "/Clients",
            page: () => Clients(
                Get.arguments != null ? Get.arguments["client_id"] : "0")),
        GetPage(name: "/InternetError", page: () => InternetError()),
      ],
      locale: Locale(compteController.currentLangue.value),
      translations: SoftStarterLocale(),
      debugShowCheckedModeBanner: false,
      title: 'Push Sale',
      // home: WelcomePage(),
    );
  }
}
