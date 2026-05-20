# CHANGELOG

## 2026-05-19 - Actions Distributeur reelles et UI Plus

- Flutter : formulaire promotions Distributeur enrichi et connecte a `/api/distributor/promotions`.
- Flutter : ajustement stock bloque proprement tant qu'aucun depot n'existe, avec raccourci vers creation depot.
- Flutter : pages/sheets workspace protegees par `Material` pour corriger les erreurs `No Material widget found` observees dans Plus/Livraisons/Creances.
- Flutter : dashboard distributeur garde le filtre tous/distributeur et livraisons garde le filtre depot/statut.
- QA : routes Distributeur et SuperAdmin verifiees, analyse Flutter no-fatal OK, APK debug VPN genere, installe et lance sur ADB `10.212.134.2:43903`.

## 2026-05-18 - SuperAdmin smartphone UX fixes

- Flutter : SuperAdmin gagne une ergonomie compacte pour smartphone avec recherche/filtres reduits, actions rapides visibles et fermeture du clavier Android avant sortie.
- Flutter : details distributeur, acteur et produit modernises; suppression des champs bruts/JSON et ajout de tabs scrollables.
- Flutter : creation acteur avec dropdown distributeur, email verifie par defaut et mot de passe temporaire copiable.
- Flutter : creation produit avec dropdown categorie/distributeur, creation rapide categorie, detail produit `Infos / Variants` et ajout/modification variants.
- Flutter : suppression des actions panier dans le workspace SuperAdmin; les cartes ouvrent directement les details.
- Flutter : ajout de toasts premium et bottom sheets utiles pour Firebase, Maps, Bluetooth printer et Google/Facebook Login.
- Backend : correction relation acteurs par distributeur et garantie de connexion directe pour les acteurs crees par SuperAdmin.
- Backend : payloads produits enrichis avec categorie/distributeur lisibles et variants relies.
- Validation : APIs SuperAdmin testees, login acteur cree OK, relation distributeur-acteur OK, APK debug VPN genere.

## 2026-05-18 - Mode reel workspace et suppression des actions demo

- Flutter : ajout de `APP_ENV=demo` et `APP_ENV=real`; `vpn`, `real` et `production` utilisent les APIs reelles.
- Flutter : `WorkspaceMvpPage` devient `WorkspacePage` et charge `/api/workspace/real` hors environnement demo.
- Flutter : garde-fou `DEMO_ACTION_NOT_ALLOWED_IN_REAL_ENV` si une ancienne route `/workspace/mvp` est appelee en environnement reel.
- Flutter : retrait des messages visibles `donnees demo`, `action demo`, `panier demo` et remplacement par vraies actions API ou message `API reelle requise`.
- Backend : ajout de l'alias `/api/workspace/real` pour les workspaces connectes aux donnees existantes.
- QA : ajout de `REAL_MODE_AUDIT.md` et `TEST_REAL_RESULTS.md`.
- Validation : APIs reelles testees par role, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, APK debug VPN genere.

## 2026-05-18 - SuperAdmin CRUD, audit et gestion plateforme

- Backend : ajout des routes `/api/superadmin/*` pour dashboard, distributeurs, acteurs, produits, categories, variants et audit logs.
- Backend : ajout du controller `SuperAdminController` avec garde SuperAdmin, payloads compatibles `SUCCESS/FAIL`, validations et journalisation `audit_logs`.
- Base de donnees : migration non destructive pour completer `distributor`, `actor` et `product` avec les champs de gestion SuperAdmin (`is_active`, contacts, liaison distributeur produit).
- Flutter : finalisation du workspace SuperAdmin avec KPIs uniquement sur Dashboard, headers simples sur Distributeurs/Acteurs/Produits/Profil, recherche, filtres, formulaires et confirmations.
- SuperAdmin : CRUD distributeur teste avec creation, modification, activation/desactivation, detail et sections acteurs/depots/produits/commandes/stats.
- SuperAdmin : CRUD acteur teste avec creation, modification, activation/desactivation et reset password confirme.
- SuperAdmin : CRUD produit teste avec creation, modification, detail et consultation variants.
- Audit : consultation des logs et ecriture des actions sensibles SuperAdmin validees.
- Validation : migrations/seeders/routes/API CRUD OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, APK debug VPN genere avec succes.

## 2026-05-18

