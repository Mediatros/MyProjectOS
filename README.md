# MyProjectOS

**Une méthode d'organisation de projets assistée par IA, pour reprendre n'importe quel projet à froid, sans aucun historique de conversation.**

Ce n'est pas un logiciel. C'est un système documentaire versionné : des templates Markdown, des règles de gouvernance, une skill assistant et des exemples. Il s'applique à lui-même (dogfooding) : ce dépôt est le premier projet MyProjectOS.

---

## L'idée en une phrase

Dire **« Reprends le projet »** et obtenir en quelques secondes un état fiable : où on en est, ce qui a été fait, pourquoi, et quelle est la prochaine action.

## Les trois questions

Tout projet répond toujours à trois questions, chacune dans un fichier dédié :

- **Où en est-on ?** → `PROGRESS.md`
- **Qu'est-ce qui a été fait ?** → `CHANGELOG.md`
- **Pourquoi ?** → `DECISIONS.md`

Les projets **Life** ajoutent : *quelle est la preuve ?* (`PREUVES.md`).
Les projets **Code** ajoutent : *la stack est-elle validée, et quels fichiers sont impactés ?* (`STACK_VALIDATION.md`, `IMPACT_ANALYSIS.md`).

## À qui ça s'adresse

À un porteur de projet, **y compris non-développeur**, qui pilote plusieurs projets avec l'aide d'agents IA : **Claude Code** sur Mac, **Hermès** sur VPS. Le système guide et protège l'utilisateur, surtout en amont des projets Code.

---

## Architecture

```
Core MyProjectOS             commun à tous les projets
├── Extension Life          projets personnels, administratifs, juridiques
├── Extension Code          projets logiciels
└── Extension Knowledge     documentation dense, navigation par niveaux, dépendances transverses
```

Un projet est de type **Life**, **Code**, **Hybrid** (Life + Code) ou **Core** (aucune extension). Le type est déclaré dans `PROJECT.md`. Les extensions sont activées selon le besoin, par des flags d'installation (`--life`, `--code`, `--knowledge`, combinables).

## Les fichiers sacrés du Core

Obligatoires dans tout projet, avec une frontière d'aiguillage stricte — **une information vit à un seul endroit**, les autres fichiers la référencent par identifiant (`DEC-XXXX`, `CHG-YYYYMMDD-HHMM`, `Tx.y`…) :

| Fichier | Rôle | Ce qui n'y vit pas |
|---|---|---|
| `PROJECT.md` | Pourquoi le projet existe, périmètre, objectifs, critères de réussite | Tout état daté, historique, tâches |
| `PROGRESS.md` | État actuel : photo de l'instant, **jamais un journal** | Historique de versions, récits de session |
| `CHANGELOG.md` | Historique daté, registre figé append-only (`CHG-YYYYMMDD-HHMM`) | Analyse longue, état courant |
| `TASKS.md` | File d'actions cochables (`Tx.y`), une tâche = une itération | Narratif, résultats détaillés |
| `DECISIONS.md` | Pourquoi des choix structurants (`DEC-XXXX`), registre figé | Micro-choix d'exécution |

Le socle pose aussi `AGENTS.md` et `CLAUDE.md` (rituels de session, garde-fous) — ce ne sont pas des fichiers sacrés, pas de registre à tenir.

## Les extensions

