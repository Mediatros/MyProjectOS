# meta-skill.md — La skill assistant MyProjectOS

> Carte d'identité de la pièce centrale du système : la skill qui pilote les projets.
> Le « quoi » et le « pourquoi » vivent ici. Le « comment » exécutable vit dans `skills/my-project-os/SKILL.md`.

## Rôle

La skill assistant est le cerveau opérationnel de MyProjectOS. Elle applique la méthode à la place de l'utilisateur : lire les fichiers sacrés, produire un état fiable, ranger l'information au bon endroit, expliquer le système, clôturer proprement. Elle rend concret le principe de **reprise à froid** (voir `docs/principles.md`, principe 7).

Elle accompagne, elle n'enferme pas. Les règles vraiment non négociables ne reposent pas sur elle mais sur les hooks (Phase 4). La skill est la couche « accompagnement » de l'enforcement à trois couches (documentation / skill / hooks).

## Les sept modes

### 1. Reprise
Déclencheur : « Reprends le projet », ouverture d'un dossier de projet, début de session.
Action : lire dans l'ordre `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md` (+ fichiers d'extension présents). Produire en sortie :
- **État actuel**
- **Dernière action**
- **Prochaine action**
- **Points de vigilance**

C'est le mode par défaut. Aucun historique de conversation requis. La reprise débouche sur **une** tâche : celle de l'itération (voir `docs/cycle-de-travail.md`).

### 2. Orientation
Déclencheur : « Où je range ça ? », un document arrive, une info doit être consignée, on lance une feature.
Action : aiguiller vers le bon fichier sacré (frontière de `docs/governance.md`) ou le bon dossier numéroté (`structures/*-tree.md`). Pour une demande métier dans un projet dense : `SUJETS.md` d'abord, source fraîche prioritaire avant toute synthèse. Pour un projet Code, arbitrer entre **parcours complet** et **parcours allégé** (voir ci-dessous).

### 3. Explication
Déclencheur : « C'est quoi ce fichier ? », « Pourquoi cette règle ? », utilisateur non-développeur qui veut comprendre.
Action : expliquer un fichier, une convention, un identifiant (`CHG`/`DEC`/`P`/`F`/`IA`/`Tx.y`), un dossier ou un principe, en langage simple, sans jargon. Renvoyer aux docs du repo méthode pour le détail.

### 4. Clôture
Déclencheur : « On s'arrête », fin de session, changement de sujet, tâche de l'itération terminée (la skill la propose alors d'elle-même).
Action : mettre à jour tous les fichiers Core concernés (PROGRESS + son en-tête, CHANGELOG, DECISIONS, TASKS), puis produire le résumé : **fait / reste / décisions / risques / prochaine action**. Suggérer `/clear`. Garantir que la reprise à froid sera possible.

### 5. Cadrage (et initialisation)
Déclencheur : dossier vide, « je démarre un projet », `PROJECT.md` resté en gabarit.
Action : interview guidée, une question à la fois (pourquoi, périmètre inclus/exclu, critères de réussite, risques, type et extensions), pose de la structure, `PROJECT.md` pré-rempli soumis à relecture. Volet Code : `CONSTITUTION` → `STACK_VALIDATION` (gate sourcé) → `SPECS` + clarify → découpage de `TASKS.md` en itérations.

### 6. Adoption
Déclencheur : dossier peuplé sans `PROJECT.md`, « mets ce projet sous méthode ».
Action : protocole `docs/INSTALL-AGENT.md` méthode 2 — inventaire en lecture seule, classification, proposition de mapping, **validation humaine avant tout déplacement**, greffe `--into-existing`, remplissage assisté des fichiers sacrés, rapport `CHG-`.

### 7. Mise à jour de la méthode
Déclencheur : « y a-t-il une mise à jour ? », avertissement de version du check.
Action : détecter (`scripts/check-update.sh`), auditer (apports des versions, artefacts remplacés, contenu jamais touché), questions fermées de validation, appliquer (`--update-method`, sauvegarde dans `99_archive/`), vérifier et tracer (`check-project.sh` + entrée `CHG-`). Jamais d'application sans validation. Détail : `docs/versioning.md`.

## Aiguillage Code : complet vs allégé

Pour les projets Code, l'orientation arbitre selon l'ampleur du changement.

| Critère | Allégé | Complet |
|---|---|---|
| Nature | Correctif, ajustement localisé, petite feature suivant une recette existante | Nouvelle fonctionnalité d'ampleur, nouveau domaine, changement d'architecture ou de stack |
| Amont | `IMPACT_ANALYSIS.md` léger (`IA-XXX`) | `SPECS.md` (`F-XXX`) + réflexe clarify, puis `IMPACT_ANALYSIS.md` |
| Gate stack | Seulement si nouvelle techno/version | `STACK_VALIDATION.md` validé avant la première ligne de code |
| Exécution | Directe, encadrée par la recette du kit de rails | Parcours encadré (Harness, Phase 5) |
| Validation | Tests + gate qualité du kit | `TEST_PLAN.md` + `RELEASE.md` |

Règle de prudence : en cas de doute sur l'ampleur, choisir le parcours complet. Toute action sensible (changement de stack, suppression massive, déploiement, push important) passe par validation humaine, quel que soit le parcours.

## Frontières de la skill

- Elle **propose et exécute la méthode**, elle ne tranche pas les choix structurants : elle éclaire (options, avantages, inconvénients, recommandation) et laisse l'humain décider (`docs/lifecycle.md`, étape 4).
- Elle ne remplace pas les hooks : ce qui doit être garanti à 100 % (MAJ PROGRESS en fin de session, nommage, placement) relève de la Phase 4.
- Elle est **agent-agnostique dans son intention** mais s'exécute côté Claude Code. La portabilité vers Hermès passe par la couche gouvernance Markdown (voir `agents/hermes.md`), pas par la skill elle-même.

## Voir aussi

- `skills/my-project-os/SKILL.md` — implémentation exécutable.
- `agents/claude-code.md`, `agents/hermes.md` — rôles et frontières des deux agents.
- `docs/governance.md`, `docs/lifecycle.md`, `docs/principles.md` — règles que la skill applique.
