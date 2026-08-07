# Veille outils upstream

> Suivi mensuel de l'évolution des deux outils dont dépend MyProjectOS :
> [github/spec-kit](https://github.com/github/spec-kit) et [Chachamaru127/claude-code-harness](https://github.com/Chachamaru127/claude-code-harness).
>
> Principe : la veille **propose**, elle n'intègre jamais seule. Chaque entrée liste ce qui a
> changé et donne un verdict pour chaque point : **à intégrer**, **à surveiller** ou **à ignorer**.
> Rapport le plus récent en haut. État de comparaison conservé dans `_etat-upstream.md`.

## 2026-08 — Harness v5 : redesign majeur ; Spec Kit : emprunts non affectés

### Harness — v4.13.3 → v5.5.0 (2026-06 à 2026-08-01)

Passage de version majeure (v4 → v5). Zero-base redesign en v5.0.0, puis consolidations jusqu'en v5.5.0.

**1. Version minimale Claude Code requise : 2.1.183+** — **à surveiller**
Le harness exige désormais Claude Code ≥ 2.1.183. Aucun impact direct sur MyProjectOS (on n'embarque pas Harness), mais repère utile pour tout projet Code qui voudrait l'adopter. Action : noter cette contrainte dans `docs/` si on documente l'adoption future.

**2. Verbe `/harness-plan` enrichi — co-génération `spec.md` + `Plans.md` + sections pre-approval** — **à surveiller**
Le plan est désormais bidirectionnel : contrat produit (`spec.md`) + tableau de tâches (`Plans.md`), avec déclaration upfront des opérations risquées. Action proposée : évaluer si le concept de « pré-approbation de tâches risquées » mérite un marquage explicite dans notre `TASKS.md` (ex. ligne `[VALIDATION HUMAINE REQUISE]`). À décider par l'humain.

**3. Nouvelles surfaces HTML** (scorecard orchestration, snapshot de progression, résumé merge/release) — **à surveiller**
Le harness expose des dashboards HTML read-only pour visualiser l'état du projet en cours. Concept à garder en tête si on envisage une couche de visualisation légère pour nos `PROGRESS.md`.

**4. Nouveaux garde-fous** — **à surveiller**
- R15 : blocage du staging de secrets (`.env`, `*.pem`, `id_rsa`) via hooks pre-commit
- Temp dir allowlist : `/tmp`, `$TMPDIR`, `~/.cache` exemptés des vérifications worktree-escape
- Floor PreToolUse : les vérifications de sécurité s'exécutent avant les policy guardrails
- Audit log : traçabilité des déclenchements de règles (IDs, catégories, commandes hachées)
Action : s'assurer que nos projets Code mentionnent dans `AGENTS.md` l'interdiction de commiter des secrets.

**5. Breaking change : `/reload-plugins` obligatoire à l'upgrade depuis v4.16.x** — **à ignorer**
On n'utilise pas directement Harness dans le système actuel.

**6. Multi-backend Work (Codex/Cursor) et dual-track Review** — **à ignorer**
Architecture multi-agent hors scope MyProjectOS mono-agent.

---

### Spec Kit — v0.9.0 → v0.15.1 (2026-06 à 2026-07-31)

**1. Format `constitution` : aucun changement détecté** — RAS
Nos emprunts (constitution, réflexe clarify) ne sont pas affectés par cette période de releases.

**2. Nouveau type d'artefact : workflow step catalogs** (v0.11.0) — **à surveiller**
Des catalogues d'étapes communautaires installables font leur apparition, proche du concept de nos skills MyProjectOS. À réévaluer si le catalogue s'étoffe ou si un emprunt de structure devient pertinent.

**3. Agent-native runtime hooks** (v0.15.0) — **à surveiller**
Les intégrations peuvent désormais déclarer des hooks exécutés par l'agent au runtime (premier support agent-natif). Concept intéressant pour enrichir notre `scripts/hooks/` à terme ; à suivre sur les prochains cycles.

**4. Sécurisation générale** (races TOCTOU, symlinks, UTF-8) — **à ignorer**
Corrections internes à Spec Kit sans impact sur nos artefacts Markdown empruntés.

---

## 2026-06 — Référence initiale

État de départ de la veille, aucune comparaison ce mois.

| Outil | Version | Dernier commit |
|---|---|---|
| Spec Kit | v0.9.0 (2026-06-01) | 258dd8e |
| Harness | v4.13.3 (2026-06-01) | 7f8279a |

Rôle de chacun dans le système (rappel) :
- **Harness** = colonne vertébrale Code (plan → work → review → release + garde-fous). On suit ses releases, ses garde-fous, ses surfaces HTML et la version minimale de Claude Code requise.
- **Spec Kit** = source d'idées empruntées en Markdown (constitution, réflexe clarify). On surveille surtout les changements de format de `constitution` et des artefacts, qui pourraient affecter nos emprunts.

Verdict : référence posée, rien à faire. Première comparaison réelle attendue au prochain passage mensuel.
