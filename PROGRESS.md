---
projet: MyProjectOS
type: Core
statut: en construction
derniere_maj: 2026-07-02
prochaine_action: Phase A terminée (sauf T-A.2, dépôt reporté). Décider la suite : Phase B (méthode 2 + mise à jour), Phase C (navigation 3 niveaux + qualité), ou banc d'essai Unjque (Phase 6). Voir `PLAN/plans/2026-07-02-audit-industrialisation-methode.md`.
prochaine_echeance:
---

# PROGRESS.md — MyProjectOS

> Source de vérité opérationnelle. Lire en début de session, mettre à jour après chaque avancée significative.
> Règle immuable : toute mise à jour de ce fichier met aussi à jour le bloc d'en-tête ci-dessus.

## Objectif du projet

Concevoir et construire `MyProjectOS` : une méthodologie unifiée d'organisation de projets (Life / Code / Hybrid), pilotable par Claude Code (Mac) et Hermès (VPS), permettant de reprendre n'importe quel projet sans historique de conversation. Livrable : un repository de templates, règles, documentation, skill assistant et exemples.

## Contexte utile

- `PLAN/HANDOFF.md` : base de travail initiale, non figée. Tout peut être remis en question.
- Profil utilisateur : non-développeur. Sait exprimer le besoin fonctionnel, pas toujours la stack ni les bonnes pratiques techniques. A besoin d'être guidé et protégé, surtout sur l'avant du pipeline Code.
- Sync Mac/VPS : Syncthing. Détection projet : ouverture directe du dossier, profil Hermès isolé par projet.
- Ce projet sert de pilote : on dogfoode la méthode sur lui-même.
- Plans : `PLAN/PLAN_PROJECT_OS_AI.md` (construction), `PLAN/PLAN_PROPOSITION_AMELIORATION.md` (analyse et décisions), `PLAN/` (plans et documents de travail isolés avant intégration).
- Inspiration : `Unjque_Projet` (naming, index, format PROGRESS, identifiants CHG).
- Outils évalués (juin 2026) : Spec Kit (GitHub, MIT, amont spec→plan→tâches), Claude Code Harness (Chachamaru127, 2,4k★, plan→work→review→release + garde-fous Go, agnostique langage), mattpocock/skills (skills ciblées, ex `/grill-me`).
- NowStack : boilerplate Codelynx LLC (codelynx.dev/nowstack, page fermée/waitlist), mono-stack TanStack Start + React + Convex + Expo + Cloudflare + Stripe, optimisée Claude Code/Cursor (« +40 règles », types stricts). Essence reproductible = les « rails » : architecture par domaine fonctionnel + conventions fortes + règles agent + recettes d'ajout de feature + gate qualité. Mantra : « pas du vibe coding, du AI Building, l'IA code comme un senior parce qu'on lui donne les bons rails ».
- Développements faits principalement avec Claude Code.

## État actuel

Socle construit, Phases 1 à 5 terminées : templates Core + extensions Life/Code/Knowledge, skill assistant installable, hooks d'enforcement, intégration Harness + emprunts Spec Kit, outils de cohérence (`check-project.sh`, `build-index.sh`), versionnement de la méthode (`VERSION`, `0.3.0`). Détail et historique complet dans `CHANGELOG.md` ; raisons des choix dans `DECISIONS.md`.

Phase A du plan `PLAN/plans/2026-07-02-audit-industrialisation-methode.md` terminée le 2026-07-02 (T-A.1, T-A.3 à T-A.8) : installation réelle en une commande (`install.sh`), `LICENSE` MIT, skill installée à la création du projet, `AGENTS.md`/`CLAUDE.md` posés pour tous les types, projet créé auto-vérifiable, repo méthode remis en conformité avec sa propre gouvernance, version portée à `0.3.0` (tag `v0.3.0` posé localement, **non poussé sur le remote**). T-A.2 reportée : le dépôt GitHub reste privé pour l'instant (DEC-0017), donc `install.sh` par `curl` ne fonctionnera pas depuis une machine tierce tant que ce n'est pas rouvert. Phases B (méthode 2 + mise à jour) et C (navigation 3 niveaux + qualité) transposées dans `TASKS.md`, non démarrées.

## Décisions actées

Les décisions structurantes sont consignées dans `DECISIONS.md` (format `DEC-XXXX`, avec contexte, options, choix, raison, conséquences). L'historique daté des changements est dans `CHANGELOG.md` (`CHG-YYYYMMDD-HHMM`). Ce fichier ne garde que l'état courant.

