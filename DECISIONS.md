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

### DEC-0029 — Brique Blue complète : skill technique portable, secrets multi-backend, registre d'équipement (D1-D5)

- **Date** : 2026-07-12
- **Contexte** : DEC-0027/0028 posent la gouvernance Blue (`GOUVERNANCE_BLUE.md`) et sa proposition active, mais la méthode ne livrait qu'un gabarit documentaire, pas d'outillage technique installable. Le plan `PLAN/plans/2026-07-12-blue-brique-complete-skill-agnostique.md` (T-PLAN-4, englobe T-PLAN-2/T-PLAN-3) propose qu'un projet qui active Blue reçoive en plus une skill technique portable (CLI + GraphQL + résolution de secrets), agnostique agent (Claude Code, Codex, Hermès), et un protocole d'équipement inter-agents. Cinq points d'architecture nécessitaient un arbitrage humain (D1-D5, § 10 du plan) ; tranchés par l'utilisateur le 2026-07-12.
- **Options envisagées et choix (D1-D5)** :
  - **D1 — Nom de la skill** : `blue-app` sous `templates/skills/blue-app/`, minuscules-tirets (compatibilité multi-implémentations du standard agentskills.io ; `blue.app`/`blue_app` écartés). Variante `blue-app-<projet>` réservée à un *comportement* différent, la *configuration* spécifique restant dans `GOUVERNANCE_BLUE.md` du projet.
  - **D2 — Conversion d'un workspace en template** : exécutée par l'agent (`convertWorkspaceToTemplate`), après accord explicite de l'humain en session (action réversible via `removeWorkspaceFromTemplates`, mais nouvelle au niveau organisation). Les réglages visuels du modèle restent un geste humain.
  - **D3 — Installation Hermès** : copie unique globale dans son dossier skills (chemin réel vérifié au premier essai VPS, `~/.hermes/skills/`), plutôt que `skills.external_dirs` (écarté : modifiable par toute session touchant le dossier projet, vulnérable aux conflits Syncthing).
  - **D4 — Migration de `~/.claude/skills/blue-cli`** (myagent, skill globale personnelle antérieure au plan) vers une instance de `blue-app`, débloquée une fois la Phase 2 (banc d'essai MySecretaire) validée en réel.
  - **D5 — Windows** : documentation seule dans `INSTALL.md` (PowerShell SecretManagement/SecretStore), aucun script `.ps1` tant qu'aucune machine Windows réelle ne permet de le tester (règle « aucune recette théorique »).
- **Raison** : chaque option retenue suit un principe déjà établi ailleurs dans la méthode — compatibilité multi-agent avant confort de frappe (D1), accord humain explicite avant toute action au niveau organisation (D2), simplicité et intégrité de la source projet avant flexibilité de configuration (D3), séquencement par validation réelle plutôt que migration anticipée (D4), aucune recette non testée (D5, cohérent avec le refus des « faits non sourcés » de la méthode).
- **Conséquences** : `templates/skills/blue-app/` créé (SKILL.md, INSTALL.md, `scripts/blue-secrets.sh`/`blue-cli.sh`/`blue-gql.sh`/`blue-files.sh`), testé en réel sur les trois agents (Phases 1-3, voir CHG-20260712-1345/1658). Workspace modèle et workflow commentaires validés en réel (Phase 4, CHG-20260712-1720). Wiring méthode (Phase 5, ce DEC) : `skills/my-project-os/SKILL.md` propose désormais la pose de la skill en Mode 5/6 après la gouvernance, et corrige la ligne obsolète sur le support de skills par Codex/Hermès ; `docs/NAMING-CONVENTIONS.md` fixe les noms d'agents canoniques (`CLAUDECODE`, `HERMES`, `CODEX`) ; `agents/hermes.md` documente les chemins skills réels et cite `blue-app` comme premier cas concret de skill partagée entre les trois agents ; `structures/core-tree.md` mentionne `98_configuration/skills/` ; `templates/configuration/HANDOFF_INTERAGENT.md` gagne le renvoi vers le tableau d'équipement et le modèle d'entrée « Équiper un agent ». Version portée à `0.11.0` (nouvelle capacité = évolution mineure). Restent, hors câblage interne du dépôt méthode : la propagation `--update-method` aux projets structurés, la mise à jour des `GOUVERNANCE_BLUE.md` déjà instanciées (LaCIOTAT, MySecretaire) et la migration D4 de `blue-cli` — actions sur des systèmes externes/live, traitées dans une session dédiée.
- **Liens** : CHG-20260712-1250, CHG-20260712-1345, CHG-20260712-1658, CHG-20260712-1720, CHG à venir pour ce wiring.

---

### DEC-0028 — Blue proposé activement par la skill assistant (Mode 5 et Mode 6)

- **Date** : 2026-07-12
- **Contexte** : DEC-0027 rend le gabarit `GOUVERNANCE_BLUE.md` disponible, mais rien ne le propose : un agent ne l'utilise que si l'utilisateur amène le sujet Blue le premier. L'utilisateur demande l'inverse : que la skill assistant pose la question elle-même en cadrage de projet (Mode 5) et en adoption de projet existant (Mode 6), avec une courte présentation de Blue, et propose d'activer immédiatement `98_configuration/GOUVERNANCE_BLUE.md` en cas de oui.
- **Options envisagées** :
  - A. Conditionner la proposition à la détection de Blue sur la machine (CLI `blue` ou skill `blue-cli` présente), pour rester neutre envers les adoptants du dépôt public MyProjectOS qui n'ont pas de compte Blue.
  - B. Proposer Blue par défaut à tout adoptant de la méthode, sans détection, en Mode 5 (cadrage) et Mode 6 (adoption).
- **Choix** : option B, tranché explicitement par l'utilisateur malgré le caractère public du dépôt (`https://github.com/Mediatros/MyProjectOS`).
- **Raison** : décision utilisateur explicite après qu'on lui a présenté l'alternative (neutralité vis-à-vis des autres adoptants vs simplicité). La question posée reste fermée et non engageante (« utilises-tu un outil de suivi ? ») : un adoptant sans Blue répond non et rien ne se passe, le coût d'une proposition non pertinente est faible face au bénéfice pour l'usage principal du dépôt (l'utilisateur lui-même, qui dogfoode la méthode).
- **Conséquences** : `skills/my-project-os/SKILL.md` — Mode 5 (Cadrage), nouvelle étape 8 après le pré-remplissage de `PROJECT.md` : présenter Blue en une phrase, question fermée, activation immédiate du gabarit si oui. Mode 6 (Adoption), nouvelle étape 6 (avant le rapport) : même proposition une fois `TASKS.md` peuplé. Aucun changement de `init-project.sh`/`check-project.sh` (l'activation reste un geste de session, pas un flag d'installation — cohérent avec DEC-0002/DEC-0027 : dossier optionnel, à la demande, seule la *proposition* devient systématique). Version portée à `0.10.0` (nouvelle capacité comportementale = évolution mineure). Point de vigilance : si le dépôt gagne des adoptants externes, cette proposition par défaut sera revisitée (piste A gardée en mémoire).
- **Liens** : CHG-20260712-1145.

---

### DEC-0027 — Blue en brique optionnelle : gabarit pré-rempli `GOUVERNANCE_BLUE.md`

- **Date** : 2026-07-12
- **Contexte** : idée notée le 2026-07-12 (avant DEC-0026), volontairement différée : transformer l'usage de Blue en brique optionnelle de MyProjectOS, avec une gouvernance de nommage/remplissage de cartes pré-remplie et réutilisable, au lieu de repartir à chaque fois du gabarit générique vide `GOUVERNANCE_INTEGRATION.md`. Condition posée à l'époque : attendre que `GOUVERNANCE_BLUE.md` de LaCIOTAT ait « assez vécu » pour en extraire ce qui est vraiment générique. Le jour même, comparaison avec un second projet indépendant utilisant Blue sur un compte différent (`Unjque_Projet/.claude/skills/blue-cli-unjque`, compte `unjque`, hors méthode MyProjectOS — pas de `TASKS.md`/`PROJECT.md` à sa racine) : les deux ont découvert indépendamment les mêmes pièges CLI (`records update` exige `-w` sinon *Internal server error* ; description avec retour à la ligne/caractères spéciaux → *Unterminated string* ; checklist en deux commandes) et le même principe de nommage (tag = domaine, checklist dès que plusieurs étapes). Confirmation qu'une partie est vraiment générique (niveau outil), le reste étant spécifique au mode d'usage.
- **Options envisagées** :
  - A. Ne rien extraire, laisser chaque projet repartir du gabarit générique vide.
  - B. Gabarit unique couvrant deux modes (miroir `TASKS.md` façon LaCIOTAT, et registre autonome façon Unjque).
  - C. Gabarit `templates/configuration/GOUVERNANCE_BLUE.md` scopé au seul mode « miroir `TASKS.md` ↔ Blue », le seul cohérent avec `TASKS.md` comme fichier sacré de la méthode ; les pièges CLI confirmés par les deux projets (niveau outil, indépendants du mode) y sont intégrés comme sous-section technique.
- **Choix** : option C.
- **Raison** : A répète l'erreur déjà actée en DEC-0026 (convention non canonisée = redécouverte à chaque projet). B aurait documenté un mode observé uniquement hors méthode (Unjque n'a pas de `TASKS.md`), sans valeur pour un projet piloté par MyProjectOS, au prix d'un gabarit plus long — écarté après clarification avec l'utilisateur. C ne canonise que ce qui est confirmé par deux sources indépendantes (pièges CLI) ou directement dérivé du fichier sacré `TASKS.md` (workflow de miroir), sans figer prématurément un usage à observation unique (principe déjà tenu en DEC-0002).
- **Conséquences** : `templates/configuration/GOUVERNANCE_BLUE.md` ajouté, non wiré à `init-project.sh` (posé à la demande, comme `GOUVERNANCE_INTEGRATION.md` et `HANDOFF_INTERAGENT.md`). `docs/NAMING-CONVENTIONS.md` et `skills/my-project-os/SKILL.md` mentionnent qu'une variante pré-remplie par outil prime sur le gabarit générique vide quand elle existe. Pas de changement de `check-project.sh`/`init-project.sh` (même raisonnement que DEC-0026 : dossier et contenu optionnels, non détectables comme obligatoires). Version portée à `0.9.0` (nouvelle capacité = évolution mineure). Le gabarit reste silencieusement daté par nature (IDs et pièges CLI valables à la vérification citée) : à rafraîchir si de nouveaux projets Blue révèlent des pièges supplémentaires.
- **Liens** : CHG-20260712-1130.

---

### DEC-0026 — Canoniser `98_configuration/` : gouvernance partagée et handoff inter-agents

- **Date** : 2026-07-12
- **Contexte** : le RETEX LaCIOTAT du 2026-07-11 (`RETEX/retex-laciotat-98-configuration-gouvernance-multiagent.md`) montre qu'un projet piloté par plusieurs agents distincts (Claude Code, Hermès Agent, Codex) a besoin (1) d'un endroit pour des règles de configuration/gouvernance d'outils tiers partagées entre agents, pour éviter qu'un outil externe (ex. Blue) devienne une source non fiable par divergence silencieuse, et (2) d'un mécanisme d'échange asynchrone entre agents sans canal de communication direct. Aucune case du canon existant (`0X_` métier, `05_correspondances/`, `99_archive/`, `.claude/skills/`) ne convenait (détail dans le RETEX). La solution locale posée dans LaCIOTAT (`98_configuration/` avec `GOUVERNANCE_BLUE.md` et `HANDOFF_CLAUDE_HERMES.md`) est jugée réutilisable.
- **Options envisagées** :
  - A. Ne rien canoniser, laisser chaque projet multi-agent réinventer sa solution.
  - B. Canoniser `98_configuration/` dans `structures/core-tree.md` (optionnel, tous types), documenter la convention dans `docs/NAMING-CONVENTIONS.md`, fournir deux gabarits génériques (`templates/configuration/HANDOFF_INTERAGENT.md`, `templates/configuration/GOUVERNANCE_INTEGRATION.md`), et étendre le garde-fou temps réel de `hook-pre-write.sh` aux collisions de préfixe numérique `NN_` (pas seulement aux quasi-doublons de nom) pour attraper les abréviations (`98_config` à côté de `98_configuration`) que la détection de quasi-doublon existante ne voit pas.
- **Choix** : option B.
- **Raison** : A répète l'erreur déjà documentée dans `retex-laciotat-doublon-archives.md` (une convention non canonisée devient une variante par projet). B suit le principe déjà établi (DEC-0002 : dossiers créés à la demande, pas de squelette imposé) et referme un angle mort du garde-fou dossiers racine (T-R.1/T-R.2, v0.7.0) qui ne détectait que les noms quasi-identiques, pas les préfixes partagés par des noms différents.
- **Conséquences** : `structures/core-tree.md` et `docs/NAMING-CONVENTIONS.md` documentent `98_configuration/` (optionnel) ; `templates/configuration/` accueille les deux gabarits génériques, non wirés à `init-project.sh` (posés à la demande, comme tous les dossiers numérotés au-delà de `00_inbox/`) ; `scripts/hooks/_lib.sh` gagne `root_prefix()`, réutilisée par `hook-pre-write.sh` pour refuser en temps réel une collision de préfixe `NN_` entre deux dossiers racine distincts ; `check-project.sh` n'a pas besoin de changement, sa section « Dossiers racine » (9b) détectait déjà génériquement les collisions de préfixe en audit. La consigne « consulter le canon avant de créer un dossier racine » (T-R.4, restée ouverte depuis le RETEX précédent) est ajoutée dans la skill `my-project-os` et `docs/NAMING-CONVENTIONS.md`, ce qui clôt T-R.4 par la même occasion. Version portée à `0.8.0` (nouvelle capacité = évolution mineure).
- **Liens** : CHG-20260712-1110, `RETEX/retex-laciotat-98-configuration-gouvernance-multiagent.md`.

### DEC-0025 — Isolation complète des hooks : copie locale au lieu d'une référence à `MyProjectOS`

- **Date** : 2026-07-04 (consignée le 2026-07-09, récupérée du clone divergent résorbé)
- **Contexte** : `init-project.sh` câblait `.claude/settings.json` de chaque projet avec un chemin absolu vers `MyProjectOS/scripts/hooks/*.sh`. Les gabarits Markdown étaient copiés (isolés), mais les hooks référencés à distance : un projet dépendait donc du dépôt `MyProjectOS` restant en place à ce chemin exact, et modifier un script de hook affectait silencieusement tous les projets déjà créés (4 projets concernés au moment du constat, aucun averti). Repéré lors d'un audit du projet LaCIOTAT, qui a demandé l'arrêt de ce partage.
- **Options envisagées** :
  - A. Garder la référence à distance, documenter le risque.
  - B. Copier les scripts de hooks (`_lib.sh`, `hook-pre-write.sh`, `hook-stop-progress.sh`) dans `.claude/hooks/` de chaque projet à la création, et câbler `settings.json` sur `$CLAUDE_PROJECT_DIR/.claude/hooks/...`.
- **Choix** : option B.
- **Raison** : cohérence avec le principe déjà appliqué aux gabarits Markdown (un projet ne dépend d'aucun autre dossier pour fonctionner) ; un projet Life peut contenir des données sensibles (succession, santé) et ne doit pas voir son comportement changer sans qu'on le sache, du fait d'une modification faite ailleurs.
- **Conséquences** : chaque nouveau projet reçoit sa propre copie des hooks, modifiable indépendamment des autres. Corriger un bug de hook dans `MyProjectOS` ne se propage plus automatiquement : recopie projet par projet, ou `--update-method` depuis la v0.5.0. Les 4 projets créés avant cette décision (LaCIOTAT, HomeLab, Assistant_Juridique, TeamLeader) gardent l'ancien câblage tant qu'ils ne sont pas migrés individuellement.
- **Note** : décision prise et implémentée le 2026-07-04 dans un clone divergent du dépôt, sous le numéro « DEC-0017 » déjà attribué ici ; l'implémentation équivalente existait déjà dans ce dépôt (v0.3.0 du 2026-07-02, puis manifest en v0.5.0). Consignée pour conserver le pourquoi.
- **Liens** : CHG-20260709-0017.

### DEC-0024 — SUJETS.md à la racine, source fraîche prioritaire (intégration du RETEX comptabilité)

- **Date** : 2026-07-07
- **Contexte** : le RETEX comptabilité (2026-06-14) montre que les demandes métier (« dépenses maison ») ne sont pas bien routées : `docs/INDEX.md` décrit la carte documentaire mais pas le vocabulaire utilisateur, et une synthèse peut être moins fraîche que le fichier source.
- **Options envisagées** : A. `SUJETS.md` à la racine du projet ; B. `docs/SUJETS.md` dans l'extension Knowledge.
- **Choix** : option A, recommandée par le RETEX.
- **Raison** : c'est un fichier de routage, pas de la documentation de détail ; il doit être visible immédiatement par tout agent.
- **Conséquences** : template `templates/extensions/knowledge/SUJETS.md` posé à la racine par `--knowledge` ; règle « SUJETS.md avant INDEX.md, source fraîche avant synthèse » dans la skill, `templates/core/AGENTS.md`, `kb_governance.md` et `docs/governance.md` ; avertissement de `check-project.sh` si Knowledge est actif sans `SUJETS.md` rempli.
- **Liens** : CHG-20260707-1100.

### DEC-0023 — Le cycle itératif devient une règle de la méthode ; la skill passe à 7 modes

- **Date** : 2026-07-07
- **Contexte** : la pratique éprouvée de l'utilisateur (une tâche par session, clôture des fichiers sacrés, `/clear`, reprise à froid) n'était codifiée nulle part ; le cadrage amont (besoin, stack, découpage), couche la plus critique pour un non-développeur, n'était pas accompagné ; l'adoption d'un projet existant n'existait pas.
- **Options envisagées** : A. laisser ces pratiques à la culture orale ; B. les codifier en doc + templates + skill.
- **Choix** : option B.
- **Raison** : une pratique non écrite ne survit ni au changement d'agent ni à la reprise à froid, ce qui contredit le principe fondateur de la méthode.
- **Conséquences** : `docs/cycle-de-travail.md` (rythme officiel), règles de découpage dans `templates/core/TASKS.md`, sections dédiées dans `templates/core/AGENTS.md`, skill à 7 modes (reprise, orientation, explication, clôture, cadrage, adoption, mise à jour), `docs/INSTALL-AGENT.md` comme protocole d'entrée agent. La skill embarquée ne référence plus de chemins internes au repo méthode : elle est identique dans le repo et dans les projets.
- **Liens** : CHG-20260707-1100.

### DEC-0022 — Mise à jour de la méthode par manifest d'artefacts, détection distante et `--update-method`

- **Date** : 2026-07-07
- **Contexte** : les artefacts méthode copiés dans un projet (skill, `check-project.sh`, `VERSION`) n'étaient jamais rafraîchis (`--into-existing` les conserve) : un projet créé en 0.3.0 gardait la skill 0.3.0 à vie, et rien ne détectait qu'une version plus récente existait (T-B.5/T-B.6).
- **Options envisagées** : A. forcer la réécriture via `--into-existing` ; B. frontière explicite par manifest + détection qui informe seulement + application dédiée avec sauvegarde.
- **Choix** : option B.
- **Raison** : A mélange greffe de contenu et mise à jour d'outillage, sans trace de ce qui appartient à la méthode ; B rend la frontière déterministe (le manifest), garantit que le contenu du projet n'est jamais touché, et impose le workflow humain : détecter → auditer → valider → appliquer → tracer.
- **Conséquences** : `.myprojectos/manifest` posé dans chaque projet ; `scripts/check-update.sh` copié à côté de `check-project.sh` (sortie 0/10/1, replis dossier local et `git ls-remote`) ; `init-project.sh --update-method` sauvegarde dans `99_archive/methode-avant-vX.Y.Z/` puis remplace les seuls fichiers du manifest et met à jour l'empreinte ; mode 7 de la skill impose la validation humaine ; runbooks dans `docs/versioning.md` ; scénario complet testé en CI.
- **Liens** : CHG-20260707-1100.

### DEC-0021 — La méthode est conçue pour un dépôt public ; la publication reste le dernier geste humain

- **Date** : 2026-07-07
- **Contexte** : DEC-0017 gardait le dépôt privé, ce qui casse `install.sh` par `curl` et la détection de mise à jour depuis une machine tierce ou le VPS Hermès. L'utilisateur demande de concevoir le système comme si le dépôt allait être public.
- **Options envisagées** : A. rester privé et documenter un accès authentifié partout ; B. concevoir pour le public (URLs brutes GitHub par défaut, replis authentifiés), la publication effective restant une action humaine.
- **Choix** : option B.
- **Raison** : le public rend l'installation et la mise à jour triviales sur toutes les machines ; la licence MIT est posée ; le contenu est vérifié sans donnée personnelle (exemples anonymisés). Les replis (`MYPROJECTOS_REPO_URL`, `git ls-remote` SSH) couvrent l'intervalle et un éventuel retour au privé.
- **Conséquences** : remplace DEC-0017 dans son intention ; T-A.2 (publier le dépôt) redevient la dernière étape, à faire par l'utilisateur (`gh repo edit --visibility public`), idéalement au moment de pousser la release v0.5.0 ; la CI sert de filet avant publication.
- **Liens** : CHG-20260707-1100, DEC-0017.

### DEC-0020 — Le check vérifie AGENTS.md/CLAUDE.md pour tous les types, et leur taille contre la limite de troncature Hermès

- **Date** : 2026-07-04
- **Contexte** : DEC-0019 (T-A.5) fait poser `AGENTS.md`/`CLAUDE.md` par `init-project.sh` pour tous les types de projet, mais `scripts/check-project.sh` ne vérifiait leur présence que dans la liste de l'extension Code (ligne réservée à `*Code*|*Hybrid*`) : un projet Core ou Life pur n'était jamais audité sur ce point, alors que le fichier est censé y être. Par ailleurs, l'utilisateur confirme (documentation officielle Hermès/Nous Research) qu'Hermès Agent charge `AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md` et `.cursorrules` dans son prompt système, tronqués par défaut à 20 000 caractères (`context_file_max_chars`) — un risque concret en usage mobile où Hermès est le seul point d'accès au projet, sans conversation Claude Code pour compenser une troncature silencieuse.
- **Options envisagées** :
  - A. Ne rien changer : laisser le contrôle d'`AGENTS.md` dans la liste Code uniquement.
  - B. Déplacer le contrôle de présence dans une section universelle (tous types), en avertissement (fichier non sacré) ; ajouter une section dédiée qui mesure la taille des fichiers de contexte agent et avertit au-delà de 20 000 caractères.
  - C. Bloquer (fail) si `AGENTS.md` dépasse la limite, plutôt qu'avertir.
- **Choix** : option B.
- **Raison** : cohérent avec DEC-0019 (le fichier est censé exister partout, donc vérifiable partout) et avec la distinction déjà actée dans `docs/governance.md` (AGENTS.md/CLAUDE.md ne sont pas des fichiers sacrés → avertissement, pas blocage). C est rejetée : la taille tolérable dépend de la config Hermès du déploiement (`context_file_max_chars` est ajustable côté VPS), un dépassement n'est donc pas toujours une erreur.
- **Conséquences** : `scripts/check-project.sh` gagne une section « Socle agent » (présence, tous types) et une section « Taille des fichiers de contexte agent » (`AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md`, `.cursorrules` si présents, seuil 20 000 caractères, avertissement non bloquant). `agents/hermes.md` documente la liste des fichiers chargés par Hermès et la limite de troncature. Version portée à `0.4.0` (nouvelle capacité de contrôle = évolution mineure).
- **Liens** : CHG-20260704-1200.

### DEC-0019 — AGENTS.md est un fichier Core, l'extension Code y ajoute une section

- **Date** : 2026-07-02
- **Contexte** : l'audit du 2026-07-02 constate que seul le type Code recevait un `AGENTS.md` ; un projet Core, Life ou Hybrid fraîchement créé n'avait donc aucune instruction agent à la racine (T-A.5).
- **Options envisagées** :
  - A. Dupliquer un `AGENTS.md` générique par extension (un par type).
  - B. Poser un `AGENTS.md` Core générique pour tous les types, et faire des extensions des sections ajoutées au même fichier.
  - C. Ne rien changer, accepter que seuls les projets Code aient des instructions agent.
- **Choix** : option B.
- **Raison** : un seul contenu source par projet, lisible nativement par Codex (`AGENTS.md`) et par Claude Code (`CLAUDE.md` qui y renvoie), sans fichiers concurrents qui s'écrasent au moment de la génération.
- **Conséquences** : `templates/core/AGENTS.md` et `templates/core/CLAUDE.md` posés par `init-project.sh` pour tous les types. `templates/extensions/code/AGENTS.md` n'est plus un document autonome mais un fragment (« ## Extension Code ») ajouté une seule fois au fichier racine (`append_code_agents`, idempotent en mode `--into-existing`). `structures/core-tree.md`, `structures/code-tree.md` et le `CLAUDE.md` du repo méthode alignés.
- **Liens** : CHG-20260702-1851.

### DEC-0018 — Licence MIT

- **Date** : 2026-07-02
- **Contexte** : le repo n'avait pas de `LICENSE`, ce qui bloque tout usage entreprise ou partage (constat de l'audit, T-A.3).
- **Choix** : licence MIT.
- **Raison** : cohérent avec les outils empruntés par la méthode (Harness, Spec Kit), tous deux MIT.
- **Conséquences** : fichier `LICENSE` ajouté à la racine.
- **Liens** : CHG-20260702-1851.

### DEC-0017 — Le dépôt GitHub reste privé pour l'instant

- **Date** : 2026-07-02
- **Contexte** : l'audit signale que le repo privé `Mediatros/MyProjectOS` casse le scénario « je donne le lien à mon agent » (T-A.2), puisque `install.sh` clone via `curl`/`git clone` sans authentification.
- **Options envisagées** : rendre le repo public ; le garder privé et documenter un accès authentifié ; ne pas trancher maintenant.
- **Choix** : rester privé, publication reportée.
- **Raison** : décision utilisateur ; les autres tâches de la Phase A (installation réelle sur le principe) ont priorité avant d'ouvrir l'accès public.
- **Conséquences** : `install.sh`/`curl` tel que documenté dans le `README.md` ne fonctionnera pas depuis une machine tierce tant que le repo reste privé ou qu'un accès authentifié n'est pas documenté. T-A.2 reste ouverte dans `TASKS.md`.

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
- **Choix** : repo unique privé `MyProjectOS` (compte Mediatros, `gh` connecté), contenant Core + extensions Life et Code dans des sous-dossiers. Commits signés avec l'email noreply GitHub.
- **Raison** : un seul point de vérité versionné, email personnel gardé privé.
- **Conséquences** : tout vit dans ce dépôt ; les projets réels sont générés ailleurs via `init-project.sh`.
