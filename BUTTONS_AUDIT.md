# BUTTONS_AUDIT - Push Sales

Date : 2026-05-18

Objectif : verifier que les boutons visibles des workspaces ont une action claire et ne restent pas morts.

## Addendum Distributeur operations reelles 2026-05-19

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Dashboard Distributeur | Filtre distributeur | Recharge `/api/workspace/real` avec `distributor_id` si un distributeur est choisi | OK |
| Depots Distributeur | Ajouter depot | Ouvre formulaire puis `POST /api/distributor/warehouses` | OK route/code |
| Clients Distributeur | Ajouter client | Ouvre formulaire puis `POST /api/distributor/clients` | OK route/code |
| Produits Distributeur | Prix variant | Ouvre formulaire puis `POST /api/distributor/variants/{id}/price` | OK route/code |
| Stock Distributeur | Ajuster stock | Grise/bloque si aucun depot; sinon `POST /api/distributor/stock/adjust` | OK |
| Promotions Distributeur | Ajouter promotion | Formulaire metier enrichi puis `POST /api/distributor/promotions` | OK route/code |
| Coupons Distributeur | Ajouter coupon | Formulaire puis `POST /api/distributor/coupons` | OK route/code |
| Livraisons Distributeur | Filtre depot | Bascule la liste des demandes par depot et statut depuis section `deliveries` | OK code |

## Resultat

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Tous workspaces | Menu haut | Ouvre le drawer ou la navigation laterale | OK |
| Tous workspaces | Notification | Affiche un message lie aux notifications du workspace | OK |
| Tous workspaces | Chat/support | Affiche un message snack ou ouvre la section support selon workspace | OK |
| Tous workspaces | Actualiser | Recharge `/api/workspace/real` pour la section courante en mode `vpn/real/production` | OK |
| Tous workspaces | Voir details | Affiche les details de la carte en bottom sheet | OK |
| Tous workspaces | Ouvrir | Affiche les details de l'element en bottom sheet | OK |
| SuperAdmin | Distributeurs | Charge section `distributors` via API reelle | OK |
| SuperAdmin | Acteurs | Charge section `actors` via API reelle | OK |
| SuperAdmin | Produits | Charge section `products` via API reelle | OK |
| Distributeur | Acteurs | Charge section `actors` via API reelle | OK |
| Distributeur | Depots | Charge section `warehouses` via API reelle | OK |
| Distributeur | Produits | Charge section `products` via API reelle | OK |
| Depot | Preparations | Charge section `prepare_orders` via API reelle | OK |
| Depot | Chargements | Charge section `loadings` via API reelle | OK |
| Depot | Stock | Charge section `warehouse_stock` via API reelle | OK |
| Livreur | Stock | Charge section `stock_mobile` via API reelle | OK |
| Livreur | Delivery | Charge section `delivery`, filtres Preparées/A livrer/En cours/Livrees | OK |
| Livreur | Trajets | Charge section `routes`, liste clients et action Maps externe | OK |
| Livreur | Generer bon reception | Disponible uniquement sur elements prepares; sinon message clair | OK |
| Point de Vente | Catalogue | Charge section `catalog` via API reelle | OK |
| Point de Vente | Ajouter | Ajoute le produit au panier local avant validation API | OK |
| Point de Vente | Panier | Affiche panier local et donnees API | OK |
| Point de Vente | Valider commande | Bloque proprement en mode reel si l'API commande point de vente manque | OK |
| Point de Vente | Support | Charge section `support` et affiche actions claires | OK |

## Notes

- Les workspaces utilisent `WorkspacePage`; `APP_ENV=vpn|real|production` charge `/api/workspace/real`.
- Les actions non encore branchees sur une route CRUD reelle affichent un feedback explicite au lieu de ne rien faire.
- Les anciennes pages commerciales restent accessibles pour conserver les workflows existants.
- Les anciens ecrans profonds gardent une dette de style Flutter documentee dans `TEST_RESULTS.md`.

## Addendum production 2026-05-18

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Workspace | Carte liste | Ouvre une fiche detail en bottom sheet moderne | OK |
| Workspace routes/clients | Maps | Ouvre Google Maps externe avec la cible disponible | OK |
| Livreur Delivery | Generer bon reception | Autorise uniquement les elements prepares; sinon message clair | OK |
| Auth | Google | Timeout + message clair si config Firebase/Google manquante | OK |
| Auth | Facebook | Timeout + message clair si config Facebook manquante | OK |
| Auth | Retour apres erreur sociale | Revient au formulaire email/password | OK |
| Point de Vente | Ajouter produit | Feedback local, panier lisible | OK |
| Promotions/Coupons | Consultation | Endpoints verifies selon donnees disponibles | OK |

