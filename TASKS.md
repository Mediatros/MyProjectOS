# TASKS.md — Construction de MyProjectOS

> Plan de construction du système. Découpé en phases et tâches actionnables.
> **Reprise après `/clear` : lire `PROGRESS.md` (contexte + décisions) puis ce fichier.**
> Cocher les tâches au fur et à mesure. Identifiants `Tx.y` pour référence rapide.

## Terminé

- [x] **T0.1** Décisions de conception actées (outils Code, gouvernance, enforcement à 3 couches). Voir PROGRESS « Décisions actées ».
- [x] **T0.2** Repo privé `MyProjectOS` créé (compte Mediatros), branche `main`.
- [x] **T0.3** Veille mensuelle upstream en place (`docs/veille/`, routine `veille-outils-upstream`).
- [x] **T1.1** Arborescence cible créée (`docs/`, `templates/{core,life,code}/`, `structures/`, `agents/`, `examples/`, `scripts/`).
- [x] **T1.2** `README.md` rédigé (présentation Core + Life + Code, public, usage).
- [x] **T1.3** `ROADMAP.md` rédigé (phases + reporté : MCP, portabilité Hermès, index, check).
- [x] **T1.4** Templates Core dans `templates/core/` (`PROJECT`, `PROGRESS`, `CHANGELOG`, `TASKS`, `DECISIONS`).
- [x] **T1.5** `docs/NAMING-CONVENTIONS.md` rédigé (fichiers, dossiers, identifiants `CHG`/`DEC`/`P`/`Tx.y`).
- [x] **T1.6** Docs de gouvernance dans `docs/` (`vision`, `principles`, `governance`, `lifecycle`, `glossary`).
- [x] **T1.7** `structures/core-tree.md` rédigé (arborescence + rôles dossiers).
- [x] **T2.1** Templates Life dans `templates/extensions/life/` (`PREUVES`, `ECHEANCES`, `CORRESPONDANCES`).
- [x] **T2.2** `structures/life-tree.md` rédigé (dossiers `05_correspondances/` à `08_modeles/`).
- [x] **T2.3** Templates Code dans `templates/extensions/code/` (`AGENTS`, `STACK_VALIDATION`, `ARCHITECTURE`, `SPECS`, `TEST_PLAN`, `IMPACT_ANALYSIS`, `RELEASE`).
- [x] **T2.4** `structures/code-tree.md` rédigé (dossiers `05_specs/` à `src/`, plus `09_scripts/`).
- [x] **T2.5** Gate `STACK_VALIDATION` défini (`docs/stack-validation-gate.md` : protocole sourcé et daté, règle d'or).
- [x] **T2.6** Concept « kit de rails » + format recette défini (`docs/kit-de-rails.md`, couplé à `IMPACT_ANALYSIS`).
- [x] **T2.7** Extension Knowledge ajoutée et câblée (`structures/knowledge-tree.md`, `templates/extensions/knowledge/`, `scripts/init-project.sh --knowledge`, skill assistant, règles de navigation progressive et dépendances transverses dans les docs).
- [x] **T3.1** Modes cadrés (reprise / orientation / explication / clôture) + aiguillage complet vs allégé (`agents/meta-skill.md`).
- [x] **T3.2** Skill assistant installable écrite (`skills/my-project-os/SKILL.md`, frontmatter + 4 modes + initialisation).
- [x] **T3.3** Fiches d'agent rédigées (`agents/claude-code.md`, `agents/hermes.md`, `agents/meta-skill.md`).
- [x] **T4.1** Modèle d'enforcement défini (`docs/enforcement.md` : 3 couches, runtime sh POSIX, portée par projet, fermeté hybride).
- [x] **T4.2** Hooks implémentés et testés (`scripts/hooks/` : `_lib.sh`, `hook-pre-write.sh` nommage+placement, `hook-stop-progress.sh` fraîcheur PROGRESS).
- [x] **T4.3** `scripts/init-project.sh` écrit et testé (Core / +Life / +Code / Hybrid, fichiers sacrés, 00_inbox, câblage hooks dans `.claude/settings.json`).
- [x] **T5.1** Installation et usage de Harness documentés (`docs/harness.md` : prérequis Claude Code v2.1+, install plugin, 5 verbes, artefacts ; faits sourcés sur le dépôt upstream le 2026-06-01).
- [x] **T5.2** Emprunts Spec Kit réimplémentés en Markdown : `templates/extensions/code/CONSTITUTION.md` (principes projet) + `docs/clarify.md` (réflexe de levée d'ambiguïté).
- [x] **T5.3** Harness articulé aux fichiers sacrés (`docs/harness.md` : table `spec.md`→`SPECS`, `Plans.md`→`TASKS`, work→`PROGRESS`/`CHANGELOG`, review→`TEST_PLAN`/`IMPACT_ANALYSIS`, release→`RELEASE`). Constitution câblée dans `code-tree` et `AGENTS`.

## En cours

- [ ] **T-PLAN-1** Relire et valider le plan `PLAN/plans/2026-06-07-company-os-integration.md` avant intégration dans les docs stables.

## À faire

### Phase A — Rendre la promesse vraie (bloquant, priorité immédiate)
But : qu'un agent qui reçoit le lien du repo puisse réellement installer la méthode, sur un projet vierge, pour Claude Code au minimum. Détail : `PLAN/plans/2026-07-02-audit-industrialisation-methode.md`.

- [x] **T-A.1** Committer l'état actuel (`install.sh`, `scripts/init-project.sh` `--into-existing`/`--sync`, `README.md`). `anatomy.md` passé en `.gitignore` (généré par le hook Stop) ; `docs/hermes-workdoc-2026-06-03-orientation-project-os-ai.md` déplacé vers `PLAN/` (document de travail).
- [x] **T-A.2** Dépôt publié le 2026-07-07 (`gh repo edit --visibility public`), avec la release v0.5.0. CI verte sur `main`. Voir DEC-0021.
- [x] **T-A.3** Ajouter une `LICENSE` (MIT, décidé le 2026-07-02).
- [x] **T-A.4** Installer la skill à la création du projet (`init-project.sh` copie `skills/my-project-os/SKILL.md` dans `.claude/skills/my-project-os/`).
- [x] **T-A.5** Générer un `AGENTS.md` racine pour tous les types (Core/Life/Hybrid), avec `CLAUDE.md` projet minimal qui pointe dessus. L'extension Code ajoute une section « Extension Code » dans le même fichier (fusion idempotente) au lieu d'un fichier séparé.
- [x] **T-A.6** Rendre le projet créé auto-vérifiable (`scripts/check-project.sh` + `VERSION` figée copiés dans le projet cible, exécutables sans dépendre du repo MyProjectOS).
- [x] **T-A.7** Mettre le repo méthode en conformité avec sa propre gouvernance (`PROJECT.md` racine créé, `PROGRESS.md` dégraissé, docs `enforcement`/`lifecycle`/`governance` réalignés). Vérifié avec `check-project.sh` : 0 bloquant.
- [x] **T-A.8** Bump de version à `0.3.0` (`VERSION`, `CHANGELOG.md`, tag `v0.3.0` posé localement, non poussé).
- [x] **T-A.9** Corriger `check-project.sh` : le contrôle d'`AGENTS.md`/`CLAUDE.md` (DEC-0019) était limité aux types Code/Hybrid, alors que ces fichiers sont posés pour tous les types depuis T-A.5. Devenu universel + nouvelle section qui avertit si `AGENTS.md`/`CLAUDE.md`/`.hermes.md`/`SOUL.md`/`.cursorrules` dépasse 20 000 caractères (limite de troncature par défaut d'Hermès Agent). `agents/hermes.md` documente la contrainte. Version portée à `0.4.0`. Voir DEC-0020.

### Phase B — Méthode 2 (adoption d'un projet existant) et mise à jour de la méthode
But : couvrir l'adoption d'un projet déjà peuplé et boucler la détection de mise à jour. **Terminée le 2026-07-07 (v0.5.0, CHG-20260707-1100), sauf T-B.7.** Reprise par le plan `PLAN/plans/2026-07-06-plan-amelioration-production-ready.md` (phases D/E/F).

- [x] **T-B.1** `docs/INSTALL-AGENT.md` écrit (protocole agent, branche méthode 1 / méthode 2 / mise à jour / migration).
- [x] **T-B.2** Méthode 2 définie pas à pas (inventaire, classification, mapping, validation humaine, exécution, rapport) dans `docs/INSTALL-AGENT.md`.
- [x] **T-B.3** Remplissage assisté des fichiers sacrés en méthode 2 (marqué « à confirmer », relecture humaine) dans le protocole et le mode 6 de la skill.
- [x] **T-B.4** Mode « adoption » ajouté à la skill (mode 6).
- [x] **T-B.5** `scripts/check-update.sh` écrit et copié dans chaque projet (sortie 0/10/1, apports par version, artefacts remplacés). Complété par le manifest `.myprojectos/manifest` et `init-project.sh --update-method` (DEC-0022).
- [x] **T-B.6** Runbooks de migration dans `docs/versioning.md` (mise à jour d'un projet, migration d'un projet né avant le versionnement, publication d'une release).
- [ ] **T-B.7** Mode « revue documentaire » périodique de la skill (état condensé + questions fermées de confirmation, déclenchable à la main ou en routine mensuelle).

### Phase C — Navigation à trois niveaux, RETEX et qualité générale
But : navigation progressive fiable et outillée, retours terrain intégrés, repo à niveau de qualité industrielle. **Terminée le 2026-07-07 (v0.5.0, CHG-20260707-1100), sauf T-C.11.**

- [x] **T-C.1** Frontmatter standard des documents Knowledge documenté dans `kb_governance.md` (niveau, domaine, résumé, dépendances, dernière maj).
- [x] **T-C.2** Convention de nommage liant les niveaux 2 et 3 (`<domaine>--<sujet>.md`) dans `docs/NAMING-CONVENTIONS.md`.
- [x] **T-C.3** Budgets de taille par niveau (niveau 1 ≤ 200 lignes, niveau 2 ≤ 300), contrôle en avertissement dans `check-project.sh`.
- [x] **T-C.4** Détection d'orphelins et de liens cassés autour de `docs/INDEX.md` dans `check-project.sh`.
- [x] **T-C.5** RETEX comptabilité intégré : template `SUJETS.md` racine posé par `--knowledge`, source fraîche prioritaire dans `kb_governance.md`, skills par agent dans `templates/core/AGENTS.md` (DEC-0024).
- [x] **T-C.6** `check-project.sh` vérifie `SUJETS.md` quand Knowledge est actif (présence, gabarit non rempli).
- [x] **T-C.7** Faux négatif du hook Stop corrigé (chemin racine exigé) ; couverture du hook pre-write limitée à `Write` documentée comme limite assumée dans `docs/enforcement.md` (rattrapée par `check-project.sh`).
- [x] **T-C.8** Bug de comptage des `WARNS` corrigé (boucle sans sous-shell).
- [x] **T-C.9** Exemples complets `examples/life-copropriete/` et `examples/code-site-vitrine/` + `examples/README.md`.
- [x] **T-C.10** CI GitHub Actions : `shellcheck -S warning` + tests de fumée (création, greffe idempotente, scénario de mise à jour complet, dogfooding).
- [ ] **T-C.11** Statuer sur les plans en attente (Company OS, SecondBrain PKB, Steward OS) : intégration ou archivage. Décision humaine.

### Phase 6 — Banc d'essai Unjque
But : valider la méthode sur un vrai projet.

- [ ] **T6.1** Onboarder Unjque via `init-project.sh` (profil Code).
- [ ] **T6.2** Relever les frictions et ajuster templates / skill / hooks.

### Phase 7 — Portabilité Hermès (ROADMAP)
- [ ] **T7.1** Exposer la couche gouvernance vers Hermès via MCP partagé ou double skill `agentskills.io`.

## Abandonné

- [x] **anatomy.md** : abandonné, remplacé par l'alignement sur le CLAUDE.md global.
