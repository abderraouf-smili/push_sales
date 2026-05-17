# AGENTS.md - Instructions pour Codex / Agents IA

## 0. Vision generale

Ce fichier est la reference principale pour tout agent IA qui travaille sur **Push Sales**.

Push Sales doit evoluer vers une solution professionnelle, moderne, rapide, securisee, complete et facile a utiliser, comme une application realisee par une equipe experte.

L'objectif n'est pas seulement de corriger le code : l'objectif est de transformer progressivement Push Sales en une application de qualite production, avec une excellente experience utilisateur, une architecture maintenable, une documentation claire et des tests fonctionnels par role.

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

**Ne jamais modifier la logique metier sans demande explicite et validation humaine.**

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

Codex ne doit pas faire sans validation humaine :

- changer les routes API utilisees par Flutter ;
- changer le format JSON des reponses API ;
- modifier les calculs stock/prix/commande/paiement ;
- modifier les workflows metier ;
- supprimer des controllers, models, migrations, ecrans ou widgets metier ;
- changer l'authentification ;
- remplacer GetX ;
- modifier le schema de base de donnees sans plan ;
- faire une montee de version majeure brutale ;
- supprimer une fonctionnalite existante ;
- faire une refonte complete sans tests.

---

## 4. Mode de travail attendu : mission one-shot controlee

Quand l'utilisateur demande une mission large comme :

```text
moderniser l'application
rendre l'application complete
rendre l'interface professionnelle
faire comme une application des experts
corriger et tester tout
```

Codex doit travailler en **one-shot controle**, c'est-a-dire :

1. Lire `AGENTS.md`.
2. Lire `PROJECT_HISTORY.md` s'il existe.
3. Lire `MAINTENANCE_HISTORY.md`, `CHANGELOG.md`, `README_DEV.md` s'ils existent.
4. Inspecter uniquement les fichiers utiles.
5. Proposer un plan court.
6. Executer les changements par phases logiques.
7. Tester apres chaque groupe de changements.
8. Ne jamais laisser le projet dans un etat non compilable.
9. Documenter chaque decision importante.
10. Donner un resume final clair.

Important : one-shot ne veut pas dire modification dangereuse en une seule fois. Cela veut dire livrer une intervention complete, coherente et testee, tout en respectant la securite et la logique metier.

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

## 6. Optimisation des tokens

Pour economiser les tokens :

1. Lire ce fichier avant chaque mission.
2. Lire `PROJECT_HISTORY.md` s'il existe.
3. Ne pas analyser tout le repository sauf necessite.
4. Lire seulement les fichiers utiles a la mission.
5. Eviter de recopier des fichiers complets.
6. Afficher seulement les diffs ou resumes utiles.
7. Faire des modifications ciblees et expliquees.
8. Utiliser l'historique projet pour eviter de reposer les memes questions.
9. En cas de risque eleve ou critique, s'arreter et demander validation.

Format de reponse attendu :

```text
Resume :
- ...

Fichiers modifies :
- ...

Tests / verifications :
- ...

Risque : faible / moyen / eleve / critique

Impact sur la logique metier : aucun / faible / a valider

Prochaine etape :
- ...
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
- ne pas modifier les migrations existantes sans validation ;
- ajouter validations et securite progressivement ;
- eviter d'exposer les erreurs sensibles ;
- respecter les controles de tenant / acteur / permissions existants.

Priorites Laravel :

1. Securite : `.env`, validation, permissions, protection endpoints.
2. Stabilite : tests login/API, conservation routes/reponses.
3. Documentation : routes, roles, scenarios de test.
4. Modernisation : upgrade progressif seulement.
5. Architecture : services, form requests, resources uniquement si non cassant.

Interdictions sans validation :

- modifier migrations existantes ;
- supprimer colonnes ;
- changer noms de routes ;
- changer format de reponse ;
- changer calculs stock/prix/commande/paiement ;
- changer authentification ;
- changer Passport/Sanctum sans plan ;
- changer la logique des permissions.

Tests backend utiles :

```bash
php artisan route:list
php artisan config:clear
php artisan cache:clear
php artisan test
composer install
composer update --dry-run
```

---

## 9. Application Flutter mobile

Chemin :

```text
push_sale_mobile-master
```

Regles Flutter :

- garder les workflows existants ;
- garder GetX pour le moment ;
- garder la compatibilite avec l'API ;
- ne pas changer les routes API consommees ;
- ne pas changer les modeles de donnees sans validation ;
- ameliorer fortement l'interface si demande ;
- ne pas casser le build Android ;
- ne pas supprimer d'ecran sans validation ;
- ne pas supprimer une dependance sans verifier qu'elle n'est pas utilisee.

Priorites Flutter :

1. Securite : pas de token hardcode, pas de logs sensibles, configuration API propre.
2. UI/UX : design moderne, clair, rapide, flexible.
3. Performance : listes efficaces, images cachees, moins de rebuilds inutiles.
4. Qualite : composants reutilisables, theme commun, duplication reduite.
5. Tests : `flutter analyze`, `flutter build apk`, tests manuels par role.
6. Documentation : scenarios, comptes de test, historique.

Tests Flutter obligatoires apres changements importants :

```bash
flutter clean
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --debug
flutter devices
```

Si device disponible :

```bash
flutter run -d 10.212.134.2:37143
```

---

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
```

