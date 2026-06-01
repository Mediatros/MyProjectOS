# Project OS AI

Une méthode d'organisation de projets assistée par IA, pour reprendre n'importe quel projet à froid, sans aucun historique de conversation.

Ce n'est pas un logiciel. C'est un système documentaire versionné : des templates Markdown, des règles de gouvernance, une skill assistant et des exemples.

## L'idée en une phrase

Dire **« Reprends le projet »** et obtenir en quelques secondes un état fiable : où on en est, ce qui a été fait, pourquoi, et quelle est la prochaine action.

## Les trois questions

Tout projet répond toujours à trois questions, chacune dans un fichier dédié :

- **Où en est-on ?** → `PROGRESS.md`
- **Qu'est-ce qui a été fait ?** → `CHANGELOG.md`
- **Pourquoi ?** → `DECISIONS.md`

Les projets **Life** ajoutent : *quelle est la preuve ?* (`PREUVES.md`).
Les projets **Code** ajoutent : *la stack est-elle validée, et quels fichiers sont impactés ?* (`STACK_VALIDATION.md`, `IMPACT_ANALYSIS.md`).

## Architecture

```
Core Project OS         commun à tous les projets
├── Extension Life      projets personnels, administratifs, juridiques
└── Extension Code      projets logiciels
```

Un projet est de type **Life**, **Code** ou **Hybrid** (les deux extensions à la fois). Le type est déclaré dans `PROJECT.md`.

## À qui ça s'adresse

À un porteur de projet, y compris non-développeur, qui pilote plusieurs projets avec l'aide d'agents IA : **Claude Code** sur Mac, **Hermès** sur VPS. Le système guide et protège l'utilisateur, surtout en amont des projets Code.

## Comment l'utiliser

1. Créer un projet à partir des templates de `templates/core/` (plus tard : `scripts/init-project.sh`).
2. Choisir le type dans `PROJECT.md` et ajouter l'extension correspondante.
3. À chaque session, suivre les rituels de `docs/governance.md` : lire les fichiers sacrés au démarrage, les mettre à jour pendant et en clôture.

## Structure du repository

```
project-os-ai/
├── README.md / ROADMAP.md / CHANGELOG.md
├── docs/              # vision, principes, gouvernance, cycle de vie, glossaire, nommage
├── templates/
│   ├── core/          # PROJECT, PROGRESS, CHANGELOG, TASKS, DECISIONS
│   ├── life/          # PREUVES, ECHEANCES, CORRESPONDANCES
│   └── code/          # AGENTS, STACK_VALIDATION, ARCHITECTURE, etc.
├── structures/        # core-tree, life-tree, code-tree
├── agents/            # claude-code, hermes, meta-skill
├── examples/          # projets d'exemple Life et Code
└── scripts/           # init-project.sh
```

## Documentation

- [Vision](docs/vision.md) — le problème et la promesse « Reprends le projet ».
- [Principes](docs/principles.md) — les règles qui tranchent les arbitrages.
- [Gouvernance](docs/governance.md) — qui met à jour quoi, quand, et ce qui exige une validation humaine.
- [Cycle de vie](docs/lifecycle.md) — de la création à l'archivage.
- [Conventions de nommage](docs/NAMING-CONVENTIONS.md) — fichiers, dossiers, identifiants.
- [Glossaire](docs/glossary.md) — le vocabulaire commun.

## État

En construction. Voir [ROADMAP.md](ROADMAP.md) et `TASKS.md` pour le plan détaillé.
