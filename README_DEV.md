# README_DEV - Push Sales

## Structure

- Backend Laravel : `push_sale-master`
- Application Flutter : `push_sale_mobile-master`

Flutter doit communiquer uniquement avec l'API Laravel. Il ne doit jamais se connecter directement a MySQL/MariaDB.

## Prerequis

- PHP/Composer compatibles avec le backend Laravel existant.
- MySQL ou MariaDB configure pour Laravel.
- Flutter 3.38.9 stable.
- Dart 3.10.8.
- Android SDK 36.
- Android API minimum effectif : 24 avec Flutter 3.38.9.
- JDK 17 disponible dans `JAVA_HOME`.

## Backend Laravel

Depuis `push_sale-master` :

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan config:clear
php artisan cache:clear
php artisan serve --host=0.0.0.0 --port=8000
```

Configurer `.env` avec la base MySQL/MariaDB locale. Ne pas versionner `.env`. Si `.env.example` n'est pas present dans le workspace, le recreer a partir de la configuration Laravel attendue avant l'installation d'un nouvel environnement.

URL de developpement recommandee pour smartphone sur le meme reseau/VPN :

```text
http://192.168.1.20:8000
```

URL de developpement recommandee pour emulateur Android :

```text
http://10.0.2.2:8000
```

## Flutter

Depuis `push_sale_mobile-master` :

```bash
flutter clean
flutter pub get
flutter analyze
flutter devices
flutter run -d <device>
flutter build apk --debug
```

APK debug :

```text
push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk
```

## Configuration API par environnement

La configuration API Flutter est centralisee dans :

```text
push_sale_mobile-master/lib/config/app_config.dart
push_sale_mobile-master/lib/config/app_environment.dart
```

L'application accepte les options suivantes :

```bash
flutter run --dart-define=APP_ENV=vpn
flutter run --dart-define=APP_ENV=emulator
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

Valeurs par defaut :

```text
vpn       -> http://192.168.1.20:8000
emulator  -> http://10.0.2.2:8000
production-> https://example.com
```

`CallApi` ajoute `/api` une seule fois. Ne pas mettre `/api` en double dans `API_BASE_URL`.

Exemple smartphone VPN :

```bash
flutter run -d <device> --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

## ADB wireless

Verifier les devices :

```bash
flutter devices
```

Lancer sur un appareil detecte :

```bash
flutter run -d <device>
```

Device cible possible :

```bash
flutter run -d 10.212.134.2:45303
```

Le port ADB wireless peut changer a chaque reconnexion. Le 2026-05-17, le device SM A165F a ete detecte sur :

```bash
flutter run -d 10.212.134.2:38587
```

## Comptes de test par role

Un seeder dev/test est disponible :

```bash
cd push_sale-master
php artisan db:seed --class=TestUsersByRoleSeeder
```

Prevoir PHP >= 8.2 pour installer les dependances backend actuelles du `composer.lock`.
Sur cette machine, utiliser PHP 8.3 explicitement si la commande `php` pointe encore vers PHP 8.1 :

```bash
C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder
```

Comptes crees :

```text
superadmin@pushsales.local / Test@123456
manager.distributeur@pushsales.local / Test@123456
admin.test@pushsales.local / Test@123456
commercial.test@pushsales.local / Test@123456
livreur.test@pushsales.local / Test@123456
depot.test@pushsales.local / Test@123456
pointvente.test@pushsales.local / Test@123456
```

Ces comptes sont uniquement pour local/dev/test. Voir `TEST_ACCOUNTS.md`.

En mode debug Flutter, les emails `@pushsales.local` peuvent se connecter via Laravel directement si Firebase Auth ne possede pas ces comptes. Le seeder doit quand meme etre execute sur la base Laravel pointee par `http://192.168.1.20:8000`.

## Donnees demo

Pour alimenter produits, clients, depots, stock, transactions et commandes de test :

```bash
cd push_sale-master
C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder
```

Le seeder est bloque en environnement `production`. Il cree aussi, si elles sont absentes, des vues de compatibilite dev utilisees par les controllers existants : `stock_warehouse`, `purchase_variants`, `full_variant`.

## Workspaces B2B

L'endpoint historique `POST /api/permissions` reste compatible avec Flutter (`permission` et `type_actor` restent presents). Il retourne aussi le contrat B2B progressif :