## Travail en cours

- Rien en cours activement. Phase A terminée (sauf T-A.2, reportée). Prochaine décision : Phase B, Phase C, ou Phase 6 (Unjque).
- Statut à trancher pour les plans en attente dans `PLAN/` (Company OS, SecondBrain PKB, Steward OS) : tâche T-C.11 du plan d'industrialisation.
- Commits locaux non poussés sur `origin/main` (dépôt privé, publication reportée par DEC-0017) : à pousser quand décidé.

## Besoins Code identifiés (trois couches)

1. Amont (spec, stack, séquençage) : couvert par Spec Kit + interrogation type `/grill-me`. Couche la plus critique pour l'utilisateur.
2. Exécution encadrée : couvert par Claude Code Harness.
3. Architecture « Agent First » : non fournie par les outils de process. Modèle retenu = un « kit de rails » par type de stack. Chaque kit = `ARCHITECTURE.md` (domaine fonctionnel + séparation des responsabilités) + conventions/typage + règles agent (CLAUDE.md/AGENTS.md) + recettes d'ajout de feature + gate qualité. Pièce maîtresse : la recette (rail générique) couplée à IMPACT_ANALYSIS (instance précise). Pas de boilerplate unique car projets hétérogènes (WordPress, n8n, SaaS).

## Problèmes ouverts / points de vigilance

- `check-project.sh` lancé sur ce repo lui-même (dogfooding, T-A.7) signale 2 avertissements attendus, pas de vrais problèmes : le placeholder `<NomDuProjet>` dans les fichiers de `templates/` (il doit y rester, c'est leur rôle) et l'exemple `CHG-20260601-1430` dans `docs/NAMING-CONVENTIONS.md` (une illustration de format, pas une vraie citation). Le script n'est pas conçu pour distinguer un gabarit d'un projet généré ; à améliorer si ça devient gênant.
- Compatibilité des versions de stack : aucun outil ne la garantit. Valeur ajoutée à construire (gate `STACK_VALIDATION` avec vérification sourcée avant tout code).
- Portabilité de la couche gouvernance vers Hermès : Hermès (Nous Research) est un agent autonome, pas Claude Code, donc il n'exécute pas Harness. Il consomme les fichiers Markdown. Il supporte MCP et agentskills.io : à terme, exposer skill assistant + règles via MCP partagé ou double skill pour qu'Hermès respecte les mêmes garde-fous. Reporté ROADMAP.
- Lien NowStack à obtenir pour reproduire précisément l'approche qui a séduit l'utilisateur.
- Détail des rôles de dossiers numérotés à finaliser une fois la gouvernance posée.

## Prochaines étapes

Détail dans `TASKS.md`. Vue macro :
1. Phase 1 : squelette + templates Core. **Faite.**
2. Phase 2 : extensions Life et Code. **Faite.**
3. Phase 3 : skill assistant (le cœur). **Faite.**
4. Phase 4 : hooks d'enforcement + script d'init. **Faite.**
5. Phase 5 : intégration Harness + emprunts Spec Kit. **Faite.**
6. Phase A : installation réelle par un agent. **Faite** (T-A.1, T-A.3 à T-A.8 ; T-A.2 reportée, dépôt reste privé).
7. Phase B : méthode 2 (adoption d'un projet existant) + mise à jour de version. Non démarrée.
8. Phase C : navigation 3 niveaux, RETEX, qualité générale. Non démarrée.
9. Phase 6 : banc d'essai Unjque.
10. Phase 7 (ROADMAP) : portabilité Hermès.

## Références utiles

- `TASKS.md` : plan de construction détaillé (source pour la reprise après `/clear`).
- `PLAN/plans/2026-07-02-audit-industrialisation-methode.md` : plan en cours (Phase A/B/C).
- `PLAN/HANDOFF.md`, `CLAUDE.md`, `PLAN/PLAN_PROJECT_OS_AI.md`, `PLAN/PLAN_PROPOSITION_AMELIORATION.md`.
- `Unjque_Projet/docs/NAMING-CONVENTIONS.md`, `Unjque_Projet/docs/INDEX.md`, `Unjque_Projet/PROGRESS.md`.

## Contraintes importantes / À ne pas faire

- Ne pas imposer d'outil lourd : l'utilisateur n'est pas développeur, priorité à la simplicité.
- Aucune action critique sans validation humaine.
- Garder simple, Markdown-first, unifié.
- Règles non négociables tenues par des hooks, pas par de simples consignes.
