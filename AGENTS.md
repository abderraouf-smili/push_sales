# AGENTS.md - Instructions pour Codex / Agents IA

## 0. Vision generale

Ce fichier est la reference principale pour tout agent IA qui travaille sur **Push Sales**.

Push Sales doit evoluer vers une solution professionnelle, moderne, rapide, securisee, complete et facile a utiliser, comme une application realisee par une equipe experte.

L'objectif n'est pas seulement de corriger le code : l'objectif est de transformer  Push Sales en une application de qualite production, avec une excellente experience utilisateur, une architecture maintenable, une documentation claire et des tests fonctionnels par role.


---

## 1. Structure du repository

Le repository contient deux parties principales :

```text
push_sale-master          # Backend Laravel API
push_sale_mobile-master   # Application mobile Flutter
```

La logique metier doit rester centralisee cote backend Laravel.
L'application mobile Flutter consomme l'API Laravel.
Flutter ne doit jamais se connecter directement a MySQL/MariaDB.

---

## 2. Objectif final du projet Push Sales

Push Sales doit devenir une solution complete de gestion commerciale / force de vente / livraison / stock.

L'application cible doit permettre, selon l'existant du projet et les roles utilisateurs :

- authentification securisee ;
- gestion des utilisateurs et profils metier ;
- gestion des clients / points de vente ;
- consultation client, solde, historique et visites ;
- gestion produits, variantes, prix, promotions et coupons ;
- creation et suivi des commandes ;
- gestion des depots / entrepots ;
- gestion du stock reel, previsionnel et mobile ;
- chargement / transfert vers livreur ;
- livraison terrain ;
- preuve de livraison ;
- encaissement / cash ;
- tracking des commandes ;
- statistiques et tableaux de bord ;
- notifications ;
- chat si present ;
- impression Bluetooth si presente ;
- future application Web similaire au mobile, sans duplication de logique metier.

L'application doit etre :

- moderne visuellement ;
- claire ;
- rapide ;
- fluide ;
- stable ;
- intuitive ;
- adaptee aux utilisateurs terrain ;
- adaptee aux roles existants ;
- maintenable ;
- securisee ;
- testable ;
- documentee ;
- compatible avec l'API Laravel existante.

---

## 3. Regle principale absolue

**Ne jamais modifier la logique metier mais tu peux rajoutter des logique adapter à la logique métier existant pour plus de visibilité ou flexibilité ou facilité ou peu import.**

La logique metier comprend notamment :

- commandes ;
- clients ;
- produits ;
- variantes ;
- prix ;
- promotions ;
- coupons ;
- stock ;
- depots / entrepots ;
- transferts ;
- chargements ;
- livraison ;
- preuve de livraison ;
- cash / paiement ;
- transactions ;
- permissions ;
- statistiques ;
- notifications ;
- chat ;
- authentification ;
- roles ;
- formats JSON API ;
- routes API.

Codex peut ameliorer par defaut :

- UI/UX ;
- design system ;
- lisibilite ;
- performance Flutter ;
- loaders ;
- empty states ;
- error states ;
- messages utilisateur ;
- confirmations ;
- documentation ;
- tests ;
- securite non cassante ;
- logs ;
- structure des widgets ;
- nettoyage d'imports ;
- bonnes pratiques ;
- preparation progressive de montee de version.



---

## 4. Mode de travail attendu : mission one-shot controlee



Codex doit travailler en **one-shot controle**, c'est-a-dire ne s'arret jusqu'a que tu finalise le tt et sans aucune erreur et avec tt puissance d'amélioration :

1. Lire `AGENTS.md`.
2. Lire `PROJECT_HISTORY.md` s'il existe.
3. Lire `MAINTENANCE_HISTORY.md`, `CHANGELOG.md`, `README_DEV.md` s'ils existent.
4. Inspecter uniquement les fichiers utiles.
5. raisonner bien et comme des experts
6. Executer les changements par phases logiques.
7. Tester apres chaque groupe de changements.
8. Ne laisser pas le projet non finaliser.
9. Documenter chaque decision importante.
10. Donner un resume final clair.



---

## 5. Priorite absolue

Toujours respecter cet ordre :

```text
1. Securite
2. Stabilite
3. Respect logique metier
4. Compatibilite API
5. Simplicite
6. UX professionnelle
7. Performance
8. Maintenabilite
9. Documentation
10. Optimisation des tokens
```

---



## 7. Historique projet obligatoire

Codex doit utiliser ce fichier comme memoire technique courte :

```text
PROJECT_HISTORY.md
```

