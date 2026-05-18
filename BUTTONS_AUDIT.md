# BUTTONS_AUDIT - Push Sales

Date : 2026-05-18

Objectif : verifier que les boutons visibles des workspaces MVP ont une action claire et ne restent pas morts.

## Resultat

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Tous workspaces MVP | Menu haut | Ouvre le drawer ou la navigation laterale | OK |
| Tous workspaces MVP | Notification | Affiche un message snack "Notifications demo chargees..." | OK |
| Tous workspaces MVP | Chat/support | Affiche un message snack ou ouvre la section support selon workspace | OK |
| Tous workspaces MVP | Actualiser | Recharge `/api/workspace/mvp` pour la section courante | OK |
| Tous workspaces MVP | Voir details | Affiche les details de la carte en bottom sheet | OK |
| Tous workspaces MVP | Ouvrir | Affiche les details de l'element en bottom sheet | OK |
| SuperAdmin | Distributeurs | Charge section `distributors` via API MVP | OK |
| SuperAdmin | Acteurs | Charge section `actors` via API MVP | OK |
| SuperAdmin | Produits | Charge section `products` via API MVP | OK |
| Distributeur | Acteurs | Charge section `actors` via API MVP | OK |
| Distributeur | Depots | Charge section `warehouses` via API MVP | OK |
| Distributeur | Produits | Charge section `products` via API MVP | OK |
| Depot | Preparations | Charge section `prepare_orders` via API MVP | OK |
| Depot | Chargements | Charge section `loadings` via API MVP | OK |
| Depot | Stock | Charge section `warehouse_stock` via API MVP | OK |
| Livreur | Stock | Charge section `stock_mobile` via API MVP | OK |
| Livreur | Delivery | Charge section `delivery`, filtres Preparées/A livrer/En cours/Livrees | OK |
| Livreur | Trajets | Charge section `routes`, liste clients et action Maps demo | OK |
| Livreur | Generer bon reception | Disponible uniquement sur elements prepares; sinon message clair | OK |
| Point de Vente | Catalogue | Charge section `catalog` via API MVP | OK |
| Point de Vente | Ajouter | Ajoute le produit au panier local demo et affiche feedback | OK |
| Point de Vente | Panier | Affiche panier local et donnees API | OK |
| Point de Vente | Valider commande demo | Affiche confirmation demo sans appel destructif | OK |
| Point de Vente | Support | Charge section `support` et affiche actions claires | OK |

## Notes

- Les workspaces MVP utilisent `WorkspaceMvpPage`; les actions non encore branchees sur une route CRUD destructive affichent un feedback explicite au lieu de ne rien faire.
- Les anciennes pages commerciales restent accessibles pour conserver les workflows existants.
- Les anciens ecrans profonds gardent une dette de style Flutter documentee dans `TEST_RESULTS.md`.

## Addendum production 2026-05-18

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Workspace MVP | Carte liste | Ouvre une fiche detail en bottom sheet moderne | OK |
| Workspace MVP routes/clients | Maps | Ouvre Google Maps externe avec la cible disponible | OK |
| Livreur Delivery | Generer bon reception | Autorise uniquement les elements prepares; sinon message clair | OK |
| Auth | Google | Timeout + message clair si config Firebase/Google manquante | OK |
| Auth | Facebook | Timeout + message clair si config Facebook manquante | OK |
| Auth | Retour apres erreur sociale | Revient au formulaire email/password | OK |
| Point de Vente | Ajouter produit | Feedback local, panier demo lisible | OK |
| Promotions/Coupons | Consultation demo | Donnees seedees et endpoints verifies | OK |
