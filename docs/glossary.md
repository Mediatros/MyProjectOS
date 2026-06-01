# Glossaire — Project OS AI

Vocabulaire commun du système. Une définition par terme.

- **Project OS** : la méthode d'organisation de projets assistée par IA décrite dans ce repository.
- **Core** : le socle commun à tous les projets (cinq fichiers sacrés, dossiers numérotés, gouvernance).
- **Extension Life** : ajout pour les projets personnels, administratifs ou juridiques (preuves, échéances, correspondances).
- **Extension Code** : ajout pour les projets logiciels (stack, architecture, specs, tests, impact, release).
- **Type de projet** : Life, Code ou Hybrid, déclaré dans `PROJECT.md`. Détermine les extensions activées.
- **Hybrid** : type activant simultanément les extensions Life et Code.
- **Fichiers sacrés** : les cinq fichiers Core obligatoires (`PROJECT.md`, `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md`, `DECISIONS.md`).
- **Reprise à froid** : capacité à reprendre un projet sans aucun historique de conversation, à partir des seuls fichiers.
- **Bloc d'en-tête** : front-matter YAML en tête de `PROGRESS.md`, lisible par machine, tenu à jour à chaque modification.
- **CHG-AAAAMMJJ-HHMM** : identifiant d'une entrée datée du `CHANGELOG.md`.
- **DEC-XXXX** : identifiant d'une décision structurante du `DECISIONS.md`.
- **P-XXXX** : identifiant d'une preuve du `PREUVES.md` (Life), reliant une affirmation à un document source.
- **Tx.y** : identifiant d'une tâche du `TASKS.md` (phase.tâche).
- **Gate STACK_VALIDATION** : contrôle de compatibilité de stack, sourcé, obligatoire avant tout code (extension Code).
- **Kit de rails** : ensemble de conventions, règles agent et recettes propre à un type de stack, qui fait coder l'IA « comme un senior » (extension Code).
- **Claude Code** : agent IA opérant les projets côté Mac.
- **Hermès** : agent IA autonome (Nous Research) opérant les projets côté VPS.
- **Skill assistant** : la skill centrale qui pilote les rituels (reprise, orientation, explication, clôture).
- **Hook** : mécanisme déterministe du harness qui rend une règle non négociable automatique.
