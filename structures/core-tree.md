# Structure d'un projet Core

Arborescence type d'un projet, commune à tous les types (Life, Code, Hybrid).
Les dossiers sont créés à la demande, au moment où ils servent. Aucun squelette vide n'est imposé.

```
MonProjet/
├── PROJECT.md          # pourquoi le projet existe, périmètre, objectifs, réussite
├── PROGRESS.md         # état actuel, dernières actions, prochaine action
├── CHANGELOG.md        # historique daté (CHG-YYYYMMDD-HHMM)
├── TASKS.md            # checklist d'actions (Tx.y)
├── DECISIONS.md        # décisions structurantes (DEC-XXXX)
├── AGENTS.md           # instructions d'opération pour les agents (rituels, garde-fous)
├── CLAUDE.md           # renvoi vers AGENTS.md, pour que Claude Code le charge
├── 00_inbox/           # zone temporaire, entrées non classées
├── 01_context/         # contexte stable du projet
├── 02_work/            # travail actif en cours
├── 03_documents/       # PDF, emails, pièces jointes
├── 04_deliverables/    # livrables finaux
├── 98_configuration/   # optionnel : gouvernance d'intégrations tierces, handoff inter-agents
└── 99_archive/         # éléments clôturés ou obsolètes
```

## Rôle des fichiers sacrés

Voir `docs/governance.md` pour la frontière détaillée. En résumé :

- `PROJECT.md` : stable, le pourquoi et le périmètre.
- `PROGRESS.md` : photo de l'instant, jamais un journal.
- `CHANGELOG.md` : registre daté de ce qui a changé.
- `TASKS.md` : actions concrètes cochables.
- `DECISIONS.md` : le pourquoi des choix structurants.

`AGENTS.md` et `CLAUDE.md` ne sont pas des fichiers sacrés (pas de registre à tenir à jour), mais font partie du socle Core posé par `init-project.sh` sur tout type de projet : rituels de session, garde-fous, frontière des fichiers sacrés. Les extensions actives (Code...) ajoutent leur propre section dans `AGENTS.md` plutôt que de créer un fichier séparé.

## Rôle des dossiers

| Dossier | Rôle | Règle |
|---|---|---|
| `00_inbox/` | Tout ce qui arrive et n'est pas encore classé | Doit se vider : on classe régulièrement |
| `01_context/` | Contexte stable, documents de référence du projet | Bouge peu |
| `02_work/` | Notes et fichiers du travail en cours | Cœur de l'activité |
| `03_documents/` | Documents sources (PDF, emails, pièces jointes) | Préfixe date `YYYY-MM-DD` |
| `04_deliverables/` | Livrables finaux destinés à sortir du projet | Versions abouties |
| `98_configuration/` | Gouvernance d'intégrations tierces partagées entre agents, handoff asynchrone inter-agents | Optionnel, créé à la demande dès qu'un projet est piloté par plusieurs agents/outils partagés ; jamais de secrets ni de contenu métier. Voir `docs/NAMING-CONVENTIONS.md` |
| `99_archive/` | Éléments clôturés ou obsolètes, anciens CHANGELOG | Conserver, ne pas supprimer |

## Extensions

- **Life** ajoute les fichiers `PREUVES.md`, `ECHEANCES.md`, `CORRESPONDANCES.md` et des dossiers dédiés. Voir `structures/life-tree.md`.
- **Code** ajoute `CONSTITUTION.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md`, une section dédiée dans `AGENTS.md` (Core) et des dossiers dédiés. Voir `structures/code-tree.md`.
- **Hybrid** combine les deux.

## Nommage

Voir `docs/NAMING-CONVENTIONS.md` : minuscules, tirets, pas d'accents, préfixe date pour les documents datés, identifiants stables pour les registres.
