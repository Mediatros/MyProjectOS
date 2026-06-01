# Vision — Project OS AI

## Le problème

Les projets vivent dans la tête, dans des conversations avec une IA, dans des fichiers éparpillés mal nommés. Dès qu'une session se termine ou qu'un contexte est perdu, il faut tout reconstituer. Un non-développeur qui pilote plusieurs projets se disperse, oublie où il en était, refait le travail de cadrage à chaque reprise.

## La vision

Un projet doit pouvoir être repris à froid, par un humain ou par un agent IA, sans aucun historique de conversation. Toute l'information nécessaire vit dans des fichiers Markdown lisibles, à un endroit prévisible.

La phrase de référence : **« Reprends le projet. »** L'agent lit les fichiers sacrés et produit en quelques secondes un état fiable : où on en est, ce qui a été fait, pourquoi, et quelle est la prochaine action.

## Les trois questions

Tout projet doit toujours répondre à trois questions, chacune logée dans un fichier dédié :

- **Où en est-on ?** → `PROGRESS.md`
- **Qu'est-ce qui a été fait ?** → `CHANGELOG.md`
- **Pourquoi ?** → `DECISIONS.md`

Pour les projets **Life** s'ajoute : **quelle est la preuve ?** → `PREUVES.md`.
Pour les projets **Code** s'ajoute : **la stack est-elle validée, et quels fichiers sont impactés ?** → `STACK_VALIDATION.md`, `IMPACT_ANALYSIS.md`.

## Ce que le système est

- Une **méthode** d'organisation, ses templates, ses règles et ses exemples.
- Un système **documentaire** versionné, pilotable par Claude Code (Mac) et Hermès (VPS).
- Un cadre **unifié** : un même socle Core, deux extensions (Life, Code), un type Hybrid.

## Ce que le système n'est pas

- Pas un logiciel à installer ni à compiler.
- Pas un journal ni une documentation exhaustive.
- Pas un outil réservé aux développeurs.

## Pour qui

Un porteur de projet non-développeur qui sait exprimer un besoin fonctionnel mais pas toujours la mise en œuvre technique. Le système le guide et le protège, surtout en amont des projets Code.
