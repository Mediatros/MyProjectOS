# MyProjectOS

**Une méthode d'organisation de projets assistée par IA, pour reprendre n'importe quel projet à froid, sans aucun historique de conversation.**

> Ce dépôt est la **vitrine publique** de MyProjectOS : templates, règles, scripts, skill assistant et exemples, régénérés à chaque release. La méthode est développée dans un atelier privé (retours d'expérience, plans, projets réels). Version courante : **0.26.0**. Installable tel quel, réutilisable en tout ou partie.

Ce n'est pas un logiciel. C'est un système documentaire versionné : des fichiers Markdown, des rituels de session, des garde-fous exécutés par des hooks, et une skill qui guide l'agent. Il tient dans un dossier, se lit sur GitHub sans outil, et se met à jour comme un logiciel.

## Le problème

Un porteur de projet, non-développeur, pilote plusieurs projets avec des agents IA (Claude Code, Codex, Hermès). Chaque session repart de zéro : l'agent n'a pas de mémoire, les décisions se perdent dans les conversations, les fichiers s'éparpillent, chaque outil impose sa convention. Au bout de trois semaines, plus personne ne sait où en est le dossier, ni pourquoi tel choix a été fait.

## La réponse

Dire **« Reprends le projet »** et obtenir en quelques secondes un état fiable : où on en est, ce qui a été fait, pourquoi, et quelle est la prochaine action. Pour ça, tout projet répond à trois questions, chacune dans un fichier dédié :

- **Où en est-on ?** → `PROGRESS.md`
- **Qu'est-ce qui a été fait ?** → `CHANGELOG.md`
- **Pourquoi ?** → `DECISIONS.md`

```
  Agent IA  ──── « Reprends le projet » ────►  PROJECT.md   pourquoi le projet existe
     │                                         PROGRESS.md  où on en est (photo, jamais un journal)
     │  rituels de session                     TASKS.md     ce qui reste à faire, une tâche par itération
     │  (démarrage, pendant, clôture)          CHANGELOG.md ce qui a changé, daté, figé
     │                                         DECISIONS.md pourquoi, avec options et raison
     ▼
  Hooks déterministes ── bloquent ce qui ne doit jamais arriver (nommage, placement, git destructif)
  check-project.sh   ── contrôle à la demande, informe sans bloquer
  check-update.sh    ── détecte une nouvelle version de la méthode, n'applique rien seul
```

Les projets **Life** ajoutent : *quelle est la preuve ?* (`PREUVES.md`). Les projets **Code** ajoutent : *la stack est-elle validée, quels fichiers sont impactés ?* (`STACK_VALIDATION.md`, `IMPACT_ANALYSIS.md`). L'extension **Knowledge** organise une documentation dense en niveaux, avec un sommaire chargé avant tout le reste.

## Ce que ce projet démontre

- **Gouverner plusieurs agents avec un seul jeu de fichiers** : Claude Code, Codex, Hermès et OpenCode lisent les mêmes rituels (`AGENTS.md`), chacun avec son mécanisme d'installation de skills.
- **Des règles tenues par du code, pas par des consignes** : ce qui est non négociable est un hook ou un check, avec preuve d'exécution avant d'être promu (`docs/enforcement.md`).
- **Des décisions tracées** : 48 décisions au format contexte / options / choix / raison / conséquences, jamais réécrites, seulement supersédées (`DECISIONS.md`).
- **Une méthode versionnée et propagée** : SemVer, `check-update.sh` dans chaque projet, mise à jour qui ne touche jamais au contenu de l'utilisateur (`docs/versioning.md`).
- **Une boucle d'amélioration gouvernée** : une leçon monte d'un cran à la fois (correction locale → RETEX → procédure → skill → hook), par décision humaine.
- **Le contexte comme ressource rare** : « le sommaire, pas tout le livre », lecture progressive, `PROGRESS.md` optimisé pour la reprise à froid.

## Essayer en deux minutes

Une seule commande, à partir du lien du dépôt. Le dépôt est cloné dans un dossier temporaire, le projet est posé, le clone est supprimé. **Le projet final est autonome** : les hooks sont copiés dans son `.claude/hooks/` et ne dépendent plus de MyProjectOS.

```sh
curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
  | sh -s -- ~/MonProjet --life
```

Flags d'extension : `--life`, `--code`, `--knowledge` (combinables ; aucun = Core seul). Pour greffer sur un projet déjà peuplé sans rien écraser : `--into-existing`. Sans `curl` :

```sh
git clone --depth 1 https://github.com/Mediatros/MyProjectOS.git /tmp/mpos
sh /tmp/mpos/scripts/init-project.sh ~/MonProjet --life
rm -rf /tmp/mpos
```

Puis ouvrir le dossier avec Claude Code et dire « Reprends le projet ». Pour voir la méthode en marche sans rien installer : `examples/` contient des projets fictifs complets, fichiers sacrés remplis.

**Vous êtes un agent ?** Le protocole complet est écrit pour vous : [docs/INSTALL-AGENT.md](docs/INSTALL-AGENT.md).

## Parcours de lecture

- **10 minutes** : ce README, puis `examples/life-copropriete/PROGRESS.md` et `DECISIONS.md` pour voir à quoi ressemble un projet tenu.
- **1 heure** : [Vision](docs/vision.md), [Principes](docs/principles.md), [Gouvernance](docs/governance.md), [Cycle de travail](docs/cycle-de-travail.md), puis `templates/core/AGENTS.md` (ce que lit réellement l'agent) et `skills/my-project-os/SKILL.md` (les 7 modes de l'assistant).
- **Je veux l'adopter** : [Installation par un agent](docs/INSTALL-AGENT.md), [Enforcement](docs/enforcement.md), [Versionnement](docs/versioning.md), puis `DECISIONS.md` pour comprendre les choix avant de les remettre en cause.

## Architecture

```
Core MyProjectOS             commun à tous les projets
├── Extension Life          projets personnels, administratifs, juridiques
├── Extension Code          projets logiciels
└── Extension Knowledge     documentation dense, navigation par niveaux, dépendances transverses
```

Un projet est de type **Life**, **Code**, **Hybrid** (Life + Code) ou **Core** (aucune extension). Le type est déclaré dans `PROJECT.md`. Les extensions s'activent par flags d'installation.

### Les fichiers sacrés du Core

Obligatoires dans tout projet, avec une frontière stricte : **une information vit à un seul endroit**, les autres fichiers la référencent par identifiant (`DEC-XXXX`, `CHG-YYYYMMDD-HHMM`, `Tx.y`).

| Fichier | Rôle | Ce qui n'y vit pas |
|---|---|---|
| `PROJECT.md` | Pourquoi le projet existe, périmètre, objectifs, critères de réussite | Tout état daté, historique, tâches |
| `PROGRESS.md` | État actuel : photo de l'instant, **jamais un journal** | Historique de versions, récits de session |
| `CHANGELOG.md` | Historique daté, registre figé (`CHG-YYYYMMDD-HHMM`) | Analyse longue, état courant |
| `TASKS.md` | File d'actions cochables, une tâche = une itération | Narratif, résultats détaillés |
| `DECISIONS.md` | Pourquoi des choix structurants (`DEC-XXXX`), registre figé | Micro-choix d'exécution |

Le socle pose aussi `AGENTS.md` et `CLAUDE.md` (rituels de session, garde-fous) : ce ne sont pas des registres.

### Les extensions

- **Life** : `PREUVES.md` (`P-XXXX`), `ECHEANCES.md`, `CORRESPONDANCES.md` (`C-XXXX`), dossiers `05_correspondances/` à `08_modeles/`, organisation par sujets `02_sujets/Sxx_NomDuSujet/`.
- **Code** : `CONSTITUTION.md`, `STACK_VALIDATION.md` (gate avant la première ligne de code), `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md`, dossiers `05_specs/` à `src/`.
- **Knowledge** (transverse) : `SUJETS.md` (routeur métier, lu avant l'index), `docs/INDEX.md`, `docs/kb_governance.md`, niveaux `01_global/` → `02_domains/` → `03_details/`, `runbooks/`, `plan/`.

### Structure d'un projet

```
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md   # fichiers sacrés
├── AGENTS.md / CLAUDE.md                                             # rituels et garde-fous
├── 00_inbox/          # entrées non classées
├── 01_context/        # contexte stable
├── 02_work/           # travail actif (ou 02_sujets/ pour les projets Life)
├── 03_documents/      # PDF, emails, pièces jointes
├── 04_deliverables/   # livrables finaux
├── 97_gouvernance/    # optionnel : droit local du projet (GOUVERNANCE_LOCALE.md)
├── 98_configuration/  # optionnel : intégrations d'outils, handoff inter-agents, skills portables
└── 99_archive/        # zone froide : clôturé, obsolète, exclu des scans
```

## Comment on travaille avec

1. Installer MyProjectOS sur le dossier du projet.
2. Choisir le type dans `PROJECT.md` et les extensions nécessaires.
3. À chaque session, suivre les rituels de [docs/governance.md](docs/governance.md) :
   - **Au démarrage** : lire `PROJECT.md` → `PROGRESS.md` → `TASKS.md` → `CHANGELOG.md` → `DECISIONS.md`, produire *État actuel / Dernière action / Prochaine action / Points de vigilance*, lancer `check-update.sh` une fois.
   - **Pendant** : mettre à jour `PROGRESS.md` après toute avancée, logger dans `CHANGELOG.md`, consigner les décisions structurantes dans `DECISIONS.md`.
   - **En clôture** : produire le résumé (*fait / reste / décisions / risques / prochaine action*) **en premier**, déléguer la tenue des fichiers Core à un sous-agent, puis vider le contexte.
4. Cycle de travail : **une tâche par itération**. Reprendre → exécuter une tâche → clôturer → vider le contexte → recommencer. La conversation est jetable, les fichiers font foi.

## Mise à jour d'un projet

Chaque projet embarque `scripts/check-update.sh` : il compare la version du projet à la dernière version publiée ici, liste les apports et les artefacts qui seraient remplacés, et **n'applique jamais rien seul**.

```sh
sh scripts/check-update.sh          # détecter et auditer
curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
  | sh -s -- ~/MonProjet --update-method   # appliquer, après validation
```

`--update-method` ne remplace que les artefacts méthode listés dans `.myprojectos/manifest` (hooks, skill, scripts de vérification, empreinte de version), avec sauvegarde préalable dans `99_archive/`. Le contenu du projet n'est jamais touché.

## Comment c'est pensé : neuf décisions qui structurent tout

Le registre complet est dans [DECISIONS.md](DECISIONS.md). Celles-ci expliquent la forme du système :

| Décision | Ce qu'elle fixe | Pourquoi |
|---|---|---|
| DEC-0005 | Frontières PROGRESS / CHANGELOG / DECISIONS | Une information, un seul endroit ; l'agent sait où lire et où écrire |
| DEC-0009 | `STACK_VALIDATION.md` avant la première ligne de code | Un non-développeur doit être protégé en amont, pas corrigé en aval |
| DEC-0015 | Versionnement SemVer de la méthode, `VERSION` à la racine | Répondre mécaniquement à « ce projet est-il à jour ? » |
| DEC-0025 | Hooks copiés dans chaque projet, pas référencés à distance | Un projet Life avec des données sensibles ne change pas de comportement depuis l'extérieur |
| DEC-0036 | Boucle de correction gouvernée, une montée de cran à la fois | Jamais transformer une réponse de modèle en règle du système |
| DEC-0040 | Hermès reçoit les skills par déclaration, pas par copie | Supprimer le second exemplaire plutôt que surveiller sa dérive |
| DEC-0041 | `99_archive/` zone froide, exclue des scans | On n'archive pas parce que c'est vieux, mais parce que c'est supersédé |
| DEC-0043 | Knowledge : « le sommaire, pas tout le livre » | Le contexte est une ressource rare ; charger le détail seulement quand l'action l'exige |
| DEC-0048 | Atelier privé, vitrine publique générée | Faire évoluer la méthode librement, publier une version propre et sûre à chaque release |

## La doctrine, en treize principes

1. **Simplicité avant élégance** : couvrir 80 % des besoins avec une base simple.
2. **Markdown-first** : lisible dans GitHub sans outil externe.
3. **Human-friendly** : compréhensible sans être développeur.
4. **Agent-friendly** : structuré pour être navigable par les agents.
5. **Git-friendly** : versionnable proprement.
6. **Une information, un seul endroit** : pas de double source.
7. **Reprise à froid** : le critère ultime, un état fiable sans historique de conversation.
8. **Validation humaine** sur les actions sensibles.
9. **Les règles non négociables sont automatiques** : hooks, pas consignes.
10. **Contexte progressif** : charger le détail seulement quand l'action le nécessite.
11. **Dépendances transverses avant action** : analyser les impacts avant de modifier.
12. **Suggestion, pas prescription unique** : un écart assumé et consigné est légitime.
13. **Répondre avant de tenir les registres** : l'utilisateur ne doit pas attendre la tenue des fichiers de suivi.

Interdit absolu : **jamais transformer une réponse de modèle en règle du système**. Une leçon devient canonique par décision humaine tracée (DEC-0036).

## Les agents

- **Claude Code** (Mac) : agent principal, exécute la skill assistant (7 modes : reprise, orientation, explication, clôture, cadrage, adoption, mise à jour) et la colonne vertébrale Code (Harness).
- **Hermès** (VPS) : consomme les fichiers Markdown sans exécuter les hooks ; reçoit les skills par déclaration `skills.external_dirs` (DEC-0040).
- **Codex** : skills par lien symbolique relatif dans `.agents/skills/`.
- **OpenCode** : découvre `.claude/skills/` et `.agents/skills/`.

Les skills de projet vivent dans `98_configuration/skills/<outil>/` (source canonique unique). Détail : [docs/skills-portables.md](docs/skills-portables.md). Les projets sont synchronisés entre machines par Syncthing : ne jamais modifier le même projet simultanément sur deux machines.

## Structure de ce dépôt

```
MyProjectOS/
├── README.md / ROADMAP.md / CHANGELOG.md / DECISIONS.md
├── docs/              # vision, principes, gouvernance, cycle de vie, enforcement, versionnement, nommage
├── templates/
│   ├── core/          # PROJECT, PROGRESS, CHANGELOG, TASKS, DECISIONS, AGENTS, CLAUDE (socle)
│   ├── configuration/ # gabarits des dossiers 97_gouvernance/ et 98_configuration/
│   └── extensions/    # life/, code/, knowledge/
├── structures/        # core-tree, life-tree, code-tree, knowledge-tree
├── agents/            # claude-code, hermes, meta-skill
├── skills/            # my-project-os/SKILL.md (skill assistant installable)
├── examples/          # projets fictifs complets, Life et Code
├── 97_gouvernance/    # vitrine du dossier optionnel « droit local du projet »
├── 98_configuration/  # vitrine du dossier optionnel « intégrations et handoff »
└── scripts/           # init-project.sh, check-project.sh, check-update.sh, check-secrets.sh, hooks/
```

## Documentation

- [Vision](docs/vision.md) : le problème et la promesse « Reprends le projet ».
- [Principes](docs/principles.md) : les règles qui tranchent les arbitrages.
- [Gouvernance](docs/governance.md) : qui met à jour quoi, quand, et ce qui exige une validation humaine.
- [Cycle de vie](docs/lifecycle.md) : de la création à l'archivage.
- [Cycle de travail](docs/cycle-de-travail.md) : une tâche par itération, clôture, contexte vidé, reprise à froid.
- [Installation par un agent](docs/INSTALL-AGENT.md) : création sur dossier vierge ou adoption d'un projet existant.
- [Enforcement](docs/enforcement.md) : les trois couches, les hooks, le contrôle à la demande.
- [Versionnement](docs/versioning.md) : numérotation, mise à jour des projets, publication d'une release.
- [Skills portables](docs/skills-portables.md) : où vit une skill de projet, comment chaque agent l'installe.
- [Outils natifs](docs/OUTILS.md) : catalogue des outils qu'un projet peut activer.
- [Conventions de nommage](docs/NAMING-CONVENTIONS.md) : fichiers, dossiers, identifiants.
- [Glossaire](docs/glossary.md) : le vocabulaire commun.

## Où ça va

La méthode est en `0.x` : elle tourne sur plusieurs projets réels (personnels, administratifs, logiciels) mais n'a pas encore passé son banc d'essai formel sur un projet Code de bout en bout, condition du `1.0.0`. Les versions publiées sont listées dans [CHANGELOG.md](CHANGELOG.md) ; les grandes étapes dans [ROADMAP.md](ROADMAP.md).

## Pièges à éviter

- Ne pas transformer `PROGRESS.md` en journal : c'est une photo de l'instant.
- Ne pas dupliquer l'information entre fichiers : référencer par identifiant.
- Ne pas créer de dossier racine jumeau (`99_archives` vs `99_archive`) : le hook le bloque.
- Ne pas supposer qu'une skill installée pour un agent l'est pour un autre : vérifier `platforms:` et l'installation par agent.
- Ne pas laisser `derniere_maj` et `prochaine_action` de `PROGRESS.md` se périmer : la promesse de reprise à froid en dépend.

## Auteur

Conçu et maintenu par [Mediatros](https://github.com/Mediatros), en dogfooding sur ses propres projets. Licence MIT. Les issues sont ouvertes ; elles sont traitées dans l'atelier et ressortent à la release suivante.
