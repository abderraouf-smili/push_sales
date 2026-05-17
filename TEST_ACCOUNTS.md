# TEST_ACCOUNTS - Push Sales

Ces comptes sont reserves aux environnements local/dev/test. Ne jamais les utiliser en production.

Seeder disponible :

```bash
cd push_sale-master
php artisan db:seed --class=TestUsersByRoleSeeder
```

Important : ces comptes doivent exister dans la base Laravel utilisee par l'API `http://192.168.1.20:8000`. Si le seeder n'a pas ete execute sur cette base, l'application affichera encore une erreur de connexion.

Validation locale du 2026-05-17 :

```text
C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder : OK
/api/login : SUCCESS pour les 4 comptes
/api/isprofiled : hasactor=1 verifie au minimum sur admin
```

Mot de passe temporaire dev/test pour tous les comptes crees par le seeder :

```text
Test@123456
```

## Comptes generes

| Role | Email | Mot de passe | Permissions principales | Scenario associe |
| --- | --- | --- | --- | --- |
| Admin | admin.test@pushsales.local | Test@123456 | Dashboard, clients, produits, tracking, statistiques, coupons, promotions, acteurs, entrepots | Validation administration et supervision |
| Commercial | commercial.test@pushsales.local | Test@123456 | Dashboard, clients, ajout client, catalogue, commandes, tracking, statistiques commerciales | Vente terrain et creation commande |
| Livreur | livreur.test@pushsales.local | Test@123456 | Dashboard livraison, livraisons, produits, compte, encaissement, preuve de livraison si activee | Livraison, cash et impression |
| Depot / Distributeur | depot.test@pushsales.local | Test@123456 | Dashboard, transfert/chargement, stock mobile, produits, compte | Preparation, chargement et stock |

## Securite

- Ne pas reutiliser ces identifiants en production.
- Ne pas exposer de vrais mots de passe existants.
- Si ces comptes sont crees sur une base partagee, les supprimer ou changer les mots de passe apres validation.
- Les cles API Google/Firebase actuellement presentes dans le mobile doivent etre restreintes cote console fournisseur.

## Notes techniques

- Les roles reels de production sont controles par `actor.type`, `actor.profile_id`, `actor_profile` et `permissions`.
- Le seeder cree des profils de test dedies avec des permissions coherentes pour les ecrans Flutter existants.
- Il ne modifie pas les routes API, les migrations existantes ou la logique metier.
- En mode debug Flutter, les comptes `@pushsales.local` utilisent un fallback Laravel direct si Firebase Auth ne les trouve pas. Les comptes normaux continuent a utiliser Firebase Auth.
- En build release/production, garder le flux Firebase normal ou creer les utilisateurs Firebase correspondants avec des UID synchronises cote Laravel.

## Donnees de validation associees

Seeder demo :

```bash
C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder
```

Donnees creees ou mises a jour :
- Produits demo avec variantes et prix.
- Clients demo pour commercial/admin.
- Depot central demo, stock mobile livreur et depot.
- Quantites de stock suffisantes pour tester catalogue, stock mobile et depots.
- Commandes/chargements demo pour tester `topackorders`, `toshiporders`, tracking et transactions.
