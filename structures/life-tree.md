# Structure d'un projet Life

Extension **Life** : projets personnels, administratifs ou juridiques. S'ajoute au socle Core (`structures/core-tree.md`).

```
MonProjet/
├── PROJECT.md / PROGRESS.md / CHANGELOG.md / TASKS.md / DECISIONS.md   # Core
├── PREUVES.md          # registre logique des preuves (P-XXXX)
├── ECHEANCES.md        # dates importantes, délais, rendez-vous
├── CORRESPONDANCES.md  # registre des échanges (C-XXXX)
├── 00_inbox/ 01_context/ 03_documents/ 04_deliverables/   # dossiers Core
├── 02_sujets/           # optionnel : organisation par sujets, redéfinit 02_work/ du Core pour Life
│   ├── INDEX.md         # sujets suivis, un par ligne, renvoi vers le sous-dossier
│   └── Sxx_NomDuSujet/  # un sous-dossier par sujet de fond (ex. S01_Succession, S02_Vente_Bien)
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
| `02_sujets/` | Organisation par sujets, optionnelle (voir section dédiée ci-dessous) : redéfinit `02_work/` du Core pour Life |
| `05_correspondances/` | Emails, courriers, réponses, brouillons (sources des `C-XXXX`) |
| `06_preuves/` | Pièces justificatives référencées par les `P-XXXX` |
| `07_echeances/` | Documents rattachés aux échéances (convocations, accusés) |
| `08_modeles/` | Modèles réutilisables de courriers et réponses types |

## Dossier `02_sujets/` : organisation par sujets (DEC-0032)

Le socle Core réserve `02_work/` au « travail actif en cours » (voir `structures/core-tree.md`), un sens générique qui convient à un projet Code mais s'avère trop pauvre pour un projet Life qui suit plusieurs sujets de fond en parallèle (succession, santé, vente d'un bien, litige...). Pour Life et Hybrid, `02_sujets/` **redéfinit ce même slot 02** : Code garde `02_work/` inchangé, un projet Life ou Hybrid ne pose jamais les deux à la fois.

**Cas Hybrid** : `02_sujets/` l'emporte systématiquement sur `02_work/`. Ce n'est pas une perte pour le côté Code du projet : ses dossiers dédiés (`05_specs/`, `06_architecture/`, `07_tests/`, `08_releases/`, `09_scripts/`, `src/`, voir `structures/code-tree.md`) couvrent déjà le travail actif côté code ; `02_work/` n'y ajoutait qu'un fourre-tout générique, moins utile qu'un rangement par sujet une fois le projet Hybrid.

- **Quand l'utiliser** : dès qu'un projet Life dépasse une dizaine de fichiers de travail thématiques à la racine, ou qu'au moins deux sujets de fond distincts sont suivis en parallèle. En dessous, un simple `02_work/` plat suffit, pas besoin d'anticiper.
- **Structure** : un sous-dossier par sujet, nommé `Sxx_NomDuSujet` (deux chiffres, underscore, nom du sujet). `02_sujets/INDEX.md` liste les sujets actifs et leur statut (voir gabarit `templates/extensions/life/INDEX.md`).
- **Ce qui ne va pas dedans** : les documents classés par nature (courrier, preuve, échéance, modèle) restent dans `05_correspondances/` à `08_modeles/`, même s'ils se rapportent à un sujet de `02_sujets/`. `02_sujets/` range le travail de fond (notes, synthèses, brouillons de dossier), pas les pièces sources.
- **Exemple réel** : `Copropriete_Jacques_Dore` et `LaCIOTAT` ont chacun créé ce motif indépendamment avant qu'il ne soit canonisé ici (voir `RETEX/retex-laciotat-organisation-par-sujets.md`).
- **`02_sujets/` est un nom suggéré, pas imposé** (DEC-0033) : un projet peut choisir un autre nom pour ce même dossier (ex. `02_thematique/`) tant que c'est un choix explicite, consigné dans le `DECISIONS.md` du projet. `check-project.sh` et `hook-pre-write.sh` reconnaissent tout dossier racine `02_<nom>` (autre que `02_work/`) comme « déjà organisé » et n'avertissent plus une fois qu'il existe, quel que soit son nom exact. Seule la lecture d'un sujet par la skill assistant suppose de retrouver ce dossier (et son `INDEX.md`) via le `DECISIONS.md` du projet s'il ne s'appelle pas `02_sujets/`.

## Règle de cohérence

- Toute affirmation engageante dans `PROGRESS.md` ou une décision doit pointer vers une preuve (`P-XXXX`) ou être marquée « à confirmer ».
- Un échange consigné dans `CORRESPONDANCES.md` range son document source dans `05_correspondances/` avec un nom préfixé `YYYY-MM-DD`.

Nommage : voir `docs/NAMING-CONVENTIONS.md`.
