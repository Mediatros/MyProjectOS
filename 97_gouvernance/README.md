# 97_gouvernance/ — droit local du projet

Dossier **optionnel** d'un projet MyProjectOS. Porte les règles de gouvernance **spécifiques au projet et à son utilisateur** : compléments aux fichiers sacrés et à la gouvernance Core de la méthode.

## Quand le créer

Dès que le projet a besoin de règles locales au-delà de ce que porte la gouvernance générique — par exemple :

- **Validation et décisions** : qui décide quoi, quelles actions exigent une validation humaine propre à ce projet, quels seuils.
- **Rituels locaux** : relectures, ordre de traitement, canaux propres au projet.
- **Règles de contenu** : formats ou conventions spécifiques aux livrables de ce projet.

## Contenu

- `GOUVERNANCE_LOCALE.md` — fichier principal (obligatoire dès que le dossier existe).
- `GOUVERNANCE_<DOMAINE>.md` — fichiers par domaine, si le besoin se précise.
- Gabarit : `templates/configuration/GOUVERNANCE_LOCALE.md`.

## Frontières (pour ne pas se tromper)

| Ça va ici | Ça va ailleurs |
|---|---|
| Règles de gouvernance du projet lui-même | Configuration technique des outils tiers → `98_configuration/` |
| Compléments aux fichiers sacrés | Rituels et garde-fous génériques de la méthode → `AGENTS.md` |
| Décisions de pilotage propres au projet | Contenu métier → dossiers `0X_` (01_context, 02_work...) |

Voir `structures/core-tree.md` et `docs/NAMING-CONVENTIONS.md` pour le canon complet.
