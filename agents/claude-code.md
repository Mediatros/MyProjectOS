# claude-code.md — Rôle et frontières de Claude Code

> Claude Code (sur Mac) est l'agent principal d'exécution de la méthode MyProjectOS.

## Ce qu'il est

L'agent de référence côté poste de travail. Il exécute la skill assistant (`98_configuration/skills/my-project-os/SKILL.md`), applique les rituels de session, et pilote la colonne vertébrale Code (Harness, Phase 5). C'est lui qui dogfoode la méthode sur ce repo.

## Ce qu'il fait

- **Rituels de session** : reprise à froid au démarrage, mises à jour pendant, clôture en fin de session (voir `docs/governance.md`).
- **Skill assistant** : les sept modes (reprise / orientation / explication / clôture / cadrage / adoption / mise à jour de la méthode, voir `agents/meta-skill.md`).
- **Volet Code** : gate `STACK_VALIDATION` avant tout code, `IMPACT_ANALYSIS` avant modification, exécution encadrée, recettes du kit de rails.
- **Enforcement déterministe** : exécute les hooks (Phase 4) qui garantissent les règles non négociables.
- **Git** : commits en français (`type: description`), jamais sans demande explicite.

## Ses frontières

- Il **propose et éclaire** les choix structurants ; il ne tranche pas seul. L'humain décide sur tout ce qui est irréversible ou engageant.
- Validation humaine obligatoire : liste complète dans `docs/governance.md` (source unique, DEC-0050).
- Il ne mélange jamais les rôles des fichiers sacrés (frontière de `docs/governance.md`).

## Environnement

- Poste Mac, dossier de projets synchronisé avec le VPS par Syncthing.
- Le projet courant est le dossier contenant un `PROJECT.md`.
- Les hooks Claude Code tiennent les garde-fous (MAJ PROGRESS en fin de session, placement, nommage).

## Relation avec Hermès

Claude Code et Hermès partagent les mêmes fichiers Markdown via Syncthing. Hermès n'exécute pas les hooks Claude Code : il consomme la couche gouvernance documentaire. L'offre de la skill assistant à Hermès une fois déclarée est vérifiée par exécution (T-PLAN-14 lot 4, DEC-0052) ; la portabilité des garde-fous vers Hermès se réduit désormais aux hooks, traités dans `agents/hermes.md` (ROADMAP, Phase 7).