Objectif : permettre a l'utilisateur de valider tout le fonctionnement de l'application.

### Comptes de test

Codex doit identifier les roles existants via Laravel et la table/metier `actor`.

Pour chaque role, documenter un compte de test.

Regles de securite :

- ne jamais afficher de vrais mots de passe existants ;
- ne jamais exposer de donnees sensibles ;
- si les mots de passe sont inconnus, proposer une methode de reset ou un seeder ;
- les comptes de test ne doivent pas etre utilises en production.

Si pertinent, proposer un seeder Laravel :

```text
TestUsersByRoleSeeder
```

Comptes de test dev possibles :

```text
admin.test@pushsales.local
commercial.test@pushsales.local
livreur.test@pushsales.local
distributeur.test@pushsales.local
```

Mot de passe dev uniquement :

```text
Test@123456
```

### Scenarios minimums

Documenter au minimum :

- scenario Admin ;
- scenario Commercial ;
- scenario Livreur ;
- scenario Distributeur / Depot ;
- scenario Offline / reseau faible ;
- scenario Impression Bluetooth ;
- scenario Cartes / localisation ;
- scenario Permissions ;
- scenario Commande complete ;
- scenario Livraison avec paiement ;
- scenario Stock / chargement.

Chaque scenario doit contenir :

- role ;
- preconditions ;
- etapes ;
- resultat attendu ;
- points a verifier ;
- statut OK/KO a remplir manuellement.

---

## 13. Securite repository

Toujours verifier la presence de fichiers ou valeurs sensibles :

```text
.env
*.key
*.pem
*.pfx
*.crt
*.cer
google-services.json
GoogleService-Info.plist
firebase_api.php
.sql
tokens
passwords
credentials
Authorization Bearer
API keys
```

Si un secret est trouve :

1. ne pas afficher le secret complet ;
2. indiquer seulement le fichier concerne ;
3. recommander revoke/rotation ;
4. deplacer vers `.env` ou configuration securisee si possible ;
5. mettre a jour `.gitignore` ;
6. noter le risque dans `PROJECT_HISTORY.md`.

Ne jamais logger :

- token ;
- password ;
- header Authorization ;
- donnees clients sensibles ;
- payload complet d'une commande en production ;
- secret API.

---

## 14. Montee de version

Ne jamais faire une montee de version brutale.

Methode obligatoire :

```text
1. Identifier versions actuelles.
2. Identifier versions compatibles.
3. Lire breaking changes.
4. Proposer chemin de migration.
5. Mettre a jour petit a petit.
6. Tester.
7. Corriger.
8. Documenter dans PROJECT_HISTORY.md.
```

Pour Laravel : verifier PHP, Laravel, Composer, Passport/Sanctum, Firebase et serveur cible.

Pour Flutter : lancer `flutter pub outdated`, puis mettre a jour progressivement et tester :

```bash
flutter pub get
flutter analyze
flutter build apk --debug
flutter run -d <device>
```

---

## 15. Future application Web

Objectif : creer une application Web similaire a l'application mobile, avec la meme logique metier cote backend.

Regles :

- le Web consomme l'API Laravel ;
- le Web ne duplique pas la logique metier ;
- le Web respecte les permissions ;
- le Web doit avoir une UI proche du mobile mais adaptee desktop ;
- ne pas commencer le Web sans plan valide.

Avant de coder le Web, Codex doit proposer :

1. mapping Mobile vers Web ;
2. roles utilisateurs ;
3. menus ;
4. ecrans prioritaires ;
5. choix technique recommande ;
6. plan progressif ;
7. risques.

