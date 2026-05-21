# MAINTENANCE_HISTORY

## 2026-05-21 - Hotfix chargement produits distributeur

Objectif :
- Debloquer l'onglet Produits du profil Distributeur qui affichait "Impossible de charger cette page".

Resume technique :
- Backend : correction du payload `/api/workspace/real` section `products`; le comptage des variants utilise maintenant `count($variants)` apres conversion du payload en tableau.
- Performance : les prix, stocks totaux et stocks par depot des variants visibles sont maintenant precharges par lots, au lieu d'executer des requetes par variant.
- Cause : l'assortiment produits avait transforme la collection de variants en tableau JSON avant la construction du compteur, provoquant une erreur 500 Laravel.

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- Test HTTP login manager distributeur
- Test HTTP `POST /api/workspace/real` avec `section=products`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:35065`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`
- `adb logcat` cible erreurs Flutter/Android

Resultats :
- Endpoint produits retourne `SUCCESS` avec les produits reels du distributeur.
- Temps local constate : environ 1,8 s pour 30 produits et le premier produit a 44 variants, contre plus de 10 s avant optimisation.
- APK debug VPN genere, installe et lance sur SM A165F.
- Logcat cible sans `FATAL EXCEPTION`, `FlutterError`, `No Material widget found`, `DropdownButton` ou erreur workspace au lancement.
- Aucun changement destructif de base de donnees.

## 2026-05-20 - Prix variant distributeur enrichi

Objectif :
- Rendre le bouton `Prix` de la fiche variant exploitable en conditions terrain, sans demander de re-selectionner le variant deja ouvert.

Resume technique :
- Flutter : formulaire `Prix variant` contextualise avec carte variant, nom de liste prix, type point de vente, date debut, date fin, prix, SKU/reference et switch tarif actif.
- Backend : `/api/distributor/variants/{id}/price` accepte les dates, le nom de liste et `active`, cree une periode tarifaire non destructive dans `pricelist` puis le prix dans `pricelist_item`.
- API : retour enrichi avec `price_history`, `price_label`, `pricelist` et audit `save_variant_price`.
- Securite metier : route limitee au workspace distributeur connecte; le SuperAdmin ne gere pas prix/stock operationnels.

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php artisan route:list --path=api/distributor`
- Test HTTP login manager distributeur
- Test HTTP validation `/api/distributor/variants/1/price` avec `price=0` refuse proprement
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:35065`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`
- `adb logcat` cible erreurs Flutter/Android

Resultats :
- APK debug VPN genere, installe et lance.
- Aucun `FlutterError`, `No Material widget found`, `DropdownButton` ou crash app cible detecte au lancement.
- Aucune ecriture de prix factice effectuee pendant le test automatique.

## 2026-05-19 - Actions Distributeur reelles et corrections Material

Objectif :
- Stabiliser les pages operationnelles Distributeur en mode reel, corriger les erreurs `No Material widget found` et remplacer les messages informatifs par des formulaires connectes aux APIs.

Resume technique :
- Ajout d'un formulaire promotion riche et valide avant appel `/api/distributor/promotions`.
- Protection de l'ajustement stock : si aucun depot n'est charge, l'action affiche un etat vide utile et propose la creation depot.
- Conservation du filtre dashboard par distributeur et du filtre livraisons par depot.
- Normalisation du wrapper `Material` autour des pages/sheets workspace.
- Verification des routes distributeur reelles : depots, clients, coupons, promotions, stock adjust et prix variant.

Commandes executees :
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php artisan route:list --path=api/distributor`
- `php artisan route:list --path=api/superadmin`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb devices`
- `adb connect` sur les ports fournis recents

Resultats :
- APK debug VPN genere.
- ADB `10.212.134.2:43903` connecte.
- APK installe avec succes sur le smartphone.
- Application lancee avec `monkey`.
- Logcat de demarrage sans crash Flutter/Android cible (`FATAL EXCEPTION`, `FlutterError`, `No Material widget found`, assertion, overflow).
- Les warnings Flutter stricts restent historiques et non bloquants.

## 2026-05-19 - Filtre categorie et edition produit SuperAdmin

Objectif :
- Finaliser l'ergonomie de l'onglet Produits SuperAdmin : filtre categorie visible, action creation categorie accessible, et formulaire modification produit correctement pre-rempli.

Resume technique :
- Ajout de l'etat `categoryFilter` dans `WorkspacePage`.
- Ajout d'un dropdown compact `Categorie` dans la toolbar Produits, avant le filtre statut.
- Ajout de l'action `create_category` et de son icone dans la barre d'actions Produits.
- Retrait du bouton de creation categorie depuis le formulaire produit pour eviter l'ambiguite pendant l'edition.
- Normalisation du pre-remplissage categorie/distributeur avec valeurs dropdown sures et `ValueKey` de rafraichissement.
- Enrichissement du payload workspace produits avec `category_label`.

Commandes executees :
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php artisan route:list --path=api/superadmin`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:44261`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`

