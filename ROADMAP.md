# ROADMAP — MyProjectOS

Étapes de construction et éléments reportés. Le plan détaillé et cochable vit dans `TASKS.md`.

## Construction (phases)

- **Phase 1 — Squelette + templates Core.** Arborescence, README, ROADMAP, templates Core, conventions de nommage, docs de gouvernance, structure Core.
- **Phase 2 — Extensions Life et Code.** Templates et structures des deux extensions, gate `STACK_VALIDATION`, concept de « kit de rails ».
- **Phase 3 — Skill assistant.** Le cœur : modes reprise / orientation / explication / clôture, initialisation de projet, fichiers `agents/`.
- **Phase 4 — Enforcement (hooks) + script d'init.** Rendre les règles non négociables automatiques. `scripts/init-project.sh`.
- **Phase 5 — Intégration Harness + emprunts Spec Kit.** Colonne vertébrale Code, constitution et réflexe clarify en Markdown.
- **Phase 6 — Banc d'essai sur un projet Code réel.** Valider la méthode sur un vrai projet, ajuster.

## Reporté

### Intégrations MCP

Relier les fichiers Markdown aux connecteurs de l'environnement, une fois le Core stabilisé :

- `ECHEANCES.md` ↔ **Google Calendar**.
- `CORRESPONDANCES.md` ↔ **Gmail**.
- Documents ↔ **Google Drive**.

Reporté volontairement : priorité au socle Markdown manuel d'abord.

### Portabilité vers Hermès

Hermès (Nous Research) est un agent autonome, pas Claude Code : il n'exécute pas le harness, il consomme les fichiers Markdown. Il supporte MCP et `agentskills.io`. Le format de la skill assistant est déjà partagé (`98_configuration/skills/`, DEC-0052), et son **offre** à Hermès une fois déclarée en `skills.external_dirs` est vérifiée par exécution (T-PLAN-14 lot 4, 2026-09-13). La portabilité des garde-fous se réduit désormais aux hooks Claude Code, qu'Hermès n'exécute pas et n'exécutera pas sans l'une des deux pistes ci-dessus (MCP partagé ou double skill).

### Outils complémentaires

- **Index global multi-projets** : `INDEX.md` à la racine du dossier de projets, régénérable par script à partir des `PROGRESS.md`.
- **Script de vérification** (`scripts/check-project.sh`) : signale fichiers sacrés manquants, mises à jour anciennes, références cassées. Alerte sans bloquer.

## Veille

Une veille mensuelle automatique (routine Claude Code, 1er du mois) compare l'état des outils amont (Spec Kit, Claude Code Harness) à un état mémorisé et écrit un rapport dans `docs/veille/VEILLE-OUTILS.md`. Elle propose, n'intègre jamais seule.
