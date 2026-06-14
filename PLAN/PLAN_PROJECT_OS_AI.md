# PLAN PROJECT OS AI

Plan de construction du repository `my-project-os`.
Source : `PLAN/HANDOFF.md`. Dernière mise à jour : 2026-06-01.

## 1. Objectif

Construire un système documentaire versionné qui permet de piloter n'importe quel projet (Life ou Code) avec l'aide d'agents IA (Claude Code sur Mac, Hermes sur VPS), de façon à pouvoir dire « Reprends le projet » et obtenir un état fiable sans historique de conversation.

Le livrable n'est pas un logiciel. C'est une méthode, ses templates, ses règles et ses exemples.

## 2. Vision résumée

Trois questions doivent toujours trouver réponse dans les fichiers du projet :
- Où en est-on ? (`PROGRESS.md`)
- Qu'est-ce qui a été fait ? (`CHANGELOG.md`)
- Pourquoi ? (`DECISIONS.md`)

Pour les projets Life s'ajoute : quelle est la preuve ? (`PREUVES.md`).
Pour les projets Code s'ajoute : la stack est-elle validée et quels fichiers sont impactés ? (`STACK_VALIDATION.md`, `IMPACT_ANALYSIS.md`).

## 3. Architecture

```
Core MyProjectOS         commun à tous les projets
├── Extension Life      projets personnels, administratifs, juridiques
└── Extension Code      projets logiciels
```

Un projet est de type Life, Code ou Hybrid. Le type est déclaré dans `PROJECT.md` et conditionne les extensions activées.

## 4. État actuel du repository

- `PLAN/HANDOFF.md` : spécification complète de référence.
- `CLAUDE.md` : règles d'opération pour Claude Code dans ce repo.
- Aucune structure, aucun template, aucun exemple créés pour l'instant.

Le repository est à l'étape zéro. Tout reste à construire.

## 5. Phases de construction

Chaque phase produit un livrable vérifiable. Les phases sont ordonnées pour livrer de la valeur tôt.

### Phase 0 — Fondation et décisions structurantes

Avant d'écrire des templates, trancher les questions qui conditionnent tout le reste (voir `PLAN/PLAN_PROPOSITION_AMELIORATION.md`) :
- mécanisme de synchronisation Mac et VPS ;
- conventions de nommage des fichiers et dossiers ;
- frontière exacte entre les fichiers sacrés (qui évite la redondance) ;
- articulation avec le système `PROGRESS.md` global déjà en place.

Livrable : `docs/governance.md` et `docs/naming-conventions.md` rédigés.

### Phase 1 — Squelette du repository

Créer l'arborescence cible et les fichiers racine.

```
my-project-os/
├── README.md
├── ROADMAP.md
├── CHANGELOG.md
├── LICENSE
├── docs/
├── templates/{core,life,code}/
├── structures/
├── agents/
├── examples/
└── scripts/
```

Initialiser Git.

Livrable : arborescence en place, `README.md` expliquant le système, `ROADMAP.md`.

### Phase 2 — Documentation de vision

Rédiger :
- `docs/vision.md` : le problème, la vision, le principe « Reprends le projet ».
- `docs/principles.md` : simplicité, Markdown-first, human et agent-friendly.
- `docs/governance.md` : règles de mise à jour, reprise, validation humaine.
- `docs/lifecycle.md` : cycle de vie d'un projet (création, travail, reprise, archivage).
- `docs/glossary.md` : vocabulaire commun.

Livrable : documentation conceptuelle complète et cohérente.

### Phase 3 — Templates Core

Créer les cinq fichiers sacrés dans `templates/core/` : `PROJECT.md`, `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md`, `DECISIONS.md`.

Chaque template doit contenir, en tête, son rôle, quand le mettre à jour et comment l'utiliser, puis un squelette remplissable.

Livrable : un projet Core peut être démarré à la main à partir de ces templates.

### Phase 4 — Templates Life

Créer dans `templates/extensions/life/` : `PREUVES.md`, `ECHEANCES.md`, `CORRESPONDANCES.md`.

Définir le registre des preuves (`P-XXXX`) reliant chaque affirmation à un document source.

Livrable : un projet Life est pilotable de bout en bout.

### Phase 5 — Templates Code

Créer dans `templates/extensions/code/` : `AGENTS.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md`.

Livrable : un projet Code peut valider sa stack et analyser l'impact d'une fonctionnalité avant codage.

### Phase 6 — Structures de dossiers

Créer `structures/core-tree.md`, `life-tree.md`, `code-tree.md`.

Chaque fichier décrit l'arborescence, le rôle de chaque dossier, les fichiers attendus et les règles de nommage.

Livrable : la structure physique est documentée et reproductible.

### Phase 7 — Instructions agents

Créer `agents/claude-code.md`, `agents/hermes.md`, `agents/meta-skill.md`.

La meta-skill décrit l'accompagnement de l'utilisateur au démarrage, pendant, à la fin, lors d'une reprise, d'une décision et d'une action critique.

Livrable : Claude Code et Hermes savent comment opérer un projet de façon identique.

### Phase 8 — Exemples

Créer au moins trois exemples réalistes et minimaux :
- `examples/life-copropriete/`
- `examples/life-comptabilite/`
- `examples/code-wordpress-plugin/`

Livrable : un utilisateur voit à quoi ressemble un projet réel.

### Phase 9 — Script d'initialisation

Créer `scripts/init-project.sh` :

```
./scripts/init-project.sh --type life --name "Copropriété"
./scripts/init-project.sh --type code --name "Plugin Gelato"
```

Génère la structure et copie les templates adéquats. Simple au départ.

Livrable : création d'un nouveau projet en une commande.

## 6. Conventions transversales

- Tous les fichiers de pilotage en Markdown.
- `PROGRESS.md` est l'état actuel, jamais un journal.
- `CHANGELOG.md` est l'historique utile, valable aussi pour Life.
- `DECISIONS.md` ne contient que les décisions structurantes (`DEC-XXXX`).
- Aucune action critique sans validation humaine.

## 7. Critères de succès

1. Un nouveau projet peut naître d'un template.
2. L'utilisateur sait où ranger chaque information.
3. Claude Code reprend un projet sans historique de conversation.
4. Hermes reprend le même projet sur VPS.
5. `PROGRESS.md` répond à « on en est où ? ».
6. `CHANGELOG.md` répond à « qu'est-ce qui a été fait ? ».
7. `DECISIONS.md` répond à « pourquoi ? ».
8. Les projets Life relient les informations aux preuves.
9. Les projets Code valident la stack avant développement.
10. Les projets Code identifient les fichiers impactés avant modification.

## 8. Explicitement reporté

Conformément à `PLAN/HANDOFF.md`, ne pas intégrer pour l'instant : Spec Kit, Claude Code Harness, Matt Pocock Skills, boilerplates Melvynx. Une phase d'analyse comparative viendra après la fondation.

## 9. Ordre de travail recommandé

Phase 0, puis 1, puis 2, puis 3. À partir de la phase 3, livrer le Core complet et le tester sur un vrai projet avant d'enchaîner Life (4) et Code (5). Les phases 6 à 9 consolident et automatisent.
