# TEST_RESULTS - Push Sales

Date : 2026-05-18

## Backend

| Test | Resultat |
| --- | --- |
| `composer update lcobucci/clock --with-all-dependencies` | OK, `lcobucci/clock` 3.0.0 -> 3.5.0 pour compatibilite PHP 8.3 |
| `composer install` | OK sous PHP 8.3.31 |
| `php artisan migrate --force` | OK, rien a migrer |
| `php artisan db:seed --class=TestUsersByRoleSeeder --force` | OK |
| `php artisan db:seed --class=DemoDataSeeder --force` | OK |
| `php artisan config:clear` | OK |
| `php artisan cache:clear` | OK |
| `php artisan route:list --path=api` | OK, inclut `/api/permissions`, `/api/permissions/workspace`, `/api/workspace/mvp` |
| `composer audit --no-interaction` | KO non bloquant : 2 advisories connus (`firebase/php-jwt` low, `laravel/framework` medium) et 2 packages abandonnes |

## Login et workspaces

| Compte | Workspace attendu | Resultat API |
| --- | --- | --- |
| `superadmin@pushsales.local` | `superadmin` | OK, dashboard MVP retourne 15 items |
| `manager.distributeur@pushsales.local` | `distributeur` | OK, depots MVP retourne 21 items |
| `commercial.test@pushsales.local` | `commercial` | OK, clients MVP retourne 9 items |
| `depot.test@pushsales.local` | `depot` | OK, preparations MVP retourne 11 items |
| `livreur.test@pushsales.local` | `livreur` | OK, delivery MVP retourne 11 items |
| `pointvente.test@pushsales.local` | `point_vente` | OK, catalogue MVP retourne 30 items |

## Endpoints metier verifies

| Endpoint | Compte | Resultat |
| --- | --- | --- |
| `/api/clients` | commercial | SUCCESS, 9 items |
| `/api/products` | commercial | SUCCESS, 53 items |
| `/api/currentorders` | commercial | SUCCESS |
| `/api/warehouses` | manager distributeur | SUCCESS, 1 item legacy |
| `/api/topackorders` | depot | SUCCESS, 1 item legacy |
| `/api/toshiporders` | livreur | SUCCESS, 4 items |
| `/api/currentstock` | livreur | SUCCESS, 20 items |

## Flutter

| Commande | Resultat |
| --- | --- |
| `flutter clean` | OK |
| `flutter pub get` | OK |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | OK, aucune erreur bloquante |
| `flutter analyze` | KO strict, 762 issues historiques non bloquantes |
| `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` | OK |
| `flutter devices` | OK, SM A165F detecte sur `10.212.134.2:35599` |
| `flutter run -d 10.212.134.2:35599 --no-resident ...` | OK, app installee et lancee sur device |

## Warnings restants

- `flutter analyze` strict reste en echec a cause de dette historique : noms non camelCase, `print`, `withOpacity` deprecie, imports de dependances transitives, widgets mutables et `WillPopScope`.
- Aucun warning restant n'est lie aux nouveaux fichiers `WorkspaceMvpController` ou `WorkspaceMvpPage`.
- `composer audit` signale une dette securite dependances : `firebase/php-jwt` et `laravel/framework`, plus `fruitcake/laravel-cors` et `swiftmailer/swiftmailer` abandonnes.
- La prochaine phase de nettoyage doit se faire module par module pour eviter de casser les workflows existants.

## Validation production du 2026-05-18

| Test | Resultat |
| --- | --- |
| Migration `2026_05_18_120000_add_production_validation_tables` | OK, tables/colonnes ajoutees sans suppression |
| `TestUsersByRoleSeeder` | OK |
| `DemoDataSeeder` | OK avec promotions, coupon demo, audit log, liaison point de vente et trajet demo |
| Login + workspace 6 comptes | OK |
| `/api/workspace/mvp` 6 workspaces | OK |
| `/api/listpromotions` | SUCCESS, donnees demo disponibles |
| `/api/listcoupons` | SUCCESS, donnees demo disponibles |
| `/api/currentorders` commercial | SUCCESS, fallback recent orders corrige |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | OK |
| `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` | OK |
| `flutter run -d 10.212.134.2:35599 --no-resident ...` | OK, app installee/lancee sur SM A165F |

Notes :
- Gmail/Facebook ne restent plus en loading infini : timeouts et erreurs lisibles ajoutes.
- Firebase Messaging demande la permission et ne bloque pas l'app si la config Firebase est absente.
- Maps externe est disponible en fallback via URL Google Maps.
- Bluetooth necessite une imprimante physique pour validation finale.

## Passe finale apres clean du 2026-05-18

| Test | Resultat |
| --- | --- |
| `composer install --no-interaction` | OK |
| `php artisan migrate --force` | OK, rien a migrer |
| `php artisan db:seed --class=TestUsersByRoleSeeder --force` | OK |
| `php artisan db:seed --class=DemoDataSeeder --force` | OK |
| Login/workspace 6 comptes sur serveur local temporaire | OK |
| Endpoints `clients/products/currentorders/listpromotions/listcoupons/currentstock/toshiporders` | OK |
| `flutter clean` | OK |
| `flutter pub get` | OK |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | OK, sortie 0 |
| `flutter analyze` strict | KO documente, 758 issues historiques |
| `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` | OK |
| `flutter devices` final | Aucun smartphone visible; Windows/Edge seulement |
| `adb connect 10.212.134.2:35599` | KO, port wireless ADB expire/non joignable |

APK final : `push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk`.
