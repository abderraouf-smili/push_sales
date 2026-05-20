# PROJECT_HISTORY

## 2026-05-19 - Stabilisation actions reelles Distributeur et UI Plus

- Zone modifiee : workspace Flutter Distributeur, formulaires promotions/stock, enveloppes Material des sheets workspace, documentation de validation.
- Objectif : remplacer les messages informatifs par des actions API reelles sur les operations visibles du manager distributeur et corriger les erreurs UI observees dans Promotions, Livraisons et Creances.
- Resume : le formulaire promotion est maintenant un vrai formulaire metier avec type point de vente, type promotion, portee catalogue/categorie/produit/variant, remise, unite et minimum; l'ajustement stock est bloque proprement tant qu'aucun depot n'existe et guide vers la creation depot; les pages/sheets workspace sont protegees par `Material` pour eviter `No Material widget found`.
- Backend : routes reelles `/api/distributor/warehouses`, `/clients`, `/coupons`, `/promotions`, `/stock/adjust` et `/variants/{id}/price` verifiees dans `route:list`.
- Risque : moyen-faible, car les changements restent centres sur le branchement UI vers les APIs existantes sans modifier les calculs metier.
- Impact logique metier : logique existante conservee; le Distributeur gere ses operations reelles, tandis que SuperAdmin reste responsable du catalogue maitre.
- Tests effectues : syntaxe PHP controller workspace OK, `route:list` distributeur/superadmin OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, APK debug VPN OK.
- Test smartphone : ADB `10.212.134.2:43903` connecte, APK installe, application lancee, logcat de demarrage sans `FATAL EXCEPTION`, `FlutterError`, `No Material widget found`, assertion ou overflow detecte.
- Tests a faire : validation tactile longue sur SM A165F des formulaires depot/client/promotion/coupon/livraisons/creances.

## 2026-05-19 - Produits SuperAdmin categories et edition pre-remplie

- Zone modifiee : onglet Produits SuperAdmin Flutter, payload produits workspace reel, action categorie Laravel.
- Objectif : rendre la gestion catalogue SuperAdmin plus fluide sur smartphone avec categorie accessible au bon endroit et formulaires qui chargent les donnees existantes.
- Resume : ajout du filtre compact par categorie avant le filtre statut, ajout de l'action `Ajouter categorie` dans la barre d'actions Produits, retrait du bouton categorie dans le formulaire produit, et correction du pre-remplissage categorie/distributeur lors de la modification produit.
- Backend : le payload `productItems` expose `category_id`, `category_label`, `distributor_id` et `distributor_label` pour alimenter les filtres et dropdowns sans saisie manuelle d'ID.
- Risque : faible, changement limite a l'UX/catalogue SuperAdmin; aucune logique de prix/stock n'est transferee au SuperAdmin.
- Impact logique metier : logique conservee; SuperAdmin gere le catalogue maitre et les variants, les distributeurs restent responsables des prix et stocks par depot.
- Tests effectues : syntaxe PHP OK, routes categories/produits/variants OK, analyse Flutter no-fatal OK, APK debug VPN OK, installation et lancement smartphone `10.212.134.2:44261` OK.
- Tests a faire : verification visuelle manuelle du filtre categorie et de la modification produit sur le smartphone.

## 2026-05-18 - SuperAdmin smartphone UX fixes

