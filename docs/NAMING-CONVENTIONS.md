# Conventions de nommage — MyProjectOS

> Règles minimales et concrètes pour nommer fichiers, dossiers et entrées de registre.
> Objectif : que l'humain et l'agent retrouvent l'information sans ambiguïté.

## Fichiers et dossiers

- **Minuscules** et **tirets** plutôt qu'espaces : `compte-rendu-ag.md`, pas `Compte Rendu AG.md`.
- **Pas d'accents ni de caractères spéciaux** dans les noms de fichiers : `echeancier.md`, pas `échéancier.md`.
- **Documents datés** : préfixe `YYYY-MM-DD` en tête de nom, pour le tri chronologique.
  - `2026-06-01-courrier-syndic.pdf`
  - `2026-05-12-facture-comptable.pdf`
- **Fichiers sacrés** : en MAJUSCULES, nom fixe imposé par la méthode (`PROJECT.md`, `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md`, `DECISIONS.md`).

### Avant / après

| Éviter | Préférer |
|---|---|
| `Réunion du 3 juin.md` | `2026-06-03-reunion.md` |
| `Facture EDF.pdf` | `2026-06-03-facture-edf.pdf` |
| `notes finales (v2).md` | `notes-finales-v2.md` |

## Identifiants de registre

Identifiants stables, jamais réutilisés ni renumérotés.

| Registre | Format | Exemple | Fichier |
|---|---|---|---|
| Changements | `CHG-YYYYMMDD-HHMM` | `CHG-20260601-1430` | `CHANGELOG.md` |
| Décisions | `DEC-XXXX` (séquentiel, zéro-paddé) | `DEC-0007` | `DECISIONS.md` |
| Preuves (Life) | `P-XXXX` | `P-0042` | `PREUVES.md` |
| Correspondances (Life) | `C-XXXX` | `C-0003` | `CORRESPONDANCES.md` |
| Fonctionnalités (Code) | `F-XXX` | `F-012` | `SPECS.md` |
| Analyses d'impact (Code) | `IA-XXX` | `IA-005` | `IMPACT_ANALYSIS.md` |
| Tâches | `Tx.y` (phase.tâche) | `T2.3` | `TASKS.md` |

### Règles

- `CHG-` : l'horodatage est celui de l'écriture de l'entrée. Une entrée figée ne change plus.
- `DEC-` : numérotation continue à l'échelle du projet. Une décision remplacée n'est pas supprimée, elle est marquée obsolète et une nouvelle `DEC-` la remplace.
- `P-` : chaque preuve relie une affirmation à un document source unique.
- Les références croisées citent l'identifiant : « voir DEC-0007 », « source P-0042 ».

## Dossiers numérotés

Les dossiers de travail sont préfixés par un numéro à deux chiffres pour fixer l'ordre de lecture :
`00_inbox/`, `01_context/`, `02_work/`, `03_documents/`, `04_deliverables/`, `99_archive/`.

Le rôle de chaque dossier est décrit dans `structures/core-tree.md` (et `life-tree.md`, `code-tree.md`).
