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

## Noms d'agents canoniques (handoff inter-agents)

Pour nommer un fichier `HANDOFF_<AGENT-A>_<AGENT-B>.md` (`templates/configuration/HANDOFF_INTERAGENT.md`) ou toute référence à un agent dans la gouvernance : majuscules, sans tiret interne au nom de l'agent.

| Agent | Nom canonique |
|---|---|
| Claude Code | `CLAUDECODE` |
| Hermès Agent | `HERMES` |
| Codex CLI | `CODEX` |

Un agent futur reprend la même règle : le nom du produit, en majuscules, sans espace ni tiret (ex. un agent « Foo Bar » deviendrait `FOOBAR`). Les fichiers de handoff déjà créés sous un autre nom (ex. `HANDOFF_CLAUDE_HERMES.md`) ne sont pas renommés d'office : la convention vaut pour les créations futures, un renommage se propose projet par projet.

## Documents Knowledge (niveaux 2 et 3)

Le lien entre un domaine et ses détails est porté par le nom : un document de niveau 3 reprend en préfixe le nom de son domaine parent, séparé par un double tiret.

```text
docs/02_domains/facturation.md              # niveau 2 : le domaine
docs/03_details/facturation--contrat-api.md # niveau 3 : un détail de ce domaine
docs/03_details/facturation--mapping-champs.md
```

Un sous-dossier par domaine (`docs/03_details/facturation/…`) est accepté pour les projets très denses ; dans ce cas, le documenter dans `docs/kb_governance.md`. Le routeur métier garde un nom fixe : `SUJETS.md`, à la racine du projet.

## Dossiers numérotés

Les dossiers de travail sont préfixés par un numéro à deux chiffres pour fixer l'ordre de lecture :
`00_inbox/`, `01_context/`, `02_work/`, `03_documents/`, `04_deliverables/`, `98_configuration/` (optionnel), `99_archive/`.

Le rôle de chaque dossier est décrit dans `structures/core-tree.md` (et `life-tree.md`, `code-tree.md`).

`98_configuration/` (optionnel, tous types) : gouvernance des intégrations d'outils tiers partagées entre plusieurs agents (`GOUVERNANCE_<OUTIL>.md`) et handoff asynchrone entre agents sans canal de communication direct (`HANDOFF_<AGENT-A>_<AGENT-B>.md`). Gabarits : `templates/configuration/`. Avant d'utiliser le gabarit générique vide `GOUVERNANCE_INTEGRATION.md`, vérifier si une variante pré-remplie existe pour l'outil concerné (ex. `GOUVERNANCE_BLUE.md` pour Blue) — elle porte déjà les règles et pièges connus, à ne pas redécouvrir à chaque projet. N'y va pas : les secrets (restent en `.env`/trousseau) ni le contenu métier du projet (reste dans les dossiers `0X_`).

Avant de créer un dossier à la racine (numéroté ou non) : vérifier dans `structures/*-tree.md` et sur le disque qu'aucune variante proche du nom canonique n'existe déjà (singulier/pluriel, casse, accents, abréviation). Un dossier racine mal nommé attire du contenu pendant des jours avant d'être détecté — voir `RETEX/retex-laciotat-doublon-archives.md`.