Resultats :
- APK debug VPN genere, installe et lance sur SM A165F.
- Les warnings Flutter stricts restent historiques et non bloquants.

## 2026-05-18 - SuperAdmin smartphone UX fixes

Objectif :
- Finaliser l'ergonomie SuperAdmin en mode reel sur petit smartphone : actions visibles, formulaires sans saisie manuelle d'ID, details lisibles, relation acteur/distributeur et messages premium.

Resume technique :
- `WorkspacePage` utilise maintenant `PopScope` pour fermer le clavier Android avant de quitter l'ecran.
- Ajout d'actions rapides SuperAdmin en haut de page et masquage de la barre d'actions basse pour eviter les boutons loin en bas.
- Recherche/filtres SuperAdmin compactes pour Distributeurs, Acteurs et Produits.
- Les cartes acteur/distributeur/produit ouvrent directement les details modernes.
- Formulaire acteur : dropdown workspace, dropdown distributeur, distributeur obligatoire sauf `superadmin`, email verifie par defaut, mot de passe temporaire copiable.
- Formulaire produit : dropdown categorie, creation rapide categorie, dropdown distributeur avec option Global, creation/modification variants.
- Details distributeur/acteur/produit : suppression des donnees JSON brutes, tabs scrollables et informations metier.
- Profil SuperAdmin : bottom sheets utiles pour Firebase, Google Maps, Bluetooth printer et Google/Facebook Login.
- Backend : filtrage acteurs distributeur corrige, `email_verified_at` garanti pour les acteurs crees/reset par SuperAdmin, payloads produits enrichis avec categorie/distributeur.

# 2026-05-19 - Variants produit SuperAdmin et APK smartphone

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/SuperAdminController.php`
- `push_sale-master/routes/api.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- `PROJECT_HISTORY.md`
- `MAINTENANCE_HISTORY.md`
- `TEST_REAL_RESULTS.md`
- `UI_AUDIT.md`

Commandes executees :
- `php -l app/Http/Controllers/SuperAdminController.php`
- `php artisan route:list --path=api/superadmin`
- Test API login SuperAdmin + `GET /api/superadmin/products/1` + `GET /api/superadmin/products/1/variants`
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:44261`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`

Resultats :
- Variants produits SuperAdmin regroupes par famille/type et affiches en liste moderne.
- Clic sur un variant ouvre l'edition.
- Glissement d'un variant lance une suppression securisee avec controle backend des dependances.
- SuperAdmin n'est pas presente comme gestionnaire stock/prix; l'UI indique que prix et stock sont geres par distributeur/depot.
- API `Serviette Awane` verifiee : 41 variants, groupes `Confort`, `Coton`, `Dry`, etc.
- APK debug VPN genere, installe et lance sur SM A165F.

Risque :
- Faible; la suppression d'un variant est refusee si des donnees metier y sont rattachees.

