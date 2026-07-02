# Plan d'intégration SecondBrain PKB — 2026-06-22

**Statut** : Document de travail (working document). Ajouté dans `PLAN/plans/`.  
**Objectif** : Analyser le repo https://github.com/PieroSierra/SecondBrain et proposer un plan d'intégration chirurgical dans MyProjectOS / Project OS AI, en intégrant toutes les informations disponibles (SecondBrain + wiki-veille + Hermes + MyProjectOS existant + autres repos mentionnés).  
**Public** : l'utilisateur (étude ultérieure). Pas de décision actée. Aucun commit / push effectué.

---

## 1. Analyse du repo PieroSierra/SecondBrain

**Description** : Personal Knowledge Base (PKB) / Second Brain locale.  
Contenu brut → ingest explicite → wiki organisé par IA (articles thématiques + wikilinks) → query avec réponses sourcées.  
Accès via slash commands Claude Code ou dashboard web local minimal.

**Structure à 3 tiers (raw → wiki → outputs)** :
- `raw/` : append-only (notes MD, PDF, images, web, Craft). Jamais modifié par l'IA.
- `wiki/` : articles thématiques gérés uniquement par l'IA + `INDEX.md` reconstruit à chaque ingest.
- `outputs/` : réponses aux requêtes + rapports de lint (datés).

**Outils principaux** :
- Slash commands Claude Code (`/second-brain-import-*`, `/second-brain-ingest`, `/second-brain-lint`, `/second-brain-query`, `/second-brain-edit-wiki`, `/second-brain-setup`).
- Dashboard local : static HTML + bridge Python minimal (`dashboard/bridge.py`) qui exécute `claude -p "/skill..." --output-format json`. Pas de logique KB dans le bridge.
- Chrome extension pour import direct de pages web.
- `CLAUDE.md` (généré par setup) : schéma du vault + intérêts déclarés.
- `specs/` : specs + plans d'implémentation (ex. 001-personal-knowledge-base, 002-interactive-dashboard).
- Sécurité stricte : permissions limitées (pas de bypassPermissions large, Bash/network refusés, Write/Edit restreint au dossier, token + Origin check).

**Points forts** :
- Ingest explicite (contrôle total).
- Lint qualité (contradictions, claims non sourcées, gaps).
- Édition wiki en langage naturel tout en préservant sources et wikilinks.
- Dashboard minimal et sécurisé.
- Specs structurées + CLAUDE.md comme vérité.

**Références** : README.md complet extrait le 2026-06-22 ; structure `.claude/skills/`, `dashboard/`, `raw/`, `wiki/`, `outputs/`.

---

## 2. Contexte MyProjectOS / Project OS AI (tous les éléments intégrés)

**MyProjectOS** (`/home/<user>/projects/MyProjectOS`) :
- Structure Core + Extensions (Life / Code / Ops / Knowledge).
- Fichiers sacrés : CLAUDE.md (vérité partagée), PROJECT.md, PROGRESS.md, TASKS.md, DECISIONS.md, CHANGELOG.md, ROADMAP.md.
- Pilier Knowledge : `structures/knowledge-tree.md`, `templates/extensions/knowledge/`, `docs/INDEX.md`, `kb_governance.md`, wiki-veille comme KB sourcée (FTS5, embeddings, wikilinks, pages=36 à date).
- wiki-veille (`/home/<user>/wiki-veille`) : bibliothèque Markdown sourcée uniquement (posts X, articles, outils). Scripts `_meta/wiki_rebuild.py`, `_meta/wiki_find.py`. Ne pas confondre avec second brain personnel.
- Hermes Agent : profils projet, gateways Telegram, skills, Mnemosyne (mémoire vectorielle), trends-surfer, etc. CLAUDE.md partagé avec Claude Code.
- Autres repos mentionnés : Unjque_Projet (naming, PROGRESS), Automatisation_Magazine, copropriété, comptabilité_globale, pCloud MyProjects, hermes-backup, etc.
- Règles : chirurgie uniquement, Spec Kit, writing-plans, gouvernance (AGENTS.md, enforcement hooks), sync Mac/VPS (Syncthing).

