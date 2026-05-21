# Resultats tests Distributeur

## 2026-05-20 - Produits, variants, prix et stock

Contexte :
- Mode reel mobile : `APP_ENV=vpn`.
- API mobile : `API_BASE_URL=http://192.168.1.20:8000`.
- Test API local : `http://127.0.0.1:8000/api`.
- Device : SM A165F via ADB `10.212.134.2:35065`.

| Test | Resultat | Notes |
| --- | --- | --- |
| Login manager distributeur | OK | Compte manager retourne un token Passport |
| `POST /api/workspace/real` section `products` | OK | Workspace `distributeur`, produits charges |
| Filtre statut produits | OK | Valeur par defaut `Actifs` |
| Payload variants | OK | `options`, `group_label`, `detail_label`, `price_history`, `stock_by_warehouse` |
| Detail variant `Infos` | OK build | Affiche SKU, groupe, conditionnement, signature, statut |
| Detail variant `Prix` | OK build/API | Historique prix du plus recent vers le plus ancien |
| Detail variant `Stock` | OK build/API | Liste depots autorises avec quantite, previsionnel, valeur, statut |
| Bouton `Stock` | OK build | Ouvre l'action distributeur existante d'ajustement stock |
| Bouton `Prix` | OK build | Ouvre l'action distributeur existante de gestion prix |
| Analyse Flutter no-fatal | OK | Warnings historiques uniquement |
| APK debug VPN | OK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Installation smartphone | OK | `adb install -r` success |
| Lancement smartphone | OK | `adb shell monkey` success |
| Logcat cible | OK | Pas de `FlutterError`, `No Material widget found`, `DropdownButton` ou crash app cible |

Points a valider tactilement :
- Ouvrir un produit, toucher plusieurs variants, basculer entre `Infos`, `Prix`, `Stock`.
- Verifier visuellement les boutons `Stock` et `Prix` sur des variants avec historiques/depots differents.

## 2026-05-20 - Actions Prix/Stock variant

Contexte :
- Mode reel mobile : `APP_ENV=vpn`.
- API mobile : `API_BASE_URL=http://192.168.1.20:8000`.
- Backend test HTTP local : `http://127.0.0.1:8000/api`.
- Device : SM A165F via ADB `10.212.134.2:35065`.

| Test | Resultat | Notes |
| --- | --- | --- |
| Ouverture action `Prix` | OK build/API | Utilise `POST /api/distributor/price-context`, pas le contexte lourd complet |
| Date debut prix | OK | Initialisee a la date du jour |
| Planification apres dernier prix | OK | Bouton calcule `last_end_date + 1 jour` |
| Chevauchement prix UI | OK | Champ date en erreur avant submit |
| Chevauchement prix backend | OK | Refus propre `status=FAIL` en rollback |
| Enregistrer prix | OK API | Creation prix valide en transaction rollback, pas d'erreur 500 |
| Historique prix | OK build/API | Statuts `Expire`, `Actif`, `Planifie`; plus recent en premier |
| Swipe suppression prix | OK build/API | Appelle `POST /api/distributor/prices/{id}/delete` avec soft delete |
| Ouverture action `Stock` | OK build/API | Utilise `POST /api/distributor/stock-context`, pas le contexte lourd complet |
| Formulaire stock variant selectionne | OK build | Champ variant masque; depot et quantite restent visibles |
| Preview stock | OK build | Ancien stock, nouveau stock et `% vs ancien` affiches |
| Valider stock | OK API | `POST /api/distributor/stock/adjust` repond `SUCCESS`, pas d'erreur 500 |
| Rafraichissement UI | OK build | Fiche variant met a jour `price_history`, `price_label`, `stock_by_warehouse` et `stock_quantity` apres action |
| APK debug VPN | OK | Build, installation et lancement smartphone OK |

Notes :
- Les actions API ecrivent dans le perimetre distributeur connecte.
- Les tests de creation prix ont ete faits dans une transaction rollback pour ne pas polluer la base reelle.

## 2026-05-20 - Assortiment produits/variants

Contexte :
- Mode reel mobile : `APP_ENV=vpn`.
- API mobile : `API_BASE_URL=http://192.168.1.20:8000`.
- Backend test HTTP local : `http://127.0.0.1:8000/api`.
- Device : SM A165F via ADB `10.212.134.2:35065`.

| Test | Resultat | Notes |
| --- | --- | --- |
| Bouton `Assortiment` | OK build | Ajoute dans la meme ligne que recherche/categorie/statut |
| Chargement assortiment | OK API | `POST /api/distributor/product-assortment` |
| Recherche assortiment | OK build | Recherche produit, categorie, variant et SKU |
| Checkbox produit | OK build | Coche/decoche tous les variants du produit |
| Checkbox variant | OK build | Permet de vendre seulement certains variants |
| Sauvegarde assortiment | OK API rollback | `POST /api/distributor/product-assortment/save` retourne SUCCESS |
| Filtrage catalogue distributeur | OK code/API | Si selection configuree, seuls les variants selectionnes restent visibles |
| Audit distributeur | OK code | Action `update_product_assortment` ecrite si `audit_logs` existe |
| APK smartphone | OK | Build, install et lancement OK |
