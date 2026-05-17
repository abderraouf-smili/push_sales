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
