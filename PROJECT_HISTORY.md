# PROJECT_HISTORY

## 2026-05-17 - Modernisation fiche client et liste clients terrain

- Zone modifiee : Flutter clients, liste clients, grille clients, fiche client detail.
- Objectif : rapprocher le module clients des maquettes fournies : liste plus lisible, filtres par jours, fiche client moderne avec informations, commandes et historique.
- Resume : ajout de chips de jours de visite sans filtrage obligatoire par defaut; refonte des cartes liste/grille avec badges stock, ventes, jours et derniere visite; remplacement de l'ancien panneau coulissant de fiche client par une page a onglets `Info / Commandes / Historique`; ajout de cartes client, metriques telephone/credit/commandes, etat de visite modifiable, jours planifies, promotions et historique de visites; modernisation du dialogue de raison de non-vente pour eviter les overflows.
- Risque : moyen-faible, car les changements touchent des widgets profonds du parcours client mais ne modifient aucune route API, aucun format JSON et aucun calcul metier.
- Impact logique metier : aucun changement volontaire; les actions existantes restent `Products`, `EditClient`, `getCurrentOrders` et `saveVisit`.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter devices` OK, `flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Tests a faire : validation visuelle sur scrcpy des filtres jours, ouverture fiche client, onglets commandes/historique, changement etat de visite et creation commande depuis la fiche.
- Prochaine etape : poursuivre la modernisation du detail commande client et du parcours ajout client apres test manuel.

## 2026-05-17 - Clients, tracking, sidebar et deconnexion propre

- Zone modifiee : Flutter HomePage/navigation, clients, nouveau client, tracking, depots, session/logout.
- Objectif : corriger les retours smartphone : liste clients vide, formulaire nouveau client ancien et peu clair, tracking illisible avec overflow, besoin d'une sidebar mobile, depot noir, deconnexion qui garde des donnees de profil.
- Resume : ajout d'un drawer lateral mobile avec profil, navigation et logout; centralisation de la deconnexion dans `SessionService` avec clear SharedPreferences, signOut Firebase et reset GetX; page clients modernisee avec recherche, filtres, chips, etats loading/empty/error et affichage tous clients par defaut; formulaire client rendu plus clair avec cartes, GPS explicite et messages d'erreur; tracking remplace par KPI + cartes + timeline responsive; correction du bug `animateToPage(2)` vers une page inexistante; ecran depots enveloppe dans un Scaffold/fond clair et chargement execute une seule fois.
- Risque : moyen, car navigation/session et plusieurs ecrans visibles sont touches; aucune route API, aucun format JSON et aucun calcul metier n'a ete modifie.
- Impact logique metier : aucun changement de calcul metier; la creation client garde l'exigence GPS existante mais affiche maintenant un message clair au lieu d'echouer silencieusement.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Tests a faire : validation manuelle sur scrcpy du drawer, logout/relogin entre roles, ajout client avec permission GPS, liste clients, tracking detail et depot admin.
- Prochaine etape : continuer la modernisation des sous-ecrans client detail/commande et nettoyer progressivement les warnings historiques.

## 2026-05-17 - Correctif depots, reception et liste de prix

- Zone modifiee : Flutter depots/stock, bon de reception, selection produits reception, liste de prix, theme.
- Objectif : corriger les retours visuels observes sur scrcpy : ecran depot noir en theme sombre, actions depot peu claires, bon de reception ancien et peu lisible, overflows sur reception, liste de prix qui charge sans fin.
- Resume : neutralisation temporaire du theme sombre legacy en conservant un rendu clair stable, remplacement des actions depot en petits boutons flottants par une barre d'actions textuelle `Reception / Ajuster / Imprimer / Imprimante`, affichage des articles de depot en cartes avec etat vide, modernisation du bon de reception avec header, total fixe et boutons visibles, modernisation de la recherche produits reception, correction du chargement unique de la liste de prix et parsing defensif des listes/prix.
- Risque : moyen-faible, car les changements touchent plusieurs ecrans UI mais ne modifient ni routes API, ni formats JSON, ni calculs metier stock/prix/reception.
- Impact logique metier : aucun changement volontaire; seules des corrections d'etat UI et de robustesse de parsing ont ete ajoutees.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter analyze` strict KO sur 770 issues historiques non bloquantes, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter devices` OK, `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Tests a faire : validation manuelle sur scrcpy des chemins admin `Mes depots -> Depot central demo -> Reception -> Bon de reception -> Liste de prix`.
- Prochaine etape : poursuivre la modernisation profonde de la fiche produit reception et des ecrans prix/acteurs si des captures montrent encore des zones anciennes.

