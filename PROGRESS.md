---
projet: ProjectOS
type: Code
statut: en construction
derniere_maj: 2026-06-07
prochaine_action: Relire/valider le plan Company OS dans PLAN puis décider l'intégration par lots
prochaine_echeance:
---

# PROGRESS.md — Project OS AI

> Source de vérité opérationnelle. Lire en début de session, mettre à jour après chaque avancée significative.
> Règle immuable : toute mise à jour de ce fichier met aussi à jour le bloc d'en-tête ci-dessus.

## Objectif du projet

Concevoir et construire `project-os-ai` : une méthodologie unifiée d'organisation de projets (Life / Code / Hybrid), pilotable par Claude Code (Mac) et Hermès (VPS), permettant de reprendre n'importe quel projet sans historique de conversation. Livrable : un repository de templates, règles, documentation, skill assistant et exemples.

## Contexte utile

- `HANDOFF.md` : base de travail initiale, non figée. Tout peut être remis en question.
- Profil utilisateur : non-développeur. Sait exprimer le besoin fonctionnel, pas toujours la stack ni les bonnes pratiques techniques. A besoin d'être guidé et protégé, surtout sur l'avant du pipeline Code.
- Sync Mac/VPS : Syncthing. Détection projet : ouverture directe du dossier, profil Hermès isolé par projet.
- Ce projet sert de pilote : on dogfoode la méthode sur lui-même.
- Plans : `PLAN_PROJECT_OS_AI.md` (construction), `PLAN_PROPOSITION_AMELIORATION.md` (analyse et décisions), `PLAN/` (plans d'évolution isolés avant intégration).
- Inspiration : `Unjque_Projet` (naming, index, format PROGRESS, identifiants CHG).
- Outils évalués (juin 2026) : Spec Kit (GitHub, MIT, amont spec→plan→tâches), Claude Code Harness (Chachamaru127, 2,4k★, plan→work→review→release + garde-fous Go, agnostique langage), mattpocock/skills (skills ciblées, ex `/grill-me`).
- NowStack : boilerplate Codelynx LLC (codelynx.dev/nowstack, page fermée/waitlist), mono-stack TanStack Start + React + Convex + Expo + Cloudflare + Stripe, optimisée Claude Code/Cursor (« +40 règles », types stricts). Essence reproductible = les « rails » : architecture par domaine fonctionnel + conventions fortes + règles agent + recettes d'ajout de feature + gate qualité. Mantra : « pas du vibe coding, du AI Building, l'IA code comme un senior parce qu'on lui donne les bons rails ».
- Développements faits principalement avec Claude Code.

## État actuel

Phases 1 à 5 terminées. Squelette en place (arborescence, `README`, `ROADMAP`, templates Core, docs de gouvernance, structure Core). Extensions livrées : templates Life (`PREUVES`, `ECHEANCES`, `CORRESPONDANCES`) et Code (`AGENTS`, `CONSTITUTION`, `STACK_VALIDATION`, `ARCHITECTURE`, `SPECS`, `TEST_PLAN`, `IMPACT_ANALYSIS`, `RELEASE`), structures `life-tree`/`code-tree`, plus la valeur ajoutée maison : gate `STACK_VALIDATION` sourcé (`docs/stack-validation-gate.md`) et concept « kit de rails » avec format de recette (`docs/kit-de-rails.md`). Extension Knowledge ajoutée et câblée le 2026-06-07 : `structures/knowledge-tree.md`, `templates/knowledge/`, `scripts/init-project.sh --knowledge`, skill assistant, règles de contexte progressif, dépendances transverses, `docs/INDEX.md`, `kb_governance.md`, plans et runbooks. Zone PLAN ajoutée le 2026-06-07 : `PLAN/README.md` isole les plans d'évolution, et `PLAN/plans/2026-06-07-company-os-integration.md` documente l'analyse Company OS + proposition d'intégration (documentation comme interface IA, température contextuelle, maturité de l'information, isolation des contextes). Test réel validé : génération Core+Knowledge et Hybrid+Knowledge dans `/tmp`, fichiers attendus présents, substitution `<NomDuProjet>` absente, `sh -n` OK. Phase 3 : skill assistant livrée sous forme installable (`skills/project-os/SKILL.md`, frontmatter + 4 modes reprise/orientation/explication/clôture + aiguillage Code complet/allégé + initialisation), cadrée dans `agents/meta-skill.md`, fiches d'agent `claude-code.md` et `hermes.md`. Phase 4 : couche enforcement déterministe livrée et testée (`docs/enforcement.md`, `scripts/hooks/` + `scripts/init-project.sh`). Phase 5 : colonne vertébrale Code branchée. `docs/harness.md` documente installation/usage de Harness (faits sourcés sur le dépôt upstream le 2026-06-01 : install via plugin marketplace, 5 verbes `/harness-setup|plan|work|review|release`, artefacts `spec.md`/`Plans.md`, MIT, v4.13.3, Claude Code v2.1+) et la correspondance avec les fichiers sacrés. Emprunts Spec Kit en Markdown figé : `templates/code/CONSTITUTION.md` (principes projet) et `docs/clarify.md` (réflexe clarify). Constitution câblée dans `code-tree` et `AGENTS`. Reste : validation du plan Company OS puis banc d'essai Unjque (Phase 6).

