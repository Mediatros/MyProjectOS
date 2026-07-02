---
projet: MyProjectOS
type: Core
methode: my-project-os
version_methode: 0.3.0
statut: actif
cree_le: 2026-06-01
---

# PROJECT.md — MyProjectOS

> Pourquoi ce projet existe, son périmètre et ce qui définit sa réussite.
> Fichier stable : il bouge rarement. L'état au jour le jour vit dans `PROGRESS.md`.

## Pourquoi ce projet existe

L'utilisateur travaille sur plusieurs projets (personnels, administratifs, professionnels, logiciels) avec Claude Code (Mac) et Hermès (VPS), et perd régulièrement le fil : fichiers dispersés, dossiers incohérents, information dupliquée, agents qui improvisent l'organisation, difficulté à reprendre un projet après interruption. MyProjectOS existe pour fournir à chaque projet une structure, une mémoire et des règles communes, afin qu'un agent puisse dire « où en est-on » de façon fiable sans historique de conversation.

## Périmètre

**Inclus**
- Templates Markdown des fichiers sacrés (Core) et des extensions activables (Life, Code, Knowledge).
- Règles de gouvernance et rituels de session (`docs/`).
- Skill assistant installable (`skills/my-project-os/`).
- Scripts d'installation et de vérification (`install.sh`, `scripts/init-project.sh`, `scripts/check-project.sh`, `scripts/build-index.sh`).
- Hooks d'enforcement déterministe (`scripts/hooks/`).
- Documents de plan et d'inspiration externe, isolés dans `PLAN/` avant intégration.

**Exclus**
- Le contenu métier des projets créés avec la méthode (vit dans chaque projet, hors de ce repo).
- L'exécution encadrée du code (déléguée à Claude Code Harness, documenté mais non réimplémenté ici).
- Les intégrations MCP (Calendar, Gmail, Drive) : reportées en `ROADMAP.md`.

## Objectifs

- Fournir une méthode installable en une commande, par un agent, sur un projet vierge ou déjà peuplé.
- Garantir une reprise à froid fiable : n'importe quel agent obtient l'état d'un projet sans relire l'historique de conversation.
- Encadrer les agents IA par trois couches (documentation, skill, hooks) plutôt que par la seule bonne volonté.
- Rester simple et Markdown-first, utilisable par un non-développeur.

## Critères de réussite

Le projet est réussi quand :
1. Un agent qui reçoit le lien du repo peut installer la méthode sur un projet vierge sans intervention manuelle supplémentaire.
2. Un projet réel (banc d'essai Unjque) tourne avec la méthode et les frictions relevées sont corrigées.
3. Le repo méthode respecte lui-même sa propre gouvernance (fichiers sacrés à jour, docs alignées sur le comportement réel des scripts).

## Type et extensions

- **Type** : Core. Le repo contient des scripts shell (`scripts/`, `scripts/hooks/`), mais il n'active pas l'extension Code sur lui-même : ce n'est pas un projet logiciel au sens de la méthode (pas de stack applicative, pas de `STACK_VALIDATION`/`ARCHITECTURE`/`IMPACT_ANALYSIS` à tenir), c'est un système documentaire versionné (voir `CLAUDE.md`).
- **Extensions activées** : aucune. Le repo a son propre `CLAUDE.md` (convention Claude Code, décrit l'architecture du système lui-même) mais pas d'`AGENTS.md` généré depuis `templates/core/` : lisibilité Codex sur ce repo méthode non couverte à ce stade, à traiter si le besoin se présente.

## Parties prenantes

- L'utilisateur (Mediatros) : pilote, décide, utilisateur final de la méthode sur ses propres projets.
- Claude Code (Mac) : agent d'exécution principal, construit et fait évoluer le repo.
- Hermès (VPS) : agent consommateur de la méthode, portabilité prévue en Phase 7 (ROADMAP).

## Références

- `PLAN/HANDOFF.md`, `PLAN/hermes-workdoc-2026-06-03-orientation-project-os-ai.md` : base de travail initiale et analyse d'orientation.
- `PLAN/plans/2026-07-02-audit-industrialisation-methode.md` : plan en cours (installation réelle, méthode 2, navigation 3 niveaux).
- `docs/vision.md`, `docs/principles.md`, `docs/governance.md` : fondations de la méthode.