## 2026-05-17 - Correctifs UI visibles, overflows et livraison demo

- Zone modifiee : HomePage Flutter, dashboard, favoris/panier, parametres, livraison mobile, notification livraison Laravel.
- Objectif : corriger les problemes constates sur smartphone (bandes `BOTTOM OVERFLOWED`, favoris en construction, theme/notifications peu fonctionnels, dashboard peu lisible, erreur livraison `id` null).
- Resume : remplacement des hauteurs fixes par `Expanded`/scroll flexible sur dashboard, parametres et livraison; ajout d'une navigation laterale responsive sur tablette/grand ecran; remplacement des placeholders favoris/panier par des pages modernes avec empty states et raccourcis; ajout de panneaux Theme et Notifications; ajout de cartes KPI modernes au dashboard.
- Livraison : l'ecran detail gere maintenant l'absence de commande selectionnee sans crash; cote Laravel, l'envoi de notification apres livraison ignore proprement le cas ou la commande source ou son acteur n'existe pas, au lieu de casser la validation livraison.
- Risque : moyen-faible, car les changements sont UI/defensifs et ne changent pas les routes API, le JSON, les calculs stock/prix/commande/livraison/paiement.
- Impact logique metier : aucun changement de logique metier; la notification manquante est sautee uniquement quand le destinataire est absent.
- Tests effectues : `php -l PurchaseOrderController.php` OK, `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter devices` OK, `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK apres retry.
- Warnings restants : `flutter analyze` strict conserve 791 issues historiques deja documentees (style, deprecated, champs non final, prints anciens).
- Prochaine etape : validation manuelle sur scrcpy des ecrans dashboard, favoris, livraison, parametres/theme/notifications, puis continuer la modernisation module par module.

## 2026-05-17 - Modernisation UI lot 2 dashboard, clients, depots, chat et theme

- Zone modifiee : dashboard Flutter, clients, produits, tracking, transfert, depots, detail depot, chat, theme global.
- Objectif : repondre aux retours visuels sur scrcpy : UI pas assez moderne, dashboard peu clair, boutons depot en menu haut, chat/theme non fonctionnels, overflows persistants.
- Resume : ajout d'un hero dashboard moderne avec metriques terrain, correction de la barre clients pour eviter les debordements, suppression de nouvelles hauteurs fixes sur produits/tracking/transfert, modernisation des cartes depot, remplacement du menu haut du detail depot par des boutons flottants avec reception/ajustement/impression/imprimante.
- Chat : creation d'un controller Flutter connecte aux routes Laravel existantes `getmessage` et `sendmessage`; l'ecran affiche loading, erreur, vide, conversations et reponse rapide.
- Theme : ajout d'un vrai `darkTheme` dans `GetMaterialApp`; les options Theme clair/sombre/systeme ont maintenant un effet visuel.
- Risque : moyen, car plusieurs ecrans UI profonds sont touches, mais aucune route API ni logique metier stock/prix/commande/livraison/paiement n'a ete changee.
- Impact logique metier : aucun changement de calcul metier; uniquement UI, consommation d'endpoints existants et actions defensives.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter devices` OK, `flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Warnings restants : `flutter analyze` strict conserve 788 issues historiques non bloquantes.
- Prochaine etape : validation visuelle page par page sur scrcpy et poursuite de la modernisation des sous-ecrans commandes, paiement, promotions et formulaire de reception.

## 2026-05-17 - Durcissement depots, notifications et warnings ciblés

- Zone modifiee : depots/stock Flutter, commandes/livraison/transfert Flutter, notifications Laravel, documentation.
- Objectif : reduire les warnings importants restants, renforcer l'affichage depot/stock et corriger les risques de logs sensibles notification sans changer les workflows metier.
- Resume : suppression de variables/imports morts, remplacement d'acces RxList proteges, correction de dead code, finalisation de widgets depot, ajout d'un empty state depot, onglets stock plus responsives, nettoyage du controller notification.
- Notifications : retrait d'un ancien bloc commente contenant une configuration Firebase, validation de payload/FCM key, suppression des logs de token FCM complet, retour JSON propre en cas de configuration manquante ou erreur FCM.
- Risque : moyen-faible, car les routes API restent identiques et les modifications sont defensives; l'envoi FCM requiert maintenant explicitement `FCM_SERVER_KEY` et un token utilisateur non vide.
- Impact logique metier : aucun changement de calcul commande, stock, prix, livraison ou paiement.
- Tests effectues : `php -l NotificationController.php` OK, `composer install` PHP 8.3 OK, `route:list` OK, `config:clear` OK, `cache:clear` OK, seeders OK, `flutter clean`, `flutter pub get`, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter analyze` strict 802 issues, `flutter build apk --debug` OK, `flutter run` sur SM A165F OK.
- Prochaine etape : nettoyer progressivement les `must_be_immutable` historiques, remplacer `WillPopScope` par `PopScope` par module, tester FCM avec une vraie cle restreinte.

