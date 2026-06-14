# Gouvernance — Project OS AI

Les règles d'opération du système : qui met à jour quoi, quand, et ce qui exige une validation humaine.

## Fichiers sacrés du Core

Tout projet, quel que soit son type, possède ces cinq fichiers à sa racine :

| Fichier | Rôle | Nature |
|---|---|---|
| `PROJECT.md` | Pourquoi le projet existe, périmètre, objectifs, critères de réussite | Stable |
| `PROGRESS.md` | État actuel, dernières actions, en cours, prochaine action | Photo de l'instant |
| `CHANGELOG.md` | Historique daté de ce qui a changé | Registre figé |
| `TASKS.md` | Checklist d'actions concrètes cochables | Vivant |
| `DECISIONS.md` | Pourquoi des choix structurants | Registre figé |

## Frontière entre fichiers sacrés

Règle d'aiguillage unique. Une information ne vit qu'à un seul endroit.

- **État présent et prochaines actions**, jamais d'historique → `PROGRESS.md`.
- **Ce qui a changé, daté** (`CHG-YYYYMMDD-HHMM`) → `CHANGELOG.md`.
- **Actions atomiques cochables** (`Tx.y`) → `TASKS.md`.
- **Le pourquoi des choix structurants** (`DEC-XXXX`) → `DECISIONS.md`.

Les autres fichiers référencent par identifiant (« voir DEC-0003 »), ils ne recopient pas.

## Rituels de session

### Au démarrage

Lire dans l'ordre : `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md`.
Puis produire : **État actuel / Dernière action / Prochaine action / Points de vigilance.**

### Pendant

- Mettre à jour `PROGRESS.md` après toute avancée significative.
- Logger les changements notables dans `CHANGELOG.md`.
- Documenter les décisions structurantes dans `DECISIONS.md`.

### En fin de session

- Mettre à jour tous les fichiers Core concernés.
- Produire un résumé : fait / reste / décisions / risques / prochaine action.

## Règles immuables

- `PROGRESS.md` est l'état actuel, jamais un journal. Son bloc d'en-tête est tenu à jour à chaque modification du fichier.
- `CHANGELOG.md` est un historique utile, valable aussi pour les projets Life, pas seulement technique.
- `DECISIONS.md` ne contient que des décisions structurantes, au format `DEC-XXXX` (contexte, options, choix, raison, conséquences).
- `PREUVES.md` (Life) relie chaque affirmation à un document source (`P-XXXX`).
- `STACK_VALIDATION.md` (Code) est obligatoire et validé avant la première ligne de code.

## Actions nécessitant une validation humaine

- Suppression massive de fichiers ou de dossiers.
- Réorganisation de l'arborescence d'un projet.
- Changement de stack technique.
- Déploiement.
- Push Git important.
- Toute action juridique ou administrative sensible.

L'agent propose et explique ; l'humain tranche.

## Extension Knowledge

L'extension `knowledge` ajoute une couche documentaire progressive dans `docs/` quand un projet devient trop dense pour être repris uniquement par les fichiers sacrés.

Règles :

- `docs/INDEX.md` est le point d'entrée documentaire.
- `docs/kb_governance.md` définit les niveaux, la navigation et les règles anti-dérive.
- Le niveau global est lu avant les domaines ; les détails sont lus uniquement si l'action l'exige.
- Avant modification, l'agent liste les composants impactés, les composants explicitement non impactés, les dépendances transverses et les documents à mettre à jour.
- Understand-Anything et les graphes sont des aides de visualisation, jamais des sources de vérité.

Structure de référence : `structures/knowledge-tree.md`. Templates : `templates/extensions/knowledge/`.

## Synchronisation Mac / VPS

Le dossier des projets est synchronisé par **Syncthing** (marqueurs `.stfolder` / `.stignore`). Le projet courant est le dossier de travail contenant un `PROJECT.md`. Lancé à la racine du dossier de projets, l'agent liste les projets et demande lequel reprendre.

## Versioning de la méthode

La méthode est versionnée (`project-os v1`, `v2`...). Chaque projet inscrit la version utilisée dans l'en-tête de `PROJECT.md`. Les évolutions de la méthode sont consignées dans le `CHANGELOG.md` du repository.

## Archivage

Quand `CHANGELOG.md` ou un registre devient long, les entrées anciennes sont déplacées vers `99_archive/CHANGELOG-YYYY.md`. `PROGRESS.md` reste court par nature.
