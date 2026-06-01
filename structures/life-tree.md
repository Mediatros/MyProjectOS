# Structure d'un projet Life

Extension **Life** : projets personnels, administratifs ou juridiques. S'ajoute au socle Core (`structures/core-tree.md`).

```
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md   # Core
├── PREUVES.md          # registre logique des preuves (P-XXXX)
├── ECHEANCES.md        # dates importantes, délais, rendez-vous
├── CORRESPONDANCES.md  # registre des échanges (C-XXXX)
├── 00_inbox/ … 04_deliverables/   # dossiers Core
├── 05_correspondances/ # emails, courriers, réponses, brouillons
├── 06_preuves/         # pièces justificatives importantes (sources des P-XXXX)
├── 07_echeances/       # documents liés aux échéances
├── 08_modeles/         # modèles de courriers, emails, réponses types
└── 99_archive/         # dossier Core
```

## Fichiers ajoutés

| Fichier | Rôle | Identifiant |
|---|---|---|
| `PREUVES.md` | Relie chaque affirmation à un document source | `P-XXXX` |
| `ECHEANCES.md` | Suit les dates importantes et les actions attendues | — |
| `CORRESPONDANCES.md` | Registre des emails, courriers, appels, réunions | `C-XXXX` |

## Dossiers ajoutés

| Dossier | Rôle |
|---|---|
| `05_correspondances/` | Emails, courriers, réponses, brouillons (sources des `C-XXXX`) |
| `06_preuves/` | Pièces justificatives référencées par les `P-XXXX` |
| `07_echeances/` | Documents rattachés aux échéances (convocations, accusés) |
| `08_modeles/` | Modèles réutilisables de courriers et réponses types |

## Règle de cohérence

- Toute affirmation engageante dans `PROGRESS.md` ou une décision doit pointer vers une preuve (`P-XXXX`) ou être marquée « à confirmer ».
- Un échange consigné dans `CORRESPONDANCES.md` range son document source dans `05_correspondances/` avec un nom préfixé `AAAA-MM-JJ`.

Nommage : voir `docs/NAMING-CONVENTIONS.md`.
