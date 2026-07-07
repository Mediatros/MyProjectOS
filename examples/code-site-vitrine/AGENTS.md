# AGENTS.md — code-site-vitrine

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

**Au démarrage**, lire dans l'ordre : `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md`. Puis produire : État actuel / Dernière action / Prochaine action / Points de vigilance. Si `SUJETS.md` existe à la racine, le lire avant `docs/INDEX.md` pour toute demande métier (il déclare la source fraîche prioritaire de chaque sujet).

**Pendant** : mettre à jour `PROGRESS.md` après toute avancée significative, logger dans `CHANGELOG.md`, documenter les décisions structurantes dans `DECISIONS.md`.

**En fin de session** : mettre à jour les fichiers Core concernés, produire un résumé (fait / reste / décisions / risques / prochaine action).

## Cycle de travail

Une itération = **une seule** tâche de `TASKS.md` : reprise à froid → exécution → clôture des fichiers Core → contexte vidé (`/clear`). Quand la tâche est terminée et vérifiée, proposer la clôture plutôt qu'enchaîner. Une tâche doit tenir dans une session et porter un critère de succès vérifiable ; sinon, la découper avant de commencer. Une découverte en cours de route se note dans `TASKS.md` sans détourner l'itération.

## Skills selon l'agent

Une skill disponible pour un agent ne l'est pas forcément pour un autre :

- Claude Code : skills projet dans `.claude/skills/` (dont `my-project-os`).
- Hermès : skills de profil dans `~/.hermes/profiles/<profil>/skills/`.
- Codex : pas de skills ; ce fichier fait foi.

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

## Extension Code

Ce projet a l'extension Code activée : instructions supplémentaires pour toute intervention sur le code, en complément des rituels Core décrits plus haut dans ce fichier.

### Comment travailler dans ce repo

- Explorer avant de coder. Lire le code existant plutôt qu'inventer l'architecture.
- Modifications chirurgicales : ne toucher que ce qui est strictement nécessaire.
- Respecter le style existant, même si on ferait autrement.

### Fichiers à lire en plus, avant toute intervention sur le code

- `CONSTITUTION.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`.
- Avant toute modification : `IMPACT_ANALYSIS.md`.

### Règles à respecter

- Respecter `CONSTITUTION.md` : un plan ou une spec qui viole un principe est refusé, pas discuté.
- Exécution encadrée via Harness pour le parcours complet (`docs/harness.md` du repo méthode) ; lever les inconnues avant d'approuver un plan (réflexe clarify, `docs/clarify.md`).
- `STACK_VALIDATION.md` doit être validé avant la première ligne de code (voir gate dans `docs/stack-validation-gate.md` du repo méthode).
- Aucune modification sans passer par `IMPACT_ANALYSIS.md` (fichiers concernés, à ne pas toucher, risques, tests).
- Suivre les conventions de `ARCHITECTURE.md` et les recettes d'ajout de feature (kit de rails).

### Validation humaine supplémentaire

- Changement de stack ou de version.
- Modification des zones marquées « à ne pas modifier » dans `ARCHITECTURE.md`.

### Mise à jour de la documentation

- `RELEASE.md` au moment de préparer une livraison.
