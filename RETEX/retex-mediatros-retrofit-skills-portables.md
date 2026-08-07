# RETEX — Rattrapage d'un parc de skills existant : le cas d'un projet migré LOCAL → SYNC

> Retour d'expérience issu du projet `/Users/jb/Documents/MyProjects/SYNC/Mediatros` (type Code + Knowledge).
> Date : 2026-08-07.
> Statut : ouvert. Consigné le 2026-08-07 (CHG-20260807-1915), les cinq évolutions proposées restent à arbitrer (T-RETEX-1). Aucune modification du squelette avant décision.

## Objet du RETEX

Le pattern « skill technique portable » est déjà au canon (DEC-0027 à DEC-0030, généralisé par DEC-0034 après le dogfood Lino) : source canonique `98_configuration/skills/<skill>/`, squelette `templates/skills/_squelette/`, résolveur `scripts/secrets.sh` multi-backend, installation par lien symbolique relatif pour Claude Code et Codex.

Ce RETEX ne conteste rien de tout cela et n'apporte aucune implémentation concurrente. Il documente un **cas d'usage que le canon ne couvre pas** : non pas créer une skill portable, mais rattraper un parc de skills déjà écrites pour une seule machine, quand le projet devient multi-agents après coup.

## Le contexte

Mediatros pilote l'activité d'une micro-entreprise (parc WordPress MainWP, facturation Stripe, obligations URSSAF). Le projet a vécu quinze mois dans `LOCAL/`, sur un seul Mac, avec un seul agent (Claude Code). Ses huit skills ont donc été écrites sans jamais se poser la question de l'environnement : lecture des secrets par `security find-generic-password`, chemins `/Users/jb/...`, scripts `scripts/*-env.sh` propres à macOS. C'était le bon choix à l'époque, il n'y avait rien d'autre à servir.

Le projet est passé en `SYNC/` (synchronisation Syncthing vers un VPS) pour devenir pilotable depuis un téléphone via l'agent Hermès. Le dossier est apparu sur le VPS, **et les huit skills sont devenues muettes d'un coup** : elles décrivent des gestes qui n'existent pas sur Linux.

Différence avec Lino, d'où venait le RETEX précédent : Lino a été construit portable dès l'origine, pour Claude Code et Codex, avec un script de vérification dédié. Mediatros est le cas inverse, celui du rattrapage. Il sera plus fréquent que le cas Lino : tout projet ancien qui devient multi-agents passe par là.

## Constat 1 — Le canon n'outille pas l'audit d'un parc existant

La skill assistant propose la pose en `98_configuration/skills/` **à la création** d'une nouvelle skill (garde-fou permanent, DEC-0034). Les modes 5 (cadrage) et 6 (adoption) couvrent l'arrivée d'un projet dans la méthode. Aucun mode ne couvre le moment où un projet déjà sous méthode change d'environnement d'exécution et doit réexaminer son parc de skills.

Ce qui manquait concrètement : une question à poser skill par skill, et un artefact où consigner la réponse. Mediatros a produit `98_configuration/AUDIT_SKILLS.md` avec, pour chaque skill : ce qu'elle fait, la dépendance qui la cloue à une machine, le secret concerné, le verdict de portabilité, le blocage résiduel. Le format s'est révélé utile au-delà de l'audit lui-même : il sert de plan de travail, et il documente les non-portabilités pour qu'elles ne soient pas réinstruites.

Résultat sur huit skills : quatre portables, une partielle, une conditionnelle, une non portable par décision, une hors périmètre.

## Constat 2 — Une non-portabilité peut être une décision, et le canon ne sait pas l'exprimer

