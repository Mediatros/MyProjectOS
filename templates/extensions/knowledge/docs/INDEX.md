# INDEX — Documentation <NomDuProjet>

> Point d'entrée unique pour naviguer dans la documentation active.

## Lire d'abord

- `../SUJETS.md` — routeur métier : pour une demande métier, le lire **avant** ce fichier.
- `../PROJECT.md` — identité, objectif, périmètre.
- `../PROGRESS.md` — état actuel et prochaine action.
- `../TASKS.md` — file d'actions.
- `kb_governance.md` — règles de navigation documentaire et analyse transverse.

## Niveau 1 — Global

| Document | Rôle | Quand le lire |
|---|---|---|
| `01_global/<document>.md` | Vue globale du projet | Reprise, orientation, décision structurante |

## Niveau 2 — Domaines

| Document | Domaine | Dépendances |
|---|---|---|
| `02_domains/<domaine>.md` | <domaine> | <amont / aval> |

## Niveau 3 — Détails

| Document | Détail | Domaine parent |
|---|---|---|
| `03_details/<detail>.md` | <détail technique> | <domaine> |

## Runbooks

| Runbook | Action | Risque |
|---|---|---|
| `runbooks/<runbook>.md` | <procédure> | faible / moyen / élevé |

## Plans

- `plan/active/` — plans validés ou en cours.
- `plan/ideas/` — plans candidats.
- `plan/archived/` — plans terminés, abandonnés ou remplacés.
- `plan/templates/plan_template.md` — modèle de plan Knowledge.

## Règle rapide

Si une action touche un domaine, lire :

1. ce fichier ;
2. le global concerné ;
3. le domaine concerné ;
4. les détails uniquement si modification technique ;
5. `kb_governance.md` pour l'analyse transverse.