Avant chaque mission :

1. lire `AGENTS.md` ;
2. lire `PROJECT_HISTORY.md` s'il existe ;
3. utiliser l'historique pour comprendre l'etat actuel ;
4. lire ensuite uniquement les fichiers necessaires.

Apres chaque changement important, mettre a jour `PROJECT_HISTORY.md` avec :

- date ;
- zone modifiee ;
- objectif ;
- resume du changement ;
- risque ;
- impact logique metier ;
- tests effectues ;
- tests a faire ;
- prochaine etape.

Ne jamais mettre dans `PROJECT_HISTORY.md` :

- mots de passe ;
- tokens ;
- cles API completes ;
- donnees clients sensibles ;
- dumps SQL ;
- secrets ;
- certificats prives.

---

## 8. Backend Laravel

Chemin :

```text
push_sale-master
```

Regles backend :

- garder les routes existantes ;
- garder la compatibilite avec Flutter ;
- garder les reponses API compatibles ;
- ne pas modifier la logique metier ;
- ne pas modifier les calculs metier ;
- eviter d'exposer les erreurs sensibles ;
- respecter les controles de tenant / acteur / permissions existants.

Priorites Laravel :

1. Securite : `.env`, validation, permissions, protection endpoints.
2. Stabilite : tests login/API, conservation routes/reponses.
3. Documentation : routes, roles, scenarios de test.
4. Modernisation : upgrade progressif seulement.
5. Architecture : services, form requests, resources uniquement si non cassant.



## 10. Objectif UI/UX professionnel

L'application doit devenir :

- simple ;
- claire ;
- moderne ;
- rapide ;
- professionnelle ;
- elegante ;
- facile pour des utilisateurs non techniques ;
- adaptee au terrain ;
- lisible sur smartphone ;
- coherente sur tous les ecrans.

Priorites UX :

- dashboard par role ;
- menus clairs ;
- navigation intuitive ;
- icones coherentes ;
- formulaires simples ;
- messages humains et actionnables ;
- listes avec recherche et filtres ;
- loaders ;
- etats vides ;
- etats erreur ;
- etats succes ;
- confirmations avant actions critiques ;
- badges de statut ;
- cartes modernes ;
- couleurs coherentes ;
- typographie lisible ;
- boutons larges et clairs ;
- meilleur feedback utilisateur ;
- design responsive pour future version Web.

Composants a creer ou standardiser si necessaire :

```text
lib/theme/app_theme.dart
lib/theme/app_colors.dart
lib/theme/app_text_styles.dart
lib/theme/app_spacing.dart
lib/widgets/common/app_scaffold.dart
lib/widgets/common/app_button.dart
lib/widgets/common/app_text_field.dart
lib/widgets/common/app_search_bar.dart
lib/widgets/common/app_card.dart
lib/widgets/common/app_empty_state.dart
lib/widgets/common/app_error_state.dart
lib/widgets/common/app_loading_state.dart
lib/widgets/common/app_status_chip.dart
lib/widgets/common/app_confirm_dialog.dart
lib/widgets/common/app_snackbar.dart
lib/widgets/common/app_page_header.dart
lib/widgets/common/app_stat_card.dart
```

Ces composants doivent etre introduits progressivement sans casser les ecrans existants.

---

## 11. Ecrans Flutter a moderniser en priorite

Priorite 1 :

- Login ;
- Signup ;
- HomePage ;
- Dashboard / statistiques ;
- Clients ;
- Produits ;
- Catalogue ;
- Commandes ;
- Tracking ;
- Livraison ;
- Transfert / chargement ;
- Stock ;
- Paiement / cash ;
- Parametres compte ;
- Erreur Internet.

Pour chaque ecran modernise :

1. Garder les memes appels API.
2. Garder les memes donnees.
3. Garder les memes permissions.
4. Ne pas changer le workflow metier.
5. Ajouter ou ameliorer loading state.
6. Ajouter ou ameliorer empty state.
7. Ajouter ou ameliorer error state.
8. Ajouter messages utilisateur clairs.
9. Ajouter confirmation pour actions critiques.
10. Ameliorer lisibilite et rapidite.
11. Tester l'ecran.
12. Documenter le changement.

Actions critiques a proteger par confirmation :

- creation commande ;
- validation livraison ;
- encaissement ;
- transfert stock ;
- confirmation chargement ;
- annulation ;
- suppression ;
- changement de statut.

---

## 12. Tests fonctionnels par role

Codex doit creer ou mettre a jour :

```text
TEST_SCENARIOS.md
TEST_ACCOUNTS.md