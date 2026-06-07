# TASKS.md — Construction de Project OS AI

> Plan de construction du système. Découpé en phases et tâches actionnables.
> **Reprise après `/clear` : lire `PROGRESS.md` (contexte + décisions) puis ce fichier.**
> Cocher les tâches au fur et à mesure. Identifiants `Tx.y` pour référence rapide.

## Terminé

- [x] **T0.1** Décisions de conception actées (outils Code, gouvernance, enforcement à 3 couches). Voir PROGRESS « Décisions actées ».
- [x] **T0.2** Repo privé `project-os-ai` créé (compte Mediatros), branche `main`.
- [x] **T0.3** Veille mensuelle upstream en place (`docs/veille/`, routine `veille-outils-upstream`).
- [x] **T1.1** Arborescence cible créée (`docs/`, `templates/{core,life,code}/`, `structures/`, `agents/`, `examples/`, `scripts/`).
- [x] **T1.2** `README.md` rédigé (présentation Core + Life + Code, public, usage).
- [x] **T1.3** `ROADMAP.md` rédigé (phases + reporté : MCP, portabilité Hermès, index, check).
- [x] **T1.4** Templates Core dans `templates/core/` (`PROJECT`, `PROGRESS`, `CHANGELOG`, `TASKS`, `DECISIONS`).
- [x] **T1.5** `docs/NAMING-CONVENTIONS.md` rédigé (fichiers, dossiers, identifiants `CHG`/`DEC`/`P`/`Tx.y`).
- [x] **T1.6** Docs de gouvernance dans `docs/` (`vision`, `principles`, `governance`, `lifecycle`, `glossary`).
- [x] **T1.7** `structures/core-tree.md` rédigé (arborescence + rôles dossiers).
- [x] **T2.1** Templates Life dans `templates/life/` (`PREUVES`, `ECHEANCES`, `CORRESPONDANCES`).
- [x] **T2.2** `structures/life-tree.md` rédigé (dossiers `05_correspondances/` à `08_modeles/`).
- [x] **T2.3** Templates Code dans `templates/code/` (`AGENTS`, `STACK_VALIDATION`, `ARCHITECTURE`, `SPECS`, `TEST_PLAN`, `IMPACT_ANALYSIS`, `RELEASE`).
- [x] **T2.4** `structures/code-tree.md` rédigé (dossiers `05_specs/` à `src/`, plus `09_scripts/`).
- [x] **T2.5** Gate `STACK_VALIDATION` défini (`docs/stack-validation-gate.md` : protocole sourcé et daté, règle d'or).
- [x] **T2.6** Concept « kit de rails » + format recette défini (`docs/kit-de-rails.md`, couplé à `IMPACT_ANALYSIS`).
- [x] **T2.7** Extension Knowledge ajoutée et câblée (`structures/knowledge-tree.md`, `templates/knowledge/`, `scripts/init-project.sh --knowledge`, skill assistant, règles de navigation progressive et dépendances transverses dans les docs).
- [x] **T3.1** Modes cadrés (reprise / orientation / explication / clôture) + aiguillage complet vs allégé (`agents/meta-skill.md`).
- [x] **T3.2** Skill assistant installable écrite (`skills/project-os/SKILL.md`, frontmatter + 4 modes + initialisation).
- [x] **T3.3** Fiches d'agent rédigées (`agents/claude-code.md`, `agents/hermes.md`, `agents/meta-skill.md`).
- [x] **T4.1** Modèle d'enforcement défini (`docs/enforcement.md` : 3 couches, runtime sh POSIX, portée par projet, fermeté hybride).
- [x] **T4.2** Hooks implémentés et testés (`scripts/hooks/` : `_lib.sh`, `hook-pre-write.sh` nommage+placement, `hook-stop-progress.sh` fraîcheur PROGRESS).
- [x] **T4.3** `scripts/init-project.sh` écrit et testé (Core / +Life / +Code / Hybrid, fichiers sacrés, 00_inbox, câblage hooks dans `.claude/settings.json`).
- [x] **T5.1** Installation et usage de Harness documentés (`docs/harness.md` : prérequis Claude Code v2.1+, install plugin, 5 verbes, artefacts ; faits sourcés sur le dépôt upstream le 2026-06-01).
- [x] **T5.2** Emprunts Spec Kit réimplémentés en Markdown : `templates/code/CONSTITUTION.md` (principes projet) + `docs/clarify.md` (réflexe de levée d'ambiguïté).
- [x] **T5.3** Harness articulé aux fichiers sacrés (`docs/harness.md` : table `spec.md`→`SPECS`, `Plans.md`→`TASKS`, work→`PROGRESS`/`CHANGELOG`, review→`TEST_PLAN`/`IMPACT_ANALYSIS`, release→`RELEASE`). Constitution câblée dans `code-tree` et `AGENTS`.

## En cours

(rien pour l'instant)

## À faire

### Phase 6 — Banc d'essai Unjque
But : valider la méthode sur un vrai projet.

- [ ] **T6.1** Onboarder Unjque via `init-project.sh` (profil Code).
- [ ] **T6.2** Relever les frictions et ajuster templates / skill / hooks.

### Phase 7 — Portabilité Hermès (ROADMAP)
- [ ] **T7.1** Exposer la couche gouvernance vers Hermès via MCP partagé ou double skill `agentskills.io`.

## Abandonné

- [x] **anatomy.md** : abandonné, remplacé par l'alignement sur le CLAUDE.md global.