- Zone modifiee : workspace Flutter SuperAdmin, APIs Laravel SuperAdmin, relation produit/distributeur, authentification comptes crees par SuperAdmin, documentation QA.
- Objectif : rapprocher le workspace SuperAdmin des maquettes fournies sur petit smartphone, supprimer les details bruts, rendre les formulaires intelligents et verifier les actions reelles hors mode demo.
- Resume : ajout d'une barre d'actions rapide SuperAdmin, recherche/filtres compacts, pull-to-refresh conserve, cartes cliquables, details distributeur/acteur/produit modernises, toasts premium, bottom sheets services externes, dropdown distributeur/categorie, creation categorie, creation/modification variant, et gestion du retour Android pour fermer le clavier avant de quitter l'ecran.
- Backend : correction du filtrage acteurs par distributeur via `distributor_id` et fallback `id_distributor`, ajout de l'email verifie par defaut/reset pour les acteurs SuperAdmin, enrichissement des payloads produits avec categorie/distributeur lisibles, et relation `Product::Distributor`.
- UI : les boutons principaux sont accessibles en haut/FAB; le bouton panier est retire du workspace SuperAdmin; les donnees techniques `id/meta/kind` et JSON bruts sont masquees au profit d'informations metier lisibles.
- Risque : moyen-faible, car les modifications restent ciblees SuperAdmin et les anciens workspaces/API metier ne sont pas supprimes.
- Impact logique metier : logique existante conservee; les operations SuperAdmin utilisent les vraies APIs et ecrivent l'audit sans simulation demo.
- Tests effectues : `route:list --path=api/superadmin` OK, `migrate --force` OK, login SuperAdmin OK, dashboard OK, creation distributeur OK, creation acteur lie distributeur OK, `email_verified_at` OK, login acteur cree OK, detail distributeur acteurs OK, creation categorie OK, creation produit OK, creation variant OK, audit logs OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, APK debug VPN OK.
- Test smartphone : ADB `10.212.134.1:40459` refuse la connexion (`10061`), donc installation/scrcpy non executes dans cette passe.
- Prochaine etape : reconnecter ADB wireless et valider visuellement les sheets SuperAdmin sur SM A165F; continuer le nettoyage des warnings Flutter stricts historiques.

## 2026-05-18 - Mode reel workspace et garde-fou anti-demo

- Zone modifiee : configuration Flutter, API client Flutter, navigation workspace Flutter, route Laravel workspace, documentation mode reel.
- Objectif : empecher les actions/pages demo en `APP_ENV=vpn|real|production` et utiliser les donnees reelles de la base pour les tests terrain.
- Resume : ajout de `APP_ENV=demo/real`, bascule automatique vers `/api/workspace/real` hors demo, blocage Flutter de `/api/workspace/mvp` avec `DEMO_ACTION_NOT_ALLOWED_IN_REAL_ENV`, retrait des messages visibles `donnees demo/action demo/panier demo`, renommage de `WorkspaceMvpPage` en `WorkspacePage`.
- Backend : ajout de l'alias `/api/workspace/real` compatible avec les donnees existantes; les APIs SuperAdmin et legacy metier restent les sources reelles.
- Risque : moyen-faible, car le changement force le mode reel sans supprimer `/workspace/mvp` pour l'environnement `APP_ENV=demo`.
- Impact logique metier : logique existante conservee; les actions non encore reliees a une API reelle sont bloquees proprement au lieu de simuler.
- Tests effectues : `migrate --force` OK sans changement, `route:list --path=api` OK, tests HTTP SuperAdmin/commercial/depot/livreur/point_vente OK, `flutter clean`, `flutter pub get`, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, APK debug VPN OK.
- Tests a faire : test manuel smartphone des boutons workspace en mode `APP_ENV=vpn`, puis implementation de l'API reelle de commande Point de Vente.
- Prochaine etape : brancher la validation panier Point de Vente sur une API metier reelle `order_source=point_vente`.

## 2026-05-19 - Profil Distributeur oriente operations metier reelles

