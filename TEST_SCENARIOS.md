# TEST_SCENARIOS - Push Sales

Utiliser ces scenarios apres lancement du backend Laravel et installation de l'APK debug.

Backend dev :

```text
http://192.168.1.20:8000
```

APK debug :

```text
push_sale_mobile-master/build/app/outputs/flutter-apk/app-debug.apk
```

Donnees demo recommandees :

```bash
C:\tools\php83\php.exe artisan db:seed --class=TestUsersByRoleSeeder
C:\tools\php83\php.exe artisan db:seed --class=DemoDataSeeder
```

Etat API verifie le 2026-05-17 :
- `/api/login` fonctionne pour admin, commercial, livreur et depot.
- `/api/products`, `/api/warehouses`, `/api/topackorders` retournent des donnees demo.
- `/api/currentstock` retourne du stock pour livreur et depot.
- `/api/toshiporders` retourne une commande demo pour livreur.

## Scenario Admin

Role : Admin

Preconditions :
- Backend Laravel lance.
- Compte `admin.test@pushsales.local` cree par `TestUsersByRoleSeeder`.

Etapes :
1. Se connecter avec le compte Admin.
2. Verifier l'acces au dashboard.
3. Ouvrir produits/catalogue.
4. Ouvrir clients si autorise.
5. Ouvrir menu compte puis menu commercial.
6. Verifier acces acteurs, coupons, promotions, creances et credit.
7. Ouvrir statistiques et commandes.
8. Verifier absence de crash et messages lisibles.

Resultat attendu :
- Les menus admin visibles respectent les permissions.
- Les donnees se chargent via API Laravel.
- Aucun token ou mot de passe n'apparait a l'ecran ou dans les logs utiles.

Statut manuel : OK / KO

## Scenario Commercial

Role : Commercial

Preconditions :
- Compte `commercial.test@pushsales.local`.
- Clients, produits et prix disponibles dans la base.

Etapes :
1. Se connecter.
2. Voir la liste clients.
3. Rechercher un client par nom.
4. Filtrer par ville ou type de point de vente.
5. Ouvrir la fiche client.
6. Consulter solde et historique si disponibles.
7. Ouvrir le catalogue produits.
8. Creer une commande.
9. Confirmer la creation de commande.
10. Verifier message succes ou stock insuffisant.
11. Verifier le tracking de commande.

Resultat attendu :
- Recherche et filtres restent fluides.
- Creation commande conserve les calculs backend.
- Confirmation visible avant creation.
- Etats loading/empty/error lisibles.

Statut manuel : OK / KO

## Scenario Livreur

Role : Livreur

Preconditions :
- Compte `livreur.test@pushsales.local`.
- Commandes pretes a livrer.
- Stock mobile configure si necessaire.

Etapes :
1. Se connecter.
2. Voir commandes a livrer.
3. Ouvrir une commande.
4. Verifier adresse client et produits.
5. Valider livraison.
6. Ajouter preuve de livraison si l'option est activee.
7. Enregistrer encaissement.
8. Imprimer le bon si imprimante Bluetooth disponible.
9. Verifier statut `shipped`, `paid` ou `partially_paid`.
10. Verifier stock mobile.

Resultat attendu :
- Actions critiques demandent confirmation ou feedback clair.
- Livraison et cash passent uniquement par API Laravel.
- Impression utilise `blue_thermal_printer`.

Statut manuel : OK / KO

## Scenario Depot / Distributeur

Role : Depot / Distributeur

Preconditions :
- Compte `depot.test@pushsales.local`.
- Commandes a preparer et stock disponible.

Etapes :
1. Se connecter.
2. Ouvrir transfert / chargement.
3. Voir commandes pretes.
4. Generer un bon de chargement.
5. Confirmer la generation dans la boite de dialogue.
6. Ouvrir le bon.
7. Confirmer le chargement.
8. Verifier mouvement de stock.
9. Verifier tracking et statut.

Resultat attendu :
- Confirmation visible avant generation et confirmation de chargement.
- Stock insuffisant affiche un message clair.
- Aucun calcul stock n'est fait cote Flutter.

Statut manuel : OK / KO

## Scenario Offline / reseau faible

Role : Tous

Etapes :
1. Couper le reseau.
2. Lancer l'application.
3. Verifier l'ecran erreur Internet.
4. Retablir le reseau.
5. Appuyer sur refresh.
6. Verifier retour vers la page attendue.

