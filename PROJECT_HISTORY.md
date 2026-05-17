# PROJECT_HISTORY

## 2026-05-17 - Flutter dependencies and Android compatibility

- Zone modifiee : `push_sale_mobile-master` Flutter/Android.
- Resume : correction du conflit `intl` impose par `flutter_localizations` avec `flutter_form_builder`, mise a jour controlee des dependances resolues, retrait de la dependance Android inutilisee `bluetooth_print`, alignement Android Gradle/AGP/Kotlin/NDK pour Flutter 3.38.9 et Android SDK 36.
- Note Android : Flutter 3.38.9 migre automatiquement le `minSdk` effectif vers `flutter.minSdkVersion` (24). Les appareils Android API 23 ou moins ne sont donc plus une cible de build avec cette version Flutter.
- Securite : suppression d'un ancien token Bearer commente dans `lib/api/call_api.dart`. Des cles Google/API restent presentes dans le code mobile et doivent etre deplacees vers une configuration securisee lors d'une prochaine intervention.
- Risque : moyen, car la correction touche la chaine de build Android et les dependances Flutter, sans modifier les routes API ni la logique metier.
- Tests a faire : refaire un lancement sur smartphone Android ADB wireless quand le device est reconnecte, puis verifier login, cartes, commandes, stock, impression Bluetooth et notifications.
- Prochaine etape : traiter progressivement les warnings `flutter analyze`, puis externaliser les cles Google/API et la configuration d'environnements.
