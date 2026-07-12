---
projet: MyProjectOS
type: Core
statut: en construction
derniere_maj: 2026-07-12
prochaine_action: T-PLAN-4 Phase 4 (workspace modèle + workflow commentaires) puis Phase 5 (wiring méthode v0.11.0, propagation, migration blue-cli D4 débloquée). En attente : vérification Hermès en session (profil MySecretaire créé le 2026-07-12, handoff 2026-07-12-1335 désormais actionnable). Aussi : T-R.3, banc d'essai Unjque (Phase 6), T-B.7 / T-C.11. Signalé : TeamLeader a 10 bloquants préexistants (fichiers sacrés Hybrid jamais greffés, --into-existing à envisager).
prochaine_echeance:
---

# PROGRESS.md — MyProjectOS

> Source de vérité opérationnelle. Lire en début de session, mettre à jour après chaque avancée significative.
> Règle immuable : toute mise à jour de ce fichier met aussi à jour le bloc d'en-tête ci-dessus.

## Objectif du projet

Concevoir et construire `MyProjectOS` : une méthodologie unifiée d'organisation de projets (Life / Code / Hybrid), pilotable par Claude Code (Mac) et Hermès (VPS), permettant de reprendre n'importe quel projet sans historique de conversation. Livrable : un repository de templates, règles, documentation, skill assistant et exemples.

## Contexte utile

- `PLAN/HANDOFF.md` : base de travail initiale, non figée. Tout peut être remis en question.
- Profil utilisateur : non-développeur. Sait exprimer le besoin fonctionnel, pas toujours la stack ni les bonnes pratiques techniques. A besoin d'être guidé et protégé, surtout sur l'avant du pipeline Code.
- Sync Mac/VPS : Syncthing. Détection projet : ouverture directe du dossier, profil Hermès isolé par projet.
- Ce projet sert de pilote : on dogfoode la méthode sur lui-même.
- Plans : `PLAN/PLAN_PROJECT_OS_AI.md` (construction), `PLAN/PLAN_PROPOSITION_AMELIORATION.md` (analyse et décisions), `PLAN/` (plans et documents de travail isolés avant intégration).
- Inspiration : `Unjque_Projet` (naming, index, format PROGRESS, identifiants CHG).
- Outils évalués (juin 2026) : Spec Kit (GitHub, MIT, amont spec→plan→tâches), Claude Code Harness (Chachamaru127, 2,4k★, plan→work→review→release + garde-fous Go, agnostique langage), mattpocock/skills (skills ciblées, ex `/grill-me`).
- NowStack : boilerplate Codelynx LLC (codelynx.dev/nowstack, page fermée/waitlist), mono-stack TanStack Start + React + Convex + Expo + Cloudflare + Stripe, optimisée Claude Code/Cursor (« +40 règles », types stricts). Essence reproductible = les « rails » : architecture par domaine fonctionnel + conventions fortes + règles agent + recettes d'ajout de feature + gate qualité. Mantra : « pas du vibe coding, du AI Building, l'IA code comme un senior parce qu'on lui donne les bons rails ».
- Développements faits principalement avec Claude Code.

## État actuel

Version `0.5.0` construite le 2026-07-07 : le plan production ready (`PLAN/plans/2026-07-06-plan-amelioration-production-ready.md`) est appliqué, ce qui clôt les Phases B et C (sauf T-B.7 revue documentaire et T-C.11 arbitrage des plans en attente). La méthode sait désormais se mettre à jour dans les projets existants (manifest `.myprojectos/manifest`, `check-update.sh`, `--update-method` avec sauvegarde), accompagne le cadrage et le rythme itératif (`docs/cycle-de-travail.md`, skill à 7 modes, `docs/INSTALL-AGENT.md`), intègre le RETEX comptabilité (`SUJETS.md`, source fraîche), outille la navigation Knowledge (orphelins, liens cassés, budgets), et passe une CI GitHub Actions. Deux exemples complets vivent dans `examples/`. Dogfooding : `check-project.sh .` à 0 bloquant / 0 avertissement. Détail : CHG-20260707-1100 ; raisons : DEC-0021 à DEC-0024.

Dépôt rendu public le 2026-07-07 (DEC-0021, T-A.2 close) : `https://github.com/Mediatros/MyProjectOS`. Commits, tag `v0.5.0` et release poussés ; CI GitHub Actions verte sur `main`. `install.sh` par `curl` et `check-update.sh` fonctionnent désormais depuis n'importe quelle machine, y compris le VPS Hermès.