- Backend : ajout de `/api/workspace/mvp`, endpoint MVP de lecture pour alimenter les pages par workspace avec donnees existantes.
- Flutter : branchement de HomePage sur les workspaces MVP SuperAdmin, Distributeur, Depot, Livreur et Point de Vente.
- Livreur : remplacement des onglets principaux anciens par pages MVP fonctionnelles `Stock`, `Delivery`, `Trajets`, `Profil`.
- QA : ajout de `BUTTONS_AUDIT.md` et `TEST_RESULTS.md`.
- Composer : correction compatibilite PHP 8.3 via mise a jour ciblee `lcobucci/clock` 3.5.0.
- Validation : login/workspace OK pour les 6 comptes B2B, endpoints metier principaux OK, APK debug genere, lancement device SM A165F OK.
- Backend : ajout du contrat B2B progressif `workspace_type`, `menus`, `actions`, `permissions` sur `/api/permissions`, avec compatibilite legacy `permission/type_actor`.
- Backend : ajout de l'alias `/api/permissions/workspace`.
- Base de donnees : migration non destructive `actor_profile.workspace_type`.
- Backend : ajout de `WorkspaceResolver` pour standardiser les workspaces `superadmin`, `distributeur`, `commercial`, `depot`, `livreur`, `point_vente`.
- Seeders : comptes dev/test ajoutes pour `superadmin@pushsales.local`, `manager.distributeur@pushsales.local` et `pointvente.test@pushsales.local`.
- Seeders : donnees demo etendues avec 20 produits et 10 points de vente/clients de demonstration.
- Flutter : `PermissionsController` lit maintenant le nouveau contrat workspace sans casser les permissions existantes.
- Documentation : ajout de `BUSINESS_WORKFLOWS.md`, `DATABASE_DESIGN.md`, `API_DOCUMENTATION.md` et `UI_UX_GUIDE.md`.
- Documentation : mise a jour des comptes de test, scenarios et README dev pour la cible plateforme B2B.

## 2026-05-17

