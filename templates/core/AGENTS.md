# AGENTS.md — <NomDuProjet>

> Instructions d'opération pour les agents (Claude Code, Codex, Hermès, futurs agents) sur ce projet.
> Fichier lu nativement par Codex et Hermès. Claude Code le charge par l'import `@AGENTS.md`, seule ligne de `CLAUDE.md`.
> Les extensions actives (Code, Life...) ajoutent leurs propres sections plus bas dans ce fichier.

## Paire d'instructions (`AGENTS.md` + `CLAUDE.md`)

Partout où vivent des instructions d'agent (racine, dossier de zone), elles vont par paire : `AGENTS.md` porte **tout** le contenu, `CLAUDE.md` ne contient **que** la ligne `@AGENTS.md`. Une consigne propre à Claude Code va dans `AGENTS.md`, sous un titre « Claude Code ».

- Ne jamais écrire dans `CLAUDE.md` au-delà de cette ligne ; toute consigne va dans `AGENTS.md`.
- Ne pas lancer `/init` ni `/import` de Claude Code dans ce projet : ces commandes recopient des instructions dans `CLAUDE.md`.
- Dérive contrôlée par `sh scripts/check-project.sh` (section « Socle agent ») : paire incomplète, `CLAUDE.md` qui porte du contenu, sens inversé, `AGENTS.md` sans les rituels de la méthode.
- À chaque reprise, `sh scripts/check-project.sh --socle` : sur un écart (code 2), proposer l'alignement (procédure : skill `my-project-os`), en expliquant qu'il rend le projet agent-agnostique. Sur refus explicite, `sh scripts/check-project.sh --socle-refus` le consigne jusqu'à la prochaine mise à jour de la méthode (code 3 : ne pas reproposer).

## Fichiers sacrés

| Fichier | Rôle |
|---|---|
| `PROJECT.md` | Pourquoi le projet existe, périmètre, objectifs, critères de réussite |
| `PROGRESS.md` | État actuel, dernières actions, en cours, prochaine action |
| `CHANGELOG.md` | Historique daté de ce qui a changé |
| `TASKS.md` | Checklist d'actions concrètes cochables |
| `DECISIONS.md` | Pourquoi des choix structurants |

Une information ne vit qu'à un seul endroit : état présent → `PROGRESS.md` ; changement daté → `CHANGELOG.md` ; tâche → `TASKS.md` ; choix structurant → `DECISIONS.md`.

**Projet organisé par sujets** (`02_sujets/Sxx_NomDuSujet/`) : chaque sujet porte son propre `PROGRESS.md` (même contrat, périmètre du sujet, statuts `actif` / `en pause` / `clos`), et `02_sujets/INDEX.md` dit de quoi traite chaque sujet. Le `PROGRESS.md` racine n'en porte qu'une projection générée (bloc entre `<!-- sujets:debut -->` et `<!-- sujets:fin -->`, une ligne par sujet, écrite par `scripts/sync-progress.sh`) : ce bloc ne s'édite jamais à la main, on corrige l'en-tête du sujet. Créer un sujet : `sh scripts/sujet.sh new "Titre"` ; archiver un sujet clos : `sh scripts/sujet.sh archive Sxx`.

## Règles locales par dossier (facultatif)

Un dossier de travail peut porter ses propres instructions d'opération, dans une paire `AGENTS.md` + `CLAUDE.md` (`@AGENTS.md`) posée **dans ce dossier**. L'agent la reçoit automatiquement dès qu'un de ses outils touche la zone — ce n'est pas une lecture à faire soi-même.

**Quand** : dès qu'une zone a des règles qui ne concernent qu'elle. Sinon rien : un dossier sans besoin propre ne porte pas de fichier.

- **La paire, comme à la racine** : le contenu dans `AGENTS.md`, et un `CLAUDE.md` réduit à `@AGENTS.md`. Sans ce `CLAUDE.md`, Claude Code ignore l'`AGENTS.md` de zone, puisqu'un `CLAUDE.md` existe à la racine.
- **Une seule descente** : racine + dossier de zone. Pas de fichier dans `02_sujets/`, pas de fichier à l'intérieur d'une zone.
- **Cible 8 000 caractères** : au-delà, la règle est mal découpée (l'agent tronque sans le dire au-delà de son plafond).
- **Une consigne, une seule feuille** : ce qui est propre à la zone, ou un renvoi vers la racine. Jamais de recopie d'une règle racine — une consigne présente à deux endroits finit par se contredire.
- **Jamais d'état, ni de décision, ni d'historique** : l'état de la zone vit dans son `PROGRESS.md`, les choix structurants dans `DECISIONS.md`.
- **À la demande** : ni `init-project.sh` ni `--update-method` n'en créent. L'agent propose quand le besoin est démontré, l'humain valide. Gabarit (dépôt méthode) : `templates/configuration/AGENTS_DOSSIER.md`.

**Frontière** : une règle de gouvernance du projet (qui décide quoi, validations supplémentaires) va dans `97_gouvernance/`. Ici, on dit seulement comment travailler dans ce dossier. Ce qui doit s'appliquer partout (ton, format de sortie, validations humaines) reste à la racine : un fichier de zone ne peut pas gouverner une réponse produite sans jamais ouvrir la zone.
## Rituels de session

**Au démarrage** (lecture allégée) : `PROJECT.md` et `PROGRESS.md` en entier ; `DECISIONS.md` par `grep "^### DEC-"` (identifiant + titre) ; `CHANGELOG.md` par les dernières entrées `CHG-` ; `TASKS.md` par `grep "\- \[ \]"` (tâches ouvertes). Jamais de lecture intégrale de ces trois derniers fichiers dans ce rituel ; le détail se lit normalement en dehors. Puis produire : État actuel / Dernière action / Prochaine action / Points de vigilance. Si `SUJETS.md` existe à la racine, le lire avant `docs/INDEX.md` pour toute demande métier (il déclare la source fraîche prioritaire de chaque sujet). Si des sujets existent (`02_sujets/Sxx_*/`), lancer `sh scripts/sync-progress.sh --check` avant de lire le `PROGRESS.md` racine et le synchroniser s'il est en retard ; ne pas lire les progrès locaux à cette étape. Pour travailler sur un sujet : sa ligne dans `02_sujets/INDEX.md` (de quoi il traite), puis son `PROGRESS.md` (où il en est), le reste du sujet seulement si nécessaire.

**Pendant** : répondre d'abord à la demande de l'utilisateur ; la mise à jour de `PROGRESS.md` (après toute avancée significative), `CHANGELOG.md` et `DECISIONS.md` (décisions structurantes) suit, jamais avant la réponse. Sur un sujet : son `PROGRESS.md`, en-tête compris (`etat`, `prochaine_action`, `statut`, `derniere_maj`) ; le parent se projette seul.

**En fin de session** : produire d'abord un résumé (fait / reste / décisions / risques / prochaine action), puis mettre à jour les fichiers Core concernés — jamais l'inverse. Si des sujets existent : `sh scripts/sync-progress.sh` après le progrès du sujet.

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