```json
{
  "workspace_type": "commercial",
  "menus": ["dashboard", "clients", "tracking", "products", "profile"],
  "actions": ["create_client", "create_order", "track_order"],
  "permissions": ["HomePage.Clients"]
}
```

Alias disponible :

```text
POST /api/permissions/workspace
```

Workspaces cibles : `superadmin`, `distributeur`, `commercial`, `depot`, `livreur`, `point_vente`.

## Cles Google/Firebase

Les cles mobiles peuvent etre surchargees en debug :

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=xxx --dart-define=FIREBASE_API_KEY=xxx
```

Pour Android native manifest, ajouter en local seulement dans `push_sale_mobile-master/android/local.properties` :

```text
GOOGLE_MAPS_API_KEY=xxx
FIREBASE_API_KEY=xxx
```

Ne pas versionner de vraies cles. Les cles deja exposees dans une app mobile doivent etre considerees comme publiques, puis restreintes par package Android, SHA-1/SHA-256 et API autorisees dans les consoles Google/Firebase.

Pour l'envoi push cote Laravel, definir uniquement dans `.env` local/dev :

```text
FCM_SERVER_KEY=...
```

Sans cette valeur, l'endpoint notification retourne une erreur JSON claire au lieu de logger ou exposer un secret.

## Scenarios de validation

Les scenarios manuels par role sont documentes dans :

```text
TEST_SCENARIOS.md
```

Ordre recommande :

```text
1. Admin
2. Commercial
3. Livreur
4. Depot / Distributeur
5. Offline
6. Impression Bluetooth
7. Cartes / localisation
```

## Validations utiles

Backend :

```bash
php artisan route:list
php artisan test
```

Flutter :

```bash
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --debug
```

Build APK avec configuration VPN :

```bash
flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

Derniere validation du 2026-05-17 :

```text
php -l PurchaseOrderController.php : OK
flutter analyze --no-fatal-infos --no-fatal-warnings : OK
flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000 : OK
flutter devices : OK, SM A165F detecte
flutter run -d 10.212.134.2:38587 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000 : OK apres retry
APK debug : push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk
flutter analyze strict : 791 issues historiques restantes
```

Validation finale audit UI du 2026-05-17 :

```text
flutter clean : OK
flutter pub get : OK
flutter analyze --no-fatal-infos --no-fatal-warnings : OK
flutter analyze strict : 751 issues historiques restantes
flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000 : OK
flutter devices : OK, SM A165F detecte sur 10.212.134.4:37055
flutter run -d 10.212.134.4:37055 --debug --no-resident --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000 : OK
adb logcat apres lancement : aucun Null check operator / Failed assertion / EXCEPTION CAUGHT / RenderFlex overflowed detecte
C:\tools\php83\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar install --no-interaction : OK
C:\tools\php83\php.exe artisan route:list --compact : OK
C:\tools\php83\php.exe artisan config:clear : OK
C:\tools\php83\php.exe artisan cache:clear : OK
C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder : OK
C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder : OK
/api/login : SUCCESS pour les 4 comptes test, tokens non affiches
APK debug : push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk
```

Note Windows : `composer` dans le PATH utilise PHP 8.1 sur cette machine et peut echouer avec `composer.lock`. Utiliser PHP 8.3 explicitement :

```bash
C:\tools\php83\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar install --no-interaction
```

Correctifs UX recents :

- dashboard modernise avec bandeau KPI terrain;
- depots modernises, detail depot avec actions flottantes;
- chat connecte aux routes API existantes `getmessage` / `sendmessage`;
- theme sombre actif via `darkTheme`;
- dashboard, parametres et livraison passent sur layouts flexibles pour eviter les erreurs `BOTTOM OVERFLOWED`;
- favoris/panier affichent des pages utiles au lieu de l'image `under construction`;
- theme et notifications ont des actions visibles dans Parametres;
- navigation laterale activee automatiquement sur tablette/grand ecran;
- validation livraison protegee si la notification associee n'a pas de destinataire.

## Securite

- Ne pas versionner `.env`, cles privees, tokens, dumps SQL ou fichiers de credentials.
- Ne pas logger les tokens, passwords ou headers `Authorization`.
- Les cles Google/API presentes dans le code mobile doivent etre restreintes, rotatees si exposees, puis externalisees progressivement.
