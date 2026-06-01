# Consigne de la veille mensuelle

> Procédure suivie chaque mois par la routine de veille. Lisible par un humain et par un agent.

## Objectif

Détecter les évolutions de `github/spec-kit` et `Chachamaru127/claude-code-harness`
pertinentes pour Project OS AI, et les restituer sans jamais modifier le système lui-même.

## Étapes

1. Lire `_etat-upstream.md` pour connaître les versions déjà vues.
2. Relever l'état actuel des deux repos :
   - dernière release (`gh api repos/<repo>/releases/latest`)
   - dernier commit de la branche par défaut
   - lire le `CHANGELOG` ou les notes de release pour le détail des changements
3. Comparer avec l'état mémorisé. S'il n'y a aucune nouveauté : ajouter une entrée courte « RAS ce mois ».
4. S'il y a des nouveautés, pour chacune, donner un verdict :
   - **à intégrer** : pertinent et applicable à notre système, avec l'action proposée
   - **à surveiller** : intéressant mais pas mûr ou pas urgent
   - **à ignorer** : sans impact pour nous
   Points d'attention prioritaires :
   - Harness : nouveaux garde-fous, nouvelles surfaces HTML, **version minimale de Claude Code requise**, changements des verbes plan/work/review/release
   - Spec Kit : changement de format de `constitution` ou des artefacts empruntés (réflexe clarify)
5. Ajouter la nouvelle entrée **en haut** de `VEILLE-OUTILS.md`, datée `AAAA-MM`.
6. Mettre à jour `_etat-upstream.md` avec les versions relevées.
7. Commit + push directement sur `main`. Message : `docs: veille upstream AAAA-MM`.

## Règle absolue

La veille ne modifie que `docs/veille/`. Elle ne touche jamais aux templates, à la gouvernance
ou au reste du système. Toute intégration d'une nouveauté est décidée par l'humain, séparément.
