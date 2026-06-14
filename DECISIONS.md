# DECISIONS.md — MyProjectOS

> Pourquoi des choix structurants. Décisions importantes uniquement, pas les détails d'exécution.
> Chaque décision porte un identifiant stable `DEC-XXXX` et pointe vers les entrées `CHG-` liées.
> Frontière : l'état actuel vit dans `PROGRESS.md` ; ce qui a changé et quand dans `CHANGELOG.md`.

## Format d'une décision

```
### DEC-XXXX — Titre de la décision
- **Date** : YYYY-MM-DD
- **Contexte** : le problème ou le besoin qui a forcé un choix.
- **Options envisagées** : option A, option B, option C.
- **Choix** : l'option retenue.
- **Raison** : pourquoi celle-là plutôt que les autres.
- **Conséquences** : ce que ce choix implique ou contraint.
- **Liens** : CHG-YYYYMMDD-HHMM.
```

---

### DEC-0001 — Regrouper les extensions sous `templates/extensions/`

- **Date** : 2026-06-13
- **Contexte** : le dossier `templates/` mélangeait le socle (`core/`) et les modules activables (`life/`, `code/`, `knowledge/`) au même niveau, ce qui ne rendait pas lisible la distinction socle / extension.
- **Options envisagées** :
  - A. Renommer `templates/` en `extensions/`.
  - B. Sortir `core/` à la racine, puis renommer `templates/` en `extensions/`.
  - C. Renommer `templates/` en `modules/`.
  - D. Garder `templates/`, créer `templates/extensions/` et y déplacer les trois modules.
- **Choix** : option D.
- **Raison** : principe « nature d'abord, rôle ensuite ». Niveau 1 = nature (`templates/` = des gabarits inertes copiés par `init-project.sh`) ; niveau 2 = rôle (`core/` socle vs `extensions/` activables). A est contradictoire car `core/` n'est pas une extension. B perd le signal « gabarit » et entre en collision avec le dogfooding (le repo a déjà ses propres `PROGRESS.md`, `TASKS.md` réels à la racine). C induit en erreur : « module » évoque une unité logicielle qui fait quelque chose, or ce ne sont que des fichiers Markdown.
- **Conséquences** : une extension = sa description dans `structures/<x>-tree.md` + ses gabarits dans `templates/extensions/<x>/`. Seul l'emplacement des gabarits a changé, le concept est inchangé. Les chemins en dur dans le script et les docs ont dû être alignés.
- **Liens** : CHG-20260613-2055, CHG-20260613-2226. Détail du raisonnement : `PLAN/handoff-2026-06-13-renommage-templates-extensions.md`.

### DEC-0002 — Structure de projet : dossiers numérotés créés à la demande

- **Date** : 2026-06-07 (consignée)
- **Contexte** : définir l'arborescence physique d'un projet sans imposer une coquille vide lourde à un non-développeur.
- **Choix** : dossiers numérotés (`00_inbox` … `99_archive`), rôles fixés par la gouvernance, créés à la demande plutôt qu'imposés d'emblée. Archive = `99_archive/`.
- **Raison** : éviter le squelette vide intimidant ; laisser la structure émerger au besoin tout en gardant des rôles stables.
- **Conséquences** : le détail des rôles de chaque dossier reste à finaliser une fois la gouvernance posée.

### DEC-0003 — Enforcement à trois couches

- **Date** : 2026-06-07 (consignée)
- **Contexte** : garantir le respect des règles de la méthode sans compter uniquement sur la bonne volonté de l'agent.
- **Choix** : trois couches, documentation (règles), skill assistant (accompagnement), hooks (déterministe). Les non-négociables passent par des hooks.
- **Raison** : une consigne Markdown peut être ignorée ; seul un hook garantit un comportement.
- **Conséquences** : voir DEC-0008 pour l'implémentation technique des hooks.

### DEC-0004 — PROGRESS toujours à jour, garanti par hook

- **Date** : 2026-06-07 (consignée)
- **Contexte** : `PROGRESS.md` est la source de vérité opérationnelle ; sa fraîcheur conditionne toute reprise fiable.
- **Choix** : règle immuable, PROGRESS et son bloc d'en-tête sont toujours à jour, garantie par un hook de fin de session.
- **Raison** : une source de vérité périmée est pire qu'absente.
- **Conséquences** : toute mise à jour de PROGRESS doit aussi mettre à jour le frontmatter.

### DEC-0005 — Frontière entre les fichiers sacrés

