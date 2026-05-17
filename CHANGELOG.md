# CHANGELOG

## 2026-05-17

- Correction du conflit de dependances Flutter 3.38.9 / Dart 3.10.8 entre `flutter_localizations`, `intl` et `flutter_form_builder`.
- Mise a jour de `flutter_form_builder` vers `^10.3.0+2`.
- Mise a jour controlee du lockfile Flutter.
- Retrait de `bluetooth_print`, dependance inutilisee qui bloquait la compilation Android recente.
- Alignement Android Gradle Plugin, Kotlin, Gradle wrapper et NDK pour Android SDK 36.
- Migration Android minSdk vers `flutter.minSdkVersion` (24) appliquee par Flutter 3.38.9.
- Ajout d'une compatibilite Gradle pour le plugin legacy `blue_thermal_printer`.
- Suppression d'un ancien token Bearer commente dans le client API Flutter.
- Validation : `flutter pub get` OK, `flutter analyze --no-fatal-infos --no-fatal-warnings` OK, `flutter build apk --debug` OK.
