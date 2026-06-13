# AGENTS.md — <NomDuProjet>

> Instructions d'opération pour les agents (Claude Code, Hermès, futurs agents) sur ce projet Code.
> Complète les fichiers sacrés Core. À lire avant toute intervention sur le code.

## Comment travailler dans ce repo

- Explorer avant de coder. Lire le code existant plutôt qu'inventer l'architecture.
- Modifications chirurgicales : ne toucher que ce qui est strictement nécessaire.
- Respecter le style existant, même si on ferait autrement.

## Fichiers à lire au démarrage

1. Sacrés Core : `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md`.
2. Code : `CONSTITUTION.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`, ce fichier.
3. Avant toute modification : `IMPACT_ANALYSIS.md`.

## Règles à respecter

- Respecter `CONSTITUTION.md` : un plan ou une spec qui viole un principe est refusé, pas discuté.
- Exécution encadrée via Harness pour le parcours complet (`docs/harness.md` du repo méthode) ; lever les inconnues avant d'approuver un plan (réflexe clarify, `docs/clarify.md`).
- `STACK_VALIDATION.md` doit être validé avant la première ligne de code (voir gate dans `docs/stack-validation-gate.md` du repo méthode).
- Aucune modification sans passer par `IMPACT_ANALYSIS.md` (fichiers concernés, à ne pas toucher, risques, tests).
- Suivre les conventions de `ARCHITECTURE.md` et les recettes d'ajout de feature (kit de rails).
- Ne pas refactoriser au-delà de la demande. Ne pas créer d'abstraction pour un usage unique.

## Actions nécessitant validation humaine

- Changement de stack ou de version.
- Modification des zones marquées « à ne pas modifier » dans `ARCHITECTURE.md`.
- Suppression massive, réorganisation, déploiement, push important.

## Mise à jour de la documentation

- `PROGRESS.md` après toute avancée significative.
- `CHANGELOG.md` (`CHG-AAAAMMJJ-HHMM`) pour ce qui a changé.
- `DECISIONS.md` (`DEC-XXXX`) pour les choix structurants.
- `RELEASE.md` au moment de préparer une livraison.

## Git

- Ne jamais committer sans demande explicite.
- Messages en français, format `type: description` (feat, fix, refactor, chore, docs).
- Ne pas stager `.env` ni secrets.

## Nommage

Voir `docs/NAMING-CONVENTIONS.md` du repo méthode.