## Décisions actées

- Structure : dossiers numérotés, rôles fixés par la gouvernance, créés à la demande (pas de squelette vide imposé). Archive = `99_archive/`.
- Enforcement à 3 couches : documentation (règles), skill assistant (accompagnement), hooks (déterministe). Les non-négociables passent par des hooks.
- Règle immuable : PROGRESS et son bloc d'en-tête toujours à jour, garanti par un hook de fin de session.
- Frontière fichiers sacrés : PROGRESS = photo de l'instant ; CHANGELOG = registre daté (`CHG-YYYYMMDD-HHMM`) ; DECISIONS = pourquoi (`DEC-XXXX` reliés aux CHG).
- PROGRESS aligné sur le CLAUDE.md global. `anatomy.md` abandonné.
- Skill assistant : pièce centrale, pas un bonus. Modes reprise / orientation / explication / clôture. Livrée comme skill Claude Code installable (`skills/project-os/SKILL.md`), pas comme simple spec Markdown, pour être dogfoodable. Nouveau dossier `skills/` ajouté au repo.
- Enforcement : hooks en `sh` POSIX (portables Mac/VPS, dégradation silencieuse si python3/jq absents), portée **par projet** (scripts dans le repo méthode, câblés dans le `.claude/settings.json` posé par `init-project.sh`, config globale non touchée), fermeté **hybride** (bloque nommage espaces/accents et placement document à la racine ; avertit sans bloquer sur la fraîcheur de PROGRESS via le signal git).
- Volet Code : gate de validation de stack avec compatibilité vérifiée et sourcée avant tout code ; IMPACT_ANALYSIS avant modif ; conseil de séquençage.
- Extensions MCP (Calendar, Gmail, Drive) : reportées en ROADMAP.
- Extension Knowledge : activée comme brique transverse optionnelle, non comme nouveau type de projet. Elle formalise la navigation progressive (`docs/INDEX.md`, niveaux global/domaines/détails), l'analyse des dépendances transverses avant modification, les plans et runbooks. Understand-Anything reste un outil complémentaire, pas une source de vérité.
- Colonne vertébrale Code = Harness (exécuté côté Mac/Claude Code). On emprunte à Spec Kit, sous forme de documents Markdown figés, la constitution (principes projet) et le réflexe clarify. Un seul outil exécuté, aucune couture entre deux moteurs. Deux modes : complet / allégé. Raison : suit Claude Code, garde-fous déterministes natifs, surfaces HTML non-dev, charge minimale pour un non-développeur. État réel juin 2026 : garde-fous natifs Go, 5 verbes (setup/plan/work/review/release), surfaces HTML Plan Brief / Progress Tracker / Acceptance Demo, MIT, Claude Code v2.1+.
- Veille mensuelle upstream = routine planifiée Claude Code (cloud Anthropic), déclenchée le 1er du mois. Elle compare l'état des deux repos avec un état mémorisé et écrit un rapport dans le repo GitHub (`docs/veille/VEILLE-OUTILS.md`) avec verdict à intégrer / à surveiller / à ignorer. Elle propose, n'intègre jamais seule. Prérequis : projet sur GitHub. VPS (instance Claude Code) = plan B. Routine active : `veille-outils-upstream` (id `trig_01UTxP1TgxFUVUsap7KkY6Ta`), cron `0 8 1 * *` (1er du mois 08h UTC), modèle sonnet-4-6, écriture directe sur `main`. Socle dans `docs/veille/` (`_consigne.md`, `_etat-upstream.md`, `VEILLE-OUTILS.md`). Gestion : https://claude.ai/code/routines. Premier passage réel : 2026-07-01.
- Repo unique privé `project-os-ai` sur GitHub (compte Mediatros, `gh` connecté). Contient Core + extension Life + extension Code dans des sous-dossiers. Commits signés avec l'email noreply GitHub (email perso en mode privé).

