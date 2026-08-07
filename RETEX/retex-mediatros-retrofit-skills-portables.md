# RETEX — Rattrapage d'un parc de skills existant : le cas d'un projet migré LOCAL → SYNC

> Retour d'expérience issu du projet `/Users/jb/Documents/MyProjects/SYNC/Mediatros` (type Code + Knowledge).
> Date : 2026-08-07.
> Statut : integre. Arbitré le 2026-08-07 par DEC-0038 (CHG-20260807-2230, v0.20.0), après reconfiguration de l'évolution 2 par DEC-0037. Les évolutions 1 à 5 sont appliquées, avec deux écarts assumés (un seul artefact de parc au lieu de deux, déclencheur du Mode 2 au lieu d'un huitième mode). **L'évolution 6 est écartée sur preuve** : le contrôle serait muet là où il devrait tourner (`Permission denied`) et la dérive qu'il visait n'existe pas (voir « Ce que la mesure a écarté » en fin de document). T-RETEX-1 close.

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

## Constat 5 — Rien ne détecte la dérive de la copie Hermès

> **Ajout postérieur à la rédaction initiale de ce RETEX** (même journée, 2026-08-07). Issu d'une question de l'utilisateur après relecture, pas du chantier Mediatros lui-même. Signalé comme tel pour qui reprend ce fichier : les constats 1 à 4 forment le RETEX d'origine, celui-ci s'y ajoute.

DEC-0034 installe Claude Code et Codex par lien symbolique relatif, et laisse Hermès en copie physique globale. La raison est explicite et n'est pas remise en cause ici : un lien depuis `~/.hermes/skills/` vers un dossier projet synchronisé serait modifiable par toute session touchant ce dossier, et vulnérable aux conflits Syncthing.

S'y ajoute une raison structurelle que le canon ne formule pas, et qui explique mieux l'asymétrie : le lien de Claude Code est **interne au projet** (`.claude/skills/<skill>` → `../../98_configuration/skills/<skill>`), donc relatif, donc il voyage avec le projet — renommage, déplacement, archive. Le dossier de skills d'Hermès est **hors du projet** et global à tous les projets : un lien depuis là exigerait un chemin absolu, qui casse au premier déplacement du projet ou à la première interruption de synchronisation. Une skill absente parce que Syncthing est en pause est un incident plus grave qu'une skill légèrement périmée. La copie physique est donc le bon arbitrage.

Le vrai manque n'est pas la copie, c'est qu'**aucun contrôle ne signale quand elle a divergé de sa source**. Vérifié le 2026-08-07 sur `scripts/check-project.sh` : le script détecte bien un lien symbolique cassé sous `.claude/skills/` ou `.agents/skills/` (ajouté par DEC-0034), et contrôle la taille des fichiers de contexte au titre de la troncature Hermès, mais ne compare jamais une copie installée à sa source canonique. Une copie Hermès qui prend trois mois de retard reste invisible.

Le contrôle est pourtant trivial dès lors que le dossier projet est présent sur la machine qui héberge Hermès, ce qui est le cas nominal d'un projet synchronisé : comparer `~/.hermes/skills/<skill>` à `98_configuration/skills/<skill>` et avertir en cas d'écart. Un `diff -r` et une ligne de sortie, non bloquant, dans l'esprit de la fermeté hybride de `docs/enforcement.md`.

Variante à considérer si le projet dédie un profil Hermès (`~/.hermes/profiles/<profil>/skills/`, motif « un projet = un profil isolé ») : le lien symbolique redevient défendable, puisqu'il ne serait plus global mais scopé au projet. Il resterait un chemin absolu, donc le contrôle de dérive garde son intérêt dans les deux cas.

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
6. **Contrôle de dérive de la copie Hermès** dans `scripts/check-project.sh` (constat 5, ajout postérieur) : comparer chaque `~/.hermes/skills/<skill>` à `98_configuration/skills/<skill>` et avertir en cas d'écart, sans bloquer. Complète le contrôle de lien symbolique cassé déjà posé par DEC-0034 pour Claude Code et Codex, et couvre le seul agent que ce contrôle laisse aujourd'hui sans filet. À ne lancer que si le dossier de skills d'Hermès est présent sur la machine, sinon rester silencieux.

## Ce que la vérification Hermès change à ce RETEX

> **Ajout postérieur du 2026-08-07 au soir**, après vérification du code d'Hermès sur le VPS (DEC-0037, CHG-20260807-2047, preuves dans `PLAN/plans/2026-08-07-verification-limites-hermes-skills.md`). Les constats 1 à 5 et les six évolutions ci-dessus restent tels qu'écrits ; cette section corrige un seul point de conception.

