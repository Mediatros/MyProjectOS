# Plan d'évolution — Industrialiser MyProjectOS (audit complet)

> **Statut :** plan de travail, non appliqué
> **Date :** 2026-07-02
> **Zone :** `PLAN/plans/`
> **Origine :** audit complet du repository (structure, docs, templates, scripts, hooks, skill, RETEX) mené à la demande de l'utilisateur, en vue d'un usage déployable en production / en entreprise, prioritairement Claude Code puis Codex puis Hermès.

---

## 1. Objectif du plan

Faire passer MyProjectOS du stade « bon prototype personnel, dogfoodé sur un seul repo » au stade « méthode installable et fiable, par un agent, sur n'importe quel projet neuf ou existant, avec auto-entretien de la gouvernance ».

Trois angles couverts, dans l'ordre où l'utilisateur les a posés :

1. **Installation par un agent** — un lien de repo suffit, que le projet soit vierge (méthode 1) ou déjà peuplé et « bordélique » (méthode 2), pour Claude Code d'abord, Codex ensuite, Hermès enfin.
2. **Navigation à trois niveaux** — un agent charge le niveau 1 par défaut, descend au niveau 2 puis 3 seulement si le besoin l'exige, sans jamais charger un niveau entier par erreur.
3. **Gouvernance auto-entretenue** — la méthode se vérifie elle-même, détecte sa propre dérive et ses propres mises à jour, avec des points de contrôle humains prévus plutôt que subis.

## 2. Constat de départ (résumé de l'audit)

