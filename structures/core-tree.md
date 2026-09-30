# Structure d'un projet Core

Arborescence type d'un projet, commune à tous les types (Life, Code, Hybrid).
Les dossiers numérotés sont créés à la demande, au moment où ils servent, à l'exception de `97_gouvernance/` et `98_configuration/`, présents dès la création du projet : aucun dossier vide n'est imposé, ces deux-là portent un contenu réel dès l'origine (README, skill assistant).

```
MonProjet/
├── PROJECT.md          # pourquoi le projet existe, périmètre, objectifs, réussite
├── PROGRESS.md         # état actuel, dernières actions, prochaine action
├── CHANGELOG.md        # historique daté (CHG-YYYYMMDD-HHMM)
├── TASKS.md            # checklist d'actions (Tx.y)
├── DECISIONS.md        # décisions structurantes (DEC-XXXX)
├── AGENTS.md           # instructions d'opération pour les agents (rituels, garde-fous)
├── CLAUDE.md           # une seule ligne : @AGENTS.md (import chargé par Claude Code)
├── 00_inbox/           # zone temporaire, entrées non classées
├── 01_context/         # contexte stable du projet
├── 02_work/            # travail actif en cours
├── 03_documents/       # PDF, emails, pièces jointes
├── 04_deliverables/    # livrables finaux
├── 97_gouvernance/     # présent dès la création, supprimable : droit local du projet (règles spécifiques utilisateur, compléments aux fichiers sacrés)
│   ├── README.md       # vocation du dossier, posé par init-project.sh
│   └── GOUVERNANCE_LOCALE.md  # à la demande, dès qu'une règle locale est exprimée
├── 98_configuration/   # présent dès la création, indispensable : gouvernance d'intégrations tierces, handoff inter-agents, skills du projet
│   └── skills/         # source canonique unique de TOUTES les skills du projet
│       ├── README.md   # tableau de bord du parc, dès plus d'une skill
│       └── my-project-os/SKILL.md  # skill assistant, posée par init-project.sh, rafraîchie par --update-method
└── 99_archive/         # éléments clôturés ou obsolètes
```

## Rôle des fichiers sacrés

Voir `docs/governance.md` pour la frontière détaillée. En résumé :

- `PROJECT.md` : stable, le pourquoi et le périmètre.
- `PROGRESS.md` : photo de l'instant, jamais un journal.
- `CHANGELOG.md` : registre daté de ce qui a changé.
- `TASKS.md` : actions concrètes cochables.
- `DECISIONS.md` : le pourquoi des choix structurants.

`AGENTS.md` et `CLAUDE.md` ne sont pas des fichiers sacrés (pas de registre à tenir à jour), mais forment la paire du socle Core posée par `init-project.sh` sur tout type de projet : `AGENTS.md` porte les rituels de session, garde-fous, frontière des fichiers sacrés ; `CLAUDE.md` ne contient que `@AGENTS.md` (DEC-0055, sens contrôlé par `check-project.sh`). Les extensions actives (Code...) ajoutent leur propre section dans `AGENTS.md` plutôt que de créer un fichier séparé.

## Règles locales par dossier (facultatif)

Un dossier de travail peut porter ses propres instructions d'opération, dans un `AGENTS.md` posé **dans ce dossier** (DEC-0054) : l'agent le reçoit dès qu'un de ses outils touche la zone, sans lecture manuelle.

Cadre : la paire, comme à la racine, le contenu dans `AGENTS.md` et un `CLAUDE.md` réduit à `@AGENTS.md` (DEC-0055 : sans lui, Claude Code ignore le fichier de zone) ; **une seule descente** — racine + zone, jamais dans `02_sujets/` ni à l'intérieur d'une zone ; cible **8 000 caractères** ; aucune recopie d'une règle racine (**une consigne, une seule feuille**) ; jamais d'état, de décision ni d'historique (c'est le rôle des registres) ; pose **à la demande** — `init-project.sh` et `--update-method` n'en créent jamais, l'agent propose, l'humain valide (gabarit `templates/configuration/AGENTS_DOSSIER.md`).

Dossiers éligibles : les zones de travail — `02_sujets/Sxx_…/` (Life), `05_specs/`, `src/` (Code). Jamais `03_documents/`, `99_archive/`, ni un dossier de dépendances. Une règle de gouvernance du projet (qui décide quoi) reste dans `97_gouvernance/` ; ce qui s'applique partout (ton, format de sortie, validations humaines) reste dans `AGENTS.md` racine, un fichier de zone ne pouvant pas gouverner une réponse produite sans jamais ouvrir la zone.

