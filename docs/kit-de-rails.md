# Kit de rails — concept et recette d'ajout de feature

> L'architecture « Agent First » n'est fournie par aucun outil de process. Le modèle retenu : un **kit de rails** par type de stack, qui fait coder l'IA « comme un senior » parce qu'on lui donne les bons rails.

## Le constat

Trois couches sont nécessaires à un projet Code :

1. **Amont** (spec, stack, séquençage) : la plus critique pour un non-développeur.
2. **Exécution encadrée** : conduite du travail de codage.
3. **Architecture Agent First** : non couverte par les outils de process. C'est le trou que le kit de rails comble.

Pas de boilerplate unique, parce que les projets sont hétérogènes (WordPress, n8n, SaaS). À la place : un kit de conventions et de recettes adapté à chaque type de stack.

## Composition d'un kit de rails

Un kit, pour un type de stack donné, réunit :

- **`ARCHITECTURE.md`** : organisation par domaine fonctionnel + séparation des responsabilités.
- **Conventions et typage** : règles de nommage et de structure, contraintes fortes.
- **Règles agent** (`AGENTS.md` / `CLAUDE.md`) : comment l'agent doit se comporter dans ce repo.
- **Recettes d'ajout de feature** : le rail générique, étape par étape, pour ajouter une fonctionnalité sans casser l'existant.
- **Gate qualité** : tests, lint, critères de validation avant de considérer une feature faite.

## La pièce maîtresse : la recette

La **recette** est le rail générique (« pour ajouter une feature de ce type, voici les étapes et les fichiers concernés »). Elle se couple à **`IMPACT_ANALYSIS.md`**, qui en est l'instance précise sur un changement donné.

```
Recette (générique, dans le kit)        IMPACT_ANALYSIS (instance, dans le projet)
« Pour ajouter un endpoint :       →    « Endpoint /factures : fichiers A, B ;
  créer X, brancher Y, tester Z »        ne pas toucher C ; risque sur D ; tests E »
```

### Format d'une recette

```
## Recette — <type de feature> (ex : ajouter un endpoint, une page, un nœud n8n)

**Quand l'utiliser** : <situation déclenchante>

**Étapes**
1. <action + fichier ou dossier concerné>
2. <action + fichier ou dossier concerné>
3. <branchement / enregistrement dans l'app>

**Fichiers typiquement concernés** : <liste>
**Fichiers à ne jamais toucher pour ce type** : <liste>
**Vérifications avant de considérer fait** : <tests, lint, critère d'acceptation>
**Renvoi** : remplir IMPACT_ANALYSIS.md (IA-XXX) avec l'instance précise.
```

## Pourquoi ça marche

L'IA ne « devine » plus l'architecture : elle suit un rail explicite. Le porteur non-développeur n'a pas à connaître la mise en œuvre ; il s'appuie sur la recette et sur l'analyse d'impact pour garder le contrôle. C'est l'esprit « pas du vibe coding, du AI Building » : l'agent code comme un senior parce qu'on lui a posé les bons rails.

## Portée

Chaque kit est propre à un type de stack. Le repo méthode fournit le format ; les kits concrets se construisent au fil des projets réels (premier banc d'essai : Unjque, phase 6).
