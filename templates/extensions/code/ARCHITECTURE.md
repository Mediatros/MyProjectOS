# ARCHITECTURE.md — <NomDuProjet>

> Comment le code est organisé et pourquoi. Permet à un agent de savoir où se trouve quoi, quoi modifier et quoi ne pas toucher.
> C'est le socle du « kit de rails » : organisation par domaine fonctionnel + responsabilités claires. Voir `docs/kit-de-rails.md`.

## Vue d'ensemble

<En quelques phrases : type d'application, grands blocs, technologie structurante.>

## Organisation du code

```
src/
├── <domaine-a>/        # responsabilité du domaine A
├── <domaine-b>/        # responsabilité du domaine B
└── <partagé>/          # utilitaires transverses
```

## Modules et responsabilités

| Module / dossier | Responsabilité | Ne contient pas |
|---|---|---|
| <...> | <...> | <...> |

## Flux principaux

<Décrire les parcours clés : entrée → traitement → sortie. Un flux par paragraphe ou schéma.>

## Décisions architecturales

- <choix structurant + renvoi DEC-XXXX>

## Zones à ne pas modifier sans validation

- <fichier ou module sensible + raison>

## Conventions

- **Nommage du code** : <règles de nommage des fichiers, fonctions, variables>
- **Séparation des responsabilités** : <règle d'or du projet>
- **Où ajouter une feature** : voir la recette dans `docs/kit-de-rails.md` et `IMPACT_ANALYSIS.md`.