Resultat attendu :
- Message clair.
- Pas de crash.
- Reprise normale apres connexion.

Statut manuel : OK / KO

## Scenario Impression Bluetooth

Role : Livreur / Depot

Etapes :
1. Connecter une imprimante Bluetooth.
2. Ouvrir les reglages imprimante.
3. Scanner et selectionner l'imprimante.
4. Imprimer bon de livraison ou stock.
5. Verifier que `blue_thermal_printer` fonctionne.

Resultat attendu :
- L'impression n'utilise plus `bluetooth_print`.
- Erreurs Bluetooth affichees clairement.

Statut manuel : OK / KO

## Scenario Cartes / localisation

Role : Commercial / Livreur

Etapes :
1. Donner permission localisation.
2. Ouvrir carte clients ou tracking.
3. Verifier position client.
4. Refuser permission localisation.
5. Relancer l'ecran.

Resultat attendu :
- Carte visible si permission accordee.
- Pas de crash si permission refusee.

Statut manuel : OK / KO

## Scenario Permissions

Role : Tous

Etapes :
1. Se connecter avec chaque compte de test.
2. Comparer les menus affiches aux permissions documentees.
3. Verifier qu'un role ne voit pas les actions non autorisees.

Resultat attendu :
- HomePage affiche uniquement les modules autorises.
- Les permissions viennent de l'API `permissions`.

Statut manuel : OK / KO

## Scenario Depots / produits / transactions

Role : Admin / Depot

Preconditions :
- `DemoDataSeeder` execute.
- Depot demo `WH-DEMO-CENTRAL` et stocks mobiles demo presents.

Etapes :
1. Se connecter avec `depot.test@pushsales.local`.
2. Ouvrir transfert / chargement.
3. Verifier commande a preparer.
4. Ouvrir stock mobile.
5. Ouvrir produits et variantes.
6. Verifier qu'une transaction demo existe via les ecrans de suivi disponibles.

Resultat attendu :
- Depot, produits et stock demo visibles.
- Aucune page importante ne reste vide faute de donnees.
- Les mouvements restent calcules par Laravel.

Statut manuel : OK / KO

## Scenario Responsive

Role : Tous

Etapes :
1. Tester petit smartphone.
2. Tester smartphone normal.
3. Tester grand smartphone.
4. Tester tablette ou fenetre large si disponible.
5. Tourner en paysage sur les ecrans de liste.

Resultat attendu :
- Pas d'overflow bloquant.
- Boutons lisibles et faciles a toucher.
- Listes et cartes restent exploitables.

Statut manuel : OK / KO

## Scenario Notifications

Role : Admin / Livreur

Preconditions :
- Firebase configure pour l'environnement.
- Autorisation notification accordee sur Android.
- `FCM_SERVER_KEY` configure dans `.env` Laravel local/dev.
- L'utilisateur cible possede un `fcmtoken` non vide.

Etapes :
1. Se connecter.
2. Verifier que l'app demande/obtient les permissions necessaires.
3. Appeler l'ecran ou endpoint de notification existant si disponible.
4. Verifier affichage ou absence de crash.

Resultat attendu :
- Aucun crash si Firebase Messaging n'est pas configure en dev.
- Si `FCM_SERVER_KEY` manque, Laravel retourne `status=FAIL` avec message de configuration.
- Les cles de production ne sont pas exposees dans les logs.
- Aucun token FCM complet n'est imprime dans les logs.

Statut manuel : OK / KO

## Scenario Dashboard par role

Role : Admin / Commercial / Livreur / Depot

Preconditions :
- `TestUsersByRoleSeeder` execute.
- `DemoDataSeeder` execute.
- Backend Laravel disponible sur l'URL configuree par Flutter.

Etapes :
1. Se connecter avec chaque compte de test.
2. Ouvrir le tableau de bord.
3. Attendre le chargement des statistiques.
4. Changer d'onglet principal puis revenir au dashboard.
5. Verifier les logs Flutter/Android si un ecran rouge apparait.

Resultat attendu :
- Pas de `Null check operator used on a null value`.
- Pas d'assertion Flutter pendant la navigation.
- Les roles livraison/depot affichent uniquement les indicateurs disponibles pour leur role.
- Les donnees absentes affichent un etat vide/loading au lieu de crasher.

Statut manuel : OK / KO
