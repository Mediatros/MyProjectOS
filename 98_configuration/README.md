# 98_configuration/ — intégrations, handoff, skills portables

Dossier **optionnel** d'un projet MyProjectOS. Porte la **gouvernance des intégrations d'outils tiers** partagées entre plusieurs agents, le **handoff asynchrone** entre agents sans canal direct, et la **copie canonique** des skills techniques portables du projet.

## Quand le créer

Dès qu'un projet est piloté par plusieurs agents/outils partagés et qu'il faut une source unique pour éviter les divergences silencieuses (ex. deux skills qui remplissent Blue différemment).

## Contenu

- `GOUVERNANCE_<OUTIL>.md` — règles de fond d'une intégration (Blue, Notion, Linear...).
- `HANDOFF_<AGENT-A>_<AGENT-B>.md` — boîte aux lettres asynchrone inter-agents (append-only).
- `skills/` — copie canonique projet des skills techniques portables, avec `README.md` comme tableau de bord du parc.
- Gabarits : `templates/configuration/`.

## Frontières (pour ne pas se tromper)

| Ça va ici | Ça va ailleurs |
|---|---|
| Configuration/gouvernance des intégrations d'outils | Règles de gouvernance du projet lui-même → `97_gouvernance/` |
| Handoff inter-agents | Rituels et garde-fous génériques → `AGENTS.md` |
| Skills techniques portables | Contenu métier → dossiers `0X_` |

**Jamais de secrets** dans ce dossier : ils restent en `.env`/trousseau.

Voir `structures/core-tree.md` et `docs/NAMING-CONVENTIONS.md` pour le canon complet.
