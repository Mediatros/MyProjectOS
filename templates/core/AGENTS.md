# AGENTS.md — <NomDuProjet>

> Instructions d'opération pour les agents (Claude Code, Codex, Hermès, futurs agents) sur ce projet.
> Fichier lu nativement par Codex. Claude Code le lit via le renvoi posé dans `CLAUDE.md`.
> Les extensions actives (Code, Life...) ajoutent leurs propres sections plus bas dans ce fichier.

## Fichiers sacrés

| Fichier | Rôle |
|---|---|
| `PROJECT.md` | Pourquoi le projet existe, périmètre, objectifs, critères de réussite |
| `PROGRESS.md` | État actuel, dernières actions, en cours, prochaine action |
| `CHANGELOG.md` | Historique daté de ce qui a changé |
| `TASKS.md` | Checklist d'actions concrètes cochables |
| `DECISIONS.md` | Pourquoi des choix structurants |

Une information ne vit qu'à un seul endroit : état présent → `PROGRESS.md` ; changement daté → `CHANGELOG.md` ; tâche → `TASKS.md` ; choix structurant → `DECISIONS.md`.

## Rituels de session

**Au démarrage**, lire dans l'ordre : `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md`. Puis produire : État actuel / Dernière action / Prochaine action / Points de vigilance.

**Pendant** : mettre à jour `PROGRESS.md` après toute avancée significative, logger dans `CHANGELOG.md`, documenter les décisions structurantes dans `DECISIONS.md`.

**En fin de session** : mettre à jour les fichiers Core concernés, produire un résumé (fait / reste / décisions / risques / prochaine action).

## Actions nécessitant une validation humaine

- Suppression massive de fichiers ou de dossiers.
- Réorganisation de l'arborescence du projet.
- Modification de fichiers de configuration critiques.
- Toute action affectant un système partagé ou distant (push, déploiement).
- Toute action juridique ou administrative sensible.

L'agent propose et explique ; l'humain tranche.

## Git

- Ne jamais committer sans demande explicite.
- Messages courts, format `type: description` (feat, fix, refactor, chore, docs).
- Ne pas stager `.env` ni fichiers de secrets.

## Nommage

Minuscules, tirets, pas d'accents ; préfixe date `YYYY-MM-DD` pour les documents datés ; identifiants stables pour les registres (`CHG-`, `DEC-`, `P-`, `Tx.y`).
