# Plan d'intégration — Extension Knowledge v2 (hiérarchie documentaire à 4 niveaux)

> **Statut :** document de travail — aucune intégration appliquée
> **Date :** 2026-08-04
> **Zone :** `PLAN/plans/`
> **Source d'inspiration :** proposition Hermes (VPS), fiche `docs/governance/classement-donnees.md` (`/root`), issue de `CHG-20260804-0030`
> **Repo cible :** `https://github.com/Mediatros/MyProjectOS`
> **Objectif :** faire converger, par échange avec l'utilisateur, une formulation aboutie d'une hiérarchie documentaire à 4 niveaux (N1-N4) destinée à remplacer ou faire évoluer l'extension Knowledge actuelle (N1/N2/N3, `docs/kb_governance.md`).

---

## 1. Résumé décisionnel

Aucune décision prise. Ce document sert de point de départ à la discussion, pas de spécification figée.

L'utilisateur juge la formulation proposée par Hermes « plus claire et plus structurée » que ce qui existait déjà dans MyProjectOS sur un sujet similaire (principe 10 « Contexte progressif », extension Knowledge N1/N2/N3). L'intention est de faire mûrir cette formulation jusqu'à une version utilisable dans MyProjectOS, puis de la comparer explicitement à l'extension Knowledge existante avant toute décision d'adoption.

---

## 2. Ce qui existe déjà dans MyProjectOS

| Élément | Contenu actuel |
|---|---|
| `docs/principles.md` (principe 10) | « Contexte progressif » : un agent commence par les fichiers sacrés et les index, descend dans les niveaux documentaires seulement si le besoin l'exige. |
| Extension Knowledge (`templates/extensions/knowledge/docs/kb_governance.md`) | 3 niveaux documentaires : niveau 1 `01_global/` (vision globale, ~200 lignes max), niveau 2 `02_domains/` (domaines/composants, ~300 lignes max), niveau 3 `03_details/` (détails techniques, libre). Pas de niveau d'archive formalisé. |
| `docs/governance.md` | Renvoie vers `kb_governance.md` pour les niveaux, la navigation, le frontmatter, les budgets de taille et les règles anti-dérive. |
| `docs/NAMING-CONVENTIONS.md` | Convention de nommage niveaux 2↔3. |

Aucun niveau d'archive (« froid ») n'existe formellement dans l'extension Knowledge actuelle ; les éléments obsolètes vont dans `99_archive/` au niveau racine du projet, sans lien structurel avec le niveau 3.

---

## 3. Proposition Hermes (point de départ de la discussion)

Résumé de la fiche partagée par l'utilisateur (`docs/governance/classement-donnees.md`, VPS Hermes) :

- **4 étages** : N1 Macro (constitution, toujours chargée), N2 Méso (thématique, à la demande), N3 Micro (fiche vivante par sujet, à la demande), N4 Archives (jamais par défaut, uniquement sur demande explicite).
- **Métaphore de température** : N1 chaud (boot), N2 chaud au besoin (orientation), N3 tiède (détail), N4 froid (archive) — empruntée à « Company OS ».
- **Budgets** : N1 ~150-200 lignes, N2 ~500 lignes max par doc (au-delà → créer une fiche N3), N3 sans limite fixe tant que vivant, N4 mémoire froide.
- **Règle de nommage N3 figée (Option A)** : `docs/<domaine>/<sujet>.md`, où `<domaine>` reprend exactement le nom du fichier N2 parent sans `.md`. Pas de dossier générique type `docs/detail/`. Pas de préfixe `detail-*`/`fiche-*`/`n3-*` dans le nom du sujet — kebab-case pur.
- **En-tête obligatoire** de toute fiche N3 : Niveau, Parent N2, MAJ.
- **Règles de circulation** : descente N2→N3 au-delà du budget, montée N3→N4 quand un sujet devient historique, MAJ N1 seulement si invariant ou état runtime change, jamais deux sources du même fait, changelog systématique, rollback documentaire, renommage N3 en miroir du renommage N2 dans le même CHG.
- **Cycle de vie** : `input brut → N2 (structuration) → N3 (vivant) → N4 (froid)`, sans retour N4 → actif sans reconstruction explicite.

---

## 4. Écarts et questions ouvertes entre les deux systèmes

| Sujet | Extension Knowledge (actuelle) | Proposition Hermes (N1-N4) | Question à trancher |
|---|---|---|---|
| Nombre de niveaux actifs | 3 (niveaux 1/2/3) | 3 actifs (N1/N2/N3) + 1 archive (N4) | L'archive doit-elle devenir un niveau formel de l'extension Knowledge, ou rester `99_archive/` racine ? |
| Niveau 1 | Vision globale du domaine (`01_global/`) | Constitution partagée (`CLAUDE.md`/`AGENTS.md`), au sens fichier sacré Core, pas Knowledge | Le N1 Hermes correspond-il au Core MyProjectOS (PROJECT/PROGRESS/AGENTS) ou à un nouveau niveau 0 de l'extension Knowledge ? |
| Nommage N3 | Libre, scindé par sujet si besoin (`<domaine>--<sujet>.md`) | Sous-dossier miroir strict du nom du fichier N2 parent (`docs/<parent-sans-.md>/<sujet>.md`) | Adopter la règle de nommage Option A à la place de la convention `--` actuelle ? Impact sur les projets déjà équipés. |
| Métaphore | Aucune | Température (chaud/tiède/froid), empruntée à Company OS | Garder la métaphore dans la doc utilisateur (non-développeur) ou la réserver au vocabulaire interne agent ? |
| Budgets de taille | 200/300 lignes (N1/N2) | 150-200/500 lignes (N1/N2) | Aligner les seuils ou les garder distincts selon le contexte (VPS Hermes vs projet MyProjectOS) ? |
| Portée du N1 | Par domaine Knowledge | Unique, unique fichier constitution par instance | Cohérence à vérifier avec le principe « une information, un seul endroit ». |
| Enforcement | `check-project.sh` (budgets, orphelins, liens cassés) | Aucun outil déterministe mentionné, seulement des règles déclaratives | Faut-il un contrôle automatique (hook/check) pour les règles de circulation et le nommage N3 miroir ? |

---

## 5. Prochaine étape

Échanger avec l'utilisateur point par point sur la section 4 jusqu'à une formulation stabilisée, avant de lancer le comparatif formel avec l'extension Knowledge existante et d'envisager une intégration (`add-extension`, bump de version, propagation `--update-method`).

Aucune modification de `templates/extensions/knowledge/`, `docs/kb_governance.md`, `docs/principles.md` ou `docs/NAMING-CONVENTIONS.md` tant que ce plan n'est pas arbitré.
