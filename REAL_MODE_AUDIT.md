# REAL_MODE_AUDIT

## 2026-05-19 - Actions Distributeur reelles

Pages/actions migrees ou verifiees en mode reel :

| Page / action | API reelle | Statut |
| --- | --- | --- |
| Dashboard distributeur filtre tous/un distributeur | `POST /api/workspace/real` avec `distributor_id` optionnel | OK code |
| Depots - creer depot | `POST /api/distributor/warehouses` | OK route |
| Clients - creer client | `POST /api/distributor/clients` | OK route |
| Coupons - creer coupon | `POST /api/distributor/coupons` | OK route |
| Promotions - creer promotion | `POST /api/distributor/promotions` | OK route + formulaire enrichi |
| Stock - ajuster variant/depot | `POST /api/distributor/stock/adjust` | OK route; bloque si aucun depot |
| Produits - prix variant distributeur | `POST /api/distributor/variants/{id}/price` | OK route |
| Livraisons - filtre par depot | `POST /api/workspace/real` section `deliveries` puis filtre `warehouse_id` | OK code |

Garde-fous :

- Aucun appel a `/api/workspace/mvp` n'a ete ajoute pour `APP_ENV=vpn`.
- Les formulaires Distributeur postent vers les routes Laravel reelles.
- L'ajustement stock ne peut pas etre lance sans depot disponible.
- Les erreurs dependantes de materiel/cle doivent rester des messages clairs, sans action demo.

## 2026-05-19 - Produits SuperAdmin en mode reel

- L'onglet Produits SuperAdmin utilise les donnees reelles `/api/workspace/real` et les actions `/api/superadmin/products`, `/api/superadmin/categories`, `/api/superadmin/products/{id}/variants`.
- Le filtre categorie s'appuie sur `category_id/category_label` retournes par l'API.
- La creation categorie est une action reelle SuperAdmin, pas une action demo.
- La modification produit precharge `category_id` et `distributor_id`; aucune saisie manuelle d'ID n'est demandee a l'utilisateur.
- Aucun bouton panier n'est expose au SuperAdmin.

## 2026-05-18 - Mode reel APP_ENV=vpn

Objectif : neutraliser le comportement workspace demo dans l'application de test reel et forcer les pages principales a utiliser les APIs Laravel reelles.

## Garde-fous ajoutes

- Flutter charge maintenant `workspace/real` pour `APP_ENV=vpn`, `APP_ENV=real` et `APP_ENV=production`.
- `workspace/mvp` reste disponible uniquement pour `APP_ENV=demo`.
- `CallApi.RequestHttp` bloque tout appel Flutter a `workspace/mvp` en mode reel avec le code `DEMO_ACTION_NOT_ALLOWED_IN_REAL_ENV`.
- Les libelles visibles `donnees demo`, `action demo`, `panier demo` et `Commande demo` ont ete retires du flux reel.
- Aucun `DemoDataSeeder`, `migrate:fresh` ou `db:wipe` n'a ete execute pendant cette passe.

## Pages passees en mode reel

| Workspace | Pages | API utilisee |
| --- | --- | --- |
| SuperAdmin | Dashboard, Distributeurs, Acteurs, Produits, Profil | `/api/workspace/real`, `/api/superadmin/*` |
| SuperAdmin | CRUD distributeurs | `/api/superadmin/distributors`, `/{id}/activate`, `/{id}/deactivate` |
| SuperAdmin | CRUD acteurs | `/api/superadmin/actors`, `/{id}/activate`, `/{id}/deactivate`, `/{id}/reset-password` |
| SuperAdmin | Produits | `/api/superadmin/products`, `/api/superadmin/products/{id}`, variants |
| SuperAdmin | Audit logs | `/api/superadmin/audit-logs` |
| Commercial | Dashboard workspace, Clients, Produits, Tracking | `/api/workspace/real`, `/api/clients`, `/api/products`, `/api/currentorders` |
| Depot | Dashboard workspace, Preparations, Stock depot | `/api/workspace/real`, `/api/topackorders`, `/api/warehouses` |
| Livreur | Dashboard workspace, Stock mobile, Delivery, Trajets | `/api/workspace/real`, `/api/currentstock`, `/api/toshiporders` |
| Point de Vente | Dashboard, Catalogue, Mes commandes, Credit | `/api/workspace/real` avec workspace `point_vente` |

## Pages encore partiellement dependantes d'une API metier specifique

| Page / action | Statut actuel en mode reel | Action attendue |
| --- | --- | --- |
| Point de Vente - validation panier | Bloquee proprement en `APP_ENV=vpn` avec message `API reelle requise` | Brancher une API de creation commande point de vente avec `order_source=point_vente`, client autorise et lignes panier |
| Livreur - generation directe bon de reception depuis carte workspace | Redirige vers la fiche operationnelle au lieu de simuler | Brancher l'impression/generation PDF reelle si le workflow backend le fournit |
| Depot - preparation/chargement depuis action globale | Redirige vers la fiche commande de preparation | Continuer avec les endpoints existants `topackorders`, `createtransfer`, `confirmtransfer` dans l'ecran detail |
| Maps/Firebase/Bluetooth | Pas de simulation demo; fallback/message necessaire selon configuration materiel/cles | Tester avec vraies cles Firebase/Maps et imprimante Bluetooth physique |

