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

### Variants par options predifinies

Les variants SuperAdmin peuvent maintenant etre identifies par une combinaison facultative d'options/valeurs. Un variant peut contenir une seule option ou plusieurs options; il n'est jamais obligatoire de renseigner `Couleur`, `Marque`, `Format`, `Taille` et `Type` en meme temps.

| Methode | Endpoint | Usage |
| --- | --- | --- |
| GET | `/api/superadmin/variant-options` | Options fixes actives : couleur, marque, format, taille, type |
| GET | `/api/superadmin/variant-options/{id}/values` | Valeurs connues pour une option, par id ou key |
| POST | `/api/superadmin/variant-option-values` | Ajout d'une valeur d'option autorisee |
| GET | `/api/superadmin/products/{id}/variants` | Variants avec `options` et `option_signature` |
| POST | `/api/superadmin/products/{id}/variants` | Creation variant avec options |
| PATCH | `/api/superadmin/variants/{id}` | Modification variant et synchronisation options |
| POST | `/api/superadmin/variants/{id}/delete` | Suppression defensive si le variant n'est pas utilise |

Payload creation/modification variant :

```json
{
  "name": "Normale x09",
  "sku": "HF0234",
  "options": [
    { "option_key": "type", "value": "Normale" },
    { "option_key": "taille", "value": "x09" }
  ]
}
```

Regles backend :
- les options sont validees contre `variant_options`;
- les valeurs sont normalisees et creees si absentes;
- la signature est triee par key, par exemple `taille=x09|type=normale`;
- deux variants d'un meme produit ne peuvent pas avoir la meme `option_signature`;
- les actions create/update/delete ecrivent dans `audit_logs`;
- les anciens variants sans options restent lisibles via les champs legacy.

### Notes SuperAdmin smartphone UX 2026-05-18

- `POST /api/superadmin/actors` accepte `email_verified=true|false`; par defaut les comptes crees par SuperAdmin sont verifies pour permettre le test reel immediat.
- `POST /api/superadmin/actors` exige `distributor_id` pour tous les workspaces sauf `superadmin`.
- `GET /api/superadmin/distributors/{id}/actors` filtre les acteurs via `distributor_id` avec fallback legacy `id_distributor` quand la colonne existe.
- Les payloads produits retournent maintenant des labels lisibles : `category_label`, `distributor_label`, `distributor_code`, ainsi que les variants quand disponibles.
- Les routes `POST /api/superadmin/categories/query`, `POST /api/superadmin/distributors/query`, `POST /api/superadmin/products/query` et `POST /api/superadmin/products/{id}/variants/query` sont disponibles pour les dropdowns Flutter.
- Toutes les actions sensibles SuperAdmin doivent ecrire dans `audit_logs` : creation/modification distributeur, acteur, produit, categorie, variant, activation/desactivation et reset acces.

### Workspace produits distributeur

`POST /api/workspace/real` avec `section=products` retourne les produits exploitables par le distributeur connecte. Les produits restent compatibles avec l'ancien payload, mais chaque variant peut maintenant inclure :

- `options` : chips `Option: Valeur` si le variant est structure;
- `option_signature` : signature normalisee de combinaison;
- `group_label` et `detail_label` : labels intelligents UI;
- `price_history` : historique `pricelist_item/pricelist` du plus recent au plus ancien;
- `price_label` et `price` : prix courant si disponible;
- `stock_by_warehouse` : stock par depot autorise du distributeur;
- `stock_label` et `stock_quantity` : resume stock total.

Le distributeur lit ces champs pour afficher les onglets variant `Infos`, `Prix` et `Stock`. La modification effective des prix et stocks reste dans les actions metier distributeur existantes.

### Actions prix et stock distributeur

Ces endpoints sont utilises par la fiche variant distributeur en mode reel. Ils sont scopes au distributeur connecte.

| Methode | Endpoint | Usage |
| --- | --- | --- |
| POST | `/api/distributor/price-context` | Contexte leger pour ouvrir rapidement le formulaire prix d'un variant |
| POST | `/api/distributor/stock-context` | Contexte leger depots pour ouvrir rapidement le formulaire stock d'un variant |
| POST | `/api/distributor/variants/{id}/price` | Cree un prix pour un variant avec periode et type point de vente optionnel |
| POST | `/api/distributor/prices/{id}/delete` | Supprime defensivement une entree prix, avec soft delete si disponible |
| POST | `/api/distributor/stock/adjust` | Ajuste le stock d'un variant dans un depot du distributeur |
| POST | `/api/distributor/stock/{id}/delete` | Supprime une ligne stock du variant/depot, limitee au distributeur connecte et auditee |
| POST | `/api/distributor/product-assortment` | Charge le catalogue global selectionnable par le distributeur |
| POST | `/api/distributor/product-assortment/save` | Enregistre les variants exploites par le distributeur |

Payload prix :

```json
{
  "price": 148,
  "typepv_id": null,
  "start_date": "2026-05-20",
  "end_date": "2026-12-31",
  "label": "Tarif boutique"
}
```

Regles prix :
- `start_date` et `end_date` definissent l'etat calcule : expire, actif ou planifie;
- les periodes ne peuvent pas se chevaucher pour un meme variant, distributeur et type point de vente;
- l'historique exclut les lignes soft-deleted;
- le statut operationnel n'est pas saisi par Flutter, il est derive cote backend et UI.

Payload stock :

```json
{
  "warehouse_id": "WH-DEMO-CENTRAL",
  "variant_id": 1,
  "mode": "set",
  "quantity": 24,
  "unit_price": 0,
  "reason": "Ajustement inventaire"
}
```

Regles stock :
- le depot doit appartenir au distributeur connecte;
- `mode` peut etre `set`, `add` ou `sub`;
- la reponse retourne `old_quantity`, `new_quantity`, `stock_by_warehouse` et `stock_quantity` pour rafraichir la fiche variant;
- la suppression d'une ligne stock exige un `stock_id` retourne par `stock_by_warehouse`, refuse les depots hors scope et ecrit un audit log `delete_stock_row`.

Sante operationnelle produits distributeur :
- `/api/workspace/real` section `products` ajoute `health_status`, `health_label`, `health_alert_count` et `health_reasons`;
- un variant est en alerte si aucun prix actif n'existe, si un depot est en rupture, ou si le stock d'un depot est inferieur de 20% a son objectif/previsionnel;
- un produit est en alerte si au moins un de ses variants est en alerte;
- en workspace Distributeur, le montant prix n'est pas expose comme information principale dans la liste produit.

Payload assortiment :

```json
{
  "variant_ids": [84, 85, 91]
}
```

Regles assortiment :
- le distributeur ne peut selectionner que des produits globaux ou rattaches a son propre `distributor_id`;
- une selection est enregistree au niveau variant dans `distributor_product_assortments`;
- selectionner un produit dans Flutter coche tous ses variants;
- si aucun assortiment n'est configure, le catalogue distributeur reste complet;
- si un assortiment existe, `/api/workspace/real` section `products` ne retourne que les variants selectionnes;
- l'action est auditee via `update_product_assortment` quand `audit_logs` existe.

## Compatibilite

- Ne pas supprimer les endpoints historiques tant que Flutter les consomme.
- Ajouter les nouveaux champs dans `data` sans retirer les anciens.
- Garder `status = SUCCESS|FAIL` pour les appels mobiles existants.
- Retourner des messages utilisateur clairs sans exposer de stack trace en production.