- Zone modifiee : workspace Flutter Distributeur, API workspace Laravel, navigation mobile par role.
- Objectif : transformer le profil distributeur en espace operationnel coherent : pilotage, commandes, produits exploitables, depots, clients et menu Plus, sans revenir au mode demo.
- Resume : la navigation distributeur devient `Accueil`, `Commandes`, `Produits`, `Depots`, `Clients`, `Plus`; le dashboard conserve les statistiques et alertes, tandis que les autres onglets n'affichent plus les KPIs globaux. Les produits restent issus du catalogue maitre cree par SuperAdmin, et le distributeur dispose d'une vue detail produit/variants orientee prix, stock depot, disponibilite et promotions.
- Backend : enrichissement des produits workspace avec variants, groupes, libelles, stock par depots du distributeur et actions operationnelles. Les sections `promotions`, `coupons`, `deliveries` et `more` sont routees dans le workspace reel.
- UI : detail produit distributeur en bottom sheet moderne avec onglets `Infos` / `Variants`, variants groupes, cartes cliquables, aucun bouton panier pour distributeur, et actions `Prix` / `Stock` expliquees selon les endpoints existants.
- Risque : moyen-faible; les changements clarifient les responsabilites sans changer les calculs metier ni supprimer de donnees.
- Impact logique metier : logique existante conservee; SuperAdmin gere le catalogue global, Distributeur gere exploitation commerciale, prix, stock et operations terrain.
- Tests effectues : `php -l WorkspaceMvpController.php` OK, `php -l WorkspaceResolver.php` OK, `route:list --path=api/workspace` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK sans erreur bloquante, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Blocage device : ADB `10.212.134.2:39423` non joignable (ping/TCP/adb KO); APK genere pret a installer des que le smartphone est reconnecte.
- Prochaine etape : validation tactile du profil distributeur sur smartphone et transformation progressive des actions prix/stock en formulaires complets si les endpoints legacy sont confirmes role par role.

## 2026-05-18 - Workspace SuperAdmin exploitable CRUD et audit

- Zone modifiee : backend Laravel SuperAdmin, routes API, migration non destructive, workspace Flutter SuperAdmin, documentation de validation.
- Objectif : passer le profil SuperAdmin d'une visualisation MVP a une vraie gestion plateforme avec operations, confirmations, audit logs et tests.
- Resume : ajout de `SuperAdminController`, routes `/api/superadmin/*`, CRUD distributeurs/acteurs/produits, detail distributeur avec acteurs/depots/produits/commandes/stats, audit logs consultables, et formulaires Flutter pour creation/modification/actions sensibles.
- UI : les KPIs globaux SuperAdmin sont maintenant limites au Dashboard; les pages Distributeurs, Acteurs, Produits et Profil affichent des headers simples avec recherche/filtres/actions adaptees.
- Risque : moyen, car la passe ajoute des operations d'administration; le guard SuperAdmin et les validations limitent l'exposition, et les anciens endpoints/workspaces restent compatibles.
- Impact logique metier : logique existante conservee; ajout d'operations de supervision et de gestion non destructives avec audit.
- Tests effectues : `migrate --force` OK, seeders test/demo OK, route:list SuperAdmin OK, login SuperAdmin OK, permissions/workspace OK, dashboard OK, CRUD distributeur/acteur/produit OK, audit logs OK, analyse Flutter no-fatal OK, APK debug VPN OK.
- Tests a faire : validation manuelle longue sur smartphone des formulaires SuperAdmin et nettoyage progressif des warnings Flutter stricts historiques.
- Prochaine etape : brancher une UX plus riche de creation/modification variants et poursuivre la meme profondeur CRUD sur le workspace Distributeur.

## 2026-05-19 - Stabilisation Produits/Acteurs et profil Distributeur reel

