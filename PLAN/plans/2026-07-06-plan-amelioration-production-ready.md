# Plan d'amélioration — MyProjectOS production ready

> **Statut :** appliqué le 2026-07-07 (v0.5.0, CHG-20260707-1100). Décisions du §6 tranchées : dépôt conçu pour le public (DEC-0021), `SUJETS.md` à la racine (DEC-0024), ordre D puis E respecté. Restent ouverts : T-B.7 (revue documentaire périodique) et T-C.11 / G.6 (arbitrage des plans en attente).
> **Date :** 2026-07-06
> **Zone :** `PLAN/plans/`
> **Origine :** revue complète du projet local et du dépôt GitHub (`Mediatros/MyProjectOS`, privé, synchronisé avec le local au 2026-07-06), à la demande de l'utilisateur, autour de quatre attentes explicites : (1) un framework d'administration de projet utilisable par Claude Code, Codex et Hermès Agent ; (2) un accompagnement de l'utilisateur non-développeur (cadrage du besoin, stack, découpage en tâches, travail par itération avec gestion de la fenêtre de contexte) ; (3) un mécanisme de mise à jour de la méthode dans les projets existants, avec audit préalable et validation humaine ; (4) un niveau de qualité production / entreprise.

## 1. Objectif du plan

Amener MyProjectOS au stade « production ready » : installable partout, mis à jour proprement dans les projets déjà créés, accompagnant réellement l'utilisateur dans le cadrage et le rythme de travail itératif, et fiabilisé par des tests automatiques.

## 2. Articulation avec le plan du 2026-07-02

Le plan `2026-07-02-audit-industrialisation-methode.md` reste valable : sa Phase A est terminée (v0.4.0), ses Phases B et C ne sont pas démarrées. Le présent plan ne le remplace pas : il **réorganise les tâches B et C autour des quatre attentes exprimées**, y ajoute les constats nouveaux de cette revue, et propose un ordre d'exécution. Chaque tâche reprise porte la référence de son identifiant d'origine (ex : « ex T-B.5 »).

## 3. Constats nouveaux de cette revue

Ces points ne figurent pas dans l'audit du 2026-07-02.

1. **Les artefacts méthode embarqués ne se mettent jamais à jour.** `init-project.sh --into-existing` conserve la skill (`.claude/skills/my-project-os/SKILL.md`), `scripts/check-project.sh` et `VERSION` s'ils existent déjà ; seuls les hooks sont réécrits. Un projet créé en 0.3.0 gardera donc à vie la skill et le check de 0.3.0, alors que le `README.md` laisse entendre que relancer l'installation met le projet à jour. C'est le trou principal du chantier « mise à jour ».
2. **Le mécanisme de mise à jour esquissé est incompatible avec le dépôt privé.** T-B.5 prévoit de lire `raw.githubusercontent.com/.../VERSION`, ce qui échoue tant que DEC-0017 (dépôt privé) tient. Il faut soit publier le dépôt, soit construire la détection sur un accès authentifié (`gh api`, `git ls-remote` en SSH, variable `MYPROJECTOS_REPO_URL`). Cette décision conditionne aussi `install.sh` par `curl` et l'usage depuis le VPS Hermès.
3. **La skill copiée dans un projet parle du repo méthode.** Son mode initialisation référence `templates/core/` et `scripts/init-project.sh`, qui n'existent pas dans un projet autonome (installation jetable). L'agent d'un projet cible reçoit donc des instructions inapplicables.
4. **Le cycle de travail itératif n'est pas codifié.** La pratique réelle de l'utilisateur (une tâche à la fois, clôture des fichiers sacrés, `/clear`, reprise à froid sur la tâche suivante) est le cœur de la méthode vécue, mais aucun document ne la décrit, le template `TASKS.md` ne donne aucune règle de découpage (une tâche = une session, critère de succès vérifiable), et la skill ne propose jamais la clôture quand une tâche se termine.
5. **Pas de mode « cadrage » guidé.** Le mode initialisation pose les fichiers mais n'accompagne pas la définition du besoin. L'interrogation type `/grill-me` est citée dans `PROGRESS.md` depuis juin mais n'a jamais été implémentée. C'est pourtant la couche « la plus critique pour l'utilisateur » d'après ses propres besoins Code.
6. **Hygiène de release incomplète.** Le tag `v0.3.0` n'est pas poussé sur origin (v0.1.0, v0.2.0, v0.4.0 le sont) ; aucune release GitHub n'existe. Or le futur audit de mise à jour s'appuiera sur les tags et le CHANGELOG distant : la chaîne de release doit être fiable avant.
7. **Les bugs connus du check deviennent bloquants pour la suite.** Le comptage des `WARNS` (ex C.8) et la couverture partielle des hooks (ex C.7) étaient des dettes tolérables ; dès que `check-project.sh` sert de base au rapport d'audit de mise à jour, sa fiabilité devient un prérequis.

