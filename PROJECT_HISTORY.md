# PROJECT_HISTORY

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

## 2026-05-17 - Flutter dependencies and Android compatibility

- Zone modifiee : `push_sale_mobile-master` Flutter/Android.
- Resume : correction du conflit `intl` impose par `flutter_localizations` avec `flutter_form_builder`, mise a jour controlee des dependances resolues, retrait de la dependance Android inutilisee `bluetooth_print`, alignement Android Gradle/AGP/Kotlin/NDK pour Flutter 3.38.9 et Android SDK 36.
- Note Android : Flutter 3.38.9 migre automatiquement le `minSdk` effectif vers `flutter.minSdkVersion` (24). Les appareils Android API 23 ou moins ne sont donc plus une cible de build avec cette version Flutter.
- Securite : suppression d'un ancien token Bearer commente dans `lib/api/call_api.dart`. Des cles Google/API restent presentes dans le code mobile et doivent etre deplacees vers une configuration securisee lors d'une prochaine intervention.
- Risque : moyen, car la correction touche la chaine de build Android et les dependances Flutter, sans modifier les routes API ni la logique metier.
- Tests a faire : refaire un lancement sur smartphone Android ADB wireless quand le device est reconnecte, puis verifier login, cartes, commandes, stock, impression Bluetooth et notifications.
- Prochaine etape : traiter progressivement les warnings `flutter analyze`, puis externaliser les cles Google/API et la configuration d'environnements.
