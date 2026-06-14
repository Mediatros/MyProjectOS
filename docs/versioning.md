# Versionnement de la méthode — MyProjectOS

> Comment MyProjectOS (la méthode) se numérote, et comment un projet sait s'il suit une version à jour.
> Cette page parle de la version de **la méthode**, pas de la version d'un projet ni d'un logiciel.

## Pourquoi une version

La méthode évolue : on change une règle, on ajoute une extension, on renomme un format (par exemple le passage des dates françaises au format anglais `YYYY-MM-DD`). Sans numéro de version, impossible de savoir si un projet créé il y a deux mois suit encore les règles actuelles.

Le versionnement répond à deux questions :

- **Dans quelle version de la méthode suis-je ?** → le fichier `VERSION` à la racine du dépôt.
- **Ce projet est-il à jour avec la méthode ?** → `scripts/check-project.sh` compare l'empreinte du projet à la version courante.

## La source de vérité : le fichier `VERSION`

Un seul fichier à la racine, contenant une seule ligne, par exemple :

```
0.1.0
```

C'est la version courante de la méthode. Tout le reste (scripts, estampille des projets) lit ce fichier. On ne maintient le numéro qu'à un seul endroit.

## Le format : `MAJEUR.MINEUR.CORRECTIF`

Trois nombres séparés par des points. Chacun a un sens précis.

| Partie | Exemple | Quand on l'incrémente |
|---|---|---|
| **MAJEUR** | `1.x.x` → `2.0.0` | Rupture. La structure des fichiers sacrés change, un format devient incompatible. Les anciens projets doivent **migrer**. |
| **MINEUR** | `0.4.x` → `0.5.0` | Ajout compatible. Nouvelle extension, nouvelle règle, nouveau script. Rien ne casse dans les projets existants. |
| **CORRECTIF** | `0.5.0` → `0.5.1` | Détail. Correction de formulation, précision d'un template, correction de script. Aucun impact de fond. |

Règle simple : **est-ce qu'un projet déjà créé risque de devenir non conforme ?** Si oui, c'est un MAJEUR. Si on ajoute sans rien casser, c'est un MINEUR. Si on ne fait que corriger ou préciser, c'est un CORRECTIF.

### Le cas du `0.x`

Tant que le premier nombre est `0`, la méthode est considérée comme **encore en construction** : on s'autorise des ajustements plus libres entre versions mineures. Le passage à `1.0.0` marquera le moment où la méthode est jugée stable (après le banc d'essai sur un vrai projet).

## Une release

Une **release** est une version figée. La marquer signifie :

1. mettre à jour le fichier `VERSION` avec le nouveau numéro ;
2. ajouter la ligne correspondante dans la section « Releases » du `CHANGELOG.md` de la méthode (ce que la version apporte, en clair) ;
3. poser un tag git `vX.Y.Z` sur le commit (`git tag v0.1.0`), pour retrouver l'état exact plus tard.

Le `CHANGELOG.md` garde le détail daté des changements (`CHG-YYYYMMDD-HHMM`) ; la section « Releases » les regroupe sous un numéro de version lisible.

## L'empreinte dans chaque projet

Quand `scripts/init-project.sh` crée un projet, il inscrit la version de la méthode utilisée dans le frontmatter de `PROJECT.md` :

```yaml
methode: my-project-os
version_methode: 0.1.0
```

Le projet sait ainsi sur quelle version de la méthode il est né. Cette empreinte ne change pas toute seule : elle ne bouge que si on décide de migrer le projet vers une version plus récente de la méthode.

## Le check d'alignement

`scripts/check-project.sh` lit `version_methode` dans le `PROJECT.md` du projet, le compare au `VERSION` de la méthode installée, et répond :

- **à jour** : `[ok] suit MyProjectOS v0.1.0 (version courante)` ;
- **en retard** : `[!] suit MyProjectOS v0.1.0, version courante v0.2.0 : voir les changements dans le CHANGELOG de la méthode` ;
- **sans empreinte** : `[!] projet sans empreinte de version (créé avant le versionnement)`.

Le check informe, il ne migre rien et ne bloque rien. La mise à jour d'un projet vers une version plus récente reste une décision humaine.

## Procédure pour publier une nouvelle version

1. Décider la partie à incrémenter (MAJEUR / MINEUR / CORRECTIF) selon la règle ci-dessus.
2. Écrire le nouveau numéro dans `VERSION`.
3. Ajouter une entrée datée dans `CHANGELOG.md` (`CHG-`) et une ligne dans la section « Releases ».
4. Si le choix est structurant, le consigner dans `DECISIONS.md` (`DEC-`).
5. Commiter, puis `git tag vX.Y.Z`.
