# Structure d'un projet Code

Extension **Code** : projets logiciels. S'ajoute au socle Core (`structures/core-tree.md`).

```
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md   # Core
├── AGENTS.md           # Core + section "Extension Code" ajoutée par cette extension
├── CLAUDE.md           # Core
├── CONSTITUTION.md     # principes non négociables du projet
├── STACK_VALIDATION.md # gate de stack, obligatoire avant tout code
├── ARCHITECTURE.md     # organisation du code, responsabilités, zones sensibles
├── SPECS.md            # fonctionnalités attendues
├── TEST_PLAN.md        # tests et critères de validation
├── IMPACT_ANALYSIS.md  # analyse d'impact avant toute modification
├── RELEASE.md          # préparation et historique des livraisons
├── 00_inbox/ … 04_deliverables/   # dossiers Core
├── 05_specs/           # specs détaillées (complément de SPECS.md)
├── 06_architecture/    # schémas, diagrammes, notes d'architecture
├── 07_tests/           # jeux de tests, fixtures, rapports
├── 08_releases/        # artefacts et notes de release
├── 09_scripts/         # scripts utilitaires du projet
├── src/                # code source
└── 99_archive/         # dossier Core
```

## Fichiers ajoutés

`AGENTS.md` existe déjà via le socle Core ; l'extension Code y ajoute une section « Extension Code » (comment travailler dans le repo, quoi lire, quoi valider), elle ne crée pas de fichier séparé.

| Fichier | Rôle |
|---|---|
| `CONSTITUTION.md` | Principes non négociables du projet, lus par l'agent et Harness (voir `docs/harness.md`) |
| `STACK_VALIDATION.md` | Gate de compatibilité de stack, sourcé, avant la première ligne de code |
| `ARCHITECTURE.md` | Où se trouve quoi, responsabilités, zones à ne pas toucher |
| `SPECS.md` | Fonctionnalités attendues et critères d'acceptation |
| `TEST_PLAN.md` | Tests manuels et automatisés, cas critiques |
| `IMPACT_ANALYSIS.md` | Cartographie de l'impact avant toute modification |
| `RELEASE.md` | Checklist de livraison, rollback, notes de release |

## Dossiers ajoutés

| Dossier | Rôle |
|---|---|
| `05_specs/` | Specs détaillées qui débordent de `SPECS.md` |
| `06_architecture/` | Schémas et notes d'architecture |
| `07_tests/` | Jeux de tests, fixtures, rapports de test |
| `08_releases/` | Artefacts et notes des releases |
| `09_scripts/` | Scripts utilitaires (build, migration, maintenance) |
| `src/` | Le code source du projet |

## Règles propres au Code

- **Gate stack** : `STACK_VALIDATION.md` au statut `validé` avant la première ligne de code (voir `docs/stack-validation-gate.md`).
- **Avant de modifier** : remplir `IMPACT_ANALYSIS.md` (fichiers concernés, à ne pas toucher, risques, tests).
- **Lisibilité agent** : un agent doit pouvoir déterminer rapidement où est la logique métier, les intégrations, les contrats API, les tests, et quels fichiers ne pas toucher.

**Cas Hybrid** : `02_work/` du socle Core est alors redéfini en `02_sujets/` par l'extension Life (organisation par sujets, voir `structures/life-tree.md`, DEC-0032) ; les dossiers ci-dessus (`05_specs/` à `09_scripts/`, `src/`) restent inchangés et couvrent le travail actif côté code.

Nommage : voir `docs/NAMING-CONVENTIONS.md`.
