# MAINTENANCE_HISTORY

## 2026-05-18 - Profil commercial dashboard, clients, tracking et produits

Objectif :
- Implementer le modele UI/UX commercial fourni : dashboard, clients, detail client, commandes/tracking et produits, avec donnees issues de l'API existante.

Resume technique :
- `StatsPage` detecte le workspace commercial via les permissions existantes et affiche un dashboard dedie connecte a `StatController`, `ClientController`, `OrderController` et `CompteMenuController`.
- `Clients` propose recherche, filtres commerciaux, bouton carte, cartes modernes et conservation du flux existant vers fiche client/creation commande.
- `FicheClient` garde les onglets et actions metier existants mais adopte une presentation dossier client plus claire.
- `OrdersToTrack` ajoute les filtres Nouveau/Livre/Restant et une progression visuelle sans modifier les statuts backend.
- `ProductMainPage` ajoute un detail produit commercial avec variantes/prix/promotions visibles en lecture, tout en conservant le flux commande existant dans `Products(client)`.
- Seeders Laravel de comptes et donnees demo relances pour assurer des donnees de test.

Commandes executees :
- `dart format lib\views\signed\menu\stats_page.dart lib\views\signed\menu\clients.dart lib\views\signed\widgets\clients\listinglist.dart lib\views\signed\widgets\clients\ficheclient.dart lib\views\signed\widgets\tracking\orders_to_track.dart lib\views\signed\widgets\products\product_main_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder`
- `C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder`
- `flutter run -d 10.212.134.2:35599 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Analyse non fatale OK.
- APK debug genere.
- Seeders comptes/donnees demo OK.
- Application installee et lancee sur SM A165F; appels initiaux API profil/acteur/permissions retournes en 200.
- Warnings stricts restants : historiques (`depend_on_referenced_packages`, deprecated APIs, style, logs), sans erreur bloquante dans ce lot.

## 2026-05-17 - Parcours livreur stock mobile, delivery et trajets

Objectif :
- Remplacer les pages peu pertinentes du role livreur par une navigation terrain claire : stock mobile, demandes de livraison et trajets.

Resume technique :
- HomePage detecte maintenant le workspace livreur via les permissions existantes et affiche Accueil, Stock, Delivery, Trajets, Profil.
- Ajout `DeliveryStockMobilePage` avec recherche, groupement par produit/etat/client, KPI stock camion/retours/anomalies et detail produit.
- Ajout `DeliveryRequestsPage` avec filtres multi-etats, compteurs et actions detail/bon reception sur les commandes `in_way`.
- Ajout `DeliveryRoutesPage` avec ordre de passage recommande et bouton d'optimisation reutilisant `OrderController.getOptimizedRoute()`.
- `MainDeliveryPage` utilise la nouvelle liste moderne sans changer `ShippingOrderDetail`.

Commandes executees :
- `dart format lib\views\signed\homepage.dart lib\views\signed\widgets\delivery\*.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `adb devices`

Resultats :
- Analyse non fatale OK.
- APK debug genere apres retry; un premier build a ete bloque par un verrou Windows temporaire sur `assets/images/firebase_api.php`.
- Aucun smartphone ADB detecte au moment du test, donc installation/scrcpy non executes dans ce lot.
- Warnings stricts restants : historiques (`depend_on_referenced_packages`, deprecated, style), sans erreur bloquante.

## 2026-05-17 - Navigation drawer, clients et tracking

Objectif :
- Rendre les pages clients/tracking utilisables et modernes, corriger le depot noir et assurer une deconnexion propre entre roles.

Resume technique :
- Ajout `SessionService.logout()` pour vider `SharedPreferences`, fermer Firebase Auth et supprimer les controllers GetX avant retour login.
- HomePage : ajout d'un drawer mobile bleu type sidebar avec navigation par role et bouton logout.
- Clients : refonte de la page principale avec recherche, filtres, etats loading/error/empty, affichage tous clients par defaut et bouton ajout lisible.
- Nouveau client : formulaire plus clair, scrollable, cartes visuelles, action GPS explicite, messages si GPS/type PV manquants.
- Tracking : refonte liste + detail avec KPI, cartes, timeline responsive et correction de navigation vers la bonne page du PageView.
- Depots : fond clair local et chargement unique pour eviter l'ecran noir/refresh en boucle.