- Zone modifiee : `WorkspaceMvpController`, workspace Flutter reel, listes et formulaires SuperAdmin/Distributeur.
- Objectif : corriger les derniers blocages observes sur smartphone : onglet Produits, edition acteur vide, affectation acteur existant, et repetition des KPIs dans le profil Distributeur.
- Resume : correction du chargement Produits en mode reel, pre-remplissage robuste du formulaire acteur, affichage des noms dans l'affectation acteur existant, detach acteur par swipe dans le detail distributeur, et masquage des statistiques hors dashboard pour SuperAdmin et Distributeur.
- Distributeur : les onglets acteurs, depots et stock sont maintenant alimentes par le distributeur rattache a l'acteur connecte; les KPIs commandes/livraisons/encaissements/stock total restent uniquement dans le dashboard.
- Risque : faible a moyen, car les changements filtrent mieux les donnees sans changer les routes historiques ni les calculs metier.
- Impact logique metier : logique existante conservee; meilleure application du scope distributeur et meilleure ergonomie d'administration.
- Tests effectues : login SuperAdmin OK, `workspace/real` produits OK, login manager distributeur OK, sections acteurs/warehouses/stock/products Distributeur OK avec `stats: []` hors dashboard, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, APK debug VPN OK, installation et lancement sur SM A165F `10.212.134.2:32895` OK.
- Tests a faire : validation tactile longue des formulaires Produits/Acteurs et du detach par swipe sur plusieurs distributeurs reels.
- Prochaine etape : poursuivre la meme profondeur sur les workflows Distributeur CRUD complets prix/promotions/stock.

## 2026-05-18 - Socle B2B workspaces, permissions et donnees demo etendues

- Zone modifiee : backend Laravel permissions/workspaces, seeders demo, controller Flutter permissions, documentation projet.
- Objectif : preparer Push Sales comme plateforme B2B multi-workspace sans casser les routes existantes ni les ecrans Flutter actuels.
- Resume : ajout d'un resolver workspace Laravel (`superadmin`, `distributeur`, `commercial`, `depot`, `livreur`, `point_vente`), ajout du champ non destructif `actor_profile.workspace_type`, enrichissement de `/api/permissions` avec `menus`, `actions`, `workspace_type` et conservation du format legacy `permission`/`type_actor`.
- Seeders : ajout des comptes SuperAdmin, Manager Distributeur et Point de Vente; extension des donnees demo a 20 produits, 10 points de vente, variants, prix, stock et workflows existants.
- Flutter : `PermissionsController` lit maintenant le contrat workspace sans casser les anciennes permissions.
- Risque : moyen, car le socle roles/workspaces touche l'authz et les seeders, mais les routes metier et formats legacy restent compatibles.
- Impact logique metier : logique existante conservee; ajout de visibilite workspace et de donnees dev/test.
- Tests effectues : migration OK, seeders OK, routes OK, login + permissions verifies pour 6 comptes, `flutter clean` OK, `flutter pub get` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug` OK, APK installe/lance sur SM A165F via ADB.
- Warnings restants : `flutter analyze` strict conserve 762 issues historiques non bloquantes, surtout style, `print`, deprecations et widgets mutables.
- Point d'attention : `AGENTS.md` est marque supprime dans le working tree avant cette finalisation; non restaure pour ne pas ecraser une action utilisateur.
- Prochaine etape : implementer les vrais ecrans UI/API SuperAdmin, Manager Distributeur et Point de Vente au-dessus de ce contrat workspace.

## 2026-05-18 - Profil commercial moderne connecte API

- Zone modifiee : Flutter mobile, dashboard commercial, clients, fiche client, tracking commandes et catalogue produits.
- Objectif : rapprocher le parcours commercial des maquettes fournies tout en gardant les controllers, endpoints et workflows metier existants.
- Resume : ajout d'un dashboard commercial dedie avec carte acteur, KPI commandes/visites/clients/CA, visites du jour et repartition types clients; refonte de la page clients avec recherche, filtres `Tous / A visiter / En retard / Credit`, cartes clients lisibles et actions existantes conservees; modernisation de la fiche client en style dossier commercial; refonte du tracking avec filtres d'etat, KPI et progression de commande; ajout d'une page detail produit commerciale montrant variantes, prix et regles commerciales visibles.
- Donnees : seeders `TestUsersByRoleSeeder` et `DemoDataSeeder` executes avec succes pour alimenter les comptes et donnees demo.
- Risque : moyen-faible, car le changement touche plusieurs ecrans commerciaux mais reste limite a l'UI, aux filtres locaux et a la presentation des donnees existantes.
- Impact logique metier : aucun changement de routes API, formats JSON, calculs prix/stock/commande/livraison/paiement, permissions ou authentification.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter devices` OK, lancement sur SM A165F `10.212.134.2:35599` OK avec API profil/acteur/permissions en 200.
- Tests a faire : validation manuelle avec le compte commercial sur les onglets Accueil, Clients, Tracking, Produits, fiche client, detail produit et creation commande depuis le flux client.
- Prochaine etape : relier les boutons visuels `Ajouter` du detail catalogue au flux commande seulement quand un client est selectionne, ou les masquer hors contexte commande.

