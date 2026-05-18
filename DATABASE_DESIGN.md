# DATABASE_DESIGN - Push Sales

## Modele actuel utile

| Concept | Table / modele | Role |
| --- | --- | --- |
| User | `users` | Compte de connexion Laravel/Passport |
| Actor | `actor` | Identite metier liee au user |
| ActorProfile | `actor_profile` | Profil, stock mobile, creation client, workspace |
| Permission | `permissions` | Droits UI/actions par profil |
| Distributor | `distributor` | Entreprise distributrice |
| Warehouse | `warehouse` | Depot physique |
| Client / Point de vente | `client` | Point de vente gere par un acteur commercial |
| Product | `product` | Produit commercial |
| Variant | `variant` | Variante/conditionnement |
| PriceList | `pricelist`, `pricelist_item` | Prix par distributeur/type PV |
| Promotion | `promotion`, `promotionitem` | Promotion applicable |
| Order | `order`, `orderitem` | Commande commerciale |
| PurchaseOrder | `purchase_order`, `purchase_orderitem` | Bon operationnel depot/livraison |
| Stock | `stock_quantity`, `stock_mobile`, `stock_operation` | Stock depot/mobile et mouvements |
| Tracking | `tracking_orders` | Historique etat commande |
| Transactions | `transactions`, `transaction_type` | Vente, paiement, credit/debit |
| Visit | `visit_days`, `visit_client` | Planification et historique visites |
| Chat | `message_chat` | Messages entre acteurs |

## Migration ajoutee

`2026_05_18_000001_add_workspace_type_to_actor_profile_table.php`

Ajoute `actor_profile.workspace_type` nullable pour clarifier les espaces :
- `superadmin`
- `distributeur`
- `commercial`
- `depot`
- `livreur`
- `point_vente`

La migration est progressive et non destructive. Le code continue a deduire le workspace depuis `actor.type` ou `actor_profile.code` si la colonne n'est pas encore renseignee.

## Points de vigilance multi-distributeur

- Les depots doivent porter `distributor_id`.
- Les acteurs non SuperAdmin doivent porter `distributor_id`.
- Les produits/prix/promotions visibles doivent etre filtres par distributeur via les vues existantes (`full_variant`, `purchase_variants`) et les scopes.
- Les clients actuels sont rattaches a un acteur commercial. Pour un vrai portail point de vente, une liaison explicite `client.user_id` ou table de liaison sera a ajouter plus tard avec migration non destructive.
- Les commandes doivent rester consultables par acteur createur et par distributeur via `PurchaseOrder`/warehouse.

## Evolutions recommandees

1. Ajouter une table `audit_logs` pour SuperAdmin et distributeur.
2. Ajouter une liaison sure `client_user_access` pour le workspace point de vente.
3. Ajouter `order_source` (`commercial`, `point_vente`) sur les commandes.
4. Ajouter `payment_due_date` et `credit_limit` si la logique credit devient contractuelle.
5. Ajouter une table `delivery_trips` si l'optimisation de route devient persistante.

## Addendum production validation 2026-05-18

Migration ajoutee :

`2026_05_18_120000_add_production_validation_tables.php`

Ajouts non destructifs :

- `audit_logs` : journal d'actions pour SuperAdmin/distributeur.
- `client_user_access` : liaison user point de vente vers client/distributeur autorise.
- `order.order_source` : source `commercial` ou `point_vente`.
- `order.payment_due_date` : echeance paiement commande.
- `client.credit_limit` : limite credit contractuelle.
- `delivery_trips` : tournee livreur.
- `delivery_trip_stops` : arrets clients d'une tournee.

Utilisation actuelle :

- `WorkspaceMvpController` lit `audit_logs` pour la section audit.
- Le workspace point de vente filtre ses clients, commandes, bons et transactions via `client_user_access` quand la liaison existe.
- `DemoDataSeeder` cree une liaison point de vente, une tournee demo et des arrets pour tester Trajets.
- Les anciennes tables et routes restent compatibles.