Commandes executees :
- `php artisan route:list --path=api/superadmin`
- `php artisan migrate --force`
- Tests HTTP login SuperAdmin, dashboard, creation distributeur, creation acteur lie distributeur, login acteur cree, detail distributeur acteurs, creation categorie, creation produit, creation variant, audit logs.
- `dart format`
- `dart analyze lib/views/signed/workspace/workspace_page.dart`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.1:40459`

Resultats :
- Routes SuperAdmin OK.
- Migration non destructive OK, rien a migrer.
- APIs SuperAdmin CRUD/categorie/variant/audit OK.
- Acteur cree par SuperAdmin : `email_verified_at` OK et login Laravel OK.
- Acteur lie au distributeur cree : visible via `/api/superadmin/distributors/{id}/actors`.
- Analyse Flutter no-fatal OK; warnings historiques stricts toujours presents.
- APK genere : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- Test smartphone bloque : ADB refuse `10.212.134.1:40459` avec erreur `10061`, aucun device liste.

Points restants :
- Validation visuelle smartphone a refaire apres reconnexion ADB wireless.
- Nettoyage progressif des warnings stricts Flutter historiques hors workspace SuperAdmin.

## 2026-05-18 - Bascule workspace en mode reel

Objectif :
- Remplacer le comportement workspace demo dans les environnements de test reel et production par des appels API reels ou des erreurs explicites.

Resume technique :
- Ajout des environnements Flutter `demo` et `real`.
- Ajout des flags `AppConfig.isDemoMode` et `AppConfig.isRealDataMode`.
- Blocage de `CallApi.RequestHttp('workspace/mvp')` en `vpn`, `real` et `production` avec `DEMO_ACTION_NOT_ALLOWED_IN_REAL_ENV`.
- Renommage Flutter de `WorkspaceMvpPage` vers `WorkspacePage`.
- HomePage utilise maintenant `WorkspacePage` et la route `/api/workspace/real` hors `APP_ENV=demo`.
- Ajout de la route Laravel `/api/workspace/real`.
- Retrait des libelles visibles `donnees demo`, `action demo`, `panier demo` dans le flux reel.

Commandes executees :
- `C:\tools\php83\php.exe artisan migrate --force`
- `C:\tools\php83\php.exe artisan route:list --path=api`
- Tests HTTP login/workspace/API reels pour SuperAdmin, Commercial, Depot, Livreur et Point de Vente.
- `dart format`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Migrations non destructives OK, rien a migrer.
- APIs SuperAdmin reelles OK.
- Endpoints reels par role OK : `clients`, `products`, `currentorders`, `warehouses`, `topackorders`, `toshiporders`, `currentstock`.
- Point de Vente lit le catalogue et ses commandes via `workspace/real`.
- APK debug genere avec succes.

Points restants :
- Brancher une vraie API de validation panier Point de Vente; le bouton est bloque proprement en mode reel au lieu de simuler.
- Nettoyer progressivement les 758 issues Flutter historiques no-fatal.

## 2026-05-18 - Finalisation SuperAdmin CRUD et audit logs

Objectif :
- Rendre le workspace SuperAdmin exploitable avec dashboard global, gestion distributeurs, gestion acteurs, gestion produits et audit des actions sensibles.

Resume technique :
- Ajout de `SuperAdminController` avec garde workspace `superadmin`.
- Ajout de routes `/api/superadmin/dashboard`, `/api/superadmin/distributors`, `/api/superadmin/actors`, `/api/superadmin/products`, `/api/superadmin/audit-logs` et endpoints enfants.
- Ajout migration non destructive sur `distributor`, `actor` et `product` pour champs de gestion manquants.
- Mise a jour des modeles `Distributor`, `Actor` et `Product`.
- Mise a jour `WorkspaceMvpController` pour ne renvoyer les KPIs SuperAdmin que sur `dashboard`.
- Mise a jour `WorkspaceMvpPage` avec formulaires, filtres, recherche, details et confirmations SuperAdmin.

Commandes executees :
- `C:\tools\php83\php.exe artisan migrate --force`
- `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder --force`
- `C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder --force`
- `C:\tools\php83\php.exe artisan route:list --path=api/superadmin`
- Tests HTTP login SuperAdmin, permissions/workspace, dashboard, CRUD distributeur, CRUD acteur, CRUD produit, audit logs.
- `dart format lib\views\signed\workspace\workspace_mvp_page.dart`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Routes SuperAdmin OK.
- Migrations et seeders OK.
- Login SuperAdmin et permissions/workspace OK.
- CRUD distributeur/acteur/produit OK avec ecriture audit.
- Audit logs consultables OK.
- Analyse Flutter no-fatal OK.
- Analyse Flutter stricte conserve 758 issues historiques non bloquantes.
- APK debug genere : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.

Risque :
- Moyen-faible. Les operations SuperAdmin sont nouvelles mais protegees par le workspace SuperAdmin; aucune route metier existante n'a ete supprimee.

Points restants :
- Nettoyer les warnings Flutter stricts historiques.
- Ajouter une UI dediee plus avancee pour creation directe de variants depuis la fiche produit.

## 2026-05-18 - Socle B2B workspaces, seeders et contrat permissions

Objectif :
- Poser une base backend/API claire pour les espaces SuperAdmin, Distributeur, Commercial, Depot, Livreur et Point de Vente, en gardant la compatibilite avec l'application Flutter existante.

Resume technique :
- Ajout de `WorkspaceResolver` pour centraliser la resolution `workspace_type`, les menus et les actions par espace.
- Ajout d'une migration non destructive sur `actor_profile.workspace_type`.
- Enrichissement de `PermissionsController` avec `user`, `actor`, `profile`, `workspace_type`, `menus`, `legacy_menus`, `actions`, `permissions`.
- Conservation du contrat legacy `permission` et `type_actor` pour ne pas casser les ecrans Flutter actuels.
- Extension de `TestUsersByRoleSeeder` avec SuperAdmin, Manager Distributeur et Point de Vente.
- Extension de `DemoDataSeeder` avec plus de points de vente, produits, variants, prix et stock demo.
- Mise a jour de `permissions_controller.dart` pour consommer le nouveau contrat workspace.

Commandes executees :
- `C:\tools\php83\php.exe artisan migrate --force`
- `C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder`
- `C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder`
- `C:\tools\php83\php.exe artisan route:list`
- `C:\tools\php83\php.exe artisan config:clear`
- `C:\tools\php83\php.exe artisan cache:clear`
- `C:\tools\php83\php.exe artisan route:clear`
- Verification HTTP login + `/api/permissions` pour les 6 comptes demo sans afficher les tokens.
- `dart format lib\controllers\permissions_controller.dart`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `adb -s 10.212.134.2:35599 install -r build\app\outputs\flutter-apk\app-debug.apk`
- `adb -s 10.212.134.2:35599 shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`

Resultats :
- Migration OK.
- Seeders OK.
- Routes OK, dont `api/permissions` et `api/permissions/workspace`.
- Comptes demo OK : superadmin, manager distributeur, commercial, depot, livreur, point de vente.
- Analyse no-fatal OK.
- Analyse stricte KO avec 762 issues historiques non bloquantes.
- APK debug genere avec succes : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- APK installe et lance sur SM A165F `10.212.134.2:35599`.

Risque :
- Moyen. La base permissions/workspaces est compatible, mais les ecrans complets SuperAdmin, Manager Distributeur et Point de Vente restent a implementer au-dessus du socle.

Points restants :
- Nettoyer progressivement les 762 warnings Flutter stricts.
- Implementer les CRUD/API/ecrans complets SuperAdmin, Distributeur et Point de Vente.
- Restaurer ou recreer `AGENTS.md` si sa suppression actuelle n'est pas volontaire.

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

# 2026-05-18 - MVP B2B fonctionnel et test device

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale-master/app/Models/Transactions.php`
- `push_sale-master/app/Support/WorkspaceResolver.php`
- `push_sale-master/routes/api.php`
- `push_sale-master/composer.lock`
- `push_sale_mobile-master/lib/views/signed/homepage.dart`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_mvp_page.dart`
- `BUTTONS_AUDIT.md`
- `TEST_RESULTS.md`
- `TEST_ACCOUNTS.md`
- `TEST_SCENARIOS.md`
- `PROJECT_HISTORY.md`
- `MAINTENANCE_HISTORY.md`

Commandes executees :
- `composer update lcobucci/clock --with-all-dependencies`
- `composer install`
- `php artisan migrate --force`
- `php artisan db:seed --class=TestUsersByRoleSeeder --force`
- `php artisan db:seed --class=DemoDataSeeder --force`
- `php artisan config:clear`
- `php artisan cache:clear`
- `php artisan route:list --path=api`
- `composer audit --no-interaction`
- Tests API login/workspace sur 6 comptes
- Tests API `clients`, `products`, `currentorders`, `warehouses`, `topackorders`, `toshiporders`, `currentstock`
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter analyze`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.2:35599 --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- `composer install` fonctionne maintenant avec PHP 8.3.31 grace a `lcobucci/clock` 3.5.0.
- Les 6 comptes B2B retournent le workspace attendu.
- Les pages MVP ne restent pas vides : SuperAdmin, Distributeur, Depot, Livreur et Point de Vente sont alimentes par `/api/workspace/mvp`.
- Le role livreur n'utilise plus l'ancien delivery blanc pour les onglets principaux; il passe par `WorkspaceMvpPage`.
- APK debug genere et app lancee sur SM A165F.
- `flutter analyze` strict reste en echec sur 762 issues historiques non bloquantes.
- `composer audit` signale 2 advisories dependances et 2 packages abandonnes a traiter dans une montee Laravel/dependances separee.

