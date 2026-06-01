---
projet: ProjectOS
type: Code
statut: en conception
derniere_maj: 2026-06-01
prochaine_action: Brancher la veille mensuelle (routine cloud) sur le repo project-os-ai
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
- Plans : `PLAN_PROJECT_OS_AI.md` (construction), `PLAN_PROPOSITION_AMELIORATION.md` (analyse et décisions).
- Inspiration : `Unjque_Projet` (naming, index, format PROGRESS, identifiants CHG).
- Outils évalués (juin 2026) : Spec Kit (GitHub, MIT, amont spec→plan→tâches), Claude Code Harness (Chachamaru127, 2,4k★, plan→work→review→release + garde-fous Go, agnostique langage), mattpocock/skills (skills ciblées, ex `/grill-me`).
- NowStack : boilerplate Codelynx LLC (codelynx.dev/nowstack, page fermée/waitlist), mono-stack TanStack Start + React + Convex + Expo + Cloudflare + Stripe, optimisée Claude Code/Cursor (« +40 règles », types stricts). Essence reproductible = les « rails » : architecture par domaine fonctionnel + conventions fortes + règles agent + recettes d'ajout de feature + gate qualité. Mantra : « pas du vibe coding, du AI Building, l'IA code comme un senior parce qu'on lui donne les bons rails ».
- Développements faits principalement avec Claude Code.

## État actuel

Phase de conception. `CLAUDE.md`, deux plans et ce PROGRESS rédigés. Le sujet central s'est déplacé de la structure vers la gouvernance : faire respecter les règles automatiquement, pas seulement les écrire.

## Décisions actées

- Structure : dossiers numérotés, rôles fixés par la gouvernance, créés à la demande (pas de squelette vide imposé). Archive = `99_archive/`.
- Enforcement à 3 couches : documentation (règles), skill assistant (accompagnement), hooks (déterministe). Les non-négociables passent par des hooks.
- Règle immuable : PROGRESS et son bloc d'en-tête toujours à jour, garanti par un hook de fin de session.
- Frontière fichiers sacrés : PROGRESS = photo de l'instant ; CHANGELOG = registre daté (`CHG-YYYYMMDD-HHMM`) ; DECISIONS = pourquoi (`DEC-XXXX` reliés aux CHG).
- PROGRESS aligné sur le CLAUDE.md global. `anatomy.md` abandonné.
- Skill assistant : pièce centrale, pas un bonus. Modes reprise / orientation / explication / clôture.
- Volet Code : gate de validation de stack avec compatibilité vérifiée et sourcée avant tout code ; IMPACT_ANALYSIS avant modif ; conseil de séquençage.
- Intégrations MCP (Calendar, Gmail, Drive) : reportées en ROADMAP.
- Colonne vertébrale Code = Harness (exécuté côté Mac/Claude Code). On emprunte à Spec Kit, sous forme de documents Markdown figés, la constitution (principes projet) et le réflexe clarify. Un seul outil exécuté, aucune couture entre deux moteurs. Deux modes : complet / allégé. Raison : suit Claude Code, garde-fous déterministes natifs, surfaces HTML non-dev, charge minimale pour un non-développeur. État réel juin 2026 : garde-fous natifs Go, 5 verbes (setup/plan/work/review/release), surfaces HTML Plan Brief / Progress Tracker / Acceptance Demo, MIT, Claude Code v2.1+.
- Veille mensuelle upstream = routine planifiée Claude Code (cloud Anthropic), déclenchée le 1er du mois. Elle compare l'état des deux repos avec un état mémorisé et écrit un rapport dans le repo GitHub (`docs/veille/VEILLE-OUTILS.md`) avec verdict à intégrer / à surveiller / à ignorer. Elle propose, n'intègre jamais seule. Prérequis : projet sur GitHub. VPS (instance Claude Code) = plan B.
- Repo unique privé `project-os-ai` sur GitHub (compte Mediatros, `gh` connecté). Contient Core + extension Life + extension Code dans des sous-dossiers. Commits signés avec l'email noreply GitHub (email perso en mode privé).

## Travail en cours

- Branchement de la veille mensuelle (routine cloud) sur le repo GitHub.
- Définition du modèle d'enforcement par hooks (mise à jour PROGRESS, placement des fichiers, nommage).
- Cadrage de la skill assistant (modes complet / allégé, aiguillage selon la taille de la feature).

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

1. Brancher la veille mensuelle (routine cloud) sur le repo.
2. Définir le modèle d'enforcement par hooks.
3. Cadrer la skill assistant (modes complet / allégé, aiguillage).
4. Figer `constitution` (template), gate `STACK_VALIDATION`, `docs/NAMING-CONVENTIONS.md`.
5. Construire le squelette et les templates.

## Références utiles

- `HANDOFF.md`, `CLAUDE.md`, `PLAN_PROJECT_OS_AI.md`, `PLAN_PROPOSITION_AMELIORATION.md`.
- `Unjque_Projet/docs/NAMING-CONVENTIONS.md`, `Unjque_Projet/docs/INDEX.md`, `Unjque_Projet/PROGRESS.md`.

## Contraintes importantes / À ne pas faire

- Ne pas imposer d'outil lourd : l'utilisateur n'est pas développeur, priorité à la simplicité.
- Aucune action critique sans validation humaine.
- Garder simple, Markdown-first, unifié.
- Règles non négociables tenues par des hooks, pas par de simples consignes.
