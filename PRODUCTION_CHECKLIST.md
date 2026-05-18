# PRODUCTION_CHECKLIST - Push Sales

Date : 2026-05-18

## Backend Laravel

- `APP_ENV=production`
- `APP_DEBUG=false`
- Base sauvegardee avant migration.
- `php artisan migrate --force` uniquement apres sauvegarde.
- Ne pas lancer les seeders demo en production.
- Verifier Passport/Sanctum, mail, queue, storage et logs.
- Verifier `FCM_SERVER_KEY` si notifications serveur utilisees.
- Verifier que `.env` n'est jamais versionne.

## Securite donnees

- Verifier isolation distributeur.
- Verifier `client_user_access` pour les comptes point de vente.
- Verifier permissions/workspace pour chaque role.
- Verifier audit logs sur actions sensibles.
- Ne pas logger tokens, mots de passe, headers `Authorization` ou cles API.

## Mobile Android

- Configurer signature release.
- Configurer `google-services.json` production.
- Restreindre cle Google Maps par package + SHA-1/SHA-256.
- Configurer Facebook App ID et callbacks.
- Verifier permissions :
  - Internet
  - Location
  - POST_NOTIFICATIONS
  - BLUETOOTH_SCAN
  - BLUETOOTH_CONNECT
- Build release :

```bash
flutter build apk --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.example.com
```

## Tests finaux

- Login 6 roles.
- Dashboard et menus par workspace.
- Creation commande.
- Preparation depot.
- Chargement livreur.
- Livraison + paiement.
- Tracking commande.
- Notifications Firebase.
- Maps client/trajet.
- Impression Bluetooth avec materiel reel.
- Tests petit smartphone, grand smartphone, tablette.

## Rollback

- Garder sauvegarde DB pre-migration.
- Garder APK/AAB precedent.
- Documenter migration lancee.
- En cas de regression, couper feature via configuration/API plutot que supprimer donnees.

