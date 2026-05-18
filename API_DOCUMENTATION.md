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
| POST | `/workspace/mvp` | Donnees agregees pour dashboards/pages MVP par workspace |

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

## Endpoint MVP workspace

`POST /api/workspace/mvp`

Body :

```json
{
  "section": "dashboard"
}
```

Sections disponibles : `dashboard`, `distributors`, `actors`, `warehouses`, `warehouse_stock`, `stock`, `stock_mobile`, `prepare_orders`, `loadings`, `delivery`, `routes`, `products`, `catalog`, `cart`, `clients`, `orders`, `my_orders`, `deliveries`, `payments`, `credit`, `support`, `profile`, `settings`, `reports`, `audit_logs`.

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

## Compatibilite

- Ne pas supprimer les endpoints historiques tant que Flutter les consomme.
- Ajouter les nouveaux champs dans `data` sans retirer les anciens.
- Garder `status = SUCCESS|FAIL` pour les appels mobiles existants.
- Retourner des messages utilisateur clairs sans exposer de stack trace en production.
