# PLAN — plans d'évolution

> Zone isolée pour les plans d'évolution du système Project OS AI.

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

## Plans disponibles

- `plans/2026-06-07-company-os-integration.md` — intégrer les apports Company OS : documentation comme interface IA, température contextuelle, maturité de l'information, isolation des contextes.
