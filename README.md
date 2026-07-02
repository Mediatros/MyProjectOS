# MyProjectOS

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
Core MyProjectOS             commun à tous les projets
├── Extension Life          projets personnels, administratifs, juridiques
├── Extension Code          projets logiciels
└── Extension Knowledge     documentation dense, navigation par niveaux, dépendances transverses
```

Un projet est de type **Life**, **Code** ou **Hybrid**. Le type est déclaré dans `PROJECT.md`. Les extensions sont activées selon le besoin : Life, Code et/ou Knowledge.

## À qui ça s'adresse

À un porteur de projet, y compris non-développeur, qui pilote plusieurs projets avec l'aide d'agents IA : **Claude Code** sur Mac, **Hermès** sur VPS. Le système guide et protège l'utilisateur, surtout en amont des projets Code.

## Installation

Une seule commande, à partir du lien du dépôt. Le dépôt est cloné dans un dossier temporaire, le projet est posé, puis le clone est supprimé. **Le projet final est autonome** : les hooks d'enforcement sont copiés dans son `.claude/hooks/` et ne dépendent plus de l'emplacement de MyProjectOS.

```sh
curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
  | sh -s -- ~/MonProjet --life
```

Flags d'extension : `--life`, `--code`, `--knowledge` (combinables ; aucun = Core seul). Pour greffer sur un projet déjà peuplé sans rien écraser : `--into-existing`.

Variante sans `curl` (clone manuel, jetable) :

```sh
git clone --depth 1 https://github.com/Mediatros/MyProjectOS.git /tmp/mpos
sh /tmp/mpos/scripts/init-project.sh ~/MonProjet --life
rm -rf /tmp/mpos
```

Pour mettre à jour les hooks d'un projet après une évolution de la méthode, relancer l'installation sur ce projet avec `--into-existing` : les hooks locaux sont réécrits, le contenu existant est préservé.

## Comment l'utiliser

1. Installer MyProjectOS sur le dossier du projet (voir ci-dessus).
2. Choisir le type dans `PROJECT.md` et ajouter les extensions nécessaires (`--life`, `--code`, `--knowledge`).
3. Activer l'extension `knowledge` si le projet accumule assez de documentation pour nécessiter une navigation par niveaux (`docs/INDEX.md`, `kb_governance.md`, `01_global/`, `02_domains/`, `03_details/`).
4. À chaque session, suivre les rituels de `docs/governance.md` : lire les fichiers sacrés au démarrage, les mettre à jour pendant et en clôture.

## Structure du repository

```
MyProjectOS/
├── README.md / ROADMAP.md / CHANGELOG.md
├── PLAN/              # handoff, plans et documents de travail hors docs stables
├── docs/              # vision, principes, gouvernance, cycle de vie, glossaire, nommage
├── templates/
│   ├── core/          # PROJECT, PROGRESS, CHANGELOG, TASKS, DECISIONS (socle)
│   └── extensions/    # modules activables selon le type de projet
│       ├── life/      # PREUVES, ECHEANCES, CORRESPONDANCES
│       ├── code/      # AGENTS, STACK_VALIDATION, ARCHITECTURE, etc.
│       └── knowledge/ # docs/INDEX, kb_governance, niveaux, plans, runbooks
├── structures/        # core-tree, life-tree, code-tree, knowledge-tree
├── agents/            # claude-code, hermes, meta-skill
├── examples/          # projets d'exemple Life et Code
└── scripts/           # init-project.sh
```

## Documentation

- [Vision](docs/vision.md) — le problème et la promesse « Reprends le projet ».
- [Principes](docs/principles.md) — les règles qui tranchent les arbitrages.
- [Gouvernance](docs/governance.md) — qui met à jour quoi, quand, et ce qui exige une validation humaine.
- [Cycle de vie](docs/lifecycle.md) — de la création à l'archivage.
- [Versionnement](docs/versioning.md) — comment la méthode se numérote et comment un projet sait s'il est à jour.
- [Conventions de nommage](docs/NAMING-CONVENTIONS.md) — fichiers, dossiers, identifiants.
- [Glossaire](docs/glossary.md) — le vocabulaire commun.

## État

En construction. Voir [ROADMAP.md](ROADMAP.md) et `TASKS.md` pour le plan détaillé.