## 2026-05-17 - Parcours livreur moderne stock, delivery et trajets

- Zone modifiee : Flutter mobile, navigation HomePage et ecrans livreur.
- Objectif : adapter l'application au role livreur avec une interface utile terrain : stock mobile, demandes de livraison et trajets, au lieu de favoris/produits generiques.
- Resume : ajout de `DeliveryStockMobilePage`, `DeliveryRequestsPage` et `DeliveryRoutesPage`; la navigation livreur affiche maintenant Accueil, Stock, Delivery, Trajets, Profil. Le stock mobile reutilise `getCurrentStockMobile`, les livraisons reutilisent `getPurchaseOrdersToShip`, et les trajets reutilisent `getOptimizedRoute` quand la localisation est disponible.
- UX : cartes modernes, filtres par etat, recherche stock, details produit en bottom sheet, compteurs livraison, actions visibles pour bon de reception/details et trajet optimise.
- Risque : moyen-faible, car les changements sont limites a l'UI/navigation du role livreur et reutilisent les controllers/endpoints existants.
- Impact logique metier : aucun changement de routes API, JSON, calcul stock/prix/commande/livraison/paiement ou authentification.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK apres un retry lie a un verrou Windows temporaire sur un asset.
- Tests a faire : reconnecter le smartphone ADB, installer l'APK, valider le compte livreur sur dashboard, stock mobile, delivery, detail livraison et trajets.
- Prochaine etape : moderniser le detail livraison/encaissement avec le meme design et tester l'impression Bluetooth sur appareil physique.

## 2026-05-17 - GUI style maquettes et durcissement Obx/PageController

- Zone modifiee : Flutter header commun, HomePage, produits, credits, tracking, livraison, depot detail.
- Objectif : rapprocher l'interface des maquettes blanches/bleues fournies et continuer la chasse aux ecrans rouges GetX/PageController.
- Resume : `AppPageHeader` affiche maintenant une entete type maquette avec logo Push Sales, actions notification/message et titre large; le menu drawer flottant est deplace pour ne plus couvrir le logo; le catalogue produits gagne recherche, chips categorie, compteur et cartes produits modernes; la page credits gagne fond clair, KPI encaissement et rendu par periodes; les navigations PageController tracking/livraison/depot sont protegees par `hasClients`; scan ciblé des `Obx` effectue pour verifier les usages sans variable observable evidente.
- Risque : moyen-faible, car les changements sont UI et defensifs; aucune route API, aucun format JSON et aucun calcul metier n'a ete modifie.
- Impact logique metier : aucun changement de logique metier.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Tests non termines : lancement sur `10.212.134.5:44217` impossible car `adb connect` termine en timeout et `flutter devices` ne detecte aucun smartphone Android.
- Prochaine etape : reconnecter ADB wireless puis lancer `flutter run -d 10.212.134.5:44217 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` et valider visuellement les pages.

## 2026-05-17 - Correctif dashboard GetX et PageController