Hermès dispose déjà d'un mécanisme qui traite la cause de ce RETEX, et que personne n'utilisait : un champ de frontmatter filtre activement les skills selon le système d'exploitation.

```yaml
platforms: [macos]           # écarte la skill sur Linux et Windows
platforms: [macos, linux]
```

Validé par exécution le 2026-08-07, 6 cas sur 6. Un second champ existe, `environments:`, mais il est écarté du canon : ses trois valeurs reconnues sont internes à l'infrastructure Hermès et sa détection s'est révélée en faux positif au test.

`skill_matches_platform()` (`agent/skill_utils.py:251`) écarte une skill dont la plateforme ne correspond pas **avant même de la proposer à l'agent** (`agent/skill_commands.py:403-409`). Champ absent ou vide égale compatible partout, donc rien ne casse sur l'existant.

C'est précisément l'incident d'origine : les huit skills de Mediatros, écrites pour macOS, ont été proposées sur le VPS Linux puis ont échoué. Avec `platforms: [macos]`, elles n'auraient jamais été offertes.

**Conséquence sur l'évolution 2.** Le champ `portable:` à quatre valeurs n'est pas abandonné, mais il change de rôle. Au sens de l'échelle de fermeté de DEC-0036, `portable:` est de la documentation, tandis que `platforms:` est un mécanisme. Le partage retenu :

| Besoin | Porté par |
|---|---|
| Incompatibilité technique d'OS | `platforms:` (actif, écarte la skill) |
| `partiel` : une partie des opérations seulement | `portable:` (la machine ne peut pas le déduire) |
| `conditionnel` : portable une fois des prérequis posés | `portable:` |
| `non` **par décision** (cas `mainwp-ssh`) | `portable:`, avec la raison et le renvoi au document qui la porte |

Règle qui en découle : toute valeur `non` ou `partiel` dont la cause est technique doit s'accompagner d'un `platforms:` restrictif, sinon le RETEX documente un problème au lieu de l'empêcher.

Point laissé à l'arbitrage : pour `mainwp-ssh`, `platforms: [macos]` produirait le bon comportement (Hermès ne voit pas la skill) mais pour une raison techniquement fausse, puisque la skill tournerait très bien sous Linux et que l'interdiction est une frontière de sécurité volontaire. Effet correct, justification approximative : à trancher.

Limite constatée au passage : le lanceur `hermes skills list` n'extrait du frontmatter que `description`, `version` et `author`. Un champ `portable:` n'apparaîtra donc pas dans cette sortie, ce qui renforce l'intérêt du tableau d'inventaire de l'évolution 4.

## Ce que la mesure a écarté

> **Ajout du 2026-08-07 au moment de l'arbitrage** (DEC-0038, CHG-20260807-2230). Les constats 1 à 5 restent tels qu'écrits ; cette section documente pourquoi l'évolution 6 n'a pas été retenue, pour qu'elle ne soit pas réinstruite.

Le constat 5 supposait que la copie Hermès d'une skill dérive de sa source projet sans que rien ne le signale. Quatre mesures en lecture seule sur le VPS l'ont réfuté.

| Mesure | Résultat |
|---|---|
| Lisibilité de `/root/.hermes/skills/` depuis le compte qui exécute `check-project.sh` (`jihad`) | `Permission denied`. Les projets sont sous `/home/jihad/projects/`, les skills d'Hermès sous `/root/.hermes/` |
| `diff -rq` entre `~/.hermes/skills/blue-app` et sa source `MySecretaire`, seul cas comparable du parc | Aucun écart, versions 1.2.0 des deux côtés, malgré 24 jours d'écart de date de modification |
| Skills de projet absentes chez Hermès | 8 sur 9, dont les 7 de Mediatros. C'est la conclusion de l'audit de portabilité, pas un défaut |
| Divergence entre le profil `mysecretaire` et le dossier global d'Hermès | 15 skills sur 31, sur 15 profils portant chacun 31 à 36 skills |

Un contrôle infaisable là où il compte, visant une dérive qui ne se produit pas, et dont la variante « couverture » ne produirait que des faux positifs sur des absences volontaires : les trois raisons se cumulent.

La quatrième ligne est le seul vrai signal, et il tombe hors du dépôt méthode. Elle relève de la gouvernance Hermès, où elle rejoint les deux autres pistes du RETEX AllDebrid. C'est un constat brut et non un diagnostic : la sémantique des profils Hermès n'est pas connue ici, et cette divergence peut être une personnalisation voulue.

Enseignement transposable au-delà du cas : **mesurer le mécanisme avant de l'outiller**. C'est le deuxième RETEX consécutif où une contrainte tenue pour acquise ne survit pas à la vérification, après les 20 000 caractères de DEC-0037, à une version d'intervalle.
