# UI_AUDIT - Push Sales

Date : 2026-05-17

Objectif : inventaire des ecrans Flutter principaux, etat UX, risques connus et priorites de modernisation. Ce fichier ne contient aucun secret.

## Addendum Distributeur 2026-05-19

Objectif : stabiliser les pages Plus/operations du manager distributeur en mode reel.

- Les pages workspace et bottom sheets operationnels sont enveloppes dans `Material` pour eviter l'erreur Flutter `No Material widget found`.
- Le formulaire promotion distributeur est enrichi : type point de vente, type promotion, portee catalogue/categorie/produit/variant, remise, unite, minimum et validations.
- L'ajustement stock affiche un etat vide utile si aucun depot n'existe et propose de creer un depot avant d'activer l'action.
- Le dashboard distributeur conserve le filtre global/tous ou distributeur choisi.
- Les livraisons conservent le filtre par depot avec affichage par demande/statut depuis les donnees workspace reelles.
- Aucune action demo n'est introduite en `APP_ENV=vpn`.

## Inventaire des pages inspectees

| Module | Fichiers principaux | Role | Etat actuel |
| --- | --- | --- | --- |
| Accueil / splash | `lib/views/welcomepage.dart`, `lib/views/auth/checklogin.dart` | Entree application, verification session | Fonctionnel, a garder simple |
| Login | `lib/views/auth/loginpage.dart` | Authentification | Deja modernise, responsive a surveiller petit ecran |
| Signup | `lib/views/auth/signuppage.dart` | Creation compte | Deja modernise, validation formulaire a tester |
| Offline | `lib/views/signed/internet_error.dart` | Erreur reseau | Etat clair, scenario offline a retester |
| Home / navigation | `lib/views/signed/homepage.dart` | Shell, bottom navigation, drawer | Corrige : plus de `setState` pendant `build`, drawer responsive |
| Dashboard / stats | `lib/views/signed/menu/stats_page.dart` | KPIs ventes/livraison/admin | Corrige : separation stats ventes/livraison, anti-null, loaders |
| Clients | `lib/views/signed/menu/clients.dart`, `widgets/clients/listinglist.dart`, `listingicon.dart` | Recherche, filtres, liste/grille/carte | Modernise avec cartes, badges et filtres jours |
| Detail client | `widgets/clients/ficheclient.dart` | Info, commandes, historique, visite | Modernise avec onglets, KPIs et actions terrain |
| Nouveau/modifier client | `widgets/clients/editclient.dart` | Formulaire client + GPS | Modernise precedemment, GPS obligatoire clarifie |
| Catalogue / produits | `widgets/products/product_main_page.dart`, `widgets/commandes/products.dart`, `product_list.dart`, `fiche_product.dart` | Catalogue, ajout commande | Modernise partiellement, detail produit encore a harmoniser |
| Commandes | `widgets/orders/sale_orders_list.dart`, `show_order_detail.dart`, `widgets/commandes/orderitem_list.dart` | Liste et detail commande | Fonctionnel, detail commande a moderniser plus profondement |
| Tracking | `widgets/tracking/main_tracking_page.dart`, `orders_to_track.dart`, `tracking_detail.dart` | Suivi commande | Modernise precedemment avec timeline responsive |
| Livraison | `widgets/delivery/main_delivery_page.dart`, `orders_to_ship.dart`, `shipping_order_detail.dart` | Livraison, encaissement | Modernise partiellement, crash detail absent corrige precedemment |
| Transfert / chargement | `widgets/transfert/main_transfer_page.dart`, `orders_page.dart`, `tranfer_page.dart`, `show_detail_transfer.dart` | Preparation/chargement | Modernise partiellement, verifier confirmation terrain |
| Depots / stock | `menu/my_warehouses.dart`, `widgets/warehouses/show_my_warehouses.dart`, `show_detail_warehouse.dart` | Depots, stock, reception | Modernise precedemment; ecran noir corrige; detail stock a continuer |
| Reception depot | `product_purchase_list.dart`, `purchase_items_list.dart`, `fiche_purchase_product.dart` | Bon reception et ajustements | Modernise partiellement; fiche produit reception encore ancienne |
| Liste de prix | `widgets/pricelist/pricelist_page.dart`, `pricelist_widget.dart` | Prix et impression | Chargement infini corrige precedemment, impression a tester physiquement |
| Acteurs | `widgets/actors/actors_list.dart`, `actor_item.dart` | Acteurs/roles | Fonctionnel, UI encore simple |
| Creances / cash | `widgets/creances/*`, `widgets/credit/*` | Paiement, creances, credit | Fonctionnel a inspecter manuellement par role |
| Promotions / coupons | `widgets/promotions/*`, `widgets/coupons/*` | Promotions et coupons | Fonctionnel, UI ancienne par endroits |
| Notifications | Parametres + backend notification | Alertes systeme | Backend durci, FCM reel a tester avec cle restreinte |
| Chat | `widgets/account/message_chat.dart` | Messages utilisateurs | Connecte aux endpoints existants, a tester avec donnees reelles |
| Profil / parametres | `comptesetting.dart`, `settings_profile_page.dart`, `account/edit_personal_data.dart` | Profil, theme, notifications, imprimante | Modernise partiellement avec drawer/action panels |
| Impression Bluetooth | `widgets/settings/printer_config.dart`, `api/printer_controller.dart` | Imprimante thermique | Fonctionnel a tester avec imprimante physique |

