# API_DOCUMENTATION - Push Sales

Backend dev : `http://192.168.1.20:8000/api`

## Authentification

| Methode | Endpoint | Usage |
| --- | --- | --- |
| POST | `/login` | Connexion Laravel/Passport |
| POST | `/register` | Creation compte |
| POST | `/userdetail` | Details utilisateur |
| POST | `/isprofiled` | Verifie l'acteur du user |
| POST | `/actorinfo` | Retourne l'acteur connecte |
| POST | `/permissions` | Permissions legacy + workspace B2B |
| POST | `/permissions/workspace` | Alias de `/permissions` |
| POST | `/workspace/real` | Donnees agregees reelles pour dashboards/pages par workspace |
| POST | `/workspace/mvp` | Ancienne route autorisee uniquement pour `APP_ENV=demo` cote Flutter |

## Contrat permissions

Le contrat legacy reste disponible :

```json
{
  "status": "SUCCESS",
  "data": {
    "permission": [],
    "type_actor": "admin"
  }
}
```

Le contrat B2B ajoute :

```json
{
  "workspace_type": "commercial",
  "menus": ["dashboard", "clients", "tracking", "products", "profile"],
  "legacy_menus": ["dashboard", "clients"],
  "actions": ["create_client", "create_order", "track_order"],
  "permissions": ["HomePage.Clients"]
}
```

## Endpoints principaux existants

| Domaine | Endpoints |
| --- | --- |
| Acteurs | `createactor`, `updateactor`, `actorslist`, `actorslistinfo`, `actorprofile` |
| Clients | `clients`, `createclient`, `updateclient`, `typepointsvente`, `createvisit`, `reasonlist` |
| Produits | `products`, `allproducts`, `createproduct`, `updateproduct`, `categories`, `variants`, `purchasevariants` |
| Prix/promos/coupons | `pricelists`, `saveprices`, `promotions`, `listpromotions`, `setpromotion`, `listcoupons`, `checkcoupon` |
| Commandes | `createorder`, `currentorders`, `statusorder` |
| Depot/stock | `warehouses`, `adjustement`, `topackorders`, `createtransfer`, `listtransfer`, `confirmtransfer`, `currentstock` |
| Livraison | `toshiporders`, `shiporder`, `cashorder`, `sendcashforall`, `purchaseorderslist` |
| Statistiques | `stats_month`, `deliverystats`, `profitstats` |
| Communication | `sendnotification`, `sendmessage`, `getmessage` |

## Endpoint workspace reel

`POST /api/workspace/real`

Body :

```json
{
  "section": "dashboard"
}
```

Sections disponibles : `dashboard`, `distributors`, `actors`, `warehouses`, `warehouse_stock`, `stock`, `stock_mobile`, `prepare_orders`, `loadings`, `delivery`, `routes`, `products`, `catalog`, `cart`, `clients`, `orders`, `my_orders`, `deliveries`, `payments`, `credit`, `support`, `profile`, `settings`, `reports`, `audit_logs`.

En Flutter :

- `APP_ENV=demo` peut encore appeler `/workspace/mvp`.
- `APP_ENV=vpn`, `APP_ENV=real` et `APP_ENV=production` appellent `/workspace/real`.
- Tout appel Flutter a `/workspace/mvp` en mode reel est bloque avec `DEMO_ACTION_NOT_ALLOWED_IN_REAL_ENV`.

Reponse :

```json
{
  "status": "SUCCESS",
  "data": {
    "workspace_type": "livreur",
    "section": "delivery",
    "title": "Delivery",
    "stats": [],
    "lists": [],
    "actions": []
  }
}
```

Cet endpoint est une couche de lecture/agregation pour rendre les workspaces testables. Il ne remplace pas les anciens endpoints metier.

## Addendum production validation 2026-05-18

- Le workspace point de vente filtre les donnees via `client_user_access` quand une liaison active existe.
- `orders` expose progressivement `order_source` et `payment_due_date` quand les colonnes sont presentes.
- Les clients peuvent porter `credit_limit` pour les vues credit/creances.
- `routes` peut lire `delivery_trips` et `delivery_trip_stops`; sinon fallback vers les bons de livraison existants.
- `dashboard` et les sections MVP renvoient des actions non destructives et des flags UI comme `can_receive`.
- `currentorders` retourne maintenant des commandes recentes si aucun `client_id`/`date` n'est fourni, afin d'eviter une page vide dans le workspace commercial.

Endpoints valides apres seed demo :

| Endpoint | Attendu |
| --- | --- |
| `/api/listpromotions` | Promotions demo |
| `/api/listcoupons` | Coupons demo |
| `/api/currentstock` | Stock mobile livreur |
| `/api/toshiporders` | Livraisons livreur |
| `/api/topackorders` | Preparations depot |
| `/api/workspace/mvp` section `audit_logs` | Journal demo |

## SuperAdmin management API

