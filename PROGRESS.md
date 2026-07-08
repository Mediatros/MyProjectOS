---
projet: MyProjectOS
type: Core
statut: en construction
derniere_maj: 2026-07-09
prochaine_action: v0.6.0 publiée (hook Stop sans git). Propager aux projets via --update-method, pilote LaCIOTAT en premier, puis Comptabilite_globale et TeamLeader (0.2.0, sans git, principaux bénéficiaires). Ensuite banc d'essai Unjque (Phase 6), ou T-B.7 / T-C.11.
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

Version `0.5.0` construite le 2026-07-07 : le plan production ready (`PLAN/plans/2026-07-06-plan-amelioration-production-ready.md`) est appliqué, ce qui clôt les Phases B et C (sauf T-B.7 revue documentaire et T-C.11 arbitrage des plans en attente). La méthode sait désormais se mettre à jour dans les projets existants (manifest `.myprojectos/manifest`, `check-update.sh`, `--update-method` avec sauvegarde), accompagne le cadrage et le rythme itératif (`docs/cycle-de-travail.md`, skill à 7 modes, `docs/INSTALL-AGENT.md`), intègre le RETEX comptabilité (`SUJETS.md`, source fraîche), outille la navigation Knowledge (orphelins, liens cassés, budgets), et passe une CI GitHub Actions. Deux exemples complets vivent dans `examples/`. Dogfooding : `check-project.sh .` à 0 bloquant / 0 avertissement. Détail : CHG-20260707-1100 ; raisons : DEC-0021 à DEC-0024.

Dépôt rendu public le 2026-07-07 (DEC-0021, T-A.2 close) : `https://github.com/Mediatros/MyProjectOS`. Commits, tag `v0.5.0` et release poussés ; CI GitHub Actions verte sur `main`. `install.sh` par `curl` et `check-update.sh` fonctionnent désormais depuis n'importe quelle machine, y compris le VPS Hermès.

## Décisions actées

Les décisions structurantes sont consignées dans `DECISIONS.md` (format `DEC-XXXX`, avec contexte, options, choix, raison, conséquences). L'historique daté des changements est dans `CHANGELOG.md` (`CHG-YYYYMMDD-HHMM`). Ce fichier ne garde que l'état courant.

## Travail en cours

- Récupéré du clone divergent résorbé le 2026-07-09 (non committé) : 3 skills de maintenance `.claude/skills/` (add-extension, evolve-method, validate, cherry-pick) et détection sans git dans `hook-stop-progress.sh`. Consigné : CHG-20260709-0017, DEC-0025. Release mineure à décider pour propager le hook aux projets existants.
- Ouvert : T-B.7 (mode revue documentaire périodique), T-C.11 (statuer sur les plans en attente Company OS / SecondBrain PKB / Steward OS, avec T-PLAN-1).

## Besoins Code identifiés (trois couches)

1. Amont (spec, stack, séquençage) : couvert par Spec Kit + interrogation type `/grill-me`. Couche la plus critique pour l'utilisateur.
2. Exécution encadrée : couvert par Claude Code Harness.
3. Architecture « Agent First » : non fournie par les outils de process. Modèle retenu = un « kit de rails » par type de stack. Chaque kit = `ARCHITECTURE.md` (domaine fonctionnel + séparation des responsabilités) + conventions/typage + règles agent (CLAUDE.md/AGENTS.md) + recettes d'ajout de feature + gate qualité. Pièce maîtresse : la recette (rail générique) couplée à IMPACT_ANALYSIS (instance précise). Pas de boilerplate unique car projets hétérogènes (WordPress, n8n, SaaS).

## Problèmes ouverts / points de vigilance

- `check-project.sh` détecte désormais le repo méthode et exclut `templates/`, `examples/`, `PLAN/` et `NAMING-CONVENTIONS.md` des scans de contenu : le dogfooding vise 0 avertissement.
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
6. Phase A : installation réelle par un agent. **Faite**, y compris T-A.2 (dépôt public depuis le 2026-07-07).
7. Phase B : méthode 2 (adoption) + mise à jour de version. **Faite le 2026-07-07** (sauf T-B.7).
8. Phase C : navigation 3 niveaux, RETEX, qualité générale. **Faite le 2026-07-07** (sauf T-C.11).
9. Publication : push v0.5.0 + tag + release + dépôt public. **Prochaine étape.**
10. Phase 6 : banc d'essai Unjque, puis passage à `1.0.0` (DEC-0015).
11. Phase 7 (ROADMAP) : portabilité Hermès.

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
