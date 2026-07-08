---
name: add-extension
description: Runbook pas-à-pas pour ajouter ou modifier un template, un fichier sacré ou une extension (Life/Code/Knowledge ou nouvelle) dans MyProjectOS, avec tous les points de câblage et la vérification exécutée. À charger dès qu'on touche templates/, structures/, ou qu'on ajoute un fichier généré par init-project.sh.
---

# Ajouter ou modifier un template / une extension

Anatomie d'une extension (DEC-0001, « nature d'abord, rôle ensuite ») : sa description dans `structures/<x>-tree.md` + ses gabarits dans `templates/extensions/<x>/` + son câblage dans `scripts/init-project.sh` (+ flag `--<x>`). Le Core (`templates/core/`) n'est PAS une extension. [read: from DECISIONS.md DEC-0001]

## Quand NE PAS utiliser cette skill

- Décider SI le changement est souhaitable et le consigner → skill `evolve-method` (gate DEC/CHG/version) — à dérouler AVANT ce runbook.
- Vérification finale seule → skill `validate`.

## Runbook

### 1. Gabarit
- Créer/modifier le fichier dans `templates/core/` ou `templates/extensions/<x>/`.
- Utiliser le placeholder `<NomDuProjet>` là où init-project doit substituer le nom ; dates en `YYYY-MM-DD` uniquement (DEC-0016 : `check-project.sh` détecte les dates françaises).
- Frontmatter : suivre le modèle de `templates/core/PROGRESS.md` (bloc d'en-tête obligatoire).

### 2. Description d'arborescence
- Reporter dans `structures/<x>-tree.md` (ou `core-tree.md`).

### 3. Câblage script
- `scripts/init-project.sh` : ajouter la copie du gabarit (et le flag si nouvelle extension). Le script lit `VERSION` et substitue `version_methode` : ne pas casser cette mécanique.
- `scripts/check-project.sh` : ajouter le contrôle de présence du nouveau fichier pour le type de projet concerné.

### 4. Documentation et skill
- `skills/my-project-os/SKILL.md` : si le fichier change ce que l'assistant doit lire ou produire.
- `docs/` concernés (governance, lifecycle…) et `README.md` si la structure affichée change.

### 5. Vérification exécutée (obligatoire)
Dérouler la batterie complète de la skill `validate` (source unique de la procédure), en incluant dans les générations de test le flag de l'extension touchée. Ne pas improviser de batterie raccourcie : c'est `validate` qui fait foi. [verified: executed 2026-07-07 — batterie validée sur un projet de test Core+Code+Knowledge]

### 6. Consignation
- `CHG-` dans CHANGELOG.md ; DEC- si structurant ; bump VERSION si nouvelle capacité (skill `evolve-method`).
- PROGRESS.md + frontmatter.

## Pièges connus

- Les scripts ne sont PAS exécutables : `./scripts/init-project.sh` → `permission denied` (exit 126). Toujours `sh scripts/<script>.sh`. [verified: executed]
- Chemins en dur : le renommage `templates/extensions/` (DEC-0001) a exigé de réaligner script ET docs ; chercher les anciens chemins avant de conclure (`grep -rn "templates/" scripts/ docs/ skills/`).
- Ne PAS modifier `scripts/hooks/*` à la légère : 4 projets legacy les référencent à distance (piège DEC-0025, voir `evolve-method`).

## Provenance et maintenance

Rédigé le 2026-07-07 par audit complet du dépôt. Re-vérification : dérouler l'étape 5 — c'est le test de non-régression du runbook lui-même.
