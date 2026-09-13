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

**Au démarrage** (lecture allégée) : `PROJECT.md` et `PROGRESS.md` en entier ; `DECISIONS.md` par `grep "^### DEC-"` (identifiant + titre) ; `CHANGELOG.md` par les dernières entrées `CHG-` ; `TASKS.md` par `grep "\- \[ \]"` (tâches ouvertes). Jamais de lecture intégrale de ces trois derniers fichiers dans ce rituel ; le détail se lit normalement en dehors. Puis produire : État actuel / Dernière action / Prochaine action / Points de vigilance. Si `SUJETS.md` existe à la racine, le lire avant `docs/INDEX.md` pour toute demande métier (il déclare la source fraîche prioritaire de chaque sujet).

**Pendant** : répondre d'abord à la demande de l'utilisateur ; la mise à jour de `PROGRESS.md` (après toute avancée significative), `CHANGELOG.md` et `DECISIONS.md` (décisions structurantes) suit, jamais avant la réponse.

**En fin de session** : produire d'abord un résumé (fait / reste / décisions / risques / prochaine action), puis mettre à jour les fichiers Core concernés — jamais l'inverse.

## Cycle de travail

Une itération = **une seule** tâche de `TASKS.md` : reprise à froid → exécution → clôture des fichiers Core → contexte vidé (`/clear`). Quand la tâche est terminée et vérifiée, proposer la clôture plutôt qu'enchaîner. Une tâche doit tenir dans une session et porter un critère de succès vérifiable ; sinon, la découper avant de commencer. Une découverte en cours de route se note dans `TASKS.md` sans détourner l'itération.

## Skills du projet

Toutes les skills du projet, la skill assistant `my-project-os` comprise, vivent dans `98_configuration/skills/<skill>/` : seule source, elle voyage avec le projet. Chaque skill est au format ouvert Agent Skills (`SKILL.md` à frontmatter `name`/`description`), lisible sans outil.

Un agent y accède par l'un de ces trois mécanismes, et seulement ceux-là :

- **découverte native** : lien symbolique relatif depuis son dossier de skills vers la source (Claude Code `.claude/skills/`, Codex `.agents/skills/`, OpenCode qui lit ces deux dossiers) ;
- **déclaration** : une ligne de configuration désignant le catalogue (Hermès `skills.external_dirs`) ;
- **lecture directe** : un agent sans mécanisme lit `98_configuration/skills/<skill>/SKILL.md` directement, ce fichier faisant foi.

Détail complet : `docs/skills-portables.md`.

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
- **Règle immuable, identité de contribution** : tout commit, tag, release ou commentaire porte l'identité du titulaire du dépôt, jamais celle d'un agent. Aucun trailer `Co-Authored-By`, aucune mention d'agent ou de session dans un message. Un agent qui ne peut pas commiter sous cette identité ne commite pas : il dépose, l'humain commite. Le hook `hook-pre-git.sh` bloque les messages qui l'enfreignent.

## Nommage

Minuscules, tirets, pas d'accents ; préfixe date `YYYY-MM-DD` pour les documents datés ; identifiants stables pour les registres (`CHG-`, `DEC-`, `P-`, `Tx.y`).