## Rôle des dossiers

| Dossier | Rôle | Règle |
|---|---|---|
| `00_inbox/` | Tout ce qui arrive et n'est pas encore classé | Doit se vider : on classe régulièrement |
| `01_context/` | Contexte stable, documents de référence du projet | Bouge peu |
| `02_work/` | Notes et fichiers du travail en cours | Cœur de l'activité ; Life/Hybrid peuvent le redéfinir en `02_sujets/` (organisation par sujets), voir `structures/life-tree.md` (DEC-0032) |
| `03_documents/` | Documents sources (PDF, emails, pièces jointes) | Préfixe date `YYYY-MM-DD` |
| `04_deliverables/` | Livrables finaux destinés à sortir du projet | Versions abouties |
| `97_gouvernance/` | Droit local du projet : règles de gouvernance spécifiques à l'utilisateur/projet (qui décide quoi, validations supplémentaires, rituels propres, règles de contenu), compléments aux fichiers sacrés et à la gouvernance Core | Présent dès la création (`README.md` posé par `init-project.sh`), seul dossier supprimable par l'utilisateur, jamais recréé par `--update-method` une fois qu'il a existé (au-delà du seuil `0.29.0`) ; fichier de règles `GOUVERNANCE_LOCALE.md` à la demande dès qu'une règle locale est exprimée, gabarit `templates/configuration/GOUVERNANCE_LOCALE.md` ; jamais de configuration d'outils (→ `98_configuration/`) ni de contenu métier (→ dossiers `0X_`) |
| `98_configuration/` | Gouvernance d'intégrations tierces partagées entre agents, handoff asynchrone inter-agents, source canonique de toutes les skills du projet | Présent dès la création de tout projet, indispensable (contrairement à `97_gouvernance/`) : il porte `98_configuration/skills/`, jamais vide. Jamais de secrets ni de contenu métier. Voir `docs/NAMING-CONVENTIONS.md` |
| `98_configuration/skills/` | Source canonique unique de TOUTES les skills du projet, la skill assistant `my-project-os` comprise (agnostique agent, ex. aussi `blue-app`, `courrier-manuscrit`, ou une skill bespoke du projet) ; chaque agent l'installe ensuite chez lui, par lien symbolique relatif pour Claude Code/Codex, par déclaration `skills.external_dirs` pour Hermès, selon l'`INSTALL.md` de la skill (voir le contrat d'un agent, `docs/skills-portables.md`). Catalogue des outils proposés nativement : `docs/OUTILS.md` du dépôt méthode ; squelette pour en créer : `templates/skills/_squelette/`. Dès qu'il y a plus d'une skill, `98_configuration/skills/README.md` tient le tableau de bord du parc (skill, `portable:`, `platforms:`, secret, agents équipés, blocage résiduel ; gabarit `templates/configuration/README_SKILLS.md`) | Présent dès la création (`my-project-os` y est posée par `init-project.sh`) ; source unique, jamais modifiée localement par un agent sans répercuter ici. Relire le tableau de bord en entier quand le projet change d'environnement d'exécution (DEC-0038) |
| `99_archive/` | Éléments clôturés ou obsolètes, anciens CHANGELOG | Conserver, ne pas supprimer |

## Extensions

- **Life** ajoute les fichiers `PREUVES.md`, `ECHEANCES.md`, `CORRESPONDANCES.md`, des dossiers dédiés, et redéfinit optionnellement `02_sujets/` (voir ci-dessus). Voir `structures/life-tree.md`.
- **Code** ajoute `CONSTITUTION.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md`, une section dédiée dans `AGENTS.md` (Core) et des dossiers dédiés. Voir `structures/code-tree.md`.
- **Hybrid** combine les deux. Sur le slot `02` spécifiquement, `02_sujets/` (Life) l'emporte sur `02_work/` (Code) : les dossiers dédiés de l'extension Code (`05_specs/` à `09_scripts/`, `src/`) couvrent déjà le besoin de « travail actif » côté code, voir `structures/life-tree.md` (DEC-0032).

## Nommage

Voir `docs/NAMING-CONVENTIONS.md` : minuscules, tirets, pas d'accents, préfixe date pour les documents datés, identifiants stables pour les registres.