## Addendum SuperAdmin CRUD 2026-05-18

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Dashboard SuperAdmin | Ajouter distributeur | Ouvre le formulaire de creation distributeur | OK |
| Dashboard SuperAdmin | Ajouter manager/acteur | Ouvre le formulaire de creation acteur | OK |
| Dashboard SuperAdmin | Voir audit logs | Charge `/api/superadmin/audit-logs` et affiche la liste | OK |
| Dashboard SuperAdmin | Parametres application | Ouvre la section profil/parametres | OK |
| Distributeurs | Rechercher | Filtre la liste locale chargee par API | OK |
| Distributeurs | Actifs/Inactifs | Filtre par `is_active` | OK |
| Distributeurs | Ajouter | `POST /api/superadmin/distributors` | OK |
| Distributeurs | Ouvrir/detail | Charge detail + acteurs + depots + produits + commandes + stats | OK |
| Detail distributeur | Modifier | `PATCH /api/superadmin/distributors/{id}` | OK |
| Detail distributeur | Desactiver | Confirmation puis `POST /deactivate` | OK |
| Detail distributeur | Activer | Confirmation puis `POST /activate` | OK |
| Acteurs | Rechercher | Filtre nom/email/workspace/distributeur | OK |
| Acteurs | Workspace/statut | Filtre la liste acteurs | OK |
| Acteurs | Ajouter | `POST /api/superadmin/actors` | OK |
| Detail acteur | Modifier | `PATCH /api/superadmin/actors/{id}` | OK |
| Detail acteur | Reset password | Confirmation puis `POST /reset-password` | OK |
| Detail acteur | Desactiver/Activer | Confirmation puis `POST /deactivate|activate` | OK |
| Produits | Rechercher | Filtre nom/categorie/distributeur | OK |
| Produits | Ajouter | `POST /api/superadmin/products` | OK |
| Detail produit | Modifier | `PATCH /api/superadmin/products/{id}` | OK |
| Detail produit | Variants | Charge `/api/superadmin/products/{id}/variants` | OK |

## Addendum SuperAdmin smartphone UX fixes 2026-05-18

| Page | Bouton | Action | Statut |
| --- | --- | --- | --- |
| Top bar SuperAdmin | N / Notifications | Ouvre un toast premium ou sheet info notifications workspace | OK |
| Top bar SuperAdmin | M / Messages | Ouvre un toast premium ou sheet info messagerie workspace | OK |
| Toutes listes SuperAdmin | Pull-to-refresh | Recharge la section reelle courante | OK |
| Toutes listes SuperAdmin | Carte acteur/distributeur/produit | Ouvre le detail moderne | OK |
| Acteurs | Ajouter acteur | Formulaire avec workspace dropdown, distributeur dropdown, email verifie | OK |
| Acteurs | Copier mot de passe temporaire | Copie dans le presse-papiers | OK |
| Detail acteur | Reset acces | Confirmation puis `/reset-password`, email verifie si necessaire | OK |
| Detail distributeur | + Acteur | Ouvre creation acteur avec distributeur preselectionne | OK |
| Produits | Ajouter categorie | `POST /api/superadmin/categories` puis selection automatique | OK |
| Produits | Ajouter produit | `POST /api/superadmin/products` avec categorie/distributeur selectionnes | OK |
| Detail produit | + Variant | `POST /api/superadmin/products/{id}/variants` | OK |
| Detail produit | Modifier variant | `POST /api/superadmin/variants/{id}/update` | OK |
| Profil | Firebase | Bottom sheet statut/configuration, pas de loading infini | OK |
| Profil | Google Maps | Bottom sheet + ouverture Maps externe de test | OK |
| Profil | Bluetooth printer | Bottom sheet permissions/materiel requis/test | OK |
| Profil | Google/Facebook Login | Bottom sheet configuration requise | OK |

## Addendum variants options 2026-05-20