## 2026-05-17 - Finalisation API config, seeders demo et verification device

- Zone modifiee : configuration Flutter, Android manifest, responsive commun, seeder Laravel demo, documentation.
- Objectif : rendre la demo Push Sales utilisable avec comptes par role, donnees de test et URL API configurable sans modifier manuellement le code.
- Resume : ajout de `AppConfig`/`AppEnvironment`, support `--dart-define`, centralisation `/api`, externalisation partielle Google/Firebase, couche responsive commune, correction packaging Android, ajout `DemoDataSeeder`.
- Backend : `TestUsersByRoleSeeder` et `DemoDataSeeder` executes avec PHP 8.3; comptes test valides sur `/api/login`; produits, depot, stock, commandes a preparer/livrer et transactions demo disponibles.
- Donnees : le seeder demo cree des vues de compatibilite dev si absentes (`stock_warehouse`, `purchase_variants`, `full_variant`) afin de respecter les controllers existants sans changer leurs routes.
- Securite : aucune vraie valeur `.env` documentee; les cles mobiles existantes doivent etre restreintes/rotatees cote Google/Firebase et peuvent etre surchargees via `--dart-define` ou `local.properties`.
- Risque : moyen, car ajout de donnees/vues demo et changement packaging Android, mais aucune route API, aucun calcul metier et aucun schema destructif n'a ete modifie.
- Impact logique metier : aucun changement volontaire; les workflows continuent a appeler Laravel.
- Tests effectues : `composer install` via PHP 8.3 OK, `route:list` OK, `config:clear` OK, `cache:clear` OK, seeders OK, endpoints demo OK, `flutter clean/pub get/analyze --no-fatal.../build apk` OK, `flutter run` sur SM A165F OK.
- Warnings restants : `flutter analyze` strict signale 840 issues historiques, surtout style, deprecations, `print`, champs non final et dependances transitives.
- Prochaine etape : nettoyer les warnings par module et valider manuellement impression Bluetooth, notifications Firebase et cartes avec cles restreintes.

## 2026-05-17 - Mobile UI modernization and role test pack

