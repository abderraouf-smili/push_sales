# AGENTS.md - Instructions pour Codex / Agents IA

## 1. Objectif du projet

Ce repository contient le projet **Push Sales** avec deux parties principales :

```text
push_sale-master                  # Backend Laravel API
push_sale_mobile-master    # Application mobile Flutter
```

Objectif global : faire evoluer Push Sales vers une solution moderne, securisee et professionnelle, avec :

- un backend Laravel stable et securise ;
- une application mobile Flutter plus moderne et facile a utiliser ;
- une future application Web similaire a l'application mobile ;
- une logique metier unique cote backend ;
- une meilleure documentation et une meilleure maintenabilite.

## 2. Regle principale absolue

**Ne pas modifier la logique metier sans demande explicite.**

La logique metier comprend notamment : commandes, clients, produits, prix, promotions, coupons, stock, entrepots, transferts, livraison, cash/paiement, permissions, statistiques, notifications et chat.

Codex peut ameliorer par defaut : securite, lisibilite, documentation, UI/UX, validation, logs, gestion d'erreurs, tests, structure, bonnes pratiques et preparation de montee de version.

Codex ne doit pas faire sans validation humaine :

- changer les routes API utilisees par Flutter ;
- changer le format JSON des reponses API ;
- modifier les calculs metier ;
- supprimer des controllers, models, migrations ou ecrans ;
- changer l'authentification ;
- modifier le schema de base de donnees sans plan ;
- faire une montee de version majeure d'un seul coup ;
- remplacer GetX ou toute architecture importante sans validation.

## 3. Optimisation des tokens

Pour economiser les tokens :

1. Lire ce fichier avant chaque mission.
2. Lire `PROJECT_HISTORY.md` s'il existe.
3. Ne pas analyser tout le repository sauf necessite.
4. Lire seulement les fichiers utiles a la mission.
5. Eviter de recopier des fichiers complets.
6. Afficher seulement les diffs ou resumes utiles.
7. Faire de petites modifications ciblees.
8. Ne pas generer de gros rapports sauf demande.
9. Utiliser l'historique du projet pour eviter de reposer les memes questions.
10. En cas de risque eleve, s'arreter et demander validation.

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

## 4. Historique projet obligatoire

Codex doit utiliser le fichier suivant comme memoire technique courte :

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
- resume du changement ;
- risque ;
- tests a faire ;
- prochaine etape.

Ne jamais mettre dans `PROJECT_HISTORY.md` : mots de passe, tokens, cles API completes, donnees clients sensibles, dumps SQL ou secrets.

## 5. Bonnes pratiques generales

### Securite

- Ne jamais mettre de mot de passe, token ou cle privee dans le code.
- Ne jamais exposer `.env`.
- Ne jamais afficher un secret complet dans une reponse.
- Deplacer les valeurs sensibles vers `.env` ou configuration securisee.
- Verifier `.gitignore` avant chaque ajout important.
- Recommander la rotation des cles exposees.
- Ne pas logger les tokens, passwords, headers Authorization ou donnees sensibles.
- Valider les entrees cote backend.
- Ne pas faire confiance aux donnees envoyees par Flutter ou Web.

### Qualite

- Faire des changements petits et lisibles.
- Respecter les patterns existants.
- Reduire les duplications progressivement.
- Ne pas faire de refactoring massif sans plan.
- Ajouter des tests autour des comportements critiques si possible.
- Documenter les decisions importantes dans `PROJECT_HISTORY.md`.

### Git

Commits recommandes :

```text
security: remove hardcoded token
backend: add request validation
mobile: improve login error message
docs: update project history
web: add dashboard planning
chore: update gitignore
refactor: extract reusable helper
```

## 6. Backend Laravel

Chemin :

```text
push_sale-master/push_sale-master
```

Regles backend :

- garder les routes existantes ;
- garder la compatibilite avec Flutter ;
- garder les reponses API compatibles ;
- ne pas modifier la logique metier ;
- ajouter les validations progressivement ;
- ameliorer la securite progressivement ;
- eviter d'exposer les erreurs sensibles.

Priorites Laravel :

1. Securite : `.env`, validation, permissions, protection endpoints.
2. Stabilite : tests login/API, conservation routes/reponses.
3. Modernisation : upgrade progressif, verification PHP/Laravel/Composer/Passport/Sanctum/Firebase.
4. Architecture : services, form requests, resources uniquement si non cassant.

Interdictions sans validation : modifier migrations existantes, supprimer colonnes, changer noms de routes, changer format de reponse, changer calculs stock/prix/commande, changer authentification.

## 7. Application Flutter mobile

Chemin :

```text
push_sale_mobile-master/push_sale_mobile-master
```

Regles Flutter :