**Convergence forte** :
- Usage de CLAUDE.md comme source de vérité.
- Skills / slash commands Claude Code.
- Specs + plans dans `specs/` ou `PLAN/`.
- INDEX.md / wikilinks / embeddings.
- Approche Markdown-first, traçable, chirurgicale.

**Différences** :
- SecondBrain = PKB généraliste (capture/organisation/recherche connaissances).
- MyProjectOS = Project Operating System orienté gouvernance projet + Life/Code/Knowledge.

---

## 3. Proposition d'intégration (chirurgicale, par lots)

**Principe** : Ne rien casser. Ajouter des patterns de SecondBrain dans le pilier Knowledge et les skills. Pas de refactor massif. Décisions à valider avant exécution.

### Lot 1 — Analyse & documentation (immédiat, déjà fait)
- Ajout de ce plan dans `PLAN/plans/2026-06-22-secondbrain-pkb-integration.md`.
- Mise à jour PROGRESS.md (ce document).

### Lot 2 — Renforcement Knowledge (wiki-veille + docs)
- Aligner `raw/` concept avec zone de capture temporaire pour veille (PDF, web, X).
- Ajouter skill `/knowledge-ingest` et `/knowledge-lint` (inspiré de second-brain-ingest/lint) pour wiki-veille et `docs/`.
- Renforcer `docs/INDEX.md` et `kb_governance.md` avec lint qualité + wikilinks automatiques.
- Intégrer Chrome extension ou web-import dans le workflow wiki-veille (complément à external-link-visitor-subagent).

### Lot 3 — Dashboard & interface légère
- Étudier le bridge minimal (`dashboard/bridge.py`) pour un dashboard projet léger (query wiki-veille + status) ou extension Hermes WebUI 8787.
- Éviter tout composant lourd.

### Lot 4 — Specs & gouvernance
- Copier/adapter la structure `specs/` de SecondBrain dans `PLAN/` ou `docs/specs/`.
- Ajouter section "intérêts déclarés" dans les CLAUDE.md projet.
- Intégrer le modèle de sécurité du bridge dans les futurs outils locaux.

### Lot 5 — Hermes & multi-profil
- Exposer les nouveaux skills Knowledge via MCP ou double skill (Hermes + Claude Code).
- Tester sur profil `spec-kit-operator` ou `comptabilite_globale`.

### Lot 6 — Validation & banc d'essai
- Dogfood sur MyProjectOS lui-même.
- Mesurer : temps d'ingest, qualité lint, pertinence réponses sourcées.

**Fichiers impactés potentiels** (liste exhaustive) :
- `PLAN/plans/2026-06-22-secondbrain-pkb-integration.md` (ce fichier)
- `PROGRESS.md`, `TASKS.md`
- `docs/kb_governance.md`, `docs/INDEX.md`
- `skills/my-project-os/SKILL.md` (ajout modes Knowledge)
- `structures/knowledge-tree.md`
- `wiki-veille/_meta/` (scripts optionnels)
- `CLAUDE.md` (template intérêts)

---

## 4. Risques & points de vigilance

- Confusion wiki-veille (sourcée, veille) vs second brain personnel (raw/wiki).
- Surface d'attaque : permissions strictes obligatoires (comme le bridge SecondBrain).
- Surcharge contexte : garder les plans isolés dans `PLAN/`.
- Sync Mac/VPS : tester après tout changement Knowledge.
- Pas de décision sans GO explicite (règle gouvernance).

---

## 5. Décisions à prendre (après étude)

1. Valider le scope Knowledge uniquement ou extension Life/Code ?
2. Priorité : ingest/lint ou dashboard ?
3. Intégration wiki-veille ou séparation stricte ?
4. Budget temps / lots par phase.

---

**Fin du plan.**  
Document ajouté le 2026-06-22. Prêt pour étude ultérieure. Aucun commit, aucun push.