- Zone modifiee : `push_sale_mobile-master` UI Flutter, documentation racine, seeder Laravel dev/test.
- Objectif : rendre l'application plus moderne, coherente et validable par role sans changer la logique metier.
- Resume : ajout d'un theme global, composants communs reutilisables, modernisation de Login, Signup, HomePage, Clients, Produits, Commandes, menus Compte/Commercial, erreur Internet, confirmations commande/chargement, logs API moins sensibles, comptes et scenarios de test.
- Backend : ajout de `TestUsersByRoleSeeder` uniquement pour dev/test; non execute automatiquement.
- Risque : moyen, car plusieurs ecrans UI prioritaires et la navigation visuelle ont ete touches, mais les routes API, modeles JSON et calculs metier ne changent pas.
- Impact logique metier : aucun changement volontaire; corrections Dart minimales sur deux variables locales pour permettre l'analyse.
- Tests effectues : `flutter clean`, `flutter pub get`, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK sans erreur bloquante, `flutter build apk --debug` OK, `flutter devices` OK, `flutter run -d 10.212.134.2:37143 --debug --no-resident` OK. `php -l` du seeder OK.
- Backend : `composer install --no-interaction` bloque sur PHP 8.1.32 alors que `composer.lock` demande PHP >= 8.2 pour plusieurs paquets; `php artisan route:list/config:clear/cache:clear` non executes tant que Composer n'est pas installe.
- Tests a faire : validation scenarios `TEST_SCENARIOS.md`, verification impression Bluetooth, cartes et comptes par role sur base de dev.
- Prochaine etape : continuer la modernisation des sous-ecrans profonds et reduire les warnings historiques par module.

## 2026-05-17 - Debug login fallback for role test accounts

- Zone modifiee : `push_sale_mobile-master/lib/controllers/authentification_controller.dart`, documentation comptes.
- Probleme : les comptes `@pushsales.local` crees par le seeder Laravel ne pouvaient pas passer le premier controle Firebase Auth du login mobile.
- Changement : ajout d'un fallback limite au mode debug et aux emails `@pushsales.local`; si Firebase ne trouve pas le compte, Flutter appelle le login Laravel existant, stocke le token Passport et verifie `isprofiled`.
- Risque : moyen-faible, car le flux normal Firebase reste intact pour tous les autres comptes et aucun endpoint/API JSON n'est modifie.
- Impact logique metier : aucun changement de calcul, permission, commande, stock ou route; adaptation dev/test de l'authentification mobile.
- Tests a faire : executer le seeder sur la base Laravel dev, reconstruire l'APK debug, tester les 4 comptes par role.
- Verification : APK debug reconstruit et reinstalle sur SM A165F. Le fallback appelle bien Laravel, mais `192.168.1.20:8000` refuse la connexion localement tant que le serveur Laravel n'est pas demarre.
- Resolution dev : Laravel relance en PHP 8.3, seeder execute, cles Passport et `APP_KEY` generees. Les 4 comptes de test repondent `SUCCESS` sur `/api/login`; `isprofiled` confirme `hasactor=1` pour le compte admin.

## 2026-05-17 - Flutter dependencies and Android compatibility

- Zone modifiee : `push_sale_mobile-master` Flutter/Android.
- Resume : correction du conflit `intl` impose par `flutter_localizations` avec `flutter_form_builder`, mise a jour controlee des dependances resolues, retrait de la dependance Android inutilisee `bluetooth_print`, alignement Android Gradle/AGP/Kotlin/NDK pour Flutter 3.38.9 et Android SDK 36.
- Note Android : Flutter 3.38.9 migre automatiquement le `minSdk` effectif vers `flutter.minSdkVersion` (24). Les appareils Android API 23 ou moins ne sont donc plus une cible de build avec cette version Flutter.
- Securite : suppression d'un ancien token Bearer commente dans `lib/api/call_api.dart`. Des cles Google/API restent presentes dans le code mobile et doivent etre deplacees vers une configuration securisee lors d'une prochaine intervention.
- Risque : moyen, car la correction touche la chaine de build Android et les dependances Flutter, sans modifier les routes API ni la logique metier.
- Tests a faire : refaire un lancement sur smartphone Android ADB wireless quand le device est reconnecte, puis verifier login, cartes, commandes, stock, impression Bluetooth et notifications.
- Prochaine etape : traiter progressivement les warnings `flutter analyze`, puis externaliser les cles Google/API et la configuration d'environnements.