Risque :
- Moyen-faible; endpoint d'agregation et UI de navigation sans changement des anciens endpoints ni calculs metier.

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

# 2026-05-18 - Durcissement production validation

Fichiers modifies/ajoutes :
- `push_sale-master/database/migrations/2026_05_18_120000_add_production_validation_tables.php`
- `push_sale-master/app/Models/AuditLog.php`
- `push_sale-master/app/Models/ClientUserAccess.php`
- `push_sale-master/app/Models/DeliveryTrip.php`
- `push_sale-master/app/Models/DeliveryTripStop.php`
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale-master/app/Http/Controllers/Order/OrderController.php`
- `push_sale-master/database/seeders/DemoDataSeeder.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_mvp_page.dart`
- `push_sale_mobile-master/lib/controllers/authentification_controller.dart`
- `push_sale_mobile-master/lib/views/auth/loginpage.dart`
- `push_sale_mobile-master/lib/views/auth/checklogin.dart`
- `push_sale_mobile-master/lib/main.dart`
- `push_sale_mobile-master/android/app/src/main/AndroidManifest.xml`
- `REAL_DATA_TESTING.md`
- `PRODUCTION_CHECKLIST.md`

Commandes executees :
- `composer install`
- `php artisan migrate --force`
- `php artisan db:seed --class=TestUsersByRoleSeeder --force`
- `php artisan db:seed --class=DemoDataSeeder --force`
- Tests API login/workspace 6 comptes
- Tests API `clients`, `products`, `currentorders`, `warehouses`, `topackorders`, `toshiporders`, `currentstock`, `listpromotions`, `listcoupons`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `flutter devices`
- `flutter run -d 10.212.134.2:35599 --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`

Resultats :
- Migrations non destructives OK.
- Seeders OK et donnees demo plus coherentes pour point de vente, promotions, coupons, audit et trajets.
- Workspaces MVP alimentes et plus compacts sur petit smartphone.
- Auth Gmail/Facebook protegee contre loading infini.
- Firebase Messaging non bloquant et permission demandee.
- Maps externe disponible en fallback.
- APK debug genere et app lancee sur SM A165F.
- Passe finale apres `flutter clean` : APK debug regenere OK; le smartphone n'etait plus visible dans `flutter devices` et `adb connect 10.212.134.2:35599` a echoue car le port ADB wireless avait expire/change.

Risque :
- Moyen-faible; les changements ajoutent une couche de fiabilite et d'audit sans supprimer de donnees ni remplacer les anciens endpoints.

# 2026-05-19 - Correctifs mode reel SuperAdmin/Distributeur

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- `PROJECT_HISTORY.md`
- `MAINTENANCE_HISTORY.md`
- `TEST_REAL_RESULTS.md`
- `TEST_RESULTS_SUPERADMIN.md`
- `REAL_MODE_AUDIT.md`
- `UI_AUDIT.md`

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php -l app/Http/Controllers/SuperAdminController.php`
- Tests API login SuperAdmin et manager distributeur
- Tests API `workspace/real` sections `products`, `actors`, `warehouses`, `stock`
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:32895`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`

