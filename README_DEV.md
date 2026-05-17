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

## Configuration API

L'URL API actuelle est definie dans :

```text
push_sale_mobile-master/lib/const/globals.dart
```

Valeur smartphone/VPN actuelle :

```text
http://192.168.1.20:8000
```

Pour un emulateur Android local, utiliser :

```text
http://10.0.2.2:8000
```

Changer cette URL prudemment sans modifier les routes API existantes.

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
flutter run -d 10.212.134.2:37143
```

## Comptes de test par role

Un seeder dev/test est disponible :

```bash
cd push_sale-master
php artisan db:seed --class=TestUsersByRoleSeeder
```

Prevoir PHP >= 8.2 pour installer les dependances backend actuelles du `composer.lock`.

Comptes crees :

```text
admin.test@pushsales.local / Test@123456
commercial.test@pushsales.local / Test@123456
livreur.test@pushsales.local / Test@123456
depot.test@pushsales.local / Test@123456
```

Ces comptes sont uniquement pour local/dev/test. Voir `TEST_ACCOUNTS.md`.

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

## Securite

- Ne pas versionner `.env`, cles privees, tokens, dumps SQL ou fichiers de credentials.
- Ne pas logger les tokens, passwords ou headers `Authorization`.
- Les cles Google/API presentes dans le code mobile doivent etre restreintes, rotatees si exposees, puis externalisees progressivement.