`mainwp-ssh` donne accès en SSH aux hébergements des clients. Techniquement, rien n'empêche de migrer la clé privée vers un backend de secrets et de la rendre lisible depuis le VPS. Le projet l'interdit : un agent joignable depuis un téléphone ne doit pas pouvoir atteindre les serveurs des clients (plan d'accès aux hébergements du projet).

Le canon ne fournit aucun moyen de dire cela. Une skill est portable, ou elle ne l'est pas encore. Sans marque explicite, « non portable » se lit comme une tâche en attente, et un agent diligent finit par « réparer » ce qui était une frontière de sécurité volontaire.

Ce que Mediatros a posé : la restriction en tête du `SKILL.md` **et** du `INSTALL.md`, formulée comme décision et non comme manque (« non portable, et par décision, pas par manque de moyens »), avec la raison, le renvoi au document qui la porte, la consigne explicite de ne pas migrer les clés, et une conduite à tenir pour l'agent qui rencontre le besoin depuis la mauvaise machine : préparer l'intervention, la remettre à l'humain, ne pas contourner.

Le `INSTALL.md` d'une telle skill porte une section « ne pas installer » plutôt qu'une commande d'installation pour l'agent concerné, et demande de la retirer si elle s'y trouve.

## Constat 3 — La portabilité n'est pas binaire

`pro-reports-templates` édite des templates PHP (fichiers du dépôt, donc synchronisés et accessibles partout) et les déploie par `scp` (donc soumis à l'interdiction du constat 2). La même skill est portable pour la moitié de ses opérations.

De même `urssaf-mediatros` : le calcul du chiffre d'affaires depuis l'API Stripe est portable, la déclaration et le paiement restent des gestes humains sur toute machine. Ce n'est pas une limite de portage, mais il faut le dire pour ne pas le confondre avec une.

Le vocabulaire retenu, à quatre valeurs, s'est avéré suffisant sur les huit cas :

| Valeur | Sens |
|---|---|
| `oui` | fonctionne partout une fois le secret disponible |
| `partiel` | une partie des opérations seulement, la frontière est documentée |
| `conditionnel` | portable une fois des prérequis identifiés posés, chemin écrit |
| `non` | non portable par décision, ne pas chercher à corriger |

Le `INSTALL.md` de chaque skill gagne alors un tableau « limites par environnement », opération par opération, plus lisible qu'une phrase de synthèse.

## Constat 4 — L'état de portabilité doit se lire sans ouvrir les fichiers

Sur un parc de huit skills, savoir laquelle marche où demandait d'ouvrir huit fichiers. Deux ajouts ont suffi :

1. un champ `portable:` dans le bloc `metadata:` du frontmatter de chaque `SKILL.md` (le squelette actuel n'a pas de bloc `metadata:`, plusieurs skills du parc en portaient déjà un avec `author`, `version`, `project`) ;
2. un tableau d'inventaire dans le `README.md` de `98_configuration/skills/` : skill, portable, secret, blocage résiduel.

Le tableau a servi de tableau de bord pour la suite du chantier, et de réponse immédiate à « qu'est-ce qu'Hermès peut faire aujourd'hui ? ».

## Ce que Mediatros a fait DE TRAVERS, et qui ne doit pas être repris

Point d'honnêteté, pour que ce RETEX ne serve pas à propager une erreur.

Mediatros a construit sa couche de portabilité **sans consulter le canon existant**, et s'en écarte sur trois points, chaque fois en moins bien :

1. **Installation par copie physique** (`cp -r`) pour Claude Code, alors que DEC-0034 prescrit un lien symbolique relatif. La copie réintroduit exactement la dérive source/copie que `98_configuration/` existe pour supprimer (RETEX LaCIOTAT, DEC-0026). Erreur nette.
2. **Résolveur de secrets réinventé** : script exécuté prenant un nom de secret et sortant la valeur sur stdout, trois backends (env, trousseau macOS, bws). Le squelette du canon fait mieux : sourcé, contrat `SECRETS_PREFIX` / `SECRETS_KEYS`, cinq backends dont `sops` (recommandé sur VPS depuis DEC-0031) et `file`. Doublon inutile.
3. **Identifiant de projet Bitwarden en dur** dans le script, là où le canon passe par un UUID par clé, configurable.

La correction incombe à Mediatros, pas au canon. Elle est inscrite dans son `TASKS.md`.

Cause racine, elle aussi instructive : la skill assistant propose la pose en `98_configuration/skills/` à la création d'une skill, mais **rien ne renvoie vers `templates/skills/_squelette/` quand un projet construit sa couche de portabilité**. Un projet qui part de zéro sur ce sujet ne découvre pas qu'un squelette existe. C'est peut-être le constat le plus actionnable de ce RETEX.

## Évolutions proposées

Rien de tout cela n'est décidé ; à arbitrer par le dépôt méthode.

1. **Mode ou déclencheur de rattrapage** dans la skill assistant : quand un projet change d'environnement d'exécution (migration `LOCAL/` → `SYNC/`, arrivée d'un second agent), proposer l'audit du parc de skills existant. Artefact suggéré : `98_configuration/AUDIT_SKILLS.md`.
2. **Champ `portable:`** au frontmatter du squelette, avec les quatre valeurs ci-dessus, et tableau « limites par environnement » dans le squelette d'`INSTALL.md`.
3. **Cas « non portable par décision »** documenté dans le squelette : où l'écrire, comment le formuler, section « ne pas installer » dans l'`INSTALL.md`, conduite à tenir pour l'agent qui rencontre le besoin depuis la mauvaise machine.
4. **Tableau d'inventaire** dans le `README.md` de `98_configuration/skills/`, à ajouter au squelette ou à `structures/core-tree.md`.
5. **Renvoi explicite vers `templates/skills/_squelette/`** dans la skill assistant, au moment où un projet outille ses secrets ou sa portabilité, et pas seulement au moment où il crée une skill. Réponse directe à la cause racine ci-dessus.