Resultats :
- Onglet Produits SuperAdmin charge de nouveau en mode reel.
- Edition acteur pre-remplit nom, prenom, email, telephone, workspace et distributeur rattache.
- Affectation acteur existant affiche les noms/emails/workspaces et permet detach par swipe dans le detail distributeur.
- Profil Distributeur : les statistiques globales ne sont plus repetees dans les onglets; elles restent dans le dashboard.
- Distributeur : acteurs, depots et stock sont filtres par distributeur rattache au manager connecte.
- APK debug genere, installe et lance sur SM A165F.

Validation supplementaire 2026-05-19 :
- `adb connect 10.212.134.2:39423` OK.
- `Test-NetConnection 10.212.134.2 -Port 39423` OK.
- APK debug VPN reinstalle avec succes sur SM A165F.
- Application relancee par `adb shell monkey`.

# 2026-05-20 - Variants options:value catalogue SuperAdmin

Fichiers modifies/ajoutes :
- `push_sale-master/database/migrations/2026_05_20_000001_add_variant_options_tables.php`
- `push_sale-master/app/Models/VariantOption.php`
- `push_sale-master/app/Models/VariantOptionValue.php`
- `push_sale-master/app/Models/VariantOptionAssignment.php`
- `push_sale-master/database/seeders/VariantOptionsSeeder.php`
- `push_sale-master/app/Models/Variant.php`
- `push_sale-master/app/Http/Controllers/SuperAdminController.php`
- `push_sale-master/routes/api.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`

