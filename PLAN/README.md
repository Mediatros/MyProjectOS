# PLAN — plans d'évolution

> Zone isolée pour les plans d'évolution du système MyProjectOS.

## Rôle

`PLAN/` contient les plans et documents de travail avant intégration dans le système principal.

Cette zone sert à :

- documenter les inspirations externes ;
- formuler les décisions candidates ;
- préparer les lots d'intégration ;
- conserver les handoffs et plans structurants hors de la documentation stable ;
- garder les plans séparés de la documentation stable ;
- éviter de polluer `docs/` avec des documents de travail.

## Statut des documents

Un document dans `PLAN/plans/` est un **plan de travail**, pas une décision appliquée.

Une évolution devient officielle seulement quand :

1. la décision est validée ;
2. les fichiers stables sont modifiés ;
3. les vérifications sont exécutées ;
4. `PROGRESS.md` / `TASKS.md` sont mis à jour ;
5. le changement est commit et poussé.

## Structure

```text
PLAN/
├── README.md
├── HANDOFF.md
├── PLAN_PROJECT_OS_AI.md
├── PLAN_PROPOSITION_AMELIORATION.md
└── plans/
    └── YYYY-MM-DD-sujet.md
```

## Documents structurants

- `HANDOFF.md` — base de travail initiale.
- `PLAN_PROJECT_OS_AI.md` — plan de construction du système.
- `PLAN_PROPOSITION_AMELIORATION.md` — analyse et propositions d'amélioration.
- `hermes-workdoc-2026-06-03-orientation-project-os-ai.md` — document de travail Hermes/l'utilisateur (analyse initiale du repo, orientations Core + extensions activables, piste d'extension Ops non tranchée). Non intégré : à relire lors de l'arbitrage C.11.

## Plans disponibles

- `plans/2026-07-12-blue-brique-complete-skill-agnostique.md` — faire de la brique Blue une brique complète : skill technique portable (`templates/skills/blue-app/`, standard agentskills.io, installable par Claude Code / Codex / Hermès), couche secrets multi-backend (trousseau macOS, Bitwarden `bws`, fichier 600 VPS, variables d'env), registre d'équipement dans `GOUVERNANCE_BLUE.md`, entrée de handoff « Équiper un agent », workflow commentaires (pilotage humain → agent depuis une carte Blue). Englobe et amende T-PLAN-2 et T-PLAN-3 (referme leur point 5.4 : query `templates` et mutation `convertWorkspaceToTemplate` vérifiées en live). Statut : proposition, décisions D1-D5 tranchées le 2026-07-12, implémentation à lancer (T-PLAN-4).
- `plans/2026-07-12-blue-cli-extension-graphql.md` — étendre la skill globale `blue-cli` avec un wrapper GraphQL (`blue-gql.sh`) pour couvrir ce que la CLI n'expose pas : wiki/documents, formulaires, discussions, chat, upload de fichiers, status updates. Constat vérifié par tests réels (même token, 128 queries / 304 mutations). Statut : proposition à valider (T-PLAN-2). Impact méthode différé : enrichir `GOUVERNANCE_BLUE.md` après application.
- `plans/2026-07-06-plan-amelioration-production-ready.md` — revue complète (local + GitHub) et plan en 4 phases (D : mise à jour sécurisée de la méthode, E : cadrage guidé + cycle itératif, F : adoption d'un projet existant, G : qualité production). **Appliqué le 2026-07-07 (v0.5.0, CHG-20260707-1100), sauf T-B.7 et T-C.11.**
- `plans/2026-07-02-audit-industrialisation-methode.md` — audit complet du repository et plan en 3 phases (A : rendre l'installation réelle, B : méthode 2 + mise à jour, C : navigation 3 niveaux + qualité) pour un usage déployable en production. Phase A terminée ; B et C repris par le plan du 2026-07-06.
- `plans/2026-06-22-secondbrain-pkb-integration.md` — analyse du repo SecondBrain (PKB) et proposition d'intégration chirurgicale. Statut à trancher (voir plan d'audit, tâche C.11).
- `plans/2026-06-22-steward-os-integration.md` — analyse de Steward OS (gestion autonome d'issues/PRs par un agent Hermès) et proposition d'intégration. Statut à trancher (voir plan d'audit, tâche C.11).
- `plans/2026-06-07-company-os-integration.md` — intégrer les apports Company OS : documentation comme interface IA, température contextuelle, maturité de l'information, isolation des contextes. Statut à trancher (voir plan d'audit, tâche C.11).
