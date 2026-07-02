# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rôle de ce repository

Ce repository documente, structure et versionne le **MyProjectOS** : une méthode d'organisation de projets assistée par IA, utilisable par un non-développeur, pilotée par Claude Code (Mac) et Hermes Agent (VPS).

Ce n'est pas un projet logiciel. C'est un système documentaire de gestion de projets.

## Architecture du système

Le système est organisé en trois couches :

```
Core MyProjectOS         # commun à tous les projets
├── Extension Life      # projets personnels, admin, juridiques
└── Extension Code      # projets logiciels
```

**Core** couvre : contexte, objectif, état, tâches, décisions, progression, reprise.
**Life** ajoute : preuves, correspondances, échéances, courriers.
**Code** ajoute : stack, architecture, specs, tests, releases, impact.

## Fichiers sacrés du Core (obligatoires dans tout projet)

| Fichier | Rôle |
|---|---|
| `PROJECT.md` | Pourquoi le projet existe, périmètre, objectifs, critères de réussite |
| `PROGRESS.md` | État actuel, dernières actions, en cours, prochaines étapes |
| `CHANGELOG.md` | Historique des évolutions importantes et décisions |
| `TASKS.md` | Checklist : à faire / en cours / terminé / abandonné |
| `DECISIONS.md` | Décisions structurantes avec contexte, alternatives, raison du choix |

## Structure physique d'un projet

```
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md
├── 00_inbox/          # zone temporaire non classée
├── 01_context/        # contexte stable
├── 02_work/           # travail actif
├── 03_documents/      # PDF, emails, pièces jointes
├── 04_deliverables/   # livrables finaux
└── 99_archive/        # éléments clôturés ou obsolètes
```

Tout projet reçoit aussi `AGENTS.md` et `CLAUDE.md` à la racine (socle Core) : rituels de session, garde-fous, frontière des fichiers sacrés. `CLAUDE.md` renvoie vers `AGENTS.md`, source unique lisible aussi par Codex.

Extension Life ajoute : `PREUVES.md`, `ECHEANCES.md`, `CORRESPONDANCES.md` + dossiers `05_correspondances/` à `08_modeles/`.

Extension Code ajoute : `CONSTITUTION.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md`, une section dédiée dans `AGENTS.md` + dossiers `05_specs/` à `src/`.

## Structure cible du repository

```
MyProjectOS/
├── README.md / ROADMAP.md / CHANGELOG.md
├── docs/              # vision, principles, governance, lifecycle, glossary, enforcement
├── templates/
│   ├── core/          # PROJECT.md, PROGRESS.md, CHANGELOG.md, TASKS.md, DECISIONS.md, AGENTS.md, CLAUDE.md (socle)
│   └── extensions/    # modules activables selon le type de projet
│       ├── life/      # PREUVES.md, ECHEANCES.md, CORRESPONDANCES.md
│       ├── code/      # AGENTS.md, STACK_VALIDATION.md, ARCHITECTURE.md, etc.
│       └── knowledge/ # docs/INDEX.md, kb_governance.md, niveaux, plans, runbooks
├── structures/        # core-tree.md, life-tree.md, code-tree.md
├── agents/            # claude-code.md, hermes.md, meta-skill.md
├── skills/            # my-project-os/SKILL.md (skill assistant installable)
├── examples/          # life-copropriete/, life-comptabilite/, code-wordpress-plugin/
└── scripts/           # init-project.sh + hooks/ (enforcement déterministe)
```

## Comportement attendu de l'agent

**Au démarrage d'une session**, lire dans l'ordre :
1. `PROJECT.md`
2. `PROGRESS.md`
3. `TASKS.md`
4. `CHANGELOG.md`
5. `DECISIONS.md`

Puis produire : État actuel / Dernière action / Prochaine action / Points de vigilance.

**Pendant la session** : mettre à jour `PROGRESS.md` après toute avancée significative, logger dans `CHANGELOG.md`, documenter les décisions structurantes dans `DECISIONS.md`.

**En fin de session** : mettre à jour tous les fichiers Core concernés, produire un résumé (fait / reste / décisions / risques / prochaine action).

## Règles de gouvernance

- Tout fichier de pilotage doit être en Markdown
- `PROGRESS.md` = état actuel (source de vérité opérationnelle), jamais un journal
- `CHANGELOG.md` = historique utile, pas seulement technique, utilisable pour les projets Life
- `DECISIONS.md` = décisions structurantes uniquement, format `DEC-XXXX` avec contexte, options, choix, raison, conséquences
- `PREUVES.md` (Life) = registre logique `P-XXXX` reliant chaque affirmation à un document source
- `STACK_VALIDATION.md` (Code) = obligatoire avant toute première ligne de code

Actions nécessitant validation humaine : suppression massive, réorganisation de dossiers, changement de stack, déploiement, push Git important, action juridique ou administrative sensible.

## Principes de conception

- Simplicité avant élégance : couvrir 80 % des besoins avec une base simple
- Markdown-first : lisible dans GitHub sans outil externe
- Human-friendly : compréhensible sans être développeur
- Agent-friendly : structuré pour être navigable par Claude Code et Hermes
- Git-friendly : versionnable proprement

## Gestion du contexte et continuité

Un fichier `PROGRESS.md` est maintenu à la racine du projet.

Rôle :
- servir de mémoire opérationnelle compacte
- refléter l'état actuel du projet
- permettre une reprise rapide et fiable

Règles :
- toujours lire `PROGRESS.md` au début d'une session
- le mettre à jour après toute avancée significative ou décision importante
- le garder synthétique, clair et orienté action
- ne pas le transformer en journal ni en historique détaillé

`PROGRESS.md` est la source principale de continuité du projet.
