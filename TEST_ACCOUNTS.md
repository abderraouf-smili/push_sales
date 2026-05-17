# TEST_ACCOUNTS - Push Sales

Ces comptes sont reserves aux environnements local/dev/test. Ne jamais les utiliser en production.

Seeder disponible :

```bash
cd push_sale-master
php artisan db:seed --class=TestUsersByRoleSeeder
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
