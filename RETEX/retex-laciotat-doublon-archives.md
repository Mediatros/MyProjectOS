# RETEX — Doublon de dossier d'archive dans LaCIOTAT (`99_archives` / `99_archive`)

> Retour d'expérience issu du dogfood MyProjectOS sur `/Users/jb/Documents/MyProjects/SYNC/LaCIOTAT` (type Life).
> Date : 2026-07-09.
> Statut : constat terrain corrigé localement, évolutions génériques à intégrer dans MyProjectOS.

## Objet du RETEX

Documenter une dérive structurelle passée inaperçue pendant deux jours malgré les trois couches d'enforcement (hooks, check, skill), et en tirer des garde-fous génériques.

Grille de lecture habituelle :

```text
problème rencontré dans LaCIOTAT → correction locale appliquée → évolution générique à intégrer dans MyProjectOS
```

## Les faits

1. **2026-07-07** : lors du classement de l'archive brute de l'extraction du PC de Jean, l'agent (Claude Code) crée un dossier racine `99_archives/` (pluriel). Le nom est inventé au fil de l'eau : le nom canonique `99_archive/` (singulier) existait déjà dans `docs/NAMING-CONVENTIONS.md` et `structures/core-tree.md`, mais rien n'a forcé ni même suggéré sa consultation au moment de créer le dossier.
2. **2026-07-09** : la migration méthode v0.3.0 → v0.6.0 (`install.sh --update-method`) crée mécaniquement le dossier canonique `99_archive/` pour y sauvegarder les anciens artefacts. Le projet se retrouve avec **deux dossiers d'archive quasi homonymes** à la racine.
3. La dérive n'est détectée par aucun mécanisme : ni au moment de la création fautive (07-07), ni au moment de la collision (09-07), ni par les audits (`check-project.sh` à 0 bloquant / 0 avertissement pendant toute la période).

## Pourquoi aucun garde-fou ne s'est déclenché

| Couche | Ce qu'elle contrôle aujourd'hui | Pourquoi elle n'a rien vu |
|---|---|---|
| `hook-pre-write.sh` (temps réel) | Nommage des **fichiers** (espaces, accents) et documents à la racine | La création d'un **dossier** racine hors canon n'est pas examinée : écrire `99_archives/x.md` passe sans question |
| `check-project.sh` (audit) | Fichiers sacrés, extensions, fraîcheur, placeholders, références DEC/CHG, dates, Knowledge | Aucun contrôle ne porte sur les **dossiers de la racine** : ni doublon, ni quasi-doublon, ni préfixe numérique en collision |
| `install.sh` / `init-project.sh` (pose de structure) | Création des dossiers canoniques | Création en aveugle : ne regarde pas si une **variante proche** du dossier canonique existe déjà (`99_archives` à côté de `99_archive`) |
| Skill / docs (consigne) | `NAMING-CONVENTIONS.md` définit les dossiers numérotés | Consigne passive : rien n'impose de la relire avant de créer un dossier racine |

Constat transverse : l'enforcement couvre bien les **fichiers**, pas les **dossiers**. Or un dossier racine mal nommé est plus coûteux qu'un fichier mal nommé : il attire du contenu pendant des jours et casse les références en cascade au moment de la correction.

## Correction locale appliquée (LaCIOTAT, 2026-07-09)

- Fusion : `99_archives/Dossier_Claude_code_Ordi_Jean/` déplacé dans `99_archive/`, dossier fautif supprimé.
- Références vivantes mises à jour (5 fichiers) ; entrées CHANGELOG antérieures laissées figées.
- Tracé dans le CHANGELOG du projet : `CHG-20260709-2340`.
- Constat annexe hors méthode : le script global `generate-anatomy.sh` excluait `*/archives/*`, motif qui ne matche ni `99_archives` ni `99_archive` (le glob exige le segment exact) ; corrigé côté Mac.

## Évolutions génériques à intégrer dans MyProjectOS

Par ordre de valeur décroissante :

### 1. `check-project.sh` : nouvelle section « Dossiers racine » (audit, priorité haute)

Pour chaque dossier de premier niveau du projet :

- **Quasi-doublons** : normaliser le nom (minuscules, accents retirés, `s` final retiré) et avertir si deux dossiers racine entrent en collision après normalisation. Attrape `99_archive`/`99_archives`, `06_preuve`/`06_preuves`, `Archives`/`99_archive`, etc.
- **Collision de préfixe numérique** : avertir si deux dossiers portent le même préfixe `NN_` (casse l'ordre de lecture qui est la raison d'être du préfixe).
- **Ne pas** imposer de liste blanche stricte : les projets étendent légitimement le canon (LaCIOTAT a `07_fiches_prestataires/`, `08_recherche_mail/`, `09_modeles_courriers/`). Le contrôle vise la **cohérence interne**, pas la conformité au canon.
- Niveau : avertissement, jamais bloquant (philosophie existante du script).

### 2. `hook-pre-write.sh` : barrière temps réel sur les dossiers racine (priorité haute)

Avant d'écrire un fichier dont le premier segment de chemin est un dossier racine **qui n'existe pas encore** :

- si le nom normalisé entre en collision avec un dossier racine existant → `deny` avec message nommant le dossier existant (« `99_archive/` existe déjà : range le fichier dedans au lieu de créer `99_archives/` ») ;
- même normalisation que `check-project.sh` (facteur commun dans `_lib.sh`).

C'est la couche qui aurait arrêté la dérive le 2026-07-07, au moment exact où elle naissait.

### 3. `install.sh` / `init-project.sh` / `--update-method` : pose de dossier non aveugle (priorité moyenne)

Avant de créer un dossier canonique (`99_archive/` notamment) : si une variante proche existe (même normalisation), ne pas créer le jumeau silencieusement. Signaler et proposer : réutiliser l'existant (le renommer vers le canon) ou s'arrêter. Un installeur ne doit jamais être le **second** créateur d'un quasi-doublon.

### 4. Consigne active dans la skill et `NAMING-CONVENTIONS.md` (priorité moyenne)

- `NAMING-CONVENTIONS.md`, section « Dossiers numérotés » : règle explicite « avant de créer un dossier à la racine, vérifier qu'aucune variante (singulier/pluriel, casse, accents) n'existe déjà ; le dossier d'archive est `99_archive`, au singulier, sans variante possible ».
- Skill `my-project-os`, garde-fous : ajouter « la création d'un dossier numéroté à la racine se fait en consultant le canon (`structures/*-tree.md`) et l'existant, jamais au fil de l'eau ».

## Leçon générique

Une convention qui n'est portée que par un document est une convention morte au moment où l'agent agit vite. Ce RETEX confirme le principe fondateur de la méthode (« règles non négociables tenues par des hooks, pas par de simples consignes ») et montre qu'il doit s'appliquer aussi à la **topologie des dossiers**, pas seulement aux fichiers.
