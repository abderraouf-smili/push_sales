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

## Compatibilite

- Ne pas supprimer les endpoints historiques tant que Flutter les consomme.
- Ajouter les nouveaux champs dans `data` sans retirer les anciens.
- Garder `status = SUCCESS|FAIL` pour les appels mobiles existants.
- Retourner des messages utilisateur clairs sans exposer de stack trace en production.
