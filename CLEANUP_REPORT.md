# CLEANUP_REPORT

## 2026-05-20 - Passe variants options:value

### Fichiers supprimes

- Aucun fichier supprime pendant cette passe.

### Code mort supprime

- Aucun nettoyage destructif effectue : la livraison ajoute un schema et une UI compatibles avec les variants legacy.

### Elements conserves volontairement

- Les anciens champs variants (`variant1_fr`, `variant2_fr`, `code_barre`, `package`) sont conserves pour compatibilite avec les workflows produits, prix, stock, commandes et seeders existants.
- Les routes legacy produits/variants restent disponibles pour les ecrans historiques.
- Les warnings Flutter stricts historiques restent documentes; la compilation utilise l'analyse no-fatal demandee pour ne pas bloquer sur la dette hors scope.

### Tests apres changement

- `php artisan migrate --force`
- `php artisan db:seed --class=VariantOptionsSeeder --force`
- Test API SuperAdmin options/variants/doublon
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000`
- Installation/lancement sur SM A165F via ADB.