## APIs verifiees pendant l'audit

- `POST /api/login`
- `POST /api/permissions/workspace`
- `POST /api/workspace/real`
- `GET /api/superadmin/dashboard`
- `GET /api/superadmin/distributors`
- `GET /api/superadmin/actors`
- `GET /api/superadmin/products`
- `GET /api/superadmin/audit-logs`
- `POST /api/clients`
- `POST /api/products`
- `POST /api/currentorders`
- `POST /api/warehouses`
- `POST /api/topackorders`
- `POST /api/toshiporders`
- `POST /api/currentstock`

## Notes securite donnees reelles

- Ne jamais lancer `php artisan migrate:fresh`, `db:wipe` ou `DemoDataSeeder` sur une base contenant des donnees reelles.
- Les migrations utilisees sont non destructives.
- Les comptes de test existants peuvent etre utilises en dev/test; ne pas les conserver en production.
- En production, utiliser `APP_ENV=production` cote Flutter et `APP_DEBUG=false` cote Laravel.

## SuperAdmin smartphone UX fixes 2026-05-18

Pages migrees/validees en mode reel :

| Page | API reelle | Resultat |
| --- | --- | --- |
| Dashboard SuperAdmin | `/api/superadmin/dashboard` | OK |
| Distributeurs | `/api/superadmin/distributors` | OK |
| Detail distributeur | `/api/superadmin/distributors/{id}` + sections enfants | OK |
| Acteurs | `/api/superadmin/actors` | OK |
| Detail acteur | `/api/superadmin/actors/{id}` | OK |
| Produits | `/api/superadmin/products` | OK |
| Categories | `/api/superadmin/categories` | OK |
| Variants | `/api/superadmin/products/{id}/variants`, `/api/superadmin/variants/{id}` | OK |
| Audit logs | `/api/superadmin/audit-logs` | OK |

Verifications importantes :

- Aucun appel a `/api/workspace/mvp` n'est requis pour les actions SuperAdmin en `APP_ENV=vpn`.
- Creation acteur SuperAdmin definit l'email comme verifie par defaut pour permettre les tests reels.
- Les acteurs lies a un distributeur sont retrouves par `distributor_id` avec fallback legacy `id_distributor`.
- Les actions panier sont masquees dans le workspace SuperAdmin.
- Les services externes n'utilisent pas de simulation demo; ils affichent configuration requise ou ouvrent le fallback pertinent.

Pages encore dependantes d'elements externes :

| Element | Statut |
| --- | --- |
| Firebase notification reelle | Necessite vraie configuration Firebase et cle restreinte |
| Google Maps interne | Necessite cle Google Maps Android restreinte; fallback externe disponible |
| Impression Bluetooth | Necessite imprimante physique et permissions Android accordees |
## 2026-05-19 - Produits SuperAdmin variants en mode reel

Pages passees/verifiees en reel :
- SuperAdmin > Produits > Detail produit > Variants.

APIs utilisees :
- `GET /api/superadmin/products`
- `GET /api/superadmin/products/{id}`
- `GET /api/superadmin/products/{id}/variants`
- `POST /api/superadmin/products/{id}/variants`
- `POST /api/superadmin/variants/{id}/update`
- `POST /api/superadmin/variants/{id}/delete`

Comportement :
- Aucune action demo.
- Les variants viennent de la vraie table `variant`.
- Groupage UI par `variant1_fr/group_label`.
- Edition par clic sur la ligne.
- Suppression par glissement, refusee si le variant est utilise dans stock/prix/commandes/promotions/mouvements.

Principe metier :
- SuperAdmin gere le catalogue maitre.
- Distributeur gere prix, stock, promotions et disponibilite operationnelle.

## 2026-05-20 - Variants options:value en mode reel

Pages migrees/verifiees en reel :
- SuperAdmin > Produits > Detail produit > Variants > Ajouter/Modifier variant.

APIs utilisees :
- `GET /api/superadmin/variant-options`
- `GET /api/superadmin/variant-options/{id}/values`
- `POST /api/superadmin/variant-option-values`
- `GET /api/superadmin/products/{id}/variants`
- `POST /api/superadmin/products/{id}/variants`
- `PATCH /api/superadmin/variants/{id}`
- `POST /api/superadmin/variants/{id}/delete`

Comportement en `APP_ENV=vpn/real/production` :
- aucune action demo;
- options fixes chargees depuis Laravel;
- valeurs existantes chargees depuis Laravel;
- nouvelle valeur option ajoutee via vraie API;
- duplication de combinaison refusee cote backend;
- groupage UI selon Type, Marque, Format, Couleur, Taille;
- SuperAdmin ne gere toujours pas prix/stock operationnels dans cette interface.