## Décisions actées

Les décisions structurantes sont consignées dans `DECISIONS.md` (format `DEC-XXXX`, avec contexte, options, choix, raison, conséquences). L'historique daté des changements est dans `CHANGELOG.md` (`CHG-YYYYMMDD-HHMM`). Ce fichier ne garde que l'état courant.

## Travail en cours

- Plan consigné le 2026-07-12 (CHG-20260712-1250, T-PLAN-4) : brique Blue complète (`PLAN/plans/2026-07-12-blue-brique-complete-skill-agnostique.md`), qui englobe et amende T-PLAN-2 et T-PLAN-3. Contenu : skill technique portable `templates/skills/blue-app/` installable par les trois agents (Claude Code, Codex — support skills confirmé depuis déc. 2025, Hermès — agentskills.io), couche secrets multi-backend (trousseau, `bws`, fichier 600 VPS, env), copie canonique projet dans `98_configuration/skills/`, registre d'équipement dans `GOUVERNANCE_BLUE.md`, handoff « Équiper un agent », workflow commentaires Blue (demande humaine en commentaire de carte → action agent → feedback). Vérifié en live : `templates` query et `convertWorkspaceToTemplate` (referme le §5.4 de T-PLAN-3). Décisions D1-D5 tranchées par l'utilisateur le 2026-07-12 (skill `blue-app`, conversion template par l'agent avec accord explicite, Hermès par copie globale, migration de `blue-cli` après validation de la Phase 2, Windows documenté seul). **Phase 1 faite le 2026-07-12** (feu vert donné) : `templates/skills/blue-app/` créé (SKILL.md, INSTALL.md, scripts/blue-secrets.sh + blue-cli.sh + blue-gql.sh, POSIX, testés en réel : 7 tests passés — keychain/env/file, refus permissions 644, erreurs GraphQL → exit 1, config.env jamais résiduel, aucun secret échoé ; contre-vérifié par l'orchestrateur : `--check` OK 7 workspaces, query `templates` OK, `check-project.sh` toujours 0 bloquant). **Phase 2 faite le 2026-07-12** (banc d'essai MySecretaire, CHG-20260712-1345) : skill validée par exécution réelle sur les trois agents (Claude Code `.claude/skills/` + trousseau ; Codex 0.144.1 `.codex/skills/` + trousseau, découverte confirmée ; Hermès copie globale `/root/.hermes/skills/blue-app/`, backend `file` posé en SSH, listée par `hermes skills list`), D3 figé (copie globale), `INSTALL.md` propagé aux 4 instances. Constats : la couche Bitwarden d'Hermès applique déjà `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` (voie env, `file` devient un repli) ; aucun profil Hermès `MySecretaire` sur le VPS au moment de la Phase 2 (profil créé par l'utilisateur le 2026-07-12 en fin de journée : le handoff est désormais actionnable). **Phase 3 faite le 2026-07-12** (CHG-20260712-1658) : recettes GraphQL par domaine exécutées en réel sur le banc d'essai MySecretaire puis figées dans le `SKILL.md` — documents/wiki, formulaires (une soumission devient un record du workspace, `formToken` = `uid`), discussions (message = `createComment`), chat, status updates (immuables, piège timeout `deleteStatusUpdate`), fichiers avec **upload presigned validé de bout en bout** via le nouveau `scripts/blue-files.sh` (la mutation GraphQL `uploadFile` est inutilisable en JSON : voie REST `GET /uploads` → PUT → `createFile`) ; table de routage CLI/GraphQL complète ; pièges transverses consignés (pagination, retours de delete, `String!`/`ID!`, `companyId` = ID d'org pas slug) ; skill portée à `1.1.0` et propagée aux 4 instances ; objets de test tous supprimés, critères T-PLAN-2 § 4 satisfaits. Rien commité. Vigilance Phase 4 : le `SKILL.md` de la skill fait 19 175 caractères, proche du seuil de troncature Hermès (20 000) — avant de l'enrichir encore (workflow commentaires, recette workspace modèle), envisager d'externaliser les recettes GraphQL dans un fichier compagnon (ex. `RECETTES.md`) référencé par le `SKILL.md`. Prochaines étapes : Phase 4 (workspace modèle + workflow commentaires), Phase 5 (wiring v0.11.0, migration `blue-cli` D4).
- Plan consigné le 2026-07-12 (CHG-20260712-1223, T-PLAN-2) : extension GraphQL de la skill globale `blue-cli` (`PLAN/plans/2026-07-12-blue-cli-extension-graphql.md`). Constat vérifié en live : le token du trousseau fonctionne tel quel sur `api.blue.app/graphql`, qui expose ce que la CLI ne couvre pas (wiki/documents, formulaires, discussions, chat, upload de fichiers, status updates). Proposition en 4 phases (wrapper `blue-gql.sh`, recettes validées, routage CLI d'abord, validation de bout en bout), en attente d'arbitrage humain. Après application : enrichir `GOUVERNANCE_BLUE.md`.
- v0.10.0 posée et publiée le 2026-07-12 (DEC-0028, CHG-20260712-1145) : la skill assistant propose désormais Blue activement, plutôt que d'attendre que l'utilisateur amène le sujet. Mode 5 (Cadrage), étape 8 : question fermée « utilises-tu un outil de suivi ? », présentation de Blue en une phrase, activation immédiate du gabarit `GOUVERNANCE_BLUE.md` si oui. Mode 6 (Adoption), étape 6 : même proposition une fois `TASKS.md` peuplé. Choix explicite de l'utilisateur : proposer par défaut à tout adoptant du dépôt public, sans détection de disponibilité de Blue sur la machine (alternative écartée, gardée en mémoire si le dépôt gagne des adoptants externes). Aucun wiring `init-project.sh`/`check-project.sh` : geste de session, pas un flag d'installation. **Publiée** : commit unique regroupant v0.9.0+v0.10.0, push `main`, tag `v0.10.0`, release GitHub (`https://github.com/Mediatros/MyProjectOS/releases/tag/v0.10.0`). **Propagée** via `--update-method` aux trois projets structurés (LaCIOTAT 0.8.0→0.10.0, Comptabilite_globale et TeamLeader 0.7.0→0.10.0), migration consignée dans le `CHANGELOG.md` de chacun (`CHG-20260712-1200`) ; bilans `check-project.sh` inchangés après migration (LaCIOTAT 0 bloquant/3 avertissements, Comptabilite_globale 0/5, TeamLeader 10 bloquants préexistants/2 — rien cassé). `GOUVERNANCE_BLUE.md` de LaCIOTAT non touché (reste la source vécue, plus riche que le gabarit).
- v0.9.0 posée le 2026-07-12 : idée « Blue en brique optionnelle » traitée (DEC-0027, CHG-20260712-1130). Comparaison de deux projets Blue indépendants (LaCIOTAT/`myagent`, mode miroir `TASKS.md` ; Unjque_Projet/`unjque`, hors méthode, registre autonome) a confirmé au niveau outil des pièges CLI communs (`-w` obligatoire sur update, description multi-ligne → `Unterminated string`, checklist en deux commandes) et, au niveau usage, que seul le mode miroir `TASKS.md` est pertinent pour un gabarit MyProjectOS (Unjque n'a pas de `TASKS.md`). Nouveau gabarit `templates/configuration/GOUVERNANCE_BLUE.md`, pré-rempli (nommage, checklists, workflow de synchro, pièges CLI), à préférer au gabarit générique vide `GOUVERNANCE_INTEGRATION.md`. `docs/NAMING-CONVENTIONS.md` et la skill assistant signalent la préséance d'une variante pré-remplie par outil. Publication et propagation : voir bullet v0.10.0 ci-dessus (les deux versions sont sorties dans le même commit).
- v0.8.0 posée le 2026-07-12 (Phase S, T-S.1 à T-S.5) à partir de l'issue GitHub #1 / RETEX LaCIOTAT `98_configuration/` : dossier optionnel canonisé pour la gouvernance d'intégrations tierces partagées entre agents et le handoff asynchrone inter-agents (gabarits génériques `templates/configuration/HANDOFF_INTERAGENT.md` et `GOUVERNANCE_INTEGRATION.md`), garde-fou temps réel étendu aux collisions de préfixe `NN_` dans `hook-pre-write.sh` (referme l'angle mort des abréviations que T-R.1/T-R.2 ne couvraient pas), consigne active dans la skill qui clôt au passage T-R.4. Voir DEC-0026, CHG-20260712-1110. **Reste à faire** : `sh scripts/validate.sh`-équivalent (skill `validate`) pour vérifier par exécution (projet test, hook testé sur une collision de préfixe), puis propagation `--update-method` aux trois projets structurés (LaCIOTAT en premier, à l'origine du RETEX) — pas encore fait.
- v0.7.0 publiée le 2026-07-10 (tag + release GitHub, CI verte) puis propagée via `--update-method` aux trois projets structurés (LaCIOTAT, Comptabilite_globale, TeamLeader, tous 0.6.0 → 0.7.0, migrations consignées dans leur CHANGELOG). Apport : garde-fous dossiers racine (T-R.1/T-R.2). Le nouveau contrôle passe à [ok] sur les trois projets.
- Historique git réécrit le 2026-07-10 (filter-branch sur main + les 7 tags, force-push, releases intactes) : suppression de tous les trailers `Co-Authored-By: Claude`. Règle permanente : aucune signature Claude/Anthropic dans les commits, PR ou releases.
- Ouvert : T-B.7 (mode revue documentaire périodique), T-C.11 (statuer sur les plans en attente Company OS / SecondBrain PKB / Steward OS, avec T-PLAN-1), T-R.3 (installeur non aveugle).
- RETEX LaCIOTAT du 2026-07-09 (`RETEX/retex-laciotat-doublon-archives.md`, CHG-20260709-2350) : un quasi-doublon de dossier racine (`99_archives`/`99_archive`) a traversé les trois couches d'enforcement, qui contrôlaient les fichiers mais pas les dossiers. Phase R : T-R.1, T-R.2 (2026-07-09) et T-R.4 (2026-07-12, généralisé via Phase S) faits ; reste T-R.3 (installeur). Propagé aux projets avec la v0.7.0.

## Besoins Code identifiés (trois couches)

1. Amont (spec, stack, séquençage) : couvert par Spec Kit + interrogation type `/grill-me`. Couche la plus critique pour l'utilisateur.
2. Exécution encadrée : couvert par Claude Code Harness.
3. Architecture « Agent First » : non fournie par les outils de process. Modèle retenu = un « kit de rails » par type de stack. Chaque kit = `ARCHITECTURE.md` (domaine fonctionnel + séparation des responsabilités) + conventions/typage + règles agent (CLAUDE.md/AGENTS.md) + recettes d'ajout de feature + gate qualité. Pièce maîtresse : la recette (rail générique) couplée à IMPACT_ANALYSIS (instance précise). Pas de boilerplate unique car projets hétérogènes (WordPress, n8n, SaaS).

## Problèmes ouverts / points de vigilance

- `check-project.sh` détecte désormais le repo méthode et exclut `templates/`, `examples/`, `PLAN/` et `NAMING-CONVENTIONS.md` des scans de contenu : le dogfooding vise 0 avertissement.
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
6. Phase A : installation réelle par un agent. **Faite**, y compris T-A.2 (dépôt public depuis le 2026-07-07).
7. Phase B : méthode 2 (adoption) + mise à jour de version. **Faite le 2026-07-07** (sauf T-B.7).
8. Phase C : navigation 3 niveaux, RETEX, qualité générale. **Faite le 2026-07-07** (sauf T-C.11).
9. Publication : push v0.5.0 + tag + release + dépôt public. **Prochaine étape.**
10. Phase 6 : banc d'essai Unjque, puis passage à `1.0.0` (DEC-0015).
11. Phase 7 (ROADMAP) : portabilité Hermès.

## Références utiles

- `TASKS.md` : plan de construction détaillé (source pour la reprise après `/clear`).
- `PLAN/plans/2026-07-02-audit-industrialisation-methode.md` : plan en cours (Phase A/B/C).
- `PLAN/HANDOFF.md`, `CLAUDE.md`, `PLAN/PLAN_PROJECT_OS_AI.md`, `PLAN/PLAN_PROPOSITION_AMELIORATION.md`.
- `Unjque_Projet/docs/NAMING-CONVENTIONS.md`, `Unjque_Projet/docs/INDEX.md`, `Unjque_Projet/PROGRESS.md`.

## Contraintes importantes / À ne pas faire

- Ne pas imposer d'outil lourd : l'utilisateur n'est pas développeur, priorité à la simplicité.
- Aucune action critique sans validation humaine.
- Garder simple, Markdown-first, unifié.
- Règles non négociables tenues par des hooks, pas par de simples consignes.