- garder les workflows existants ;
- garder GetX pour le moment ;
- garder la compatibilite avec l'API ;
- ne pas changer les routes API consommees ;
- ameliorer progressivement l'interface ;
- ne pas casser le build Android.

Priorites Flutter :

1. Securite : pas de token hardcode, pas de logs sensibles, config API centralisee.
2. UI/UX : design moderne, loaders, messages clairs, confirmation des actions critiques, recherche/filtres.
3. Code : API centralisee, widgets reutilisables, duplication reduite.
4. Mise a jour : utiliser `flutter pub outdated`, upgrader par groupe, tester `flutter analyze` et `flutter build apk`.

Interdictions sans validation : remplacer GetX, modifier toute l'UI d'un coup, changer modeles de donnees, supprimer ecrans, modifier logique commande/stock/prix.

## 8. Future application Web

Objectif : creer une application Web similaire a l'application mobile, avec la meme logique metier cote backend.

Avant de coder le Web, Codex doit proposer :

1. mapping Mobile vers Web ;
2. roles utilisateurs ;
3. menus ;
4. ecrans prioritaires ;
5. choix technique recommande ;
6. plan progressif ;
7. risques.

Technologies a evaluer : Laravel Blade moderne, Laravel + Vue, Laravel + React, Flutter Web si justifie.

Regle importante : le Web ne doit pas dupliquer la logique metier. Il doit consommer l'API Laravel.

## 9. Securite repository

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
4. deplacer vers `.env` ou config securisee ;
5. mettre a jour `.gitignore` ;
6. noter le risque dans `PROJECT_HISTORY.md`.

## 10. Montee de version

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

Pour Laravel : verifier PHP, Laravel, Composer, Passport, Sanctum, Firebase et serveur cible.

Pour Flutter : lancer `flutter pub outdated`, puis mettre a jour progressivement et tester `flutter analyze`, `flutter run`, `flutter build apk`.

## 11. UI/UX cible

L'application doit devenir : simple, claire, moderne, rapide, professionnelle et facile pour des utilisateurs non techniques.

Priorites UX :

- dashboard par role ;
- menus clairs ;
- icones coherentes ;
- formulaires simples ;
- messages humains ;
- listes avec recherche, filtres et pagination ;
- loaders ;
- etats vides ;
- confirmations avant actions critiques ;
- design responsive pour le Web.

## 12. Tests utiles

Backend Laravel :

```bash
php artisan route:list
php artisan config:clear
php artisan cache:clear
php artisan test
composer install
composer update --dry-run
```

Flutter :

```bash
flutter pub get
flutter pub outdated
flutter analyze
flutter run
flutter build apk
```

Verifications manuelles : login, profil utilisateur, clients, produits, commandes, stock, permissions, notifications, impression Bluetooth, geolocalisation.

## 13. Gestion des risques

Niveaux : faible, moyen, eleve, critique.

Risque faible : documentation, UI legere, typo, `.gitignore`.

Risque moyen : refactoring limite, validation API, package mineur.

Risque eleve : auth, routes API, modeles, upgrade majeur, stock/commande/prix.

Risque critique : migration destructive, suppression fichiers, secrets, paiement/cash, permissions, logique metier.

Si risque eleve ou critique : demander validation avant modification.

## 14. Roadmap strategique

### Phase 1 - Securite et stabilisation

- verifier secrets ;
- ameliorer `.gitignore` ;
- supprimer tokens hardcodes ;
- documenter installation backend/mobile ;
- verifier login et API principale.

### Phase 2 - Documentation et visibilite

- creer/maintenir `PROJECT_HISTORY.md` ;
- ameliorer README ;
- documenter setup backend/mobile ;
- documenter API et roadmap Web.

### Phase 3 - Modernisation technique

- analyser versions Laravel/Flutter ;
- proposer upgrade path ;
- upgrader progressivement ;
- tester apres chaque etape.

### Phase 4 - UI/UX mobile

- moderniser login/dashboard ;
- ameliorer menus, listes, filtres, messages ;
- creer composants reutilisables.

### Phase 5 - Application Web

- mapping fonctionnalites ;
- roles et menus ;
- choix technique ;
- maquette ;
- implementation progressive avec API Laravel.

### Phase 6 - Production readiness

- tests ;
- logs ;
- monitoring ;
- CI/CD plus tard ;
- backup/rollback ;
- documentation deploiement.

## 15. Instruction finale

Priorite absolue :

```text
1. Securite
2. Stabilite
3. Respect logique metier
4. Simplicite
5. Bonnes pratiques
6. Modernisation progressive
7. UX professionnelle
8. Optimisation tokens
```

Ne jamais transformer le projet d'un seul coup. Moderniser progressivement avec controle.