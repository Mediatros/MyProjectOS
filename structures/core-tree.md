# Structure d'un projet Core

Arborescence type d'un projet, commune à tous les types (Life, Code, Hybrid).
Les dossiers sont créés à la demande, au moment où ils servent. Aucun squelette vide n'est imposé.

```
MonProjet/
├── PROJECT.md          # pourquoi le projet existe, périmètre, objectifs, réussite
├── PROGRESS.md         # état actuel, dernières actions, prochaine action
├── CHANGELOG.md        # historique daté (CHG-AAAAMMJJ-HHMM)
├── TASKS.md            # checklist d'actions (Tx.y)
├── DECISIONS.md        # décisions structurantes (DEC-XXXX)
├── 00_inbox/           # zone temporaire, entrées non classées
├── 01_context/         # contexte stable du projet
├── 02_work/            # travail actif en cours
├── 03_documents/       # PDF, emails, pièces jointes
├── 04_deliverables/    # livrables finaux
└── 99_archive/         # éléments clôturés ou obsolètes
```

## Rôle des fichiers sacrés

Voir `docs/governance.md` pour la frontière détaillée. En résumé :

- `PROJECT.md` : stable, le pourquoi et le périmètre.
- `PROGRESS.md` : photo de l'instant, jamais un journal.
- `CHANGELOG.md` : registre daté de ce qui a changé.
- `TASKS.md` : actions concrètes cochables.
- `DECISIONS.md` : le pourquoi des choix structurants.

## Rôle des dossiers

| Dossier | Rôle | Règle |
|---|---|---|
| `00_inbox/` | Tout ce qui arrive et n'est pas encore classé | Doit se vider : on classe régulièrement |
| `01_context/` | Contexte stable, documents de référence du projet | Bouge peu |
| `02_work/` | Notes et fichiers du travail en cours | Cœur de l'activité |
| `03_documents/` | Documents sources (PDF, emails, pièces jointes) | Préfixe date `AAAA-MM-JJ` |
| `04_deliverables/` | Livrables finaux destinés à sortir du projet | Versions abouties |
| `99_archive/` | Éléments clôturés ou obsolètes, anciens CHANGELOG | Conserver, ne pas supprimer |

## Extensions

- **Life** ajoute les fichiers `PREUVES.md`, `ECHEANCES.md`, `CORRESPONDANCES.md` et des dossiers dédiés. Voir `structures/life-tree.md`.
- **Code** ajoute `AGENTS.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, `TEST_PLAN.md`, `IMPACT_ANALYSIS.md`, `RELEASE.md` et des dossiers dédiés. Voir `structures/code-tree.md`.
- **Hybrid** combine les deux.

## Nommage

Voir `docs/NAMING-CONVENTIONS.md` : minuscules, tirets, pas d'accents, préfixe date pour les documents datés, identifiants stables pour les registres.
