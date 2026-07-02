## Extension Code

Ce projet a l'extension Code activée : instructions supplémentaires pour toute intervention sur le code, en complément des rituels Core décrits plus haut dans ce fichier.

### Comment travailler dans ce repo

- Explorer avant de coder. Lire le code existant plutôt qu'inventer l'architecture.
- Modifications chirurgicales : ne toucher que ce qui est strictement nécessaire.
- Respecter le style existant, même si on ferait autrement.

### Fichiers à lire en plus, avant toute intervention sur le code

- `CONSTITUTION.md`, `STACK_VALIDATION.md`, `ARCHITECTURE.md`, `SPECS.md`.
- Avant toute modification : `IMPACT_ANALYSIS.md`.

### Règles à respecter

- Respecter `CONSTITUTION.md` : un plan ou une spec qui viole un principe est refusé, pas discuté.
- Exécution encadrée via Harness pour le parcours complet (`docs/harness.md` du repo méthode) ; lever les inconnues avant d'approuver un plan (réflexe clarify, `docs/clarify.md`).
- `STACK_VALIDATION.md` doit être validé avant la première ligne de code (voir gate dans `docs/stack-validation-gate.md` du repo méthode).
- Aucune modification sans passer par `IMPACT_ANALYSIS.md` (fichiers concernés, à ne pas toucher, risques, tests).
- Suivre les conventions de `ARCHITECTURE.md` et les recettes d'ajout de feature (kit de rails).

### Validation humaine supplémentaire

- Changement de stack ou de version.
- Modification des zones marquées « à ne pas modifier » dans `ARCHITECTURE.md`.

### Mise à jour de la documentation

- `RELEASE.md` au moment de préparer une livraison.