## Correctifs appliques dans ce lot

- Dashboard : suppression du crash `Null check operator used on a null value` quand un role livraison n'a pas de `stats_day`.
- Dashboard : ajout d'etats de chargement separes pour stats ventes et stats livraison.
- Dashboard : appels API proteges contre les relances repetees dans `build()`.
- HomePage : suppression du `setState()` pendant `build()` lors du traitement de `client_id`.
- HomePage : ajout d'une cle stable dans `AnimatedSwitcher` pour eviter les assertions de reparentage.

## Validation realisee

- `flutter clean` : OK.
- `flutter pub get` : OK.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` : OK.
- `flutter analyze` strict : 751 issues historiques restantes.
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` : OK.
- `flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` : OK.
- `adb logcat` apres lancement : aucune trace `Null check operator`, `Failed assertion`, `EXCEPTION CAUGHT`, `RenderFlex overflowed` ou `BOTTOM OVERFLOWED`.

## Priorites restantes

1. Moderniser le detail commande et le detail livraison avec le meme style que les maquettes.
2. Harmoniser fiche produit commande/reception et boutons quantite.
3. Moderniser promotions, coupons, creances et acteurs.
4. Nettoyer les warnings stricts historiques par module.
5. Tester FCM et impression Bluetooth avec materiel/configuration reels.

## Addendum SuperAdmin 2026-05-18

Objectif : corriger le workspace SuperAdmin pour qu'il ne soit plus une page de visualisation, mais un espace d'administration exploitable.

### Corrections UI

- Les KPIs globaux SuperAdmin sont affiches uniquement dans `dashboard`.
- Les sections `distributors`, `actors`, `products` et `profile` utilisent des headers simples et adaptes a la page.
- Ajout recherche et filtres statut sur les listes SuperAdmin.
- Ajout formulaires bottom sheet pour creation/modification distributeur, acteur et produit.
- Ajout confirmations pour actions sensibles : desactivation distributeur, activation distributeur, desactivation acteur, activation acteur, reset password.
- Ajout consultation audit logs depuis le dashboard/action.
- Profil SuperAdmin enrichi avec sections compte, application, securite et services externes.

### Validation UI

| Page | Attendu | Resultat |
| --- | --- | --- |
| Dashboard | KPIs + supervision + raccourcis | OK |
| Distributeurs | Header simple + liste + recherche + filtres + ajouter | OK |
| Detail distributeur | Infos + acteurs + depots + produits + commandes + stats | OK |
| Acteurs | Header simple + liste + filtres + ajouter | OK |
| Detail acteur | Modifier, reset password, activer/desactiver | OK |
| Produits | Header simple + liste + ajouter + detail/variants | OK |
| Audit logs | Liste consultable en bottom sheet | OK |
| Profil | Parametres sans KPIs globaux | OK |

### Dette restante

- L'analyse stricte Flutter garde des warnings historiques non bloquants; la passe SuperAdmin compile et passe l'analyse no-fatal.

## SuperAdmin smartphone UX fixes 2026-05-18

Objectif : rapprocher le workspace SuperAdmin des maquettes fournies tout en gardant les vraies APIs Laravel.

### Corrections appliquees

