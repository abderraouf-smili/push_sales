# UI_AUDIT - Push Sales

Date : 2026-05-17

Objectif : inventaire des ecrans Flutter principaux, etat UX, risques connus et priorites de modernisation. Ce fichier ne contient aucun secret.

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