- **Life** (personnel, administratif, juridique) : `PREUVES.md` (`P-XXXX`), `ECHEANCES.md`, `CORRESPONDANCES.md` (`C-XXXX`) + dossiers `05_correspondances/` → `08_modeles/` + organisation par sujets `02_sujets/Sxx_NomDuSujet/` (DEC-0032).
- **Code** : `CONSTITUTION.md`, `STACK_VALIDATION.md` (gate avant la première ligne de code), `ARCHITECTURE.md`, `SPECS.md` (`F-XXX`), `TEST_PLAN.md`, `IMPACT_ANALYSIS.md` (`IA-XXX`), `RELEASE.md` + dossiers `05_specs/` → `src/`.
- **Knowledge** (transverse) : `SUJETS.md` (routeur métier, lu avant l'index), `docs/INDEX.md`, `docs/kb_governance.md`, niveaux `01_global/` → `02_domains/` → `03_details/`, `runbooks/`, `plan/`.

---

## Installation

**Vous êtes un agent ?** Le protocole complet (création sur dossier vierge, adoption d'un projet existant) est écrit pour vous : [docs/INSTALL-AGENT.md](docs/INSTALL-AGENT.md).

Une seule commande, à partir du lien du dépôt. Le dépôt est cloné dans un dossier temporaire, le projet est posé, puis le clone est supprimé. **Le projet final est autonome** : les hooks d'enforcement sont copiés dans son `.claude/hooks/` et ne dépendent plus de l'emplacement de MyProjectOS.

```sh
curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
  | sh -s -- ~/MonProjet --life
```

Flags d'extension : `--life`, `--code`, `--knowledge` (combinables ; aucun = Core seul). Pour greffer sur un projet déjà peuplé sans rien écraser : `--into-existing`.

Variante sans `curl` (clone manuel, jetable) :

```sh
git clone --depth 1 https://github.com/Mediatros/MyProjectOS.git /tmp/mpos
sh /tmp/mpos/scripts/init-project.sh ~/MonProjet --life
rm -rf /tmp/mpos
```

## Mise à jour d'un projet

Chaque projet embarque `scripts/check-update.sh` : il compare la version du projet à la dernière version publiée, liste les apports et les artefacts qui seraient remplacés, et **n'applique jamais rien seul**.

```sh
sh scripts/check-update.sh          # détecter et auditer
curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
  | sh -s -- ~/MonProjet --update-method   # appliquer, après validation
```

`--update-method` ne remplace que les artefacts méthode listés dans `.myprojectos/manifest` (hooks, skill, scripts de vérification, empreinte de version), avec sauvegarde préalable dans `99_archive/`. Le contenu du projet n'est jamais touché. Détail : [docs/versioning.md](docs/versioning.md).

---

## Comment l'utiliser

1. Installer MyProjectOS sur le dossier du projet (voir ci-dessus).
2. Choisir le type dans `PROJECT.md` et ajouter les extensions nécessaires (`--life`, `--code`, `--knowledge`).
3. À chaque session, suivre les rituels de [docs/governance.md](docs/governance.md) :
   - **Au démarrage** : lire dans l'ordre `PROJECT.md` → `PROGRESS.md` → `TASKS.md` → `CHANGELOG.md` → `DECISIONS.md`, produire *État actuel / Dernière action / Prochaine action / Points de vigilance*, lancer `check-update.sh` une fois.
   - **Pendant** : mettre à jour `PROGRESS.md` après toute avancée, logger dans `CHANGELOG.md`, consigner les décisions structurantes dans `DECISIONS.md`.
   - **En clôture** : produire le résumé (*fait / reste / décisions / risques / prochaine action*) **en premier**, déléguer la mise à jour des fichiers Core à un sous-agent, puis vider le contexte (`/clear`).
4. Cycle de travail : **une tâche par itération** — reprendre → exécuter UNE tâche → clôturer → `/clear` → recommencer. La conversation est jetable, les fichiers font foi.

## La méthode

- **Gouvernance** : frontière stricte entre PROGRESS (état) / CHANGELOG (historique) / DECISIONS (pourquoi) / TASKS (actions) ; règles immuables ; validation humaine obligatoire avant suppression massive, réorganisation, changement de stack, déploiement, push important, action juridique ou administrative sensible.
- **Versioning** : `VERSION` à la racine, SemVer ; release = bump + ligne dans la section Releases + tag `vX.Y.Z` + release GitHub. Détail : [docs/versioning.md](docs/versioning.md).
- **Archivage** : `99_archive/` est la zone froide (DEC-0041) — historique déplacé, copies avant purge, indexée par `INDEX.md`, **exclue des scans croisés**. Règles de réduction : purge de PROGRESS (état courant seulement), coupe du CHANGELOG, sujets clos, supersession des décisions.
- **Boucle de correction gouvernée** (DEC-0036) : une leçon monte d'un cran à la fois — correction locale → RETEX → procédure → skill → hook/check — avec 5 exigences (fréquence/impact, preuve exécutée, périmètre, faux positifs, décision humaine + test et rollback). Les RETEX portent un statut fermé (`ouvert`, `en-cours`, `integre`, `rejete`, `hors-canon`) ; un statut fermé sans référence `DEC-`/`CHG-` est signalé.
- **Enforcement à 3 couches** : documentation (informe) → skill assistant (accompagne) → hooks déterministes (garantissent). Les hooks bloquent le nommage (espaces/accents), le placement (binaires à la racine) et les quasi-doublons de dossiers ; `check-project.sh` contrôle à la demande (fichiers sacrés manquants, PROGRESS périmé, références cassées, formats de date…) et **ne bloque jamais** : il informe.
- **Plans** : une idée vit dans `PLAN/`, devient un plan (un plan interne), puis une décision `DEC-XXXX`, puis une règle du canon — jamais l'inverse, jamais en sautant une étape.

## Les agents

- **Claude Code** (Mac) : agent principal, exécute la skill assistant (7 modes : reprise, orientation, explication, clôture, cadrage, adoption, mise à jour) et la colonne vertébrale Code (Harness).
- **Hermès** (VPS) : consomme les fichiers Markdown (rituels, gouvernance) sans exécuter Harness ni les hooks ; reçoit les skills par **déclaration** `skills.external_dirs` pointant `98_configuration/skills/` (DEC-0040).
- **Codex** : skills par lien symbolique relatif dans `.agents/skills/`.
- **OpenCode** : découvre `.claude/skills/` et `.agents/skills/`.

Les skills de projet vivent dans `98_configuration/skills/<outil>/` (source canonique unique), installées par lien symbolique (Claude Code, Codex) ou déclaration (Hermès), avec les champs `platforms:` (filtre natif Hermès) et `portable:` (documentaire). Détail : [docs/skills-portables.md](docs/skills-portables.md).

**Synchronisation Mac/VPS** : les projets sont synchronisés par **Syncthing**. Ne jamais modifier le même projet simultanément sur les deux machines.

---

## La doctrine — 13 principes

1. **Simplicité avant élégance** — couvrir 80 % des besoins avec une base simple.
2. **Markdown-first** — lisible dans GitHub sans outil externe.
3. **Human-friendly** — compréhensible sans être développeur.
4. **Agent-friendly** — structuré pour être navigable par les agents.
5. **Git-friendly** — versionnable proprement.
6. **Une information, un seul endroit** — pas de double source.
7. **Reprise à froid** — le critère ultime : un état fiable sans historique de conversation.
8. **Validation humaine** sur les actions sensibles.
9. **Les règles non négociables sont automatiques** — hooks, pas consignes.
10. **Contexte progressif** — charger le détail seulement quand l'action le nécessite.
11. **Dépendances transverses avant action** — analyser les impacts avant de modifier.
12. **Suggestion, pas prescription unique** — un écart assumé et consigné est légitime.
13. **Répondre avant de tenir les registres** — l'utilisateur ne doit pas attendre la tenue des fichiers de suivi.

Interdit absolu : **jamais transformer une réponse de modèle en règle du système**. Une leçon devient canonique par décision humaine tracée (DEC-0036).

---

## Structure du repository

```
MyProjectOS/
├── README.md / ROADMAP.md / CHANGELOG.md
├── PLAN/              # handoff, plans et documents de travail hors docs stables
├── docs/              # vision, principes, gouvernance, cycle de vie, glossaire, nommage
├── templates/
│   ├── core/          # PROJECT, PROGRESS, CHANGELOG, TASKS, DECISIONS (socle)
│   ├── configuration/ # gabarits des dossiers 97_gouvernance/ et 98_configuration/
│   └── extensions/    # modules activables selon le type de projet
│       ├── life/      # PREUVES, ECHEANCES, CORRESPONDANCES
│       ├── code/      # AGENTS, STACK_VALIDATION, ARCHITECTURE, etc.
│       └── knowledge/ # docs/INDEX, kb_governance, niveaux, plans, runbooks
├── 97_gouvernance/    # vitrine : droit local du projet (règles spécifiques utilisateur)
├── 98_configuration/  # vitrine : intégrations d'outils tiers, handoff inter-agents
├── structures/        # core-tree, life-tree, code-tree, knowledge-tree
├── agents/            # claude-code, hermes, meta-skill
├── skills/            # my-project-os/SKILL.md (skill assistant installable)
├── examples/          # projets d'exemple Life et Code
└── scripts/           # init-project.sh, check-project.sh, check-update.sh, hooks/
```

## Structure d'un projet (en un coup d'œil)

Un projet MyProjectOS est un dossier Markdown organisé par dossiers numérotés :

```
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md   # fichiers sacrés
├── 00_inbox/          # entrées non classées
├── 01_context/        # contexte stable
├── 02_work/           # travail actif (ou 02_sujets/ pour les projets Life)
├── 03_documents/      # PDF, emails, pièces jointes
├── 04_deliverables/   # livrables finaux
├── 97_gouvernance/    # optionnel : droit local du projet (GOUVERNANCE_LOCALE.md)
├── 98_configuration/  # optionnel : intégrations d'outils, handoff inter-agents
└── 99_archive/        # éléments clôturés ou obsolètes
```

- **`97_gouvernance/`** — les règles de gouvernance propres au projet et à son utilisateur, en complément des fichiers sacrés (qui décide quoi, validations supplémentaires, rituels locaux). Gabarit : `templates/configuration/GOUVERNANCE_LOCALE.md`.
- **`98_configuration/`** — la gouvernance des intégrations d'outils tiers partagées entre agents (`GOUVERNANCE_<OUTIL>.md`), le handoff asynchrone inter-agents (`HANDOFF_<AGENT-A>_<AGENT-B>.md`) et les skills techniques portables (`skills/`). Gabarits : `templates/configuration/`.

## Documentation

- [Vision](docs/vision.md) — le problème et la promesse « Reprends le projet ».
- [Principes](docs/principles.md) — les règles qui tranchent les arbitrages.
- [Gouvernance](docs/governance.md) — qui met à jour quoi, quand, et ce qui exige une validation humaine.
- [Cycle de vie](docs/lifecycle.md) — de la création à l'archivage.
- [Cycle de travail](docs/cycle-de-travail.md) — une tâche par itération, clôture, contexte vidé, reprise à froid.
- [Installation par un agent](docs/INSTALL-AGENT.md) — création sur dossier vierge ou adoption d'un projet existant.
- [Enforcement](docs/enforcement.md) — les trois couches, les hooks, le contrôle à la demande.
- [Versionnement](docs/versioning.md) — numérotation, mise à jour des projets, publication d'une release.
- [Skills portables](docs/skills-portables.md) — où vit une skill de projet, comment chaque agent l'installe.
- [Conventions de nommage](docs/NAMING-CONVENTIONS.md) — fichiers, dossiers, identifiants.
- [Glossaire](docs/glossary.md) — le vocabulaire commun.

## État

Version **0.22.0** (2026-08-08). En construction — voir [ROADMAP.md](ROADMAP.md) et `TASKS.md` pour le plan détaillé. Dernière étape : archivage de l'historique CHANGELOG (DEC-0041, 2026-08-21).

---

## Pièges à éviter

- Ne pas transformer `PROGRESS.md` en journal — c'est une photo de l'instant.
- Ne pas dupliquer l'information entre fichiers — référencer par identifiant.
- Ne pas créer de dossier racine jumeau (`99_archives` vs `99_archive`) — le hook le bloque.
- Ne pas supposer qu'une skill installée pour un agent l'est pour un autre — vérifier `platforms:` et l'installation par agent.
- Ne pas laisser `derniere_maj` et `prochaine_action` de `PROGRESS.md` se périmer — c'est la promesse de reprise à froid qui en dépend.