- Search et filtres rendus plus compacts sur Distributeurs, Acteurs et Produits.
- Actions principales accessibles en haut via raccourcis/FAB; plus besoin de descendre en bas pour ajouter.
- Pull-to-refresh conserve sur les listes workspace.
- Gestion retour Android : si le clavier est ouvert, retour ferme le clavier au lieu de quitter l'application.
- Cartes acteurs : suppression du bouton `Profil`, ouverture du detail au clic sur la carte.
- Detail acteur : affichage metier moderne, sans JSON brut ni champs techniques.
- Creation acteur : workspace en dropdown, distributeur en dropdown nom/code/ID, email verifie par defaut.
- Detail distributeur : tabs scrollables, adresse formatee, onglet Acteurs alimente par relation API corrigee.
- Produits SuperAdmin : suppression des actions panier, creation via categorie/distributeur dropdowns, categorie rapide, detail `Infos / Variants`.
- Profil : bottom sheets Firebase, Google Maps, Bluetooth printer et Google/Facebook Login.
- Messages : snackbars remplaces par toasts premium pour les actions SuperAdmin.

### Validation

| Point | Resultat |
| --- | --- |
| API relation distributeur-acteur | OK |
| Login acteur cree par SuperAdmin | OK |
| Creation categorie/produit/variant | OK |
| `workspace_page.dart` analyse ciblee | OK |
| APK debug VPN | OK |
| Test scrcpy | KO environnement, ADB refuse `10.212.134.1:40459` |

### Dette restante

- Validation visuelle smartphone a refaire apres reconnexion ADB.
- Warnings Flutter stricts historiques hors workspace SuperAdmin a nettoyer par module.

## SuperAdmin produits / variants 2026-05-19

Objectif : rendre le detail produit lisible et coherent avec le role SuperAdmin.

Corrections UI :
- Variants regroupes par famille/type avec sections repliables.
- Ligne variant cliquable pour ouvrir la modification, sans bouton `Modifier` repete sur chaque ligne.
- Suppression par glissement lateral, avec confirmation et securite backend.
- Affichage centre sur catalogue maitre : famille, detail, SKU, conditionnement.
- Mention claire : prix et stock sont geres par les distributeurs/depots, pas par SuperAdmin.

Regle UX/metier :
- SuperAdmin cree et organise le catalogue global lisible par les distributeurs.
- Le distributeur fixe ses prix, gere ses depots et alimente ses stocks.
- L'interface SuperAdmin ne doit pas donner l'impression qu'il gere les prix ou stocks operationnels.

Validation :
- API `Serviette Awane` : 41 variants regroupes correctement.
- Build APK debug VPN OK.
- Installation et lancement smartphone OK sur SM A165F.

## SuperAdmin produits / categories 2026-05-19

Objectif : simplifier la gestion catalogue sur petit smartphone.

Corrections UI :
- Filtre `Categorie` ajoute dans la barre compacte Produits, avant `Statut`.
- Bouton `Ajouter categorie` ajoute aux actions rapides de l'onglet Produits.
- Formulaire produit nettoye : plus de bouton categorie interne pendant creation/modification.
- Edition produit : categorie et distributeur sont precharges avec des valeurs dropdown sures, meme apres chargement asynchrone des references.

Regle metier affichee :
- SuperAdmin organise categories, produits et variants du catalogue maitre.
- Les prix, stocks et mouvements restent dans le perimetre distributeur/depot.

## Variants options:value 2026-05-20

Objectif : afficher et modifier les variants comme des combinaisons metier lisibles au lieu d'une liste plate.

Corrections UI :
- Formulaire variant avec nom, SKU, conditionnement indicatif et section `Options du variant`.
- Options disponibles en dropdown fixe : Couleur, Marque, Format, Taille, Type.
- Un variant peut contenir 1 a 5 options, sans obligation de tout renseigner.
- Apercu de signature lisible, par exemple `Type: Normale | Taille: x09`.
- Chips `Option: Valeur` visibles sur chaque carte variant.
- Groupage intelligent par Type, sinon Marque, sinon Format, sinon Couleur, sinon Taille, sinon Autres.
- Tap variant = edition, swipe gauche = suppression/desactivation, swipe droite = modification rapide.
- Aucun bouton `Modifier` repete sur chaque ligne.

Validation :
- Analyse Flutter no-fatal OK.
- APK debug VPN OK.
- Installation et lancement SM A165F OK.
- Logcat cible sans `No Material widget found`, `DropdownButton` ou crash fatal.
