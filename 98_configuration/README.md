# 98_configuration/ — intégrations, handoff, skills portables

Dossier présent dès la création de tout projet MyProjectOS, ce dépôt compris (dogfooding de la méthode sur elle-même). Contrairement à `97_gouvernance/`, il est indispensable : il porte le catalogue de skills du projet. Porte la **gouvernance des intégrations d'outils tiers** partagées entre plusieurs agents, le **handoff asynchrone** entre agents sans canal direct, et la **source canonique** des skills techniques portables du projet.

## Quand créer les autres fichiers

`GOUVERNANCE_<OUTIL>.md` et `HANDOFF_<AGENT-A>_<AGENT-B>.md` se créent dès qu'un projet est piloté par plusieurs agents/outils partagés et qu'il faut une source unique pour éviter les divergences silencieuses (ex. deux skills qui remplissent Blue différemment). `skills/`, lui, existe toujours.

## Contenu

- `GOUVERNANCE_<OUTIL>.md` — règles de fond d'une intégration (Blue, Notion, Linear...).
- `HANDOFF_<AGENT-A>_<AGENT-B>.md` — boîte aux lettres asynchrone inter-agents (append-only).
- `skills/` — source canonique **unique** de **toutes** les skills du projet, y compris la skill assistant `my-project-os` (posée par `init-project.sh`, voir `98_configuration/skills/my-project-os/SKILL.md`) ; `README.md` y sert de tableau de bord du parc.
- Gabarits : `templates/configuration/`.

## Frontières (pour ne pas se tromper)

| Ça va ici | Ça va ailleurs |
|---|---|
| Configuration/gouvernance des intégrations d'outils | Règles de gouvernance du projet lui-même → `97_gouvernance/` |
| Handoff inter-agents | Rituels et garde-fous génériques → `AGENTS.md` |
| Skills techniques portables | Contenu métier → dossiers `0X_` |

**Jamais de secrets** dans ce dossier : ils restent en `.env`/trousseau.

Voir `structures/core-tree.md` et `docs/NAMING-CONVENTIONS.md` pour le canon complet.
