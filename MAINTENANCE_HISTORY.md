# MAINTENANCE_HISTORY

## 2026-05-17 - Modernisation UI/UX mobile et pack de validation

Objectif :
- Moderniser fortement l'interface mobile sans modifier la logique metier.
- Ajouter des composants communs, comptes de test et scenarios de validation par role.

Resume technique :
- Ajout du theme Flutter global dans `lib/theme`.
- Ajout de composants communs dans `lib/widgets/common`.
- Modernisation de Login, Signup, HomePage, Clients, Produits, Commandes, menus Compte/Commercial et InternetError.
- Ajout de confirmations pour creation commande, generation et confirmation de chargement.
- Reduction des logs API sensibles dans `CallApi`.
- Ajout de `TestUsersByRoleSeeder` pour dev/test.
- Ajout de `TEST_ACCOUNTS.md` et `TEST_SCENARIOS.md`.

Commandes executees :
- `dart format lib\theme lib\widgets\common ...`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug`
- `flutter devices`
- `flutter run -d 10.212.134.2:37143 --debug --no-resident`
- `php -l database\seeders\TestUsersByRoleSeeder.php`
- `composer install --no-interaction`

Resultats :
- Deux erreurs Dart existantes ont ete corrigees par initialisation/renommage local sans changement metier.
- `flutter pub get` : OK.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` : OK sans erreur bloquante; 856 issues historiques restent a nettoyer progressivement.
- `flutter build apk --debug` : OK, APK genere dans `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter devices` : smartphone detecte sur `10.212.134.2:37143`, Windows et Edge detectes.
- `flutter run -d 10.212.134.2:37143 --debug --no-resident` : OK, application installee/lancee sur SM A165F. Un avertissement de localisation `fr` a ete corrige dans `main.dart`, puis le lancement a ete confirme a nouveau.
- `php -l` du seeder : OK.
- `composer install --no-interaction` : bloque par PHP 8.1.32 alors que `composer.lock` demande PHP >= 8.2; commandes Artisan non executees.

Points a surveiller :
- Tester la navigation par permissions sur les 4 roles.
- Tester les actions critiques sur vraie base de dev.
- Tester impression Bluetooth avec imprimante reelle.

Prochaines etapes :
- Executer le seeder en dev apres `composer install`.
- Lancer les scenarios manuels.
- Continuer le nettoyage progressif de `flutter analyze`.

## 2026-05-17 - Correction compatibilite Flutter 3.38.9

Objectif :
- Corriger l'echec `flutter pub get` cause par le conflit entre `flutter_localizations`, `intl` et `flutter_form_builder`.
- Garder la logique metier, les ecrans, les endpoints API et les workflows existants.

Environnement :
- Flutter 3.38.9 stable.
- Dart 3.10.8.
- Android SDK 36 disponible.
- JDK utilise par Gradle : Eclipse Adoptium JDK 17 via `JAVA_HOME`.

Probleme initial :
- `flutter_localizations` impose `intl 0.20.2`.
- `flutter_form_builder ^9.3.0` depend de `intl ^0.19.0`.
- La resolution des packages Flutter echouait.

Dependances modifiees :
- `flutter_form_builder` : `^9.3.0` vers `^10.3.0+2`.
- `bluetooth_print` retire de `pubspec.yaml` car non importe par l'application et incompatible avec Flutter/Android recents.
- `pubspec.lock` regenere par `flutter pub get` et `flutter pub upgrade`.

Compatibilite Android :
- AGP : `8.2.2` vers `8.9.1`.
- Kotlin Gradle plugin : `1.9.22` vers `2.3.10`.
- Gradle wrapper : `8.3` vers `8.11.1`.
- NDK : `28.2.13676358`.
- Correction locale du plugin legacy `blue_thermal_printer` en lui declarant un `namespace` et `compileSdkVersion 36`.
- Suppression du chemin JDK local invalide dans `android/gradle.properties`.
- `minSdkVersion` migre par Flutter vers `flutter.minSdkVersion` (24), car Flutter 3.38.9 remplace automatiquement les valeurs inferieures a 24.

Securite :
- Ancien token Bearer commente supprime de `lib/api/call_api.dart`.
- Des cles Google/API sont encore presentes dans `lib/const/globals.dart`, `lib/main.dart`, `lib/controllers/position_controller.dart` et `android/app/src/main/AndroidManifest.xml`.
- Recommandation : rotation/restriction des cles exposees, puis externalisation via configuration d'environnement.

Commandes executees :
- `flutter --version`
- `dart --version`
- `flutter pub get`
- `flutter pub upgrade`
- `flutter clean`
- `flutter analyze`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter pub outdated`
- `flutter devices`
- `flutter build apk --debug`

Resultats :
- `flutter pub get` : OK.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` : OK, sans erreur bloquante.
- `flutter analyze` strict : echoue encore a cause de warnings/infos historiques, 2912 issues signalees.
- `flutter build apk --debug` : OK, APK genere dans `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter devices` : aucun smartphone ADB wireless detecte au moment du test; seuls Windows et Edge etaient visibles.

Problemes restants :
- Warnings/infos Dart historiques nombreux.
- Smartphone Android ADB wireless non connecte pendant la verification finale.
- Cles Google/API presentes dans le code.
- Le minSdk effectif est maintenant 24 a cause de la migration Flutter 3.38.9; verifier si des appareils Android API 23 ou moins devaient encore etre supportes.
- Des dependances majeures plus recentes existent, mais n'ont pas ete appliquees pour eviter une montee de version massive.

Points a surveiller :
- Impression Bluetooth avec `blue_thermal_printer` apres test sur appareil reel.
- Cartes Google, Firebase Auth, Firebase Messaging et permissions Android.
- Connectivite API vers `http://192.168.1.20:8000` sur smartphone.

Recommandations futures :
- Nettoyer `flutter analyze` par zones fonctionnelles.
- Centraliser la configuration API par environnement simple.
- Deplacer les cles Google/API hors code source et restreindre leurs usages cote consoles Google/Firebase.
- Mettre a jour les dependances majeures par petits lots avec tests manuels.