Commandes executees :
- `php -l` sur les nouveaux fichiers backend et `SuperAdminController.php`
- `composer dump-autoload`
- `php artisan route:list --path=api/superadmin`
- `php artisan migrate --force`
- `php artisan db:seed --class=VariantOptionsSeeder --force`
- Test API SuperAdmin : options, creation variant options, rejet doublon, liste variants, nettoyage variant temporaire
- `flutter clean`
- `flutter pub get`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale 1`
- `adb logcat` cible erreurs Flutter/Android

Resultats :
- Variants par options predifinies operationnels cote API et UI.
- Doublons de combinaison option/valeur refuses par backend.
- Ancien modele variant conserve en compatibilite.
- APK installe et lance sur SM A165F.

Risque :
- Faible a moyen; schema additif et validations backend. Les variants existants peuvent etre progressivement enrichis avec options sans migration destructive.

# 2026-05-20 - Produits distributeur variant Infos/Prix/Stock

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- `PROJECT_HISTORY.md`
- `MAINTENANCE_HISTORY.md`
- `TEST_REAL_RESULTS.md`
- `UI_AUDIT.md`
- `BUTTONS_AUDIT.md`

Commandes executees :
- `php artisan migrate --force`
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- Test API login manager distributeur
- Test API `POST /api/workspace/real` section `products`
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:35065`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`
- `adb logcat` cible erreurs Flutter/Android

Resultats :
- L'onglet Produits du profil Distributeur utilise le filtre `Actifs` par defaut.
- Le detail variant affiche trois onglets centres : `Infos`, `Prix`, `Stock`.
- L'onglet `Prix` lit l'historique de `pricelist_item/pricelist` du plus recent vers le plus ancien.
- L'onglet `Stock` liste les depots autorises avec quantite disponible, previsionnel, valeur et statut.
- Les boutons `Stock` et `Prix` restent visibles en bas de la sheet et ouvrent les actions distributeur existantes.
- APK debug VPN genere, installe et lance sur SM A165F.
- Logcat cible sans `FlutterError`, `No Material widget found`, `DropdownButton` ou crash app.

Blocage device :
- Port precedent `10.212.134.2:43903` refusait la connexion, mais le nouveau port `10.212.134.2:35065` est OK.

Risque :
- Faible; enrichissement lecture seule du payload workspace et UI defensive sans suppression ni changement de calcul metier.

Risque :
- Faible; corrections de mapping, scope et UI defensive sans operation destructive ni changement de workflow metier.

# 2026-05-20 - Correction actions Prix/Stock distributeur

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale-master/app/Models/PriceListItem.php`
- `push_sale-master/routes/api.php`
- `push_sale-master/database/migrations/2026_05_20_000001_add_deleted_at_to_pricelist_item_table.php`
- `push_sale_mobile-master/lib/api/call_api.dart`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- documentation racine de validation.

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php -l routes/api.php`
- `php -l app/Models/PriceListItem.php`
- `php artisan migrate --force`
- `php artisan route:list --path=api/distributor`
- Test API login manager distributeur
- Test API `POST /api/distributor/price-context`
- Test API `POST /api/distributor/stock-context`
- Test API `POST /api/distributor/stock/adjust`
- Test transaction rollback creation prix + rejet chevauchement
- `dart format lib/api/call_api.dart lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:35065`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`
- `adb logcat` cible erreurs Flutter/Dio.

Resultats :
- `Enregistrer prix` ne cree plus d'erreur 500 liee aux IDs legacy.
- `Valider stock` ne cree plus d'erreur 500 liee a `stock_quantity.id`.
- Les actions `Prix` et `Stock` utilisent des contextes legers quand le variant est deja selectionne, ce qui evite le chargement lourd de tout le contexte distributeur.
- Les erreurs API ne remontent plus comme exception Dio brute avec texte technique; Flutter affiche le message backend ou un message court.
- Le prix est planifie par date, avec statut automatique `Expire`, `Actif` ou `Planifie`; les chevauchements sont bloques cote UI et backend.
- L'historique prix est triable naturellement du plus recent au plus ancien et supporte la suppression douce par glissement.
- Le formulaire stock affiche depot, ancien stock, nouveau stock et variation en pourcentage, puis rafraichit la fiche variant.