| Page | Bouton / geste | Action | Statut |
| --- | --- | --- | --- |
| SuperAdmin Produits | Carte produit | Ouvre le detail produit avec onglets Infos / Variants | OK |
| Detail produit > Variants | `+ Variant` | Ouvre formulaire options:value et appelle `POST /api/superadmin/products/{id}/variants` | OK |
| Formulaire variant | `Ajouter option` | Ajoute une ligne option facultative sans forcer toutes les options | OK |
| Formulaire variant | Dropdown option | Charge `Couleur`, `Marque`, `Format`, `Taille`, `Type` depuis API | OK |
| Formulaire variant | Dropdown valeur | Charge les valeurs existantes de l'option selectionnee | OK |
| Formulaire variant | `+ Nouvelle valeur` | Envoie/prepare une valeur dans le payload reel du variant | OK |
| Formulaire variant | `Creer/Enregistrer` | Valide unicite option, envoie l'API, affiche erreur si doublon | OK |
| Liste variants | Tap variant | Ouvre modification du variant | OK |
| Liste variants | Swipe droite | Edition rapide du variant | OK |
| Liste variants | Swipe gauche | Confirmation puis suppression defensive via API | OK |

## Addendum produits distributeur variant 2026-05-20

| Page | Bouton / geste | Action | Statut |
| --- | --- | --- | --- |
| Distributeur > Produits | Filtre statut | `Actifs` selectionne par defaut, filtre local sur `is_active/status` | OK |
| Distributeur > Produits | Carte produit | Ouvre detail produit avec variants reels | OK |
| Detail produit > Variants | Tap variant | Ouvre fiche variant `Infos / Prix / Stock` | OK |
| Fiche variant | Onglet Infos | Affiche SKU, groupe, conditionnement, signature options, statut | OK |
| Fiche variant | Onglet Prix | Affiche `price_history` depuis `pricelist_item/pricelist` du plus recent au plus ancien | OK |
| Fiche variant | Onglet Stock | Affiche `stock_by_warehouse` par depot autorise | OK |
| Fiche variant | Stock | Ouvre l'action distributeur d'ajustement stock pour le variant | OK |
| Fiche variant | Prix | Ouvre l'action distributeur de gestion prix pour le variant | OK |

## Addendum actions prix/stock distributeur 2026-05-20

| Page | Bouton / geste | Action | Statut |
| --- | --- | --- | --- |
| Fiche variant distributeur | Prix | Ouvre le formulaire prix rapide via `/api/distributor/price-context` | OK |
| Formulaire prix | Planifier apres dernier prix | Calcule debut = derniere date fin + 1 jour | OK |
| Formulaire prix | Enregistrer prix | Appelle `POST /api/distributor/variants/{id}/price`, bloque chevauchement UI/backend | OK |
| Onglet prix variant | Swipe gauche prix | Confirmation puis `POST /api/distributor/prices/{id}/delete` | OK |
| Fiche variant distributeur | Stock | Ouvre le formulaire stock rapide via `/api/distributor/stock-context` | OK |
| Formulaire stock | Valider stock | Appelle `POST /api/distributor/stock/adjust` et rafraichit la fiche variant | OK |
| Formulaire stock | Variation stock | Affiche ancien stock, nouveau stock et pourcentage de variation | OK |
| Erreurs API | Dialogue/toast erreur | Affiche le message backend lisible, sans exception Dio brute | OK |

## Addendum assortiment distributeur 2026-05-20

| Page | Bouton / geste | Action | Statut |
| --- | --- | --- | --- |
| Distributeur > Produits | Assortiment | Ouvre `/api/distributor/product-assortment` dans une bottom sheet de selection | OK |
| Assortiment | Checkbox produit | Selectionne ou retire tous les variants du produit | OK |
| Assortiment | Expansion produit | Affiche les variants selectionnables | OK |
| Assortiment | Checkbox variant | Selection fine d'un variant exploite par le distributeur | OK |
| Assortiment | Valider la selection | `POST /api/distributor/product-assortment/save` puis refresh Produits | OK |
| Distributeur > Produits | Liste produits apres validation | Affiche seulement les variants selectionnes quand l'assortiment est configure | OK |

## Addendum alertes produits distributeur 2026-05-21

| Page | Bouton / geste | Action | Statut |
| --- | --- | --- | --- |
| Distributeur > Produits | Filtre `Alerte` | Filtre local les produits dont au moins un variant a une alerte prix/stock | OK |
| Distributeur > Produits | Filtre `OK` | Filtre local les produits sans alerte operationnelle | OK |
| Distributeur > Produits | Carte produit | Ouvre detail produit sans afficher prix ni chevron | OK |
| Detail produit > Variants | Tap variant | Ouvre fiche variant avec badge `Actif` + indicateur `OK/Alerte` | OK |
| Fiche variant > Stock | Swipe gauche ligne stock | Confirmation puis `POST /api/distributor/stock/{id}/delete` | OK API/build |
| Fiche variant > Stock | Ligne sans `stock_id` | Non supprimable, evite une action impossible sur donnees non persistantes | OK |
