# REAL_DATA_TESTING - Push Sales

Date : 2026-05-18

Objectif : tester Push Sales avec de vraies donnees sans ecraser la base existante.

## Regles de securite

- Ne jamais lancer `migrate:fresh` ou `db:wipe` sur une base reelle.
- Faire une sauvegarde SQL avant toute migration de production.
- Executer uniquement des migrations non destructives.
- Ne pas lancer `DemoDataSeeder` en production.
- Ne jamais mettre de vrais mots de passe, tokens ou cles dans Git.

## Connexion mobile vers serveur reel

Build debug/dev :

```bash
flutter build apk --debug --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://VOTRE_SERVEUR:8000
```

Run device :

```bash
flutter run -d <DEVICE_ID> --dart-define=APP_ENV=vpn --dart-define=API_BASE_URL=http://VOTRE_SERVEUR:8000
```

`API_BASE_URL` doit etre l'URL racine Laravel sans `/api`.

## Creation comptes reels

Procedure recommandee :

1. Creer ou verifier le distributeur.
2. Creer un `users` Laravel pour le compte.
3. Creer un `actor` lie au user.
4. Affecter `actor_profile.workspace_type`.
5. Affecter `distributor_id` quand le role n'est pas SuperAdmin.
6. Verifier `/api/login`, puis `/api/permissions/workspace`.

Workspaces attendus :

- `superadmin`
- `distributeur`
- `commercial`
- `depot`
- `livreur`
- `point_vente`

Pour un point de vente, ajouter aussi une ligne `client_user_access` active afin que le user ne voie que ses propres donnees.

## Donnees metier minimales

Pour tester un distributeur reel :

1. Creer 1 depot.
2. Creer produits, variants et prix.
3. Alimenter `stock_quantity`.
4. Creer clients / points de vente.
5. Affecter clients aux commerciaux.
6. Creer une commande.
7. Generer ou verifier le bon operationnel `purchase_order`.
8. Affecter au depot/livreur.
9. Tester livraison, paiement et tracking.

## Tests terrain

- Commercial : clients, detail client, produits, commande, tracking.
- Depot : commandes a preparer, chargement, stock depot.
- Livreur : stock mobile, delivery, detail livraison, encaissement, trajet.
- Point de vente : catalogue, panier, mes commandes, credit.
- SuperAdmin/Distributeur : dashboards, acteurs, depots, produits, audit.

## Firebase / Google / Facebook

Les connexions Gmail/Facebook et les notifications exigent de vraies cles.

- Ajouter `google-services.json` Android du vrai projet Firebase.
- Verifier le package Android.
- Ajouter SHA-1 et SHA-256 dans Firebase.
- Restreindre les cles Google Maps par package + SHA.
- Configurer Facebook App ID, Client Token et callbacks Android.

Si une cle manque, l'app doit afficher une erreur claire et ne doit pas rester en loading infini.

## Google Maps

Si la carte interne n'est pas configuree, les boutons Maps ouvrent Google Maps externe avec une URL `search`/itineraire.

## Bluetooth

Les permissions Android Bluetooth sont declarees. Pour valider :

1. Activer Bluetooth et localisation si requis par Android.
2. Appairer l'imprimante.
3. Ouvrir l'ecran impression/configuration imprimante.
4. Scanner, connecter, imprimer bon de reception/livraison/recu.
5. Si aucun materiel n'est disponible, documenter le resultat en KO materiel, pas KO applicatif.