Risque :
- Faible a moyen; corrections operationnelles sur prix/stock avec validations backend. Aucune commande destructive n'a ete executee.

# 2026-05-20 - Assortiment distributeur produits/variants

Fichiers modifies/ajoutes :
- `push_sale-master/database/migrations/2026_05_20_000002_create_distributor_product_assortments_table.php`
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale-master/routes/api.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- documentation racine de validation.

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php -l routes/api.php`
- `php -l database/migrations/2026_05_20_000002_create_distributor_product_assortments_table.php`
- `php artisan migrate --force`
- `php artisan route:list --path=api/distributor/product-assortment`
- Test API login manager distributeur
- Test API `POST /api/distributor/product-assortment`
- Test sauvegarde `saveDistributorProductAssortment` en transaction rollback
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb connect 10.212.134.2:35065`
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- `adb shell monkey -p com.softstarter.pushsale -c android.intent.category.LAUNCHER 1`
- `adb logcat` cible erreurs Flutter/Android.

Resultats :
- Le manager distributeur dispose d'un bouton compact `Assortiment` dans la ligne de filtres Produits.
- La selection produit coche tous ses variants; l'expansion permet de cocher seulement certains variants.
- La sauvegarde est persistante dans `distributor_product_assortments`.
- Quand un assortiment existe, l'onglet Produits distributeur ne retourne que les variants actifs selectionnes.
- Si aucun assortiment n'est encore configure, le catalogue distributeur reste complet pour ne pas bloquer l'utilisation initiale.

Risque :
- Faible a moyen; nouvelle preference operationnelle par distributeur, sans suppression catalogue/prix/stock.

# 2026-05-21 - Alertes Produits/Variants distributeur

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale-master/routes/api.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- documentation racine de validation.

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php -l routes/api.php`
- `php artisan route:list --path=api/distributor`
- Test API login manager distributeur
- Test API `POST /api/workspace/real` section `products`
- Test API `POST /api/distributor/stock/999999999/delete` pour validation route/message sans toucher aux donnees
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb devices`
- `adb connect 10.212.134.2:35065` tente.

Resultats :
- Le filtre Produits distributeur n'utilise plus `Actif/Inactif`; il propose `Tous`, `Alerte`, `OK`.
- La liste produits ne montre plus le prix ni le gros chevron.
- Chaque produit affiche une pastille iconisee `OK` ou `n alertes`.
- Chaque variant n'affiche plus le tag `Actif`; il affiche seulement la pastille operationnelle `OK/Alerte` avec raisons principales : prix actif manquant, rupture depot, ou stock inferieur de 20% a l'objectif.
- Le payload backend fournit `health_status`, `health_alert_count`, `health_reasons` et `stock_id`.
- L'onglet `Variant > Stock` supporte le swipe gauche pour supprimer une ligne stock existante via API auditee.
- APK debug genere : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- Installation smartphone OK : `adb connect 192.168.0.28:44039`, `adb install -r`, puis lancement `com.softstarter.pushsale` OK.

Risque :
- Faible a moyen; la suppression stock est une operation reelle, limitee aux depots du distributeur connecte et journalisee.

# 2026-05-21 - Etat Depots selon variants selectionnes

Fichiers modifies :
- `push_sale-master/app/Http/Controllers/WorkspaceMvpController.php`
- `push_sale_mobile-master/lib/views/signed/workspace/workspace_page.dart`
- documentation racine de validation.

Commandes executees :
- `php -l app/Http/Controllers/WorkspaceMvpController.php`
- `php artisan migrate --force`
- Test API login manager distributeur
- Test API `POST /api/workspace/real` section `warehouses`
- `dart format lib/views/signed/workspace/workspace_page.dart`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- `adb devices`

Resultats :
- L'etat d'un depot distributeur est maintenant calcule uniquement sur les variants selectionnes dans l'assortiment actif du distributeur.
- Les variants non selectionnes ne peuvent plus mettre un depot en `Alerte`.
- Si aucun variant n'est selectionne, le depot reste `OK` avec le meta `0 variants selectionnes`.
- Le statut `OK` est colore en vert dans Flutter.
- APK debug genere : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
- Installation smartphone non executee : aucun device ADB liste au moment du test.

Risque :
- Faible; aucune modification destructive, calcul de lecture uniquement.