- Zone modifiee : Flutter dashboard, slider promotion, filtres clients.
- Objectif : corriger l'ecran rouge `GetX improper use` signale sur la page d'accueil et l'assertion `PageController is not attached to a PageView` vue pendant le test device.
- Resume : les blocs `Obx` du dashboard lisent maintenant toujours des flags observables (`statsReady`, `deliveryStatsReady`, `statsLoading`, `deliveryStatsLoading`) avant d'afficher les donnees simples; le slider promotion ne cree plus de timer dans `build`, annule son timer au `dispose` et verifie `hasClients`; les boutons Liste/Grille/Carte clients ne pilotent plus un `PageController` non attache.
- Risque : faible, car les changements sont UI/runtime defensifs et ne modifient aucune route API, aucun format JSON et aucun calcul metier.
- Impact logique metier : aucun changement de logique metier.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter run -d 10.212.134.5:41605 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, redemarrage ADB propre et `logcat` sans `improper use of a GetX`, `PageController is not attached`, `Failed assertion`, `Null check operator` ou overflow filtre.
- Tests a faire : validation visuelle manuelle sur scrcpy apres navigation dashboard -> clients -> produits -> livraison.
- Prochaine etape : continuer le nettoyage des warnings historiques et la verification page par page.

## 2026-05-17 - Audit UI global et correctifs crash dashboard

- Zone modifiee : Flutter dashboard, navigation HomePage, documentation audit UI.
- Objectif : traiter les erreurs visibles sur smartphone (`Null check operator used on a null value` et assertion Flutter) et demarrer l'audit global des pages demande avant nouvelle modernisation massive.
- Resume : creation de `UI_AUDIT.md` avec inventaire des pages principales; separation des etats statistiques ventes et livraison dans `StatController`; protection du dashboard contre `stats_day` null pour les roles livraison; suppression de l'appel API repete dans `build`; suppression du `setState()` pendant `build()` dans `HomePage`; ajout d'une cle stable autour de l'ecran courant pour `AnimatedSwitcher`.
- Risque : moyen-faible, car les changements sont defensifs/UI et ne changent ni routes API, ni JSON, ni calculs metier.
- Impact logique metier : aucun changement de logique metier; les stats restent fournies par les endpoints Laravel existants.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter devices` OK, `flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `adb logcat` sans `Null check operator`, `Failed assertion` ou `EXCEPTION CAUGHT` apres lancement.
- Tests a faire : validation visuelle manuelle sur scrcpy du dashboard pour admin/commercial/livreur/depot, puis poursuite des ecrans commande/livraison/stock.
- Prochaine etape : moderniser le detail commande et le flux livraison/encaissement avec le style des maquettes.

## 2026-05-17 - Validation finale audit UI et donnees demo

