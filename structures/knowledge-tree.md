# Structure d'un projet avec extension Knowledge

Extension **Knowledge** : projets qui accumulent assez de documentation de référence pour nécessiter une navigation par niveaux et une analyse d'impact documentaire avant modification.

Elle s'ajoute au socle Core (`structures/core-tree.md`) et peut cohabiter avec Life, Code ou Hybrid. Elle ne remplace jamais `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md` ou `DECISIONS.md`.

```text
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md   # Core
├── 00_inbox/ … 04_deliverables/   # dossiers Core
├── docs/
│   ├── kb_governance.md  # règles de navigation, niveaux, dépendances transverses
│   ├── INDEX.md          # carte d'entrée documentaire
│   ├── 01_global/        # vue d'ensemble stable du projet
│   ├── 02_domains/       # domaines, composants, flux, responsabilités
│   ├── 03_details/       # détails techniques uniquement quand nécessaire
│   ├── runbooks/         # procédures d'action vérifiables
│   └── plan/             # plans de travail hors source de vérité permanente
│       ├── templates/
│       ├── active/
│       ├── ideas/
│       └── archived/
└── 99_archive/           # dossier Core
```

## Variante de nommage acceptée

Un projet peut utiliser les noms `01_macro`, `02_meso`, `03_micro` si cela correspond mieux à son historique. Dans ce cas, le mapping doit être documenté dans `docs/kb_governance.md` :

- `01_macro/` = Niveau 1 / `01_global/` ;
- `02_meso/` = Niveau 2 / `02_domains/` ;
- `03_micro/` = Niveau 3 / `03_details/`.

## Fichiers ajoutés

| Fichier | Rôle |
|---|---|
| `docs/kb_governance.md` | Règles de navigation progressive, analyse transverse, limites des outils complémentaires |
| `docs/INDEX.md` | Point d'entrée documentaire : quoi lire selon le besoin |

## Dossiers ajoutés

| Dossier | Rôle |
|---|---|
| `docs/01_global/` | Contexte haut niveau : architecture globale, cycle de vie, principes métier |
| `docs/02_domains/` | Domaines ou composants : workflows, bases, intégrations, modules |
| `docs/03_details/` | Détails techniques : contrats, schémas précis, notes d'implémentation |
| `docs/runbooks/` | Procédures d'exploitation ou de maintenance |
| `docs/plan/active/` | Plans validés ou en exécution |
| `docs/plan/ideas/` | Plans candidats non validés |
| `docs/plan/archived/` | Plans terminés, abandonnés ou remplacés |

## Règles propres à Knowledge

- **Lecture progressive** : lire `docs/INDEX.md`, puis le niveau global, puis les domaines concernés, puis les détails seulement si l'action l'exige.
- **Analyse transverse obligatoire** : avant modification documentaire ou technique, lister composants impactés, composants explicitement non impactés, dépendances bidirectionnelles et documents à mettre à jour.
- **Plans hors vérité permanente** : les plans guident l'action mais ne remplacent pas les fichiers sacrés ni les docs actives.
- **Runbooks vérifiables** : une procédure doit inclure prérequis, commandes ou étapes, validation, rollback quand pertinent.
- **Outils complémentaires** : Understand-Anything peut aider à visualiser les dépendances, mais la source de vérité reste Markdown + preuves système réelles.

Nommage : voir `docs/NAMING-CONVENTIONS.md`.
