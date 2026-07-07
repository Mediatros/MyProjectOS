# AGENTS.md — MyProjectOS (repo méthode)

> Instructions d'opération pour les agents (Codex, Hermès, Claude Code) sur **ce repository**.
> Ce repo n'est pas un projet ordinaire : c'est la méthode elle-même, dogfoodée sur elle-même.
> L'architecture complète du système est décrite dans `CLAUDE.md` (lu nativement par Claude Code).

## Rituels de session

**Au démarrage**, lire dans l'ordre : `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md`. Puis produire : État actuel / Dernière action / Prochaine action / Points de vigilance.

**Pendant** : mettre à jour `PROGRESS.md` après toute avancée significative, logger dans `CHANGELOG.md` (`CHG-YYYYMMDD-HHMM`), documenter les décisions structurantes dans `DECISIONS.md` (`DEC-XXXX`).

**En fin de session** : mettre à jour les fichiers Core concernés, produire un résumé (fait / reste / décisions / risques / prochaine action). Cycle de travail : une tâche de `TASKS.md` par itération (`docs/cycle-de-travail.md`).

## Spécificités de ce repo

- `templates/` contient des **gabarits inertes** : leurs placeholders (nom de projet en balise, dates `YYYY-MM-DD`) doivent y rester. Ne jamais les « corriger ».
- `examples/` contient des projets d'exemple : contenu illustratif, non gouverné par les registres racine.
- `PLAN/` contient les plans de travail non appliqués : un plan ne devient officiel qu'une fois transposé dans `TASKS.md` et exécuté (voir `PLAN/README.md`).
- Toute évolution visible de la méthode suit `docs/versioning.md` : bump de `VERSION`, entrée `CHG-`, ligne Releases, tag, release GitHub.
- Vérification : `sh scripts/check-project.sh .` doit rester à 0 bloquant et 0 avertissement.

## Garde-fous

- Ne jamais committer sans demande explicite. Messages en français, format `type: description`.
- Validation humaine avant : suppression massive, réorganisation, push important, changement de visibilité du dépôt.
- Ne pas stager de secrets.
