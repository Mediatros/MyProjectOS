# TASKS.md — Construction de Project OS AI

> Plan de construction du système. Découpé en phases et tâches actionnables.
> **Reprise après `/clear` : lire `PROGRESS.md` (contexte + décisions) puis ce fichier.**
> Cocher les tâches au fur et à mesure. Identifiants `Tx.y` pour référence rapide.

## Terminé

- [x] **T0.1** Décisions de conception actées (outils Code, gouvernance, enforcement à 3 couches). Voir PROGRESS « Décisions actées ».
- [x] **T0.2** Repo privé `project-os-ai` créé (compte Mediatros), branche `main`.
- [x] **T0.3** Veille mensuelle upstream en place (`docs/veille/`, routine `veille-outils-upstream`).

## En cours

(rien pour l'instant)

## À faire

### Phase 1 — Squelette + templates Core
But : une arborescence lisible et les 5 fichiers sacrés en version template.

- [ ] **T1.1** Créer l'arborescence cible : `docs/`, `templates/{core,life,code}/`, `structures/`, `agents/`, `examples/`, `scripts/`.
- [ ] **T1.2** `README.md` du repo : présentation du système (Core + Life + Code), à qui il s'adresse, comment l'utiliser.
- [ ] **T1.3** `ROADMAP.md` : étapes et éléments reportés (MCP Calendar/Gmail/Drive, portabilité Hermès).
- [ ] **T1.4** Templates Core dans `templates/core/` : `PROJECT.md`, `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md`, `DECISIONS.md` (avec placeholders et en-têtes normalisés).
- [ ] **T1.5** `docs/NAMING-CONVENTIONS.md` : conventions de nommage et identifiants (`CHG-AAAAMMJJ-HHMM`, `DEC-XXXX`, `P-XXXX`). S'inspirer d'Unjque.
- [ ] **T1.6** Docs de gouvernance dans `docs/` : `vision.md`, `principles.md`, `governance.md`, `lifecycle.md`, `glossary.md`.
- [ ] **T1.7** `structures/core-tree.md` : arborescence type d'un projet Core (dossiers numérotés + rôles).

### Phase 2 — Extensions Life et Code
But : les deux extensions de la méthode.

- [ ] **T2.1** Templates Life dans `templates/life/` : `PREUVES.md`, `ECHEANCES.md`, `CORRESPONDANCES.md`.
- [ ] **T2.2** `structures/life-tree.md` (dossiers `05_correspondances/` à `08_modeles/`).
- [ ] **T2.3** Templates Code dans `templates/code/` : `AGENTS.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md`.
- [ ] **T2.4** `structures/code-tree.md` (dossiers `05_specs/` à `src/`).
- [ ] **T2.5** Définir le gate `STACK_VALIDATION` : vérification de compatibilité de versions, sourcée, obligatoire avant tout code. C'est la valeur ajoutée maison.
- [ ] **T2.6** Définir le concept de « kit de rails » + le format de la recette d'ajout de feature (couplée à `IMPACT_ANALYSIS`).

### Phase 3 — Skill assistant (le cœur)
But : le cerveau qui pilote les projets.

- [ ] **T3.1** Cadrer les modes : reprise / orientation / explication / clôture, et l'aiguillage complet vs allégé selon la taille de la feature.
- [ ] **T3.2** Écrire la skill assistant : lecture des fichiers sacrés au démarrage, production de l'état (actuel / dernière action / prochaine action / vigilance), initialisation de projet.
- [ ] **T3.3** `agents/claude-code.md`, `agents/hermes.md`, `agents/meta-skill.md` : rôles et frontières de chaque agent.

### Phase 4 — Enforcement (hooks) + script d'init
But : rendre les règles non négociables automatiques.

- [ ] **T4.1** Définir le modèle d'enforcement par hooks : MAJ PROGRESS en fin de session, placement des fichiers, nommage.
- [ ] **T4.2** Implémenter les hooks.
- [ ] **T4.3** `scripts/init-project.sh` : pose un nouveau projet (Core, +Life ou +Code) avec structure et fichiers sacrés.

### Phase 5 — Intégration Harness + emprunts Spec Kit
But : brancher la colonne vertébrale Code et les emprunts.

- [ ] **T5.1** Documenter installation et usage de Harness dans le système (prérequis Claude Code v2.1+).
- [ ] **T5.2** Réimplémenter en Markdown les emprunts à Spec Kit : template `constitution` (principes projet) + réflexe `clarify`.
- [ ] **T5.3** Articuler Harness avec les fichiers sacrés : correspondance `spec.md` / `Plans.md` ↔ `PROGRESS` / `TASKS`.

### Phase 6 — Banc d'essai Unjque
But : valider la méthode sur un vrai projet.

- [ ] **T6.1** Onboarder Unjque via `init-project.sh` (profil Code).
- [ ] **T6.2** Relever les frictions et ajuster templates / skill / hooks.

### Phase 7 — Portabilité Hermès (ROADMAP)
- [ ] **T7.1** Exposer la couche gouvernance vers Hermès via MCP partagé ou double skill `agentskills.io`.

## Abandonné

- [x] **anatomy.md** : abandonné, remplacé par l'alignement sur le CLAUDE.md global.