## Travail en cours

- Construction du système. Plan détaillé et découpé dans `TASKS.md` (phases 1 à 7). Phases 1 à 5 faites. Plan Company OS ajouté dans `PLAN/` ; validation et intégration par lots à décider avant reprise du banc d'essai Unjque.

## Besoins Code identifiés (trois couches)

1. Amont (spec, stack, séquençage) : couvert par Spec Kit + interrogation type `/grill-me`. Couche la plus critique pour l'utilisateur.
2. Exécution encadrée : couvert par Claude Code Harness.
3. Architecture « Agent First » : non fournie par les outils de process. Modèle retenu = un « kit de rails » par type de stack. Chaque kit = `ARCHITECTURE.md` (domaine fonctionnel + séparation des responsabilités) + conventions/typage + règles agent (CLAUDE.md/AGENTS.md) + recettes d'ajout de feature + gate qualité. Pièce maîtresse : la recette (rail générique) couplée à IMPACT_ANALYSIS (instance précise). Pas de boilerplate unique car projets hétérogènes (WordPress, n8n, SaaS).

## Problèmes ouverts / points de vigilance

- Compatibilité des versions de stack : aucun outil ne la garantit. Valeur ajoutée à construire (gate `STACK_VALIDATION` avec vérification sourcée avant tout code).
- Portabilité de la couche gouvernance vers Hermès : Hermès (Nous Research) est un agent autonome, pas Claude Code, donc il n'exécute pas Harness. Il consomme les fichiers Markdown. Il supporte MCP et agentskills.io : à terme, exposer skill assistant + règles via MCP partagé ou double skill pour qu'Hermès respecte les mêmes garde-fous. Reporté ROADMAP.
- Lien NowStack à obtenir pour reproduire précisément l'approche qui a séduit l'utilisateur.
- Détail des rôles de dossiers numérotés à finaliser une fois la gouvernance posée.

## Prochaines étapes

Détail dans `TASKS.md`. Vue macro :
1. Phase 1 : squelette + templates Core. **Faite.**
2. Phase 2 : extensions Life et Code. **Faite.**
3. Phase 3 : skill assistant (le cœur). **Faite.**
4. Phase 4 : hooks d'enforcement + script d'init. **Faite.**
5. Phase 5 : intégration Harness + emprunts Spec Kit. **Faite.**
6. Phase 6 : banc d'essai Unjque.
7. Phase 7 (ROADMAP) : portabilité Hermès.

## Références utiles

- `TASKS.md` : plan de construction détaillé (source pour la reprise après `/clear`).
- `HANDOFF.md`, `CLAUDE.md`, `PLAN_PROJECT_OS_AI.md`, `PLAN_PROPOSITION_AMELIORATION.md`.
- `Unjque_Projet/docs/NAMING-CONVENTIONS.md`, `Unjque_Projet/docs/INDEX.md`, `Unjque_Projet/PROGRESS.md`.

## Contraintes importantes / À ne pas faire

- Ne pas imposer d'outil lourd : l'utilisateur n'est pas développeur, priorité à la simplicité.
- Aucune action critique sans validation humaine.
- Garder simple, Markdown-first, unifié.
- Règles non négociables tenues par des hooks, pas par de simples consignes.