- Zone modifiee : validation Flutter/Laravel, documentation.
- Resume : validation complete apres `flutter clean`, regeneration APK, lancement sur SM A165F, execution des seeders de comptes et donnees demo, verification des 4 logins de test sans afficher les tokens.
- Backend : `composer install` OK avec PHP 8.3 explicite. Le `composer` du PATH utilise encore PHP 8.1 et echoue; utiliser `C:\tools\php83\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar install --no-interaction`.
- API : `api/configuration` retourne `401` avec `Accept: application/json` si non authentifie; l'appel sans en-tete JSON peut produire une redirection Laravel vers `login` inexistante.
- Tests effectues : `flutter clean`, `flutter pub get`, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter analyze` strict, `flutter build apk --debug`, `flutter devices`, `flutter run -d 10.212.134.4:37055 --debug --no-resident`, `composer install` PHP 8.3, `route:list`, `config:clear`, `cache:clear`, seeders `TestUsersByRoleSeeder` et `DemoDataSeeder`.
- Resultats : APK debug OK, app lancee sur smartphone, comptes `admin/commercial/livreur/depot.test@pushsales.local` connectes avec `Test@123456`.
- Risque : moyen-faible; aucune logique metier existante modifiee.

## 2026-05-17 - Correctifs runtime GetX smartphone

- Zone modifiee : Flutter HomePage, CompteSetting, fiche client, produits, edition profil.
- Probleme : ecrans rouges signales sur smartphone (`GetX improper use`, `CompteMenuController not found`, assertion Flutter `framework.dart` pendant navigation).
- Resume : reinjection defensive de `CompteMenuController` apres logout/session reset, suppression de l'`AnimatedSwitcher` autour des pages principales pour eviter les assertions de reparentage, correction d'un `Obx` fiche client qui ne lisait pas toujours d'observable, deplacement du chargement produits hors de `build()`.
- Risque : faible, car changements UI/runtime uniquement; aucune route API, aucun JSON et aucun calcul metier modifies.
- Tests effectues : `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `flutter run -d 10.212.134.5:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK, `adb logcat` sans les erreurs rouges signalees apres lancement.

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

## 2026-05-18 - MVP B2B testable par workspace

- Zone modifiee : backend Laravel workspace, routes API, seeders/verifications, HomePage Flutter, page MVP Flutter, documentation de tests.
- Objectif : rendre les comptes SuperAdmin, Distributeur, Depot, Livreur et Point de Vente navigables avec des pages non vides et alimentees par API.
- Resume : ajout de `/api/workspace/mvp`, enrichissement du contrat `WorkspaceResolver`, ajout d'une page Flutter generique responsive `WorkspaceMvpPage`, branchement HomePage sur les workspaces MVP, bascule du role livreur vers les pages MVP `stock_mobile/delivery/routes` pour eviter l'ancien ecran blanc.
- Backend : `WorkspaceMvpController` agrege les donnees existantes (acteurs, distributeurs, clients, produits, depots, stock, commandes, purchase orders, transactions) sans modifier les anciens endpoints.
- Compatibilite : `/api/permissions` et `/api/permissions/workspace` conservent le format legacy et ajoutent `workspace_type`, `menus`, `actions`, `profile`, `actor`, `user`.
- Securite : aucun token documente; tests login realises sans afficher les tokens; aucune suppression destructive.
- Risque : moyen-faible, car ajout d'un endpoint de lecture/agrégation et branchement UI pour workspaces manquants; logique metier existante conservee.
- Impact logique metier : aucun calcul de prix/stock/commande modifie; les actions non finalisees dans les pages MVP donnent un feedback demo au lieu d'executer une action destructive.
- Tests effectues : `composer install` OK, `migrate` OK, seeders OK, login 6 comptes OK, permissions/workspace 6 comptes OK, endpoints `clients/products/currentorders/warehouses/topackorders/toshiporders/currentstock` OK, `flutter clean/pub get/analyze --no-fatal.../build apk` OK, `flutter run --no-resident` sur SM A165F OK.
- Tests a faire : validation manuelle longue des anciens ecrans commerciaux profonds, impression Bluetooth, notifications Firebase et cartes avec cles restreintes.
- Prochaine etape : reduire progressivement les 762 issues `flutter analyze` strict par module historique.

## 2026-05-18 - Durcissement production validation

- Zone modifiee : migrations Laravel, workspace MVP, seeders demo, auth sociale Flutter, Firebase Messaging, Maps fallback, documentation production.
- Objectif : rendre le MVP B2B plus fiable pour tests reels sans loading infini, pages blanches ou donnees vides.
- Resume : ajout des tables `audit_logs`, `client_user_access`, `delivery_trips`, `delivery_trip_stops`; ajout de `order_source`, `payment_due_date` et `client.credit_limit`; seed demo enrichi avec promotions, coupon, audit, liaison point de vente et tournee; dashboard/listes MVP densifies pour petit smartphone.
- Auth : Google/Facebook ont maintenant timeouts et messages clairs si les vraies cles Firebase/Facebook ne sont pas configurees.
- Notifications : permission Firebase Messaging demandee et configuration non bloquante si Firebase est absent.
- Maps : bouton externe Google Maps ajoute comme fallback.
- Risque : moyen-faible, migrations progressives et UI defensive; aucune suppression de donnees ni changement de calcul metier.
- Impact logique metier : intention existante conservee; ajout de champs/supports pour audit, credit, point de vente et trajets.
- Tests effectues : migrations OK, seeders OK, login/workspace 6 comptes OK, endpoints metier/promotions/coupons OK, analyse no-fatal OK, APK debug OK. Un lancement SM A165F avait ete valide avant clean; sur la passe finale le port ADB wireless n'etait plus joignable.
- Tests a faire : validation Gmail/Facebook avec vraies cles, push Firebase reel, impression Bluetooth avec materiel physique, build release signe, relance device quand le nouveau port ADB wireless est disponible.


## 2026-05-19 - Variants SuperAdmin groupes et responsabilites catalogue/prix/stock

- Zone modifiee : workspace Flutter SuperAdmin Produits, API Laravel SuperAdmin variants, documentation de validation.
- Objectif : rendre le detail produit plus intelligent pour les variants et clarifier la responsabilite metier : SuperAdmin gere le catalogue maitre, les distributeurs gerent prix et stock par depot.
- Resume : les variants sont maintenant regroupes par famille/type (`Confort`, `Coton`, etc.), avec ligne cliquable pour modification et suppression par glissement. La suppression est bloquee cote API si le variant est deja utilise dans stock, prix, commandes, promotions ou operations stock.
- UI : l'onglet Variants n'affiche plus de bouton `Modifier` par ligne; un clic sur la carte ouvre l'edition. L'affichage met en avant detail, SKU et conditionnement, avec mention que prix/stock sont geres par distributeur.
- Backend : ajout payload variant enrichi (`group_label`, `detail_label`, `sku`, `package`, `stock_label`) et route de suppression defensive `/api/superadmin/variants/{id}/delete`.
- Risque : faible, car aucune suppression automatique n'est autorisee si le variant est rattache a des donnees metier.
- Impact logique metier : clarification sans casser l'existant; SuperAdmin reste proprietaire du catalogue maitre, distributeur reste proprietaire des prix et stocks operationnels.
- Tests effectues : `php -l SuperAdminController.php` OK, routes SuperAdmin produits/variants OK, API produit `Serviette Awane` OK avec 41 variants groupes, APK debug VPN OK, installation et lancement sur SM A165F `10.212.134.2:44261` OK.
- Tests a faire : validation tactile sur smartphone du clic variant, swipe suppression et edition variant dans un cas reel non utilise.

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

## 2026-05-17 - Fonctionnalisation espace livreur stock, delivery et trajets

- Zone modifiee : Flutter livreur (`StatsPage`, `OrderController`, stock mobile) et donnees demo Laravel (`DemoDataSeeder`).
- Objectif : garder la nouvelle UI livreur moderne mais la brancher sur les donnees backend afin d'eviter les pages blanches et les chiffres dupliques.
- Resume : le dashboard livreur conserve le grand cadre de pilotage et ajoute un second cadre `Etat stock camion` calcule depuis les commandes a livrer; la page stock mobile affiche maintenant uniquement la liste produits/detail avec filtres; le chargement delivery n'attend plus la geolocalisation/carte pour afficher les commandes; les erreurs GPS/maps passent en etat degrade au lieu de laisser l'ecran blanc.
- Backend demo : ajout de commandes livreur supplementaires (`in_way`, `shipped`, `paid`) et de quantites stock camion variees pour tester `a livrer`, `retour` et `livre`.
- Risque : moyen-faible, car les changements restent UI/donnees demo/defensifs; aucune route API, aucun format JSON et aucun calcul metier existant n'ont ete modifies.
- Impact logique metier : aucun changement de logique metier; les nouveaux indicateurs lisent les etats existants Laravel.
- Tests effectues : `php -l DemoDataSeeder.php` OK, seeders `TestUsersByRoleSeeder` et `DemoDataSeeder` OK, endpoints login/currentstock/toshiporders OK, `dart format` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` OK.
- Blocage device : `10.212.134.3:35079` ne repond pas au ping/TCP/ADB; `flutter devices` ne liste aucun smartphone Android.
- Prochaine etape : reconnecter le telephone en debogage sans fil, installer l'APK genere et valider visuellement les trois onglets livreur.

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
