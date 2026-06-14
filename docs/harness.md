# Harness — colonne vertébrale du volet Code

> Comment Project OS exécute le travail de codage encadré. Harness est le moteur ; Project OS fournit les fichiers sacrés, la gouvernance et les emprunts (constitution, réflexe clarify).
> Faits vérifiés le 2026-06-01 sur le dépôt upstream. La routine de veille (`docs/veille/`) suit leur évolution.

## Pourquoi Harness

Le volet Code a besoin d'une exécution encadrée (couche 2 du `docs/kit-de-rails.md`) : conduite du codage avec garde-fous, pas du « vibe coding ». On retient **Claude Code Harness** (Chachamaru127, MIT) plutôt que de recoudre plusieurs outils :

- il suit Claude Code (chemin supporté en v2.1+) ;
- ses garde-fous sont déterministes et natifs (moteur Go, pas de Node) ;
- il expose des surfaces lisibles par un non-développeur ;
- un seul outil exécuté, aucune couture entre deux moteurs.

À Spec Kit, on n'emprunte que deux pièces, sous forme de documents Markdown figés : la **constitution** (principes du projet, `templates/extensions/code/CONSTITUTION.md`) et le **réflexe clarify** (`docs/clarify.md`). On ne fait pas tourner deux moteurs.

## Prérequis

- Claude Code v2.1+ (chemin Claude supporté).
- Un dépôt de projet avec accès en écriture.
- Pas de Node.js (moteur Go natif).
- Optionnel : `harness-mem` pour la mémoire inter-session.

## Installation

Dans Claude Code, à la racine du projet :

```
/plugin marketplace add Chachamaru127/claude-code-harness
/plugin install claude-code-harness@claude-code-harness-marketplace
/harness-setup
```

`/harness-setup` installe la guidance projet, les surfaces, les hooks et les checks de Harness. À faire **après** `scripts/init-project.sh` (qui pose les fichiers sacrés et les hooks Project OS) : Harness se branche sur un projet déjà structuré.

## Les cinq verbes

| Verbe | Rôle |
|---|---|
| `/harness-setup` | Installe guidance, surfaces, hooks, checks dans le projet. |
| `/harness-plan` | Génère `spec.md` et `Plans.md` : périmètre, critères, inconnues. |
| `/harness-work` | Exécute les tâches approuvées (TDD, vérification). |
| `/harness-review` | Revue indépendante, séparée de l'implémentation. |
| `/harness-release` | Valide la préparation, le packaging, les preuves. |

Cycle de fond : **Plan → Work → Review → Release**. L'utilisateur approuve les contrats générés (`spec.md`, `Plans.md`) **avant** exécution, au lieu de tout écrire à la main en amont. C'est le point d'insertion du réflexe clarify : lever les inconnues avant d'approuver.

## Artefacts générés

- `spec.md` : périmètre, critères d'acceptation, inconnues, conditions d'arrêt.
- `Plans.md` : plan d'exécution, tâches approuvées.
- sortie de vérification et preuves de tests ;
- paquets de preuves PR / release.

## Correspondance avec les fichiers sacrés (T5.3)

Harness produit des artefacts de travail ; les fichiers sacrés Project OS restent la **source de vérité pour la reprise à froid** (principe 7). Règle : ce qui compte pour reprendre le projet doit avoir été reporté dans les fichiers sacrés, pas seulement dans les artefacts Harness. Application directe du principe 6 (« une information, un seul endroit ») : on ne duplique pas, on relie.

| Artefact / phase Harness | Fichier sacré Project OS | Relation |
|---|---|---|
| `spec.md` (périmètre, critères, inconnues) | `SPECS.md` (`F-XXX`) + `05_specs/` | `SPECS.md` catalogue la feature et la relie par `F-XXX` ; `spec.md` en est le détail de travail (déporté dans `05_specs/`). |
| `Plans.md` (tâches approuvées) | `TASKS.md` (`Tx.y`) | Les tâches approuvées se reportent dans `TASKS.md`, checklist de référence du projet. |
| `/harness-work` (avancement, preuves) | `PROGRESS.md` + `CHANGELOG.md` | État courant → `PROGRESS.md` ; changement daté → `CHANGELOG.md` (`CHG-YYYYMMDD-HHMM`). |
| `/harness-review` | `TEST_PLAN.md` + `IMPACT_ANALYSIS.md` (`IA-XXX`) | La revue alimente le plan de test et l'analyse d'impact. |
| `/harness-release` (readiness, evidence) | `RELEASE.md` | Les preuves de livraison se consignent dans `RELEASE.md`. |

Frontière : `spec.md` détaille **une** feature en cours ; `SPECS.md` est le catalogue figé des fonctionnalités. `Plans.md` est le plan d'un lot courant ; `TASKS.md` est la checklist durable du projet. En cas de divergence, le fichier sacré fait foi pour la reprise.

## Quand utiliser Harness : complet vs allégé

Harness sert le **parcours complet** de l'aiguillage Code (`agents/meta-skill.md`). Pour le **parcours allégé** (correctif, petite feature suivant une recette du kit de rails), on peut rester sur `IMPACT_ANALYSIS.md` + la recette sans dérouler tout le cycle Harness.

| | Allégé | Complet |
|---|---|---|
| Amont | `IMPACT_ANALYSIS.md` (`IA-XXX`) | `/harness-plan` → clarify → `spec.md` / `SPECS.md` |
| Gate stack | Si nouvelle techno seulement | `STACK_VALIDATION.md` validé avant la 1re ligne de code |
| Exécution | Recette du kit de rails | `/harness-work` |
| Validation | Tests + gate du kit | `/harness-review` puis `/harness-release` |

En cas de doute sur l'ampleur : parcours complet. Le gate `STACK_VALIDATION` (`docs/stack-validation-gate.md`) et la validation humaine sur les actions sensibles (principe 8) restent prioritaires quel que soit le parcours.

## Préséance des garde-fous

Harness apporte ses propres hooks et checks. Ils s'ajoutent aux hooks Project OS (`docs/enforcement.md`), ils ne les remplacent pas. Les non-négociables Project OS (fraîcheur PROGRESS, nommage, placement) restent tenus par les hooks du repo méthode.

## Voir aussi

- `templates/extensions/code/CONSTITUTION.md` — principes du projet (emprunt Spec Kit), lus par l'agent et Harness.
- `docs/clarify.md` — le réflexe de levée d'ambiguïté avant d'approuver un plan.
- `docs/kit-de-rails.md` — architecture Agent First, recettes d'ajout de feature.
- `docs/stack-validation-gate.md` — gate de compatibilité avant tout code.
- `docs/veille/` — suivi mensuel de l'évolution de Harness et Spec Kit.