- Audit UI : ajout de `UI_AUDIT.md` avec inventaire des pages Flutter principales et priorites restantes.
- Dashboard : correction du crash `Null check operator used on a null value` pour les roles livraison.
- Dashboard : separation des etats de chargement ventes/livraison et protection contre les appels API repétés dans `build()`.
- HomePage : suppression d'un `setState()` pendant `build()` et stabilisation de l'`AnimatedSwitcher`.
- Navigation : ajout d'une sidebar/drawer mobile avec navigation par role et deconnexion.
- Session : logout nettoie maintenant preferences, Firebase Auth et controllers GetX pour eviter le profil precedent.
- Clients : page principale modernisee, affichage tous clients par defaut, etats vide/erreur/loading et filtres plus lisibles.
- Nouveau client : formulaire plus clair, scrollable, GPS explicite et messages professionnels en cas de blocage.
- Tracking : refonte lisible avec KPI, cartes et timeline responsive; correction d'une navigation vers une page inexistante.
- Depots : fond clair force et chargement unique pour eviter l'ecran noir/refresh repetitif.
- Depots/reception : actions depot transformees en barre lisible, cartes stock modernisees et etat vide ajoute.
- Bon de reception : header, total, ajouter/enregistrer/imprimer/imprimante rendus visibles; suppression de hauteurs fixes responsables d'overflows.
- Module clients : liste et grille modernisees avec badges stock/visite/ventes, filtres rapides par jour et cartes anti-overflow.
- Fiche client : nouvelle interface a onglets `Info / Commandes / Historique` avec resume client, credit, telephone, etats commandes, jours de visite, historique et action terrain.
- Visites : dialogue de raison de non-vente modernise, scrollable et plus lisible sur petit smartphone.
- Validation : APK debug VPN reconstruit et lance sur SM A165F (`10.212.134.4:37055`).
- Liste de prix : correction du chargement infini et parsing plus robuste des donnees backend.
- Theme : rendu sombre legacy neutralise temporairement pour eviter les ecrans noirs sur les anciens widgets.
- Validation : APK debug VPN reconstruit et lance sur SM A165F.
- Modernisation dashboard lot 2 : hero KPI moderne pour le pilotage terrain.
- Correction overflows supplementaires : clients, produits, tracking, transfert et depots.
- Depots : cartes modernisees et detail depot avec actions flottantes reception/ajustement/impression/imprimante.
- Chat : nouvel ecran connecte aux endpoints Laravel `getmessage` et `sendmessage`.
- Theme : ajout d'un vrai theme sombre via `darkTheme`.
- Validation device : APK installe et lance sur SM A165F apres build debug VPN.
- Correction UX visible : suppression des overflows dashboard/parametres/livraison, favoris et panier remplaces par des pages utiles.
- Ajout d'une navigation laterale responsive sur tablette/grand ecran, en conservant la barre basse sur smartphone.
- Dashboard enrichi avec cartes KPI modernes pour chiffre du jour, clients visites, panier moyen et restants.
- Parametres : actions Theme et Notifications ajoutees avec panneaux clairs.
- Livraison : correction defensive du detail sans commande selectionnee et de la notification Laravel quand la commande source/acteur est absent.
- Validation : `flutter analyze --no-fatal-infos --no-fatal-warnings` OK et APK debug VPN genere.
- Durcissement depots/stock : empty state depot, cartes depot plus flexibles, onglets stock responsives.
- Nettoyage warnings ciblés : variables mortes, imports inutiles, dead code, acces RxList proteges.
- Notifications backend : retrait d'une ancienne configuration Firebase commentee, validation `FCM_SERVER_KEY`, suppression des logs de token FCM complet.
- Nouvelle validation : `flutter clean`, `flutter pub get`, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter build apk --debug`, `flutter run` sur SM A165F OK.
- Finalisation demo : comptes test verifies, donnees demo ajoutees, endpoints principaux alimentes.
- Ajout de `DemoDataSeeder` pour produits, clients, depot, stock mobile, commandes, tracking et transactions de test.
- Centralisation de la configuration API Flutter via `AppConfig`, `APP_ENV` et `API_BASE_URL`.
- Ajout d'une couche responsive commune Flutter et de widgets communs complementaires.
- Externalisation partielle des cles Google/Firebase via `--dart-define` et placeholders Android.
- Correction du packaging Android apres externalisation des placeholders manifest.
- Validation device : APK installe/lance sur SM A165F via ADB wireless.
- Modernisation UI/UX mobile progressive : theme global, composants communs, login/signup, navigation HomePage, clients, produits, commandes, menus compte/commercial et erreur Internet.
- Ajout de confirmations UI pour creation commande et chargement/transfert.
- Ajout de composants reutilisables Flutter : boutons, cartes, headers, list tiles, statuts, loading, empty, error, confirmations et snackbars.
- Ajout du seeder dev/test `TestUsersByRoleSeeder` pour comptes par role.
- Ajout de `TEST_ACCOUNTS.md` et `TEST_SCENARIOS.md`.
- Correction du conflit de dependances Flutter 3.38.9 / Dart 3.10.8 entre `flutter_localizations`, `intl` et `flutter_form_builder`.
- Mise a jour de `flutter_form_builder` vers `^10.3.0+2`.
- Mise a jour controlee du lockfile Flutter.
- Retrait de `bluetooth_print`, dependance inutilisee qui bloquait la compilation Android recente.
- Alignement Android Gradle Plugin, Kotlin, Gradle wrapper et NDK pour Android SDK 36.
- Migration Android minSdk vers `flutter.minSdkVersion` (24) appliquee par Flutter 3.38.9.
- Ajout d'une compatibilite Gradle pour le plugin legacy `blue_thermal_printer`.
- Suppression d'un ancien token Bearer commente dans le client API Flutter.
- Validation : `flutter pub get` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug` OK.
- Validation finale audit UI : `flutter clean`, `flutter pub get`, analyse no-fatal, APK debug VPN, `flutter devices`, lancement sur SM A165F et logcat sans crash dashboard.
- Backend validation : Composer OK avec PHP 8.3 explicite, routes/cache/config OK, seeders comptes/demo OK.
- Comptes test : login API SUCCESS pour admin, commercial, livreur et depot sans afficher les tokens.
- Dette restante : `flutter analyze` strict conserve 751 issues historiques a nettoyer module par module.
- Correctifs smartphone : suppression des ecrans rouges `GetX improper use`, `CompteMenuController not found` et assertion Flutter de navigation observes sur fiche client/produits.
- Accueil : correction du `GetX improper use` du dashboard en observant explicitement les flags Rx avant les donnees non observables.
- Slider promotion et clients : protection des `PageController` non attaches pour eviter les assertions rouges pendant navigation/chargement.
- UI maquettes : header commun Push Sales avec logo, actions notification/message et titres larges.
- Produits : catalogue modernise avec recherche, categories, compteur et cartes produit visuelles.
- Credits : page encaissements modernisee avec KPI, fond clair et navigation par periodes.
- Stabilite : protections `PageController.hasClients` ajoutees sur tracking, livraison et detail depot.

## 2026-05-18 - Production validation hardening

- Ajout migrations non destructives : `audit_logs`, `client_user_access`, `delivery_trips`, `delivery_trip_stops`, `order_source`, `payment_due_date`, `credit_limit`.
- Enrichissement demo : promotions, coupon, audit log, liaison point de vente, tournee livreur.
- Point de vente : filtrage backend via `client_user_access` quand disponible.
- Workspace MVP : cartes plus compactes, bottom sheet detail, actions Maps, bons reception proteges.
- Auth sociale : Google/Facebook avec timeouts et erreurs lisibles au lieu de loading infini.
- Firebase : permission notification demandee et configuration non bloquante en dev.
- Android : permission `POST_NOTIFICATIONS` ajoutee.
- Documentation : ajout `REAL_DATA_TESTING.md` et `PRODUCTION_CHECKLIST.md`.