- **Date** : 2026-06-07 (consignée)
- **Contexte** : éviter que PROGRESS, CHANGELOG et DECISIONS se chevauchent et deviennent redondants.
- **Choix** : PROGRESS = photo de l'instant ; CHANGELOG = registre daté (`CHG-YYYYMMDD-HHMM`) ; DECISIONS = le pourquoi (`DEC-XXXX` reliés aux CHG).
- **Raison** : chaque fichier répond à une seule question (où en est-on / qu'a-t-il changé / pourquoi ce choix).
- **Conséquences** : les décisions structurantes vivent ici, pas dans PROGRESS ; PROGRESS ne garde que l'état courant.

### DEC-0006 — PROGRESS aligné sur le CLAUDE.md global, anatomy abandonné

- **Date** : 2026-06-07 (consignée)
- **Contexte** : cohérence entre la structure de PROGRESS du projet et les règles globales de l'utilisateur.
- **Choix** : aligner PROGRESS sur le `CLAUDE.md` global ; abandonner `anatomy.md` comme fichier suivi.
- **Raison** : éviter deux conventions divergentes ; `anatomy.md` est auto-régénéré et n'a pas à être versionné.
- **Conséquences** : `anatomy.md` reste non suivi.

### DEC-0007 — Skill assistant livrée comme skill Claude Code installable

- **Date** : 2026-06-07 (consignée)
- **Contexte** : l'assistant de méthode est la pièce centrale pour un non-développeur, pas un bonus.
- **Options envisagées** : simple spécification Markdown ; skill Claude Code installable.
- **Choix** : skill installable (`skills/my-project-os/SKILL.md`), avec 4 modes (reprise / orientation / explication / clôture).
- **Raison** : être réellement dogfoodable et exécutable, pas seulement décrit.
- **Conséquences** : nouveau dossier `skills/` ajouté au repo.

### DEC-0008 — Hooks d'enforcement en sh POSIX, par projet, fermeté hybride

- **Date** : 2026-06-07 (consignée)
- **Contexte** : implémenter la couche déterministe de DEC-0003 de façon portable Mac/VPS.
- **Choix** : hooks en `sh` POSIX (dégradation silencieuse si `python3`/`jq` absents), portée par projet (scripts dans le repo méthode, câblés via le `.claude/settings.json` posé par `init-project.sh`, config globale non touchée), fermeté hybride (bloque le nommage avec espaces/accents et le placement de document à la racine ; avertit sans bloquer sur la fraîcheur de PROGRESS via le signal git).
- **Raison** : portabilité, non-intrusion sur la config globale, et fermeté proportionnée au risque.
- **Conséquences** : implémente DEC-0003 ; documenté dans `docs/enforcement.md`.

### DEC-0009 — Volet Code : gate de validation de stack avant tout code

- **Date** : 2026-06-07 (consignée)
- **Contexte** : un non-développeur ne maîtrise pas la compatibilité des versions ; aucun outil ne la garantit.
- **Choix** : gate `STACK_VALIDATION` avec compatibilité vérifiée et sourcée avant la première ligne de code ; `IMPACT_ANALYSIS` avant toute modification ; conseil de séquençage.
- **Raison** : protéger l'avant du pipeline Code, couche la plus critique pour l'utilisateur.
- **Conséquences** : `STACK_VALIDATION.md` obligatoire ; valeur ajoutée maison sourcée dans `docs/stack-validation-gate.md`.

### DEC-0010 — Extensions MCP reportées en ROADMAP

- **Date** : 2026-06-07 (consignée)
- **Contexte** : tentation d'intégrer tôt Calendar, Gmail, Drive.
- **Choix** : reporter ces extensions MCP en ROADMAP.
- **Raison** : rester simple et centré sur le socle avant d'ajouter des intégrations externes.
- **Conséquences** : non implémentées dans la version courante.

### DEC-0011 — Extension Knowledge comme brique transverse optionnelle

- **Date** : 2026-06-07
- **Contexte** : besoin de navigation progressive et de gestion de dépendances dans des projets riches en documentation.
- **Choix** : activer Knowledge comme brique transverse optionnelle, non comme nouveau type de projet. Elle formalise la navigation progressive (`docs/INDEX.md`, niveaux global/domaines/détails), l'analyse des dépendances transverses avant modification, les plans et runbooks.
- **Raison** : garder Knowledge orthogonale à Life/Code sans dupliquer. Understand-Anything reste un outil complémentaire, pas une source de vérité.
- **Conséquences** : `structures/knowledge-tree.md`, `templates/extensions/knowledge/`, `scripts/init-project.sh --knowledge`.

### DEC-0012 — Colonne vertébrale Code = Harness, emprunts Spec Kit figés

- **Date** : 2026-06-07 (consignée)
- **Contexte** : choisir un moteur d'exécution encadrée côté Code sans cumuler deux outils.
- **Options envisagées** : Spec Kit comme moteur ; Harness comme moteur ; combinaison des deux moteurs.
- **Choix** : Harness exécuté côté Mac/Claude Code, avec emprunt à Spec Kit (sous forme de documents Markdown figés) de la constitution et du réflexe clarify. Deux modes : complet / allégé.
- **Raison** : un seul outil exécuté, aucune couture entre deux moteurs ; suit Claude Code, garde-fous déterministes natifs, surfaces HTML non-dev, charge minimale pour un non-développeur.
- **Conséquences** : `docs/harness.md`, `docs/clarify.md`, `templates/extensions/code/CONSTITUTION.md`. État réel juin 2026 : garde-fous natifs Go, 5 verbes (setup/plan/work/review/release), surfaces HTML, MIT, Claude Code v2.1+.

### DEC-0013 — Veille mensuelle upstream via routine planifiée

- **Date** : 2026-06-07 (consignée)
- **Contexte** : suivre l'évolution des outils amont (Spec Kit, Harness) sans intégration automatique risquée.
- **Choix** : routine planifiée Claude Code (cloud Anthropic) le 1er du mois, qui compare l'état des deux repos à un état mémorisé et écrit un rapport dans `docs/veille/VEILLE-OUTILS.md` avec verdict (à intégrer / à surveiller / à ignorer). Elle propose, n'intègre jamais seule.
- **Raison** : rester à jour tout en gardant la décision d'intégration humaine.
- **Conséquences** : prérequis projet sur GitHub ; VPS = plan B. Routine `veille-outils-upstream` (id `trig_01UTxP1TgxFUVUsap7KkY6Ta`), cron `0 8 1 * *`, modèle sonnet-4-6, écriture sur `main`. Premier passage réel : 2026-07-01.

### DEC-0016 — Le check vérifie la conformité de contenu, pas seulement l'empreinte

- **Date** : 2026-06-14
- **Contexte** : l'empreinte `version_methode` (DEC-0015) est déclarative, posée à la main. Un projet peut afficher la bonne version tout en restant, dans son contenu, sur l'ancienne convention (ex : dates `JJ/MM/AAAA` alors que la méthode impose `YYYY-MM-DD`). Le check ne regardait la date qu'au champ `derniere_maj`, pour la fraîcheur, et ne scannait jamais le contenu.
- **Choix** : ajouter à `check-project.sh` une détection de non-conformité de contenu, en commençant par le format de date (dates `JJ/MM/AAAA`, mois en toutes lettres, champs datés hors `YYYY-MM-DD`). Avertissement non bloquant.
- **Raison** : un versionnement sans détection concrète est creux. L'empreinte dit « sur quelle version je suis né » ; la conformité de contenu dit « est-ce que je respecte vraiment les conventions courantes ». Les deux se complètent.
- **Conséquences** : `check-project.sh` gagne une section « Format de date » ; version portée à `0.2.0` (nouvelle capacité = évolution mineure). D'autres contrôles de conformité pourront s'ajouter sur le même principe.
- **Liens** : CHG-20260614-2100.

### DEC-0015 — Versionnement de la méthode en SemVer simplifié, démarrage à 0.1.0

- **Date** : 2026-06-14
- **Contexte** : la méthode évolue (ex : passage des dates françaises au format `YYYY-MM-DD`) sans qu'aucun numéro ne dise dans quelle version on est, ni si un projet existant suit encore les règles courantes. Le template `PROJECT.md` portait un `methode: my-project-os v1` statique, non relié à une vraie version.
- **Options envisagées** :
  - A. Garder un libellé statique (`v1`) sans mécanique.
  - B. Versionner via les seules entrées datées `CHG-` du CHANGELOG.
  - C. Numéro `MAJEUR.MINEUR.CORRECTIF` dans un fichier `VERSION`, estampille dans chaque projet, check d'alignement.
- **Choix** : option C, démarrage à `0.1.0`.
- **Raison** : une source de vérité unique (`VERSION`) lisible par l'humain et les scripts ; un format standard et compréhensible ; une empreinte par projet qui permet de répondre mécaniquement à « ce projet est-il à jour avec la méthode ? ». Démarrage en `0.x` car la méthode n'est pas encore validée sur un vrai projet (banc d'essai Unjque, Phase 6) ; le `1.0.0` marquera ce cap.
- **Conséquences** : `VERSION` à la racine devient un fichier de référence ; `docs/versioning.md` fixe la politique et la procédure de release (tag git `vX.Y.Z` + section « Releases » du CHANGELOG) ; `init-project.sh` lit `VERSION` et substitue `version_methode` ; `check-project.sh` gagne une section d'alignement non bloquante. Migrer un projet vers une version plus récente reste une décision humaine.
- **Liens** : CHG-20260614-0312.

### DEC-0014 — Repo unique privé sur GitHub

- **Date** : 2026-06-07 (consignée)
- **Contexte** : choisir l'hébergement et la granularité du dépôt.
- **Choix** : repo unique privé `my-project-os` (compte Mediatros, `gh` connecté), contenant Core + extensions Life et Code dans des sous-dossiers. Commits signés avec l'email noreply GitHub.
- **Raison** : un seul point de vérité versionné, email personnel gardé privé.
- **Conséquences** : tout vit dans ce dépôt ; les projets réels sont générés ailleurs via `init-project.sh`.
