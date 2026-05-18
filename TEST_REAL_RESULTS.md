# TEST_REAL_RESULTS

## 2026-05-18 - Validation mode reel sans reseed demo

Contexte :
- Branche : `feature/mobile-ui-modernization`
- Backend teste : Laravel local `http://127.0.0.1:8001/api`
- Flutter build : `APP_ENV=vpn`, `API_BASE_URL=http://192.168.1.20:8000`
- Protection donnees : aucun `migrate:fresh`, aucun `db:wipe`, aucun `DemoDataSeeder`.

## Backend

| Test | Resultat | Notes |
| --- | --- | --- |
| `php artisan migrate --force` | OK | Rien a migrer, aucune operation destructive |
| `php artisan route:list --path=api` | OK | Routes legacy, `workspace/real`, `workspace/mvp` et `superadmin/*` presentes |
| Login SuperAdmin | OK | `superadmin@pushsales.local` |
| `permissions/workspace` SuperAdmin | OK | `workspace_type=superadmin` |
| `workspace/real` Dashboard SuperAdmin | OK | Donnees chargees depuis la base |
| `superadmin/dashboard` | OK | API reelle |
| `superadmin/distributors` | OK | API reelle |
| `superadmin/actors` | OK | API reelle |
| `superadmin/products` | OK | API reelle |
| `superadmin/audit-logs` | OK | API reelle |

## Tests par role

| Compte | Endpoint | Resultat |
| --- | --- | --- |
| `commercial.test@pushsales.local` | login | OK |
| `commercial.test@pushsales.local` | `permissions/workspace` | OK, `commercial` |
| `commercial.test@pushsales.local` | `clients` | OK |
| `commercial.test@pushsales.local` | `products` | OK |
| `commercial.test@pushsales.local` | `currentorders` | OK |
| `commercial.test@pushsales.local` | `workspace/real` section `clients` | OK |
| `depot.test@pushsales.local` | login | OK |
| `depot.test@pushsales.local` | `permissions/workspace` | OK, `depot` |
| `depot.test@pushsales.local` | `warehouses` | OK |
| `depot.test@pushsales.local` | `topackorders` | OK |
| `depot.test@pushsales.local` | `workspace/real` section `prepare_orders` | OK |
| `livreur.test@pushsales.local` | login | OK |
| `livreur.test@pushsales.local` | `permissions/workspace` | OK, `livreur` |
| `livreur.test@pushsales.local` | `currentstock` | OK |
| `livreur.test@pushsales.local` | `toshiporders` | OK |
| `livreur.test@pushsales.local` | `workspace/real` section `stock_mobile` | OK |
| `pointvente.test@pushsales.local` | login | OK |
| `pointvente.test@pushsales.local` | `permissions/workspace` | OK, `point_vente` |
| `pointvente.test@pushsales.local` | `workspace/real` section `catalog` | OK |
| `pointvente.test@pushsales.local` | `workspace/real` section `my_orders` | OK |

## Flutter

| Commande | Resultat |
| --- | --- |
| `flutter clean` | OK |
| `flutter pub get` | OK |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | OK, 758 issues historiques non bloquantes |
| `flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://192.168.1.20:8000` | OK |
| `flutter devices` | OK, aucun smartphone ADB detecte pendant ce test; seulement Windows et Edge |

APK genere :

```text
push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk
```

## Points de vigilance

- Le flux de validation panier Point de Vente est volontairement bloque en mode reel tant que l'API de commande point de vente complete n'est pas branchee. Le bouton ne simule plus une commande.
- Les endpoints legacy doivent etre testes avec le bon role. Exemple : `currentstock` est OK avec le compte livreur, mais peut retourner une erreur metier avec SuperAdmin.
- Les warnings stricts Flutter restent historiques et non bloquants pour le build no-fatal.
