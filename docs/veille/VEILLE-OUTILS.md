# Veille outils upstream

> Suivi mensuel de l'évolution des deux outils dont dépend Project OS AI :
> [github/spec-kit](https://github.com/github/spec-kit) et [Chachamaru127/claude-code-harness](https://github.com/Chachamaru127/claude-code-harness).
>
> Principe : la veille **propose**, elle n'intègre jamais seule. Chaque entrée liste ce qui a
> changé et donne un verdict pour chaque point : **à intégrer**, **à surveiller** ou **à ignorer**.
> Rapport le plus récent en haut. État de comparaison conservé dans `_etat-upstream.md`.

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