## 4. Phasage

Quatre phases, nommées D à G pour ne pas entrer en collision avec les phases A/B/C existantes.

### Phase D — Mise à jour sécurisée de la méthode

But : depuis un projet existant, demander « vérifie s'il y a une mise à jour de la méthode » produit un audit lisible (version actuelle, version disponible, liste des améliorations, fichiers concernés), pose des questions fermées de validation, applique sans jamais toucher au contenu utilisateur, et laisse une trace.

| ID | Tâche | Détail | Effort |
|---|---|---|---|
| D.1 | Trancher l'accès distant (revisite DEC-0017 / T-A.2) | Public (recommandé : `curl` et `check-update` fonctionnent partout, LICENSE MIT déjà posée, aucun contenu personnel dans le repo) ou privé avec accès authentifié documenté (`gh`, SSH, `MYPROJECTOS_REPO_URL`). Décision humaine. | Faible (décision) |
| D.2 | Manifest des artefacts méthode | Fichier posé par `init-project.sh` (ex : `.myprojectos/manifest`) listant les fichiers appartenant à la méthode (hooks, skill, `check-project.sh`, `VERSION`) avec leur version d'origine. Frontière déterministe entre « artefact méthode » (remplaçable à la mise à jour) et « contenu utilisateur » (intouchable). | Moyen |
| D.3 | `check-update.sh` (ex T-B.5, adapté) | Compare `version_methode` du projet à la dernière version distante (tags ou `VERSION`, via le mode d'accès choisi en D.1), liste les entrées `CHG-` et les releases entre les deux versions, indique les artefacts locaux qui seraient remplacés (via D.2). N'applique rien. Copié dans le projet comme `check-project.sh`. | Moyen |
| D.4 | `init-project.sh --update-method` | Nouveau mode qui rafraîchit uniquement les artefacts méthode du manifest (hooks, skill, check, `VERSION`, empreinte `version_methode`), avec sauvegarde préalable des versions remplacées (ex : `99_archive/methode-avant-vX.Y.Z/`) et rapport de ce qui a changé. Corrige le constat n°1. | Moyen |
| D.5 | Mode « mise à jour » de la skill | Sixième mode : déclenché par « y a-t-il une mise à jour ? ». Workflow imposé : détecter (D.3) → présenter l'audit en langage simple (ce que la nouvelle version apporte, ce qui sera remplacé, ce qui ne sera pas touché) → questions fermées de validation → appliquer (D.4) → consigner `CHG-` dans le projet et confirmer par `check-project.sh`. Jamais d'application sans validation. | Moyen |
| D.6 | Runbook de migration (ex T-B.6) | `docs/versioning.md` : procédure concrète de migration d'un projet, y compris projet né avant le versionnement (demande du RETEX comptabilité, ajustement n°4). | Faible |
| D.7 | Hygiène de release | Pousser `v0.3.0`, créer les releases GitHub v0.1.0 à v0.4.0 avec notes (résumé des `CHG-` par version), et intégrer « pousser le tag + créer la release » à la procédure de `docs/versioning.md`. | Faible |
| D.8 | Tests de mise à jour | Scénario automatisé : générer un projet avec une vieille version simulée, lancer `check-update.sh` (détection correcte), lancer `--update-method` (artefacts rafraîchis, contenu utilisateur intact, sauvegarde créée), `check-project.sh` vert. Intégré à la CI (G.2). | Moyen |

Critère de sortie : un projet estampillé 0.3.0 peut être audité et migré vers la version courante en une session, avec validation humaine à chaque étape, sans qu'aucun fichier de contenu ne soit modifié.

### Phase E — Cadrage guidé et cycle de travail itératif

But : que la méthode accompagne activement l'utilisateur non-développeur sur l'avant du pipeline (définir le besoin, la stack, le découpage) et sur le rythme d'exécution (une tâche par itération, clôture, `/clear`, reprise), au lieu de seulement fournir des gabarits.

| ID | Tâche | Détail | Effort |
|---|---|---|---|
| E.1 | Codifier le cycle itératif | Nouveau `docs/cycle-de-travail.md` : le rythme officiel de la méthode. Une itération = choisir **une** tâche de `TASKS.md` → l'exécuter → mettre à jour les fichiers sacrés (clôture) → `/clear` → reprise à froid sur la suivante. Pourquoi : préserver la fenêtre de contexte, garantir que chaque reprise part des fichiers et non de l'historique. C'est la formalisation de la pratique déjà éprouvée par l'utilisateur. | Moyen |
| E.2 | Règles de découpage des tâches | Dans `templates/core/TASKS.md` : une tâche doit tenir dans une session, porter un critère de succès vérifiable (« écrire le test qui le reproduit, puis le faire passer », pas « corriger le bug »), et être découpée sinon. Section courte correspondante dans `templates/core/AGENTS.md`. | Faible |
| E.3 | Signal de clôture dans la skill | Règle ajoutée au mode reprise/clôture : quand la tâche en cours est terminée, proposer explicitement la clôture (mise à jour des fichiers sacrés + résumé + suggestion de `/clear`) plutôt que d'enchaîner sur la tâche suivante dans la même fenêtre. | Faible |
| E.4 | Mode « cadrage » de la skill | Interview guidée à la création (ou à la reprise d'un projet mal défini) : pourquoi, périmètre inclus/exclu, objectifs, critères de réussite, risques ; questions une par une, reformulation, `PROJECT.md` pré-rempli soumis à validation. Volet Code : enchaîner ensuite `CONSTITUTION` → `STACK_VALIDATION` (gate sourcé) → `SPECS` avec réflexe clarify → proposition de découpage dans `TASKS.md` conforme à E.2. Implémente enfin l'esprit `/grill-me`. | Élevé |
| E.5 | Intégrer le RETEX comptabilité (ex T-C.5, T-C.6) | Template `SUJETS.md` (routeur : alias utilisateur → sujet canonique → ordre de lecture → source fraîche prioritaire → dépendances → preuves/décisions), posé par `--knowledge` ; règle skill « lire `SUJETS.md` avant `docs/INDEX.md` pour une demande métier » ; notion de source fraîche prioritaire dans `kb_governance.md` ; section « Skills disponibles selon l'agent » dans les templates ; contrôle `SUJETS.md` dans `check-project.sh` (avertissement). Emplacement racine ou `docs/` : à trancher (le RETEX recommande la racine). | Moyen |

Critère de sortie : un utilisateur qui dit « je veux démarrer un projet de site pour un client » est conduit, question par question, jusqu'à un `PROJECT.md` validé, une stack vérifiée et un `TASKS.md` découpé en itérations tenables ; et le projet copropriété (Life + Knowledge) route « retrouve les mails de X sur le sujet Y » via `SUJETS.md`.

### Phase F — Adoption d'un projet existant (méthode 2)

Reprend telles quelles les tâches T-B.1 à T-B.4 du plan du 2026-07-02 (protocole `docs/INSTALL-AGENT.md`, méthode 2 pas à pas avec validation humaine avant toute réorganisation, remplissage assisté des fichiers sacrés, mode « adoption » de la skill). Rien à redéfinir ici ; seule la priorité change (voir §5).

### Phase G — Qualité production et fiabilité

| ID | Tâche | Détail | Effort |
|---|---|---|---|
| G.1 | Corriger les bugs connus (ex T-C.7, T-C.8) | Comptage `WARNS` faussé par le sous-shell dans `check-project.sh` ; faux négatif du hook Stop (`PROGRESS\.md$` matche aussi `templates/core/PROGRESS.md`) ; couverture du hook pre-write limitée à l'outil `Write` (étendre à `Edit`/commandes shell ou documenter la limite). **À faire en premier : prérequis de fiabilité pour D.** | Moyen |
| G.2 | CI minimale (ex T-C.10) | GitHub Actions : `shellcheck` sur tous les `.sh`, tests de fumée (`init-project.sh` sur dossier temporaire pour chaque combinaison de flags, `check-project.sh` vert sur le projet généré, `--into-existing` idempotent), plus les scénarios D.8. Filet obligatoire avant publication du dépôt (D.1). | Moyen |
| G.3 | Skill embarquée cohérente | Purger la copie projet de la skill de ses références au repo méthode (constat n°3) : soit deux variantes (repo / projet) générées depuis une source unique, soit une rédaction indépendante de l'emplacement. | Faible |
| G.4 | Exemples réels (ex T-C.9) | Au moins `examples/life-copropriete/` (calqué anonymisé sur le cas réel : mails, sujets suivis, échéances, preuves) et un exemple Code (petit site ou plugin). Un exemple concret vaut mieux que des pages de gouvernance pour un non-développeur. | Élevé |
| G.5 | Navigation à trois niveaux outillée (ex T-C.1 à T-C.4) | Frontmatter standard des documents Knowledge, convention de nommage liant niveaux 2 et 3, budgets de taille par niveau, détection d'orphelins et de liens cassés dans `docs/INDEX.md`. | Moyen |
| G.6 | Statuer sur les plans en attente (ex T-C.11) | Company OS, SecondBrain PKB, Steward OS : intégration ou archivage. | Faible (décision) |

Critère de sortie : CI verte sur chaque commit, dépôt publiable sans crainte, exemples consultables, navigation Knowledge fiable.

## 5. Ordre d'exécution recommandé

1. **Assainissement immédiat** : G.1 (bugs) + D.7 (tags/releases) + D.1 (décision d'accès). Court, débloque tout le reste.
2. **Chantier mise à jour** : D.2 → D.3 → D.4 → D.5 → D.6, avec G.2 et D.8 en parallèle (la CI se construit en testant l'update). C'est la priorité n°1 exprimée par l'utilisateur.
3. **Chantier accompagnement** : E.1 → E.2 → E.3 (rapides, forte valeur), puis E.4 (le gros morceau), puis E.5.
4. **Adoption** : Phase F (méthode 2), qui bénéficie alors de E.4 (le cadrage guidé sert aussi à remplir les fichiers sacrés d'un projet adopté).
5. **Finition production** : G.3, G.4, G.5, G.6, puis banc d'essai Unjque (Phase 6 existante).

Jalon proposé : **la sortie des phases D et E plus le banc d'essai Unjque déclenche le passage à `1.0.0`** (cohérent avec DEC-0015 : le `1.0.0` marque la validation sur un vrai projet).

## 6. Décisions à trancher par l'utilisateur avant démarrage

1. **Visibilité du dépôt (D.1)** : public ou privé avec accès authentifié ? Recommandation : public (LICENSE MIT posée, aucun contenu personnel, c'est la seule option qui rend `curl` et la détection de mise à jour triviales partout, y compris VPS Hermès).
2. **Emplacement de `SUJETS.md` (E.5)** : racine du projet (recommandation du RETEX : c'est un fichier de routage, pas de la documentation) ou `docs/`.
3. **Priorité D contre E** : l'ordre proposé met la mise à jour avant l'accompagnement ; inverser si le besoin de cadrage sur un nouveau projet client est plus urgent.
4. **Jalon `1.0.0`** : valider la définition proposée (D + E + banc d'essai Unjque).

## 7. Ce qui n'est volontairement pas dans ce plan

- Portabilité complète vers Hermès (MCP partagé ou double skill agentskills.io) : reste en Phase 7 / ROADMAP. Le contrat minimal actuel (gouvernance Markdown, `AGENTS.md` sous la limite de troncature, garde-fou de taille dans le check) est déjà en place depuis v0.4.0.
- Intégrations MCP (Calendar, Gmail, Drive) : toujours reportées en ROADMAP.
- Réécriture des templates existants : ils sont sains ; ce plan les complète (E.2, E.5) sans les refondre.

## 8. Suivi

Document de travail au sens de `PLAN/README.md` : il ne devient officiel qu'une fois validé, les tâches transposées dans `TASKS.md` (format `Tx.y`), exécutées et vérifiées, avec `PROGRESS.md` / `CHANGELOG.md` mis à jour.

Statut à date : **à valider par l'utilisateur.**