Technologies a evaluer :

- Laravel Blade moderne ;
- Laravel + Vue ;
- Laravel + React ;
- Flutter Web si justifie.

---

## 16. Documentation obligatoire

Apres toute mission importante, mettre a jour si necessaire :

```text
PROJECT_HISTORY.md
MAINTENANCE_HISTORY.md
CHANGELOG.md
README_DEV.md
TEST_ACCOUNTS.md
TEST_SCENARIOS.md
```

Documentation attendue :

- quoi a ete fait ;
- pourquoi ;
- fichiers modifies ;
- commandes executees ;
- tests effectues ;
- resultats ;
- risques ;
- points restants ;
- prochaine etape.

---

## 17. Gestion des risques

Niveaux :

```text
faible
moyen
eleve
critique
```

Risque faible : documentation, UI legere, typo, `.gitignore`.

Risque moyen : refactoring limite, validation API non cassante, package mineur, design system progressif.

Risque eleve : auth, routes API, modeles, upgrade majeur, stock/commande/prix, paiement, permissions.

Risque critique : migration destructive, suppression fichiers, secrets, schema DB, logique metier, cash/paiement, stock.

Si risque eleve ou critique : demander validation avant modification.

---

## 18. Roadmap strategique

### Phase 1 - Securite et stabilisation

- verifier secrets ;
- ameliorer `.gitignore` ;
- supprimer tokens hardcodes ;
- documenter installation backend/mobile ;
- verifier login et API principale.

### Phase 2 - Compatibilite technique

- stabiliser Flutter ;
- stabiliser Android build ;
- corriger dependances ;
- compiler APK ;
- verifier execution smartphone.

### Phase 3 - Design system mobile

- theme global ;
- couleurs ;
- typographie ;
- composants reutilisables ;
- loaders ;
- empty/error states ;
- boutons et formulaires modernes.

### Phase 4 - Modernisation UI/UX mobile

- moderniser login/dashboard ;
- moderniser clients ;
- moderniser produits/catalogue ;
- moderniser commandes ;
- moderniser livraison ;
- moderniser stock/transfert ;
- moderniser statistiques ;
- tester par role.

### Phase 5 - Tests metier et documentation

- comptes de test par role ;
- scenarios de test ;
- validation login ;
- validation commande ;
- validation livraison ;
- validation paiement ;
- validation stock ;
- validation permissions.

### Phase 6 - Application Web

- mapping fonctionnalites ;
- roles et menus ;
- choix technique ;
- maquette ;
- implementation progressive avec API Laravel.

### Phase 7 - Production readiness

- logs propres ;
- monitoring ;
- CI/CD plus tard ;
- backup/rollback ;
- documentation deploiement ;
- securisation cles ;
- tests de non regression.

---

## 19. Definition of Done pour une mission UI/UX complete

Une mission UI/UX complete est terminee seulement si :

- les ecrans modifies compilent ;
- `flutter pub get` est OK ;
- `flutter analyze --no-fatal-infos --no-fatal-warnings` ne montre pas d'erreur bloquante ;
- `flutter build apk --debug` est OK ;
- les workflows metier ne sont pas changes ;
- les routes API ne sont pas changees ;
- les formats JSON ne sont pas changes ;
- les tests manuels a faire sont documentes ;
- les comptes de test sont documentes ou une methode de creation est fournie ;
- `PROJECT_HISTORY.md` est mis a jour ;
- le resume final indique les risques et l'impact metier.

---

## 20. Format final obligatoire de reponse Codex

A la fin de chaque mission, Codex doit repondre ainsi :

```text
Resume :
- ...

Fichiers modifies :
- ...

Ecrans / modules impactes :
- ...

Tests / verifications :
- ...

Comptes de test :
- ...

Scenarios de test :
- ...

Risque : faible / moyen / eleve / critique

Impact sur la logique metier : aucun / faible / a valider

Points restants :
- ...

Message de commit recommande :
`...`
```

---

## 21. Instruction finale

Quand l'utilisateur demande de rendre Push Sales moderne, complet et professionnel, Codex doit viser un resultat expert :

- interface moderne ;
- experience utilisateur claire ;
- composants reutilisables ;
- application rapide ;
- application stable ;
- documentation claire ;
- tests par role ;
- comptes de test documentes ;
- APK compilable ;
- aucune logique metier cassee.

Codex doit toujours travailler avec discipline : analyser, modifier, tester, documenter, resumer.