Commandes executees :
- `dart format ...`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Analyse sans erreur bloquante.
- APK debug genere.
- Application reinstallee/lancee sur SM A165F.
- Warnings stricts restants : historiques, non traites dans ce lot.

## 2026-05-17 - UI depots/reception et liste de prix

Objectif :
- Corriger les ecrans signales sur smartphone : depots peu lisibles, actions cachees, bon de reception ancien, overflows et liste de prix en chargement infini.

Resume technique :
- `PricelistPage` converti en `StatefulWidget` pour charger les prix une seule fois apres le premier rendu.
- `PricelistController` rend le chargement finalisable dans tous les cas et expose un message d'erreur au lieu de laisser le spinner tourner.
- Modeles `PriceList` et `PriceListItem` durcis contre les valeurs nulles ou types variables du backend.
- `ShowDetailWarehouse` remplace le dock vertical par une barre d'actions claire et affiche les stocks en cartes.
- `ProductPurchaseList` remplace les hauteurs fixes par une structure responsive avec recherche, chips de mode et etats vides.
- `PurchaseItemsList` remplace le menu cache par des actions visibles : ajouter, enregistrer, imprimer, imprimante.
- Theme sombre legacy neutralise temporairement pour eviter les ecrans noirs tant que tous les vieux widgets ne sont pas theme-aware.

Commandes executees :
- `dart format ...`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Analyse Flutter sans erreur bloquante.
- APK debug genere.
- Application reinstallee et lancee sur SM A165F.
- Warnings stricts restants : `flutter analyze` strict retourne 770 issues historiques, principalement style/deprecations/`print`/imports packages non declares; aucune erreur bloquante avec `--no-fatal-infos --no-fatal-warnings`.

## 2026-05-17 - Correction login comptes de test

Objectif :
- Permettre aux comptes `@pushsales.local` documentes de fonctionner dans l'application debug sans creer manuellement les comptes Firebase.

Resume technique :
- Ajout d'un fallback dans `SigninWithMail()` uniquement pour les emails `@pushsales.local` en mode debug.
- Si Firebase Auth retourne compte introuvable/identifiants invalides pour ces comptes, l'app appelle `login` Laravel, sauvegarde le token Passport, puis appelle `isprofiled`.
- Documentation `README_DEV.md`, `TEST_ACCOUNTS.md` et `PROJECT_HISTORY.md` mise a jour.

Point important :
- Le seeder `TestUsersByRoleSeeder` doit etre execute sur la base Laravel reellement consommee par l'API mobile.
- Sur cette machine, `composer install` reste bloque car seul PHP 8.1.32 est disponible alors que le lock backend exige PHP >= 8.2.
- Verification reseau : `Test-NetConnection 192.168.1.20 -Port 8000` echoue avec connexion refusee; aucun processus PHP Laravel n'est visible localement au moment du test.
- L'application debug corrigee a ete reinstallee sur le telephone `10.212.134.2:38587`.
- Apres demarrage Laravel via PHP 8.3 : `Test-NetConnection 192.168.1.20 -Port 8000` OK.
- Seeder execute avec `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder` : OK.
- Correction environnement dev : `passport:keys --force` puis `key:generate --force`, `config:clear`, `cache:clear`.
- Verification API : les 4 comptes `@pushsales.local` retournent `SUCCESS` sur `/api/login`; `/api/isprofiled` retourne `hasactor=1` pour `admin.test@pushsales.local`.

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
# 2026-05-17 - Durcissement depots, notifications et warnings ciblés

Objectif :
- Continuer la finition sans changer la logique metier : depot/stock plus robuste, notifications plus sures, warnings importants reduits.