- Le dépôt GitHub `Mediatros/MyProjectOS` est **privé** (404 en accès anonyme) : le scénario « je donne le lien à mon agent » est cassé aujourd'hui.
- `install.sh` et les dernières évolutions d'`init-project.sh` (`--into-existing`, `--sync`) ainsi que le README associé sont **non commités** : même en rendant le repo public, la version en ligne n'a pas ces fonctionnalités.
- La **skill n'est jamais installée** dans le projet cible par `init-project.sh` ; aucun `AGENTS.md`/`CLAUDE.md` n'est posé pour les types Core et Life. Un projet fraîchement créé n'a donc aucune instruction pour l'agent qui l'ouvre.
- La **méthode 2 (adoption d'un projet existant désordonné)** n'existe pas : `--into-existing` est une greffe passive (ne pose que les fichiers manquants), pas un audit-puis-réorganisation.
- La **navigation à trois niveaux** repose sur une convention documentée mais non outillée : pas de frontmatter standard par document, pas de lien de nommage niveau 2 ↔ niveau 3, pas de détection d'orphelins, pas de budget de taille par niveau.
- **Pas de mécanisme de détection de mise à jour de la méthode** dans un projet déjà créé (le check compare à une copie locale du repo, jamais à la version distante).
- Le repo méthode **ne respecte pas sa propre gouvernance** : pas de `PROJECT.md` racine, `PROGRESS.md` transformé en journal et périmé, `examples/` vide, docs internes en retard sur le code (`enforcement.md`, `lifecycle.md`, `governance.md`).
- Pas de `LICENSE`.
- Le RETEX comptabilité (`RETEX/retex-projet-comptabilite.md`) contient des évolutions déjà validées sur le terrain (`SUJETS.md`, source fraîche prioritaire, section skills multi-agents) qui ne sont pas encore intégrées à la méthode générique.
- Trois plans en attente (`PLAN/plans/2026-06-07-company-os-integration.md`, `2026-06-22-secondbrain-pkb-integration.md`, `2026-06-22-steward-os-integration.md`) ne sont référencés dans aucune tâche active.

## 3. Phasage

Trois phases, dans l'ordre de dépendance : rien dans la phase B ou C n'a de sens tant que la phase A n'est pas faite (un projet ne peut pas s'auto-mettre-à-jour depuis un repo qu'il ne peut pas atteindre).

---

### Phase A — Rendre la promesse vraie (bloquant, à faire en premier)

But : qu'un agent qui reçoit le lien du repo puisse réellement installer la méthode, sur un projet vierge, pour Claude Code au minimum.

| ID | Tâche | Détail | Effort |
|---|---|---|---|
| A.1 | Committer l'état actuel | `install.sh`, `scripts/init-project.sh` (`--into-existing`, `--sync`), `README.md` mis à jour. Ranger ou trancher le sort de `anatomy.md` et de `docs/hermes-workdoc-2026-06-03-orientation-project-os-ai.md` (non suivis). | Faible |
| A.2 | Publier le dépôt | Rendre `Mediatros/MyProjectOS` public, ou documenter explicitement un accès authentifié si le choix est de rester privé. Décision humaine requise (visibilité d'un repo). | Faible (décision) |
| A.3 | Ajouter une `LICENSE` | Nécessaire pour tout usage entreprise ou partage. Choix à trancher (MIT cohérent avec les outils empruntés : Harness, Spec Kit). | Faible (décision) |
| A.4 | Installer la skill à la création du projet | `init-project.sh` doit copier `skills/my-project-os/SKILL.md` dans le projet (`.claude/skills/my-project-os/SKILL.md`), pas seulement les hooks. | Moyen |
| A.5 | Générer un fichier d'instructions agent racine pour tous les types | Aujourd'hui seul le type Code reçoit `AGENTS.md`. Poser un `AGENTS.md` racine (rituels de session, ordre de lecture, garde-fous, frontière fichiers sacrés) pour Core/Life/Hybrid aussi, et faire pointer un `CLAUDE.md` projet minimal vers lui. Un seul contenu source, lisible nativement par Codex (qui lit `AGENTS.md`) et par Claude Code (`CLAUDE.md` qui référence). | Moyen |
| A.6 | Rendre le projet créé auto-vérifiable | Copier `check-project.sh` et le fichier `VERSION` (valeur figée au moment de la création) dans le projet cible, puisque le repo méthode peut avoir disparu après un `install.sh` en mode jetable. | Moyen |
| A.7 | Mettre le repo méthode en conformité avec sa propre gouvernance | Créer `PROJECT.md` racine ; dégraisser `PROGRESS.md` (retirer l'historique chronologique, le renvoyer vers `CHANGELOG.md`) et le remettre à jour ; réaligner `docs/enforcement.md`, `docs/lifecycle.md`, `docs/governance.md` sur le comportement réel des scripts. | Moyen |
| A.8 | Bump de version | Faire passer `VERSION` à `0.3.0` (évolution mineure : nouvelles capacités, rien ne casse), entrée `CHANGELOG.md`, tag `v0.3.0`. | Faible |

Critère de sortie de phase A : depuis une machine vierge, `curl ... | sh -s -- ~/TestProjet --life` pose un projet qui contient les fichiers sacrés, la skill, `AGENTS.md`, les hooks, `check-project.sh` et une empreinte de version — sans avoir besoin d'accéder au repo `MyProjectOS` par la suite.

---

### Phase B — Méthode 2 (adoption d'un projet existant) et mise à jour de la méthode

But : couvrir le scénario « mon projet dérive, je veux appliquer la méthode dessus », et boucler la mise à jour (un projet créé sait qu'une nouvelle version de la méthode existe).

| ID | Tâche | Détail | Effort |
|---|---|---|---|
| B.1 | Écrire le protocole d'adoption | `docs/INSTALL-AGENT.md` (ou `ADOPTION.md`) : point d'entrée unique adressé à l'agent, pas à l'humain. Contient la branche de décision : dossier vierge → méthode 1 ; dossier peuplé → méthode 2. Référencé en tête du README. | Moyen |
| B.2 | Définir la méthode 2 pas à pas | Inventaire de l'existant (arborescence, fichiers, taille), classification (quoi ressemble à quel fichier sacré / quel dossier numéroté), proposition de mapping présentée à l'humain, **validation humaine obligatoire avant toute réorganisation** (déjà une action sensible au sens de `docs/governance.md`), exécution, rapport de migration. | Élevé |
| B.3 | Remplissage assisté des fichiers sacrés | En méthode 2, `PROJECT.md` et `PROGRESS.md` ne doivent pas rester en gabarit : l'agent doit les pré-remplir à partir des traces trouvées (README existant, commits, structure) puis les soumettre à relecture humaine. | Moyen |
| B.4 | Ajouter le mode « adoption » à la skill | `skills/my-project-os/SKILL.md` : cinquième mode, déclenché quand un dossier ne contient pas `PROJECT.md` mais contient déjà du contenu. | Faible (une fois B.1/B.2 écrits) |
| B.5 | Script de vérification de version distante | `check-update.sh` (ou extension de `check-project.sh`) : compare `version_methode` du projet à la dernière version publiée sur GitHub (`raw.githubusercontent.com/.../VERSION`), lit le `CHANGELOG.md` distant pour lister ce qui a changé depuis, propose sans jamais appliquer seul. | Moyen |
| B.6 | Runbook de migration de version | `docs/versioning.md` renvoie aujourd'hui vers « décision humaine » sans procédure. Écrire les étapes concrètes (vérifier l'écart, relancer `init-project.sh --into-existing --sync`, corriger les conflits, mettre à jour l'empreinte). | Faible |
| B.7 | Mode « revue documentaire » périodique | Sixième mode de la skill (ou routine dédiée) : présente à l'utilisateur un état condensé (sorties de `check-project.sh`, écarts INDEX/disque, sujets détectés) et pose des questions fermées de confirmation, sur le modèle décrit par l'utilisateur (« confirmes-tu ces 5 sujets ? »). Déclenchable à la main, ou en routine mensuelle aux côtés de la veille outils existante. | Moyen |

Critère de sortie de phase B : un projet réel non structuré peut être audité puis réorganisé par l'agent avec validation humaine à chaque étape sensible ; un projet déjà sous MyProjectOS peut détecter seul qu'une version plus récente existe et se faire proposer une migration.

---

### Phase C — Navigation à trois niveaux, RETEX et qualité générale

But : que la navigation progressive (niveau 1 → 2 → 3) soit réellement fiable et outillée, intégrer les retours terrain, et remettre le repo à niveau de qualité industrielle.

| ID | Tâche | Détail | Effort |
|---|---|---|---|
| C.1 | Frontmatter standard des documents Knowledge | Chaque fichier de `01_global/`, `02_domains/`, `03_details/` porte : niveau, domaine parent, dépendances amont/aval, résumé une ligne, dernière mise à jour. Permet à l'agent de savoir depuis le niveau 1 ce qu'il trouvera en descendant, sans charger le contenu. | Moyen |
| C.2 | Convention de nommage liant les niveaux | Lien explicite entre un document de domaine et ses détails (ex. `02_domains/facturation.md` ↔ `03_details/facturation--*.md`, ou sous-dossiers par domaine dans `03_details/`). À trancher et documenter dans `docs/NAMING-CONVENTIONS.md`. | Faible (décision) + Moyen (application) |
| C.3 | Budgets de taille par niveau | Fixer des seuils indicatifs (ex. niveau 1 global ≤ 200 lignes cumulées, un document de domaine ≤ 300 lignes) au-delà desquels on scinde vers le niveau inférieur. Ajouter le contrôle à `check-project.sh` en avertissement. | Faible |
| C.4 | Détection d'orphelins et de liens cassés dans `INDEX.md` | `check-project.sh` : signaler un fichier Knowledge présent sur disque mais absent de `docs/INDEX.md`, et une entrée d'`INDEX.md` pointant vers un fichier disparu. | Moyen |
| C.5 | Intégrer le RETEX comptabilité | Template `SUJETS.md` (routeur lexical : alias utilisateur → sujet canonique → ordre de lecture → source fraîche prioritaire → dépendances → preuves/décisions liées), posé par `init-project.sh --knowledge`. Règle skill : lire `SUJETS.md` avant `docs/INDEX.md` pour une demande métier. Notion de « source fraîche prioritaire » ajoutée à `kb_governance.md`. Section « Skills disponibles selon l'agent » ajoutée aux templates. | Moyen |
| C.6 | Étendre `check-project.sh` pour Knowledge dense | Si `docs/INDEX.md` présent : vérifier `SUJETS.md` présent et non vide, chemins cités valides. Avertissement, pas bloquant. | Faible |
| C.7 | Élargir la couverture des hooks | `hook-pre-write.sh` ne matche que l'outil `Write` ; un fichier créé via `Edit` ou une commande shell (`cp`, `mv`) échappe au contrôle. Étendre le matcher ou documenter explicitement la limite. Corriger le faux négatif du hook Stop (`PROGRESS\.md$` matche aussi `templates/core/PROGRESS.md`). | Moyen |
| C.8 | Corriger le bug de comptage dans `check-project.sh` | L'incrément de `WARNS` pour les placeholders résiduels se fait dans un sous-shell (pipe vers `while`), donc le compteur du bilan final est faux dès qu'il y a plusieurs occurrences. | Faible |
| C.9 | Créer au moins un exemple Life et un exemple Code | `examples/` est vide alors que README et CLAUDE.md le promettent. Un exemple concret vaut plus que des pages de gouvernance pour un non-développeur. | Élevé |
| C.10 | CI minimale | `shellcheck` sur `scripts/*.sh` et `scripts/hooks/*.sh`, test de fumée (`sh -n`, exécution sur un dossier temporaire) en GitHub Actions. Filet de sécurité avant de rendre le repo public. | Moyen |
| C.11 | Statuer sur les plans en attente | `PLAN/plans/2026-06-07-company-os-integration.md`, `2026-06-22-secondbrain-pkb-integration.md`, `2026-06-22-steward-os-integration.md` : décider intégration par lots ou archivage, et les faire apparaître dans `TASKS.md` au lieu de rester hors radar. | Faible (décision) puis variable |

Critère de sortie de phase C : un projet Knowledge dense peut être navigué par niveaux sans que l'agent charge un niveau entier par erreur, la dérive documentaire est détectable automatiquement, et le repo méthode passe une CI de base.

## 4. Ce qui n'est volontairement pas dans ce plan

- Portabilité complète vers Hermès (MCP partagé ou double skill `agentskills.io`) : déjà tracée en Phase 7 de `TASKS.md` / ROADMAP, dépend de la stabilisation des phases A et B ci-dessus. Priorité confirmée : Claude Code, puis Codex, puis Hermès.
- Intégrations MCP (Calendar, Gmail, Drive) : déjà reportées en ROADMAP, hors périmètre de cet audit.
- Les trois plans externes en attente (Company OS, SecondBrain, Steward OS) : traités comme décision de statut en C.11, pas comme travail d'intégration détaillé dans ce plan-ci.

## 5. Suivi

Ce document est un plan de travail au sens de `PLAN/README.md` : il ne devient officiel qu'une fois les tâches transposées dans `TASKS.md` (format `Tx.y`), exécutées, vérifiées, et `PROGRESS.md`/`CHANGELOG.md` mis à jour en conséquence.

Statut à date : **à valider par l'utilisateur avant démarrage de la Phase A.**