Toutes les routes ci-dessous sont protegees par authentification et par garde workspace `superadmin`.
Les reponses restent au format mobile attendu :

```json
{
  "status": "SUCCESS",
  "data": {}
}
```

### Dashboard et audit

| Methode | Endpoint | Usage |
| --- | --- | --- |
| GET | `/api/superadmin/dashboard` | KPIs globaux, supervision, derniers logs |
| GET | `/api/superadmin/audit-logs` | Liste filtree des logs audit |

Filtres audit supportes : `user_id`, `actor_id`, `distributor_id`, `action`, `entity_type`, `date_from`, `date_to`.

### Distributeurs

| Methode | Endpoint | Usage |
| --- | --- | --- |
| GET | `/api/superadmin/distributors` | Liste/recherche distributeurs |
| POST | `/api/superadmin/distributors` | Creation distributeur |
| GET | `/api/superadmin/distributors/{id}` | Detail distributeur |
| PATCH | `/api/superadmin/distributors/{id}` | Modification distributeur |
| POST | `/api/superadmin/distributors/{id}/activate` | Activation |
| POST | `/api/superadmin/distributors/{id}/deactivate` | Desactivation |
| GET | `/api/superadmin/distributors/{id}/actors` | Acteurs du distributeur |
| GET | `/api/superadmin/distributors/{id}/warehouses` | Depots du distributeur |
| GET | `/api/superadmin/distributors/{id}/products` | Produits du distributeur |
| GET | `/api/superadmin/distributors/{id}/orders` | Commandes du distributeur |
| GET | `/api/superadmin/distributors/{id}/stats` | Statistiques du distributeur |

Champs creation/modification : `name`, `code`, `phone`, `email`, `country`, `city`, `address`, `contact_name`, `is_active`.

### Acteurs

| Methode | Endpoint | Usage |
| --- | --- | --- |
| GET | `/api/superadmin/actors` | Liste/recherche acteurs |
| POST | `/api/superadmin/actors` | Creation user + acteur |
| GET | `/api/superadmin/actors/{id}` | Detail acteur |
| PATCH | `/api/superadmin/actors/{id}` | Modification acteur |
| POST | `/api/superadmin/actors/{id}/activate` | Activation |
| POST | `/api/superadmin/actors/{id}/deactivate` | Desactivation |
| POST | `/api/superadmin/actors/{id}/reset-password` | Reset password temporaire |
| GET | `/api/superadmin/workspaces` | Liste workspaces |
| GET | `/api/superadmin/actor-profiles` | Profils acteurs |

Regles : un acteur non SuperAdmin doit etre rattache a un distributeur; un reset password ecrit un audit log.

### Produits, categories et variants

| Methode | Endpoint | Usage |
| --- | --- | --- |
| GET | `/api/superadmin/products` | Liste/recherche produits |
| POST | `/api/superadmin/products` | Creation produit |
| GET | `/api/superadmin/products/{id}` | Detail produit |
| PATCH | `/api/superadmin/products/{id}` | Modification produit |
| GET | `/api/superadmin/products/{id}/variants` | Variants du produit |
| POST | `/api/superadmin/products/{id}/variants` | Creation variant |
| PATCH | `/api/superadmin/variants/{id}` | Modification variant |
| GET | `/api/superadmin/categories` | Categories |
| POST | `/api/superadmin/categories` | Creation categorie |

Creation/modification produit supporte `name`, `description`, `ssin`, `category_id`, `distributor_id`, `is_active`.

### Notes SuperAdmin smartphone UX 2026-05-18

- `POST /api/superadmin/actors` accepte `email_verified=true|false`; par defaut les comptes crees par SuperAdmin sont verifies pour permettre le test reel immediat.
- `POST /api/superadmin/actors` exige `distributor_id` pour tous les workspaces sauf `superadmin`.
- `GET /api/superadmin/distributors/{id}/actors` filtre les acteurs via `distributor_id` avec fallback legacy `id_distributor` quand la colonne existe.
- Les payloads produits retournent maintenant des labels lisibles : `category_label`, `distributor_label`, `distributor_code`, ainsi que les variants quand disponibles.
- Les routes `POST /api/superadmin/categories/query`, `POST /api/superadmin/distributors/query`, `POST /api/superadmin/products/query` et `POST /api/superadmin/products/{id}/variants/query` sont disponibles pour les dropdowns Flutter.
- Toutes les actions sensibles SuperAdmin doivent ecrire dans `audit_logs` : creation/modification distributeur, acteur, produit, categorie, variant, activation/desactivation et reset acces.

## Compatibilite

- Ne pas supprimer les endpoints historiques tant que Flutter les consomme.
- Ajouter les nouveaux champs dans `data` sans retirer les anciens.
- Garder `status = SUCCESS|FAIL` pour les appels mobiles existants.
- Retourner des messages utilisateur clairs sans exposer de stack trace en production.
