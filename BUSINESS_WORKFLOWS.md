# BUSINESS_WORKFLOWS - Push Sales

Ce document decrit la cible B2B de Push Sales. Les workflows existants Laravel/Flutter restent la base : les evolutions doivent garder les routes et donnees compatibles tant qu'une migration explicite n'est pas validee.

## Workspaces

| Workspace | Objectif | Menus cibles | Actions principales |
| --- | --- | --- | --- |
| `superadmin` | Administrer toute la plateforme | Dashboard global, distributeurs, acteurs, audit, parametres | Creer/suspendre distributeur, creer manager, voir audit |
| `distributeur` | Piloter une entreprise distributrice | Dashboard, produits, depots, stock, clients, commandes, livraisons, acteurs, rapports | Gerer catalogue, stock, acteurs, promotions, rapports |
| `commercial` | Vendre et suivre les clients terrain | Dashboard, clients, tracking, produits, profil | Creer client, creer commande, suivre solde et tracking |
| `depot` | Preparer commandes et chargements | Dashboard, commandes a preparer, chargements, stock depot, profil | Preparer, affecter livreur, confirmer chargement |
| `livreur` | Livrer, encaisser et gerer stock mobile | Dashboard, stock mobile, delivery, trajets, profil | Prendre en charge, livrer, encaisser, retours |
| `point_vente` | Portail B2B client final | Accueil, catalogue, panier, commandes, credit, support | Commander, suivre livraison, voir credit, chat support |

## Workflow global

1. SuperAdmin cree un distributeur et son manager.
2. Le manager cree depots, acteurs, produits, variants, prix, promotions et stock.
3. Le commercial gere ses points de vente, visite et cree des commandes.
4. Le point de vente peut consulter le catalogue et demander/creer une commande selon configuration.
5. Laravel verifie acteur, distributeur, permissions, client, prix, stock, promotion/coupon et credit.
6. Le depot prepare les commandes et confirme le chargement.
7. Le livreur voit son stock mobile, ses livraisons, son trajet, livre et encaisse.
8. Laravel met a jour commandes, bons operationnels, stock depot/mobile, transactions, solde, tracking et notifications.
9. Commercial, point de vente, distributeur et superadmin supervisent selon leurs droits.

## Etats metier normalises

### Order
- `draft` : Brouillon
- `pending_validation` : En attente validation
- `new` : Nouveau
- `processing` : En traitement
- `partially_delivered` : Livree partiellement
- `delivered` : Livree
- `cancelled` : Annulee

### PurchaseOrder
- `new` : Nouveau
- `ready_to_pack` : A preparer
- `packed` : Prepare
- `taken` : Pris en charge
- `in_way` : En route
- `shipped` : Livre
- `returned` : Retourne
- `paid` : Paye
- `partially_paid` : Paye partiellement
- `cancelled` : Annule

### Delivery
- `prepared` : Preparee
- `assigned` : Affectee
- `in_route` : En route
- `delivered` : Livree
- `partially_delivered` : Livree partiellement
- `failed` : Echec livraison
- `returned` : Retournee

### Payment
- `unpaid` : Non paye
- `partially_paid` : Paye partiellement
- `paid` : Paye
- `overdue` : En retard

## Regle de conservation metier

Les calculs de prix, stock, promotion, coupon, credit, livraison et encaissement restent dans Laravel. Flutter affiche, filtre et declenche les actions via API, sans recalculer le metier.
