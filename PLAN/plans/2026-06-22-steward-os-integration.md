# Plan d’évolution — Intégration Steward OS dans MyProjectOS / MyCompanyOS

**Date** : 2026-06-22  
**Statut** : Document de travail (working document)  
**Objectif** : Proposer une feuille de route chirurgicale pour faire évoluer MyProjectOS en intégrant des éléments pertinents de Steward OS, tout en conservant notre gouvernance existante.  
**Contexte** : Ce plan s’inscrit dans la lignée des audits précédents (SecondBrain, Tokenade, Hermes Dreaming, BWS) et vise à renforcer le pilier Ops / Code de MyProjectOS.

---

## 1. Analyse rapide de Steward OS

**Source** : Post @hermes_updates + site https://nesquena.github.io/steward-os/

**Ce que c’est** :
- Framework léger permettant à un agent Hermes de maintenir de manière autonome des projets open source complexes.
- Focus sur la gestion d’issues, PRs, releases à grande échelle (milliers d’issues/PRs, centaines de releases).
- Philosophie « simply feed your agent ».

**Points forts** :
- Très bon retour d’expérience réel avec Hermes.
- Approche agent-first.
- Volume et fiabilité démontrés.

**Limites pour nous** :
- Très orienté OSS / GitHub.
- Moins de gouvernance structurée (specs, décisions, traçabilité).
- Risque d’autonomie trop forte par rapport à notre règle « chirurgie + validation humaine ».

---

## 2. Positionnement par rapport à MyProjectOS

MyProjectOS est déjà un **Project Operating System** complet (Core + Extensions Life/Code/Ops/Knowledge + gouvernance forte).

Steward OS est plutôt un **mainteneur agentique** spécialisé.

**Conclusion** :  
Steward OS n’est **pas** un remplacement, mais une **source d’inspiration** pour renforcer le pilier **Ops** (maintenance automatisée) et potentiellement le pilier **Code**.

---

## 3. Plan d’évolution proposé (chirurgical)

### Lot 1 — Documentation & veille (immédiat)
- Ajout de ce plan dans `PLAN/plans/2026-06-22-steward-os-integration.md`.
- Mise à jour de `PROGRESS.md`.

### Lot 2 — Analyse approfondie de Steward OS
- Audit complet du repo (structure, prompts, garde-fous, intégration Hermes).
- Comparaison avec nos outils existants (Spec Kit, Harness, writing-plans, enforcement hooks).

### Lot 3 — Identification des éléments réutilisables
Possibles points d’intégration :
- Patterns de maintenance autonome d’issues/PRs (pilier Ops).
- Boucle de review explicite avant application de changements (proche de Hermes Dreaming).
- Gestion de « behavior history » portable entre forks (idée mentionnée dans les replies).
- Intégration possible avec notre skill `github-pr-workflow` et `github-issues`.

### Lot 4 — Design d’une extension « Steward-like » pour MyProjectOS
- Création d’un skill ou d’une extension Ops : `steward-maintenance`.
- Règles fortes de validation humaine avant tout merge/PR.
- Conservation de notre gouvernance (CLAUDE.md, DECISIONS.md, CHG).

### Lot 5 — Test sur un projet pilote
- Application sur un projet OSS ou sur MyProjectOS lui-même (dogfooding).
- Mesure : volume traité, qualité des propositions, respect des garde-fous.

### Lot 6 — Gouvernance & documentation
- Mise à jour de `docs/` et `kb_governance.md` si des patterns sont retenus.
- Ajout dans `ROADMAP.md` de MyProjectOS.

---

## 4. Fichiers potentiellement impactés

- `PLAN/plans/2026-06-22-steward-os-integration.md` (ce fichier)
- `PROGRESS.md` et `TASKS.md`
- `docs/` (éventuellement `docs/ops/` ou `docs/github-automation.md`)
- `skills/` (nouveau skill steward-maintenance si retenu)
- `ROADMAP.md`

---

## 5. Risques & points de vigilance

- Risque de dérive vers trop d’autonomie agentique.
- Risque de dilution de notre gouvernance structurée.
- Risque de complexité inutile si on intègre des éléments trop spécifiques à l’open source.

**Règle** : Toute intégration doit passer par un audit + validation explicite avant implémentation.

---

## 6. Décisions à prendre ultérieurement

1. Faut-il faire un audit complet de Steward OS maintenant ou attendre d’autres besoins ?
2. Priorité : pilier Ops ou pilier Code ?
3. Intégration directe ou création d’une extension « Steward-inspired » maison ?

---

**Fin du plan**

Document ajouté le 2026-06-22.  
Aucun commit, aucun push effectué. Prêt pour étude ultérieure.