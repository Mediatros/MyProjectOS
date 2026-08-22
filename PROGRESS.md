---
projet: MyProjectOS
type: Core
statut: en construction
derniere_maj: 2026-08-21
prochaine_action: Propager --update-method aux quatre projets en retard (Projet Alpha, Projet Delta, Projet Epsilon, Projet Beta) ; puis A6 du plan Pro Workflow (inventaire lisible des hooks) ; acter la publication de v0.21.0 (T-PUB-1).
prochaine_echeance:
---

# PROGRESS.md — MyProjectOS

> Source de vérité opérationnelle. Lire en début de session, mettre à jour après chaque avancée significative.
> Règle immuable : toute mise à jour de ce fichier met aussi à jour le bloc d'en-tête ci-dessus.
> Fichier purgé le 2026-08-21 (étape 1, DEC-0041) : l'historique vit dans `CHANGELOG.md` et `99_archive/`.

## Objectif du projet

Concevoir et construire `MyProjectOS` : une méthodologie unifiée d'organisation de projets (Life / Code / Hybrid), pilotable par Claude Code (Mac) et Hermès (VPS), permettant de reprendre n'importe quel projet sans historique de conversation. Livrable : un repository de templates, règles, documentation, skill assistant et exemples.

## Contexte utile

- Profil utilisateur : non-développeur. Sait exprimer le besoin fonctionnel, pas toujours la stack ni les bonnes pratiques techniques. A besoin d'être guidé et protégé.
- Sync Mac/VPS : Syncthing. Détection projet : ouverture directe du dossier, profil Hermès isolé par projet.
- Ce projet sert de pilote : on dogfoode la méthode sur lui-même.
- Plans : `PLAN/` (plans et documents de travail isolés avant intégration).
- Développements faits principalement avec Claude Code.

## État actuel

Version `0.22.0` publiée le 2026-08-08 (DEC-0040, CHG-20260808-1130) : Hermès reçoit le catalogue de skills par déclaration `skills.external_dirs`, copie physique globale abandonnée, OpenCode acté comme quatrième agent. Dépôt public : `https://github.com/Mediatros/MyProjectOS`. `check-project.sh .` à 0 bloquant.

Le 2026-08-21 : archivage des entrées `CHG-` antérieures au 2026-08-01 dans `99_archive/CHANGELOG-2026.md` et purge de ce fichier (étape 1, DEC-0041, CHG-20260821-2157). Voir `99_archive/INDEX.md`.

## Décisions actées

Les décisions structurantes sont consignées dans `DECISIONS.md` (format `DEC-XXXX`, avec contexte, options, choix, raison, conséquences). L'historique daté des changements est dans `CHANGELOG.md` (`CHG-YYYYMMDD-HHMM`). Ce fichier ne garde que l'état courant.

## Travail en cours

- **T-PLAN-10 — writing-unslop** : conservée localement dans Hermes (légère préférence l'utilisateur), candidature MyProjectOS ouverte, licence à clarifier. Tests : léger avantage synthétique, aucune différence utile sur email réel.
- **T-RETEX-4 — RETEX préliminaire multi-progress Projet Beta** : observation du 2026-08-13 au 2026-08-20 close, arbitrage à faire (dérives parent/local, conflits Syncthing, lecture ciblée du changelog).
- **T-PLAN-9 — Agent Plugins v1 portables** : format de distribution optionnel à arbitrer, POC isolé si validé, aucun changement de méthode sans GO.
- **T-PLAN-8 — Extension Knowledge v2 (hiérarchie 4 niveaux)** : **arbitré le 2026-08-22 (DEC-0043, CHG-20260822-0918)** — structure 4 niveaux rejetée après challenge multi-modèles ; doctrine « carte jamais territoire » intégrée (carte / Vision / Domaines / Détails, zone froide unique `99_archive/knowledge/`). Voir TASKS.md pour le détail des modifications.
- **Dette de propagation** : les quatre projets structurés (Projet Alpha, Projet Delta, Projet Epsilon, Projet Beta) sont en retard de méthode et attendent `--update-method` (détection de retard active, application manuelle requise).

## Besoins Code identifiés (trois couches)

1. Amont (spec, stack, séquençage) : couvert par Spec Kit + interrogation type `/grill-me`. Couche la plus critique pour l'utilisateur.
2. Exécution encadrée : couvert par Claude Code Harness.
3. Architecture « Agent First » : non fournie par les outils de process. Modèle retenu = un « kit de rails » par type de stack. Chaque kit = `ARCHITECTURE.md` (domaine fonctionnel + séparation des responsabilités) + conventions/typage + règles agent (CLAUDE.md/AGENTS.md) + recettes d'ajout de feature + gate qualité. Pièce maîtresse : la recette (rail générique) couplée à IMPACT_ANALYSIS (instance précise). Pas de boilerplate unique car projets hétérogènes (WordPress, n8n, SaaS).

## Problèmes ouverts / points de vigilance

- **3 avertissements résiduels `check-project.sh`** (mesuré 2026-08-08, toujours d'actualité) : placeholder de nom de projet dans `.claude/skills/validate/SKILL.md` et `add-extension/SKILL.md` (légitime), `CHG-20260714-1945` cité sans entrée. À trancher : corriger l'exclusion ou acter la cible à 3.
- **Deux avertissements parasites sur tout projet fraîchement généré** : « DEC-0037/DEC-0039 cités mais non définis » (skill distribuée cite des décisions du dépôt méthode). Voies à arbitrer : retirer les identifiants DEC- de la skill ou exclure `.claude/skills/` du contrôle de citations. La batterie `validate` annonce « 1 avertissement attendu » et devra suivre.
- **Détection de retard de méthode** : corrigée le 2026-08-08 (DEC-0039, v0.21.0). Limite assumée : garantie au niveau skill, dépend de l'exécution de l'agent ; garantie déterministe = montée de cran distincte (option D de DEC-0039).
- **Sujet figé le 2026-08-04 (revue docs N2 Hermes)** : `[chemin serveur]` — périmètre registre vs services.md, nommage, fiches N2 restantes. Tant que non tranché : ne pas modifier `hermes-registre.md`, `services.md`, `governance.md` ni leur structure.
- **Compatibilité des versions de stack** : aucun outil ne la garantit. Valeur ajoutée à construire (gate `STACK_VALIDATION`).
- **Portabilité de la gouvernance vers Hermès** : Hermès consomme les fichiers Markdown mais n'exécute pas Harness. À terme : exposer skill assistant + règles via MCP partagé ou double skill. Reporté ROADMAP.
- **Projet Epsilon** : 10 bloquants préexistants (fichiers sacrés Hybrid jamais greffés) — `--into-existing` à envisager lors de la propagation.

## Prochaines étapes

Détail dans `TASKS.md`. Vue macro :
1. Propager `--update-method` aux 4 projets en retard (P0, T-PUB-1 reliée).
2. Acter la publication de v0.21.0 (tag + release) si encore nécessaire.
3. A6 du plan Pro Workflow (inventaire lisible des hooks), puis A1/A2.
4. Arbitrages en cours : T-PLAN-9, T-PLAN-7, T-PLAN-6 (T-PLAN-8 arbitré le 2026-08-22).
5. Phase 6 : banc d'essai Projet Zeta, puis passage à `1.0.0` (DEC-0015).

## Références utiles

- `TASKS.md` : plan de construction détaillé (source pour la reprise après `/clear`).
- `99_archive/INDEX.md` : index des archives (historique froid, consulté sur demande).
- Documents de passation et de plan internes, `CLAUDE.md`.

## Contraintes importantes / À ne pas faire

- Ne pas imposer d'outil lourd : l'utilisateur n'est pas développeur, priorité à la simplicité.
- Aucune action critique sans validation humaine.
- Garder simple, Markdown-first, unifié.
- Règles non négociables tenues par des hooks, pas par de simples consignes.
