# UI_UX_GUIDE - Push Sales

## Direction visuelle

Push Sales doit rester clair, B2B et terrain :
- fond clair legerement bleute ;
- cartes blanches avec bordure fine ;
- bleu primaire pour navigation/action ;
- vert pour succes/livre/paye ;
- orange pour attention/preparation/stock faible ;
- rouge pour blocage/retard/rupture ;
- typographie lisible, titres forts, libelles courts.

## Navigation par workspace

| Workspace | Navigation mobile |
| --- | --- |
| Commercial | Accueil, Clients, Tracking, Produits, Profil |
| Livreur | Accueil, Stock, Delivery, Trajets, Profil |
| Depot | Accueil, Preparation/Chargement, Stock depot, Produits, Profil |
| Distributeur | Accueil, Produits, Depots, Stock, Acteurs/Profil |
| SuperAdmin | Accueil global, Distributeurs, Acteurs, Audit, Profil |
| Point de Vente | Accueil, Catalogue, Panier, Commandes, Profil |

## Composants communs

Utiliser progressivement :
- `AppScaffold`
- `AppPageHeader`
- `AppCard`
- `AppButton`
- `AppTextField`
- `AppSearchBar`
- `AppStatusChip`
- `AppStatCard`
- `AppEmptyState`
- `AppErrorState`
- `AppLoadingState`
- `AppConfirmDialog`

## Regles responsive

- Pas de hauteur fixe pour une page complete.
- Toujours proteger les formulaires par `SingleChildScrollView`.
- Preferer `Wrap` aux `Row` quand le contenu peut deborder.
- Les cartes KPI passent en grille 2 colonnes sur smartphone, 3/4 colonnes sur tablette.
- Le bottom navigation ne doit pas cacher les boutons critiques : ajouter un padding bas adapte.
- Les actions critiques doivent etre visibles et confirmees.

## Etats UI requis

Chaque page principale doit avoir :
- loading state ;
- empty state ;
- error state ;
- action principale visible ;
- messages courts et actionnables ;
- filtres/recherche si liste longue ;
- badge d'etat metier en francais.

## Priorites d'ecran

1. Dashboard par role.
2. Liste metier principale.
3. Detail avec onglets ou sections.
4. Action critique avec confirmation.
5. Feedback succes/echec.

## Densite mobile ajustee 2026-05-18

Pour Samsung A16 / petits smartphones :

- boutons communs reduits a une hauteur compacte ;
- grille KPI en 2 colonnes des 360 px quand possible ;
- cartes MVP moins hautes et padding vertical reduit ;
- actions secondaires de fiche liste en bottom sheet ;
- bottom navigation conservee avec padding bas ;
- detail liste affiche en bottom sheet au lieu d'ecran vide ;
- timeouts auth/API pour eviter loading infini.

Les actions Maps ouvrent Google Maps externe si la carte interne n'est pas configuree.