Fichiers principaux modifies :
- `push_sale-master/app/Http/Controllers/NotificationController.php`
- `push_sale_mobile-master/lib/controllers/client_controller.dart`
- `push_sale_mobile-master/lib/controllers/purchaseorder_controller.dart`
- `push_sale_mobile-master/lib/views/signed/menu/my_warehouses.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/warehouses/show_my_warehouses.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/warehouses/show_detail_warehouse.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/transfert/orders_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/transfert/stock_location_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/orders_to_ship.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/shipping_order_detail.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/commandes/orderitem_list.dart`

Commandes executees :
- `C:\tools\php83\php.exe -l app\Http\Controllers\NotificationController.php`
- `C:\tools\php83\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar install --no-interaction`
- `C:\tools\php83\php.exe artisan route:list --compact`
- `C:\tools\php83\php.exe artisan config:clear`
- `C:\tools\php83\php.exe artisan cache:clear`
- `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder`
- `C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder`
- `flutter clean`
- `flutter pub get`
- `flutter pub outdated`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug`
- `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- NotificationController syntax OK.
- Laravel routes/cache/seeders OK.
- APK debug regenere OK.
- Lancement SM A165F OK avec appels `isprofiled`, `actorinfo`, `permissions`.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` OK.
- `flutter analyze` strict : 802 issues restantes, contre 840 avant cette passe.

Points restants :
- Warnings historiques surtout `must_be_immutable`, noms non camelCase, `print`, `WillPopScope`, deprecations Flutter et dependances transitives.
- Tester notification push reelle avec `FCM_SERVER_KEY` configuree et cle Firebase restreinte.

Risque :
- Moyen-faible.

# 2026-05-17 - Finalisation demo Push Sales

Objectif :
- Finaliser une passe professionnelle non destructive : comptes test reels, donnees demo, configuration API par environnement, build APK et lancement device.

Fichiers principaux modifies :
- `push_sale_mobile-master/lib/config/app_config.dart`
- `push_sale_mobile-master/lib/config/app_environment.dart`
- `push_sale_mobile-master/lib/api/call_api.dart`
- `push_sale_mobile-master/lib/const/globals.dart`
- `push_sale_mobile-master/lib/main.dart`
- `push_sale_mobile-master/lib/controllers/position_controller.dart`
- `push_sale_mobile-master/android/app/build.gradle`
- `push_sale_mobile-master/android/app/src/main/AndroidManifest.xml`
- `push_sale_mobile-master/lib/core/responsive/*`
- `push_sale_mobile-master/lib/widgets/common/app_responsive_container.dart`
- `push_sale_mobile-master/lib/widgets/common/app_section_title.dart`
- `push_sale_mobile-master/lib/widgets/common/app_list_item.dart`
- `push_sale-master/database/seeders/DemoDataSeeder.php`
- Documentation racine.

Commandes executees :
- `C:\tools\php83\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar install --no-interaction`
- `C:\tools\php83\php.exe artisan route:list --compact`
- `C:\tools\php83\php.exe artisan config:clear`
- `C:\tools\php83\php.exe artisan cache:clear`
- `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder`
- `C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug`
- `flutter devices`
- `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Composer OK avec PHP 8.3 explicite.
- Routes API listees OK.
- Caches Laravel nettoyes OK.
- Seeders comptes et donnees demo OK.
- `/api/login` OK pour admin, commercial, livreur et depot.
- Endpoints demo verifies : produits, clients, depots, stock mobile, commandes a preparer/livrer.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` OK.
- `flutter analyze` strict : 840 issues historiques restantes.
- APK debug genere : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- Lancement sur SM A165F OK.

Points restants :
- Nettoyer `flutter analyze` strict par lots.
- Tester impression Bluetooth avec imprimante physique.
- Tester notifications Firebase avec configuration projet reelle.
- Restreindre/rotater les cles Google/Firebase exposees historiquement.

Risque :
- Moyen pour la partie demo DB, faible pour UI/config Flutter.
# 2026-05-17 - Correctifs UX visibles et overflow smartphone

Fichiers modifies :
- `push_sale_mobile-master/lib/views/signed/homepage.dart`
- `push_sale_mobile-master/lib/views/signed/menu/stats_page.dart`
- `push_sale_mobile-master/lib/views/signed/menu/favorite.dart`
- `push_sale_mobile-master/lib/views/signed/menu/cart.dart`
- `push_sale_mobile-master/lib/views/signed/comptesetting.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/main_delivery_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/orders_to_ship.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/shipping_order_detail.dart`
- `push_sale-master/app/Http/Controllers/Purchase/PurchaseOrderController.php`
- Documentation racine.

Commandes executees :
- `dart format ...`
- `C:\tools\php83\php.exe -l app\Http\Controllers\Purchase\PurchaseOrderController.php`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Analyse Flutter non bloquante OK.
- APK debug genere : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter analyze` strict : 791 issues historiques restantes.
- Device SM A165F detecte et APK lance apres un retry; le premier essai avait echoue sur un verrou Windows temporaire du fichier asset `firebase_api.php`.
- Syntaxe PHP OK.
- Overflows corriges sur les ecrans dashboard, parametres et livraison en supprimant les hauteurs fixes principales.
- Favoris/panier ne sont plus des pages under construction.
- Theme et notifications disposent d'une action utilisateur visible.
- Livraison ne casse plus quand la notification post-livraison n'a pas de destinataire associe.

Points restants :
- Valider visuellement sur scrcpy apres installation de ce nouvel APK.
- Continuer le nettoyage strict `flutter analyze` par modules.
- Tester Firebase/FCM avec une cle reelle restreinte.

Risque :
- Moyen-faible, changements UI/defensifs sans modification de logique metier.

# 2026-05-17 - Modernisation UI lot 2

Fichiers modifies :
- `push_sale_mobile-master/lib/main.dart`
- `push_sale_mobile-master/lib/theme/app_theme.dart`
- `push_sale_mobile-master/lib/controllers/message_chat_controller.dart`
- `push_sale_mobile-master/lib/views/signed/menu/clients.dart`
- `push_sale_mobile-master/lib/views/signed/menu/stats_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/account/message_chat.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/products/product_main_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/tracking/main_tracking_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/tracking/orders_to_track.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/transfert/main_transfer_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/warehouses/show_my_warehouses.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/warehouses/show_detail_warehouse.dart`

Commandes executees :
- `dart format ...`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Dashboard modernise avec bandeau KPI.
- Clients/produits/tracking/transfert corriges contre plusieurs overflows de hauteur.
- Depots modernises, detail depot avec actions flottantes au lieu du menu haut.
- Chat connecte aux endpoints existants.
- Theme sombre active via `darkTheme`.
- APK debug genere et lance sur SM A165F.
- `flutter analyze` strict : 788 issues historiques restantes.

Risque :
- Moyen pour les ecrans UI profonds; impact metier nul.

# 2026-05-17 - Modernisation module clients terrain

Fichiers modifies :
- `push_sale_mobile-master/lib/views/signed/menu/clients.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/clients/listinglist.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/clients/listingicon.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/clients/ficheclient.dart`

Commandes executees :
- `dart format push_sale_mobile-master/lib/views/signed/widgets/clients/ficheclient.dart push_sale_mobile-master/lib/views/signed/widgets/clients/listinglist.dart push_sale_mobile-master/lib/views/signed/widgets/clients/listingicon.dart push_sale_mobile-master/lib/views/signed/menu/clients.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Liste clients modernisee avec cartes, badges stock/visite/ventes et jours de visite.
- Ajout de filtres rapides par jour de visite sans masquer les clients par defaut.
- Fiche client remplacee par une page a onglets `Info`, `Commandes`, `Historique`.
- Dialogue de raison de non-vente rendu responsive et plus clair.
- APK debug genere, installe et lance sur SM A165F.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` OK; warnings stricts historiques toujours presents.

Risque :
- Moyen-faible; aucune route API, aucun JSON et aucune logique metier n'ont ete changes.

# 2026-05-17 - Audit UI global et correctifs dashboard runtime

Fichiers modifies :
- `UI_AUDIT.md`
- `push_sale_mobile-master/lib/controllers/stats_controller.dart`
- `push_sale_mobile-master/lib/views/signed/menu/stats_page.dart`
- `push_sale_mobile-master/lib/views/signed/homepage.dart`
- `PROJECT_HISTORY.md`
- `MAINTENANCE_HISTORY.md`
- `CHANGELOG.md`

Commandes executees :
- `rg --files lib/views lib/widgets`
- `rg "class .* extends (StatelessWidget|StatefulWidget|GetView|GetWidget)" lib/views lib/widgets`
- `dart format lib/controllers/stats_controller.dart lib/views/signed/menu/stats_page.dart lib/views/signed/homepage.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb -s 10.212.134.4:37055 logcat -d`

Resultats :
- Inventaire des pages Flutter principales documente dans `UI_AUDIT.md`.
- Crash dashboard livraison corrige en separant `statsReady` et `deliveryStatsReady`.
- Dashboard rendu tolerant aux valeurs nulles selon le role connecte.
- Navigation HomePage rendue plus stable en retirant `setState()` de `build()`.
- Aucun log runtime `Null check operator`, `Failed assertion` ou `EXCEPTION CAUGHT` detecte apres lancement.

Risque :
- Moyen-faible; correctifs UI/etat sans changement de logique metier.

# 2026-05-17 - Validation finale audit UI

Commandes executees :
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb -s 10.212.134.4:37055 logcat -d`
- `C:\tools\php83\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar install --no-interaction`
- `C:\tools\php83\php.exe artisan route:list --compact`
- `C:\tools\php83\php.exe artisan config:clear`
- `C:\tools\php83\php.exe artisan cache:clear`
- `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder`
- `C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder`

Resultats :
- `flutter analyze --no-fatal-infos --no-fatal-warnings` : OK.
- `flutter analyze` strict : KO non bloquant, 751 issues historiques restantes.
- APK debug : OK, `build/app/outputs/flutter-apk/app-debug.apk`.
- Device : SM A165F detecte sur `10.212.134.4:37055`.
- Lancement smartphone : OK, app installee et ouverte.
- Logcat apres lancement : aucune trace `Null check operator`, `Failed assertion`, `EXCEPTION CAUGHT`, `RenderFlex overflowed` ou `BOTTOM OVERFLOWED`.
- Composer : OK avec PHP 8.3 explicite; KO avec `composer` du PATH car il utilise PHP 8.1.
- Laravel routes/cache/config : OK.
- Seeders comptes et demo : OK.
- Login API comptes test : SUCCESS pour admin, commercial, livreur et depot; tokens non affiches.

Points restants :
- Poursuivre le nettoyage des 751 warnings stricts par modules.
- Valider visuellement sur scrcpy les flux profonds : commande, livraison/encaissement, reception depot, prix, chat et notifications FCM reelles.

# 2026-05-17 - Correctifs runtime GetX smartphone

Fichiers modifies :
- `push_sale_mobile-master/lib/views/signed/homepage.dart`
- `push_sale_mobile-master/lib/views/signed/comptesetting.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/clients/ficheclient.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/products/product_main_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/account/edit_personal_data.dart`

Commandes executees :
- `dart format ...`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `adb connect 10.212.134.5:37055`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter run -d 10.212.134.5:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb -s 10.212.134.5:37055 logcat -d`

Resultats :
- `CompteMenuController not found` corrige par reinjection defensive.
- `GetX improper use` fiche client corrige en observant explicitement `current_orders_ready`.
- Assertion Flutter de navigation reduite en retirant l'`AnimatedSwitcher` des pages principales.
- Chargement produits deplace hors de `build()` pour eviter les appels repetes.
- Logcat apres lancement : aucune trace des erreurs rouges signalees.

# 2026-05-17 - Correctif accueil GetX et PageController

Fichiers modifies :
- `push_sale_mobile-master/lib/views/signed/menu/stats_page.dart`
- `push_sale_mobile-master/lib/views/signed/customer/promotion_slide.dart`
- `push_sale_mobile-master/lib/views/signed/menu/clients.dart`

Commandes executees :
- `dart format lib\views\signed\menu\stats_page.dart lib\views\signed\menu\clients.dart lib\views\signed\customer\promotion_slide.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.5:41605`
- `flutter run -d 10.212.134.5:41605 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb -s 10.212.134.5:41605 shell am force-stop com.softstarter.pushsale`
- `adb -s 10.212.134.5:41605 logcat -c`
- `adb -s 10.212.134.5:41605 shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`
- `adb -s 10.212.134.5:41605 logcat -d`

Resultats :
- L'accueil observe maintenant des variables GetX dans les blocs `Obx` avant d'utiliser les donnees dashboard non Rx.
- Le slider promotion ne demarre plus de timers dans `build()` et verifie `PageController.hasClients`.
- Les filtres clients evitent `jumpToPage` quand le `PageView` n'est pas encore attache.
- APK debug genere et installe sur SM A165F.
- Logcat filtre apres redemarrage propre : aucune trace `improper use of a GetX`, `PageController is not attached`, `Failed assertion`, `Null check operator`, `RenderFlex overflowed`.

Risque :
- Faible; correctifs UI defensifs sans changement de logique metier.

# 2026-05-17 - GUI style maquettes et protections runtime

Fichiers modifies :
- `push_sale_mobile-master/lib/widgets/common/app_page_header.dart`
- `push_sale_mobile-master/lib/views/signed/homepage.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/products/product_main_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/credit/main_credit_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/tracking/main_tracking_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/tracking/orders_to_track.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/orders_to_ship.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/warehouses/show_detail_warehouse.dart`

Commandes executees :
- `dart format ...`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.5:44217`
- `flutter devices`

Resultats :
- Header commun rapproche des maquettes : logo Push Sales, actions hautes, titre grand format.
- Catalogue produits plus proche de la reference : recherche, categories, compteur, cartes modernes, badges.
- Page credits modernisee avec KPI et rendu clair.
- Protections `PageController.hasClients` ajoutees sur depot detail, tracking et livraison.
- Analyse no-fatal OK et APK debug genere.
- Lancement smartphone non effectue : `10.212.134.5:44217` ne repond pas a ADB et aucun device Android n'est liste par `flutter devices`.

Risque :
- Moyen-faible; UI et protections runtime sans changement de logique metier.

# 2026-05-17 - Espace livreur connecte aux donnees backend

Fichiers modifies :
- `push_sale_mobile-master/lib/controllers/order_controller.dart`
- `push_sale_mobile-master/lib/views/signed/menu/stats_page.dart`
- `push_sale_mobile-master/lib/views/signed/widgets/delivery/delivery_stock_mobile_page.dart`
- `push_sale-master/database/seeders/DemoDataSeeder.php`

Commandes executees :
- `dart format lib\controllers\order_controller.dart lib\views\signed\menu\stats_page.dart lib\views\signed\widgets\delivery\delivery_stock_mobile_page.dart`
- `php -l database\seeders\DemoDataSeeder.php`
- `php artisan db:seed --class=TestUsersByRoleSeeder`
- `php artisan db:seed --class=DemoDataSeeder`
- Verification API dev `login`, `currentstock`, `toshiporders`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.3:35079`
- `flutter devices`

Resultats :
- Dashboard livreur simplifie : un cadre principal + un cadre `Etat stock camion` calcule depuis les commandes backend.
- Delivery ne depend plus du succes GPS/maps pour afficher les demandes; les commandes sont marquees chargees avant la carte.
- Stock mobile recentre sur liste produits + detail + filtres, sans duplication de KPI.
- Donnees demo ajoutees pour tester commandes `in_way`, `shipped`, `paid`, retours et stock camion.
- APK debug genere avec succes.
- Installation smartphone non effectuee : `10.212.134.3:35079` ne repond pas et aucun device Android n'est visible dans `flutter devices`.

Risque :
- Moyen-faible; correction UI, robustesse de chargement et donnees demo sans changement de routes API ni logique metier.
