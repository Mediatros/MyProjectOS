# Plan — Brique Blue complète : skill installable agent-agnostique, secrets multi-backend, handoff cohérent

> Statut : **proposition, non appliquée** — décisions d'architecture D1-D5 (§ 10) tranchées par l'utilisateur le 2026-07-12 ; reste le feu vert d'implémentation. Zone PLAN/ = plan de travail isolé avant intégration.
> Date : 2026-07-12. Auteur de l'analyse : Claude Code (session Mac), à la demande de l'utilisateur.
> Origine : revue des plans `2026-07-12-blue-cli-extension-graphql.md` (T-PLAN-2) et `2026-07-12-blue-workspace-template.md` (T-PLAN-3), avec une exigence nouvelle : la brique Blue de MyProjectOS ne doit plus livrer seulement la gouvernance, mais aussi une **skill technique prête à installer**, utilisable par n'importe lequel des trois agents (Claude Code, Codex, Hermès Agent), avec une gestion des secrets adaptée à chaque environnement (Mac, Windows, VPS headless), et un handoff qui permet au premier agent installé d'équiper les suivants.
> Ce plan **englobe et amende** T-PLAN-2 et T-PLAN-3 (voir § 4) ; il ne les remplace pas, il les réordonne dans une architecture commune.

## 1. Objectif

Qu'un projet MyProjectOS qui active Blue reçoive trois choses au lieu d'une :

1. la **gouvernance** (`98_configuration/GOUVERNANCE_BLUE.md`, existant depuis v0.9.0) ;
2. une **skill technique portable** (CLI + GraphQL + résolution de secrets), déjà écrite, que chaque agent installe chez lui en quelques commandes documentées ;
3. un **protocole d'équipage** : le premier agent qui installe consigne ce qu'il a fait ; tout autre agent qui arrive sur le projet voit ce qui lui manque et sait l'installer (registre + entrée de handoff pré-rédigée).

Contrainte de fond : MyProjectOS est agent-agnostique. La skill doit fonctionner à l'identique que la session soit Claude Code (Mac), Codex, ou Hermès Agent (VPS), l'utilisateur n'ayant à fournir que ses clés API via le backend de secrets de sa plateforme.

## 2. Faits vérifiés (tests réels et sources, 2026-07-12)

### 2.1 Tests exécutés en live depuis le Mac

| Test | Résultat |
|---|---|
| Wrapper trousseau + CLI (`blue-kc.sh workspaces list --company myagent`) | OK, 7 workspaces retournés, exit 0 |
| GraphQL avec les mêmes credentials (`blue-token-id`/`blue-token-secret`) | Authentification acceptée ; `workspaceList` exige un filtre : `workspaceList(filter: { companyIds: ["myagent"] })` validé |
| Introspection du schéma (mutations/queries « template ») | La doc Blue cite `convertProjectToTemplate` ; le schéma réel expose **`convertWorkspaceToTemplate`**, plus `removeWorkspaceFromTemplates`, `instantiateTemplateFolder`, `templateFolders` |
| Query `templates { items { id name } }` | Validée, retourne `[]` (aucun template dans l'organisation à ce jour) — **referme le point 5.4 du plan T-PLAN-3** : les templates sont listables par API |
| Outils de secrets présents sur le Mac | `security` (trousseau) et `gpg` seulement ; ni `bws`, ni `bw`, ni `op`, ni `pass` |

### 2.2 Portabilité des skills entre les trois agents (sourcé)

Le format « Agent Skills » (dossier + `SKILL.md` à frontmatter YAML, standard ouvert publié sur agentskills.io fin 2025) est aujourd'hui supporté par les trois agents cibles :

| Agent | Support | Emplacements | Installation |
|---|---|---|---|
| Claude Code | natif | `~/.claude/skills/` (global), `<projet>/.claude/skills/` (projet) | copie du dossier |
| Codex CLI | depuis déc. 2025 | `~/.codex/skills/` (global), `<projet>/.codex/skills/` (projet) | copie du dossier ; découverte au démarrage via le champ `description` |
| Hermès Agent | natif, compatible agentskills.io | `~/.hermes/skills/` (source de vérité) + répertoires externes déclarables dans `~/.hermes/config.yaml` (`skills.external_dirs`, priorité au local en cas de doublon) | `hermes skills install <hub|GitHub|URL>`, `/skills install` en chat, ou copie |

Précisions Hermès utiles : frontmatter requis `name`, `description`, `version` ; champs `platforms` (restriction OS) et `required_environment_variables` (déclaration des secrets attendus, avec invite de configuration) ; les installations depuis le hub passent par un scanner de sécurité. Sources : developers.openai.com/codex/skills, hermes-agent.nousresearch.com/docs/user-guide/features/skills, agentskills.io.

**Correction à faire dans la méthode** : `skills/my-project-os/SKILL.md` (Garde-fous) affirme « Codex : pas de skills, `AGENTS.md` fait foi » — obsolète. Et le chemin Hermès y est donné comme `~/.hermes/profiles/<profil>/skills/` alors que la doc actuelle donne `~/.hermes/skills/` : les deux coexistent peut-être (le précédent MySecretaire utilise le chemin par profil) — à vérifier sur le VPS au premier essai, puis figer la formulation exacte.

### 2.3 Backends de secrets par environnement (sourcé)

| Environnement | Backend | Lecture d'un secret (stdout) |
|---|---|---|
| macOS | Trousseau (`security`) | `security find-generic-password -a <compte> -s <service> -w` — limite connue : trousseau potentiellement verrouillé en session SSH sans session graphique |
| Toutes plateformes (Bitwarden Secrets Manager) | CLI `bws` (binaire GitHub, brew, cargo) | auth par `BWS_ACCESS_TOKEN` ; `bws secret get <uuid> \| jq -r .value` |
| Windows | PowerShell `Microsoft.PowerShell.SecretManagement` + `SecretStore` (fonctionne aussi Linux/macOS) | `Get-Secret -Name <nom> -AsPlainText` |
| VPS Linux headless | fichier `chmod 600` hors du dossier synchronisé (ex. `~/.config/blue/secrets.env`) | `source` du fichier ; la pratique la plus simple et acceptée pour un serveur mono-utilisateur ; alternatives : `pass` (GPG), systemd-creds |
| Universel (repli et CI) | variables d'environnement `BLUE_TOKEN_ID` / `BLUE_TOKEN_SECRET` | déjà posées par l'environnement appelant |

Règle absolue transverse : **aucun secret dans le dossier projet** (il est synchronisé par Syncthing entre Mac et VPS) ni dans le dépôt méthode. Le projet ne consigne que le *nom* du backend et les *noms* de clés.

### 2.4 Précédent réel à généraliser (MySecretaire, 2026-07-12)

`MySecretaire/98_configuration/hermes/` contient déjà : une copie de skill adaptée à Hermès (`skills/radar-projets/`), un `INSTALL.md` (procédure de copie côté VPS vers le profil Hermès), et une entrée de handoff `HANDOFF_CLAUDECODE_HERMES.md` demandant à Hermès de l'installer, avec critère de vérification. Le pattern fonctionne ; ce plan le canonise au lieu de le laisser se réinventer par projet.

### 2.5 Divergence constatée dans le handoff

Deux projets, deux noms pour le même fichier : `HANDOFF_CLAUDE_HERMES.md` (LaCIOTAT) vs `HANDOFF_CLAUDECODE_HERMES.md` (MySecretaire). Le gabarit `HANDOFF_INTERAGENT.md` ne fixe pas de noms d'agents canoniques : chaque projet improvise. À corriger (voir § 7).

## 3. Architecture cible de la brique Blue

### 3.1 Nouveau gabarit de skill portable dans le dépôt méthode

```text
templates/skills/blue-app/
├── SKILL.md          # agnostique : aucune organisation ni ID en dur ;
│                     # 1re instruction : lire 98_configuration/GOUVERNANCE_BLUE.md du projet
├── INSTALL.md        # installation par agent (Claude Code / Codex / Hermès)
│                     # + configuration des secrets par backend (§ 2.3)
└── scripts/
    ├── blue-secrets.sh   # couche de résolution des secrets (voir § 5)
    ├── blue-cli.sh       # wrapper CLI : config.env éphémère (généralise blue-kc.sh,
    │                     # sans COMPANY_ID en dur — l'org vient de la gouvernance projet)
    └── blue-gql.sh       # wrapper GraphQL (reprend la Phase 1 de T-PLAN-2 : --check,
                          # -w workspace, variables JSON séparées, détection errors[] → exit ≠ 0)
```

Frontmatter du `SKILL.md` : `name`, `description`, `version` (requis par Hermès), plus `required_environment_variables` déclarant `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` comme repli universel. Le corps porte : routage CLI d'abord / GraphQL pour le reste (table de décision de T-PLAN-2 § 3 Phase 3), pièges CLI et GraphQL confirmés, recettes validées, workflow commentaires (§ 6), et le renvoi systématique vers la gouvernance du projet pour tout ce qui est spécifique (org, workspace, IDs, conventions).

### 3.2 Instanciation dans un projet

Quand un projet active Blue (Modes 5/6 de la skill assistant), l'agent pose, en plus de la gouvernance :

```text
<projet>/98_configuration/skills/blue-app/   # copie canonique, synchronisée Syncthing
```

C'est la **source projet** de la skill : visible du Mac, du VPS et de toute machine synchronisée. Chaque agent l'installe ensuite chez lui selon `INSTALL.md` :

- Claude Code → copie vers `<projet>/.claude/skills/blue-app/` (ou `~/.claude/skills/` si l'utilisateur la veut globale) ;
- Codex → copie vers `<projet>/.codex/skills/blue-app/` (ou `~/.codex/skills/`) ;
- Hermès → copie unique globale vers son dossier skills (tranché, D3) ; le chemin exact (`~/.hermes/skills/` vs profil) se vérifie au premier essai VPS, puis est figé dans `INSTALL.md`.

### 3.3 Registre d'équipement (qui a installé quoi)

La section « Accès technique » de `GOUVERNANCE_BLUE.md` (aujourd'hui un simple placeholder) devient un tableau tenu à jour par chaque agent qui s'équipe :

```markdown
| Agent | Skill installée (chemin) | Backend secrets | Vérifié le |
|---|---|---|---|
| Claude Code (Mac) | .claude/skills/blue-app/ | keychain (service blue-cli) | 2026-07-12 |
| Hermès (VPS) | ~/.hermes/skills/blue-app/ | file (~/.config/blue/secrets.env) | — |
```

Un agent qui ouvre le projet et ne se trouve pas dans le tableau sait immédiatement : (a) que la skill existe, (b) où est la source (`98_configuration/skills/blue-app/`), (c) comment s'équiper (`INSTALL.md`), (d) quel backend de secrets utiliser sur sa plateforme. S'il ne peut pas s'équiper seul (secrets à fournir par l'humain), il le demande via le handoff (entrée pré-rédigée, § 7).

## 4. Amendements aux deux plans existants

### 4.1 Plan T-PLAN-2 (extension GraphQL) — amendé, pas remplacé

- **Les scripts naissent dans le gabarit générique** (`templates/skills/blue-app/scripts/`), pas dans la skill globale personnelle `~/.claude/skills/blue-cli/`. La couche secrets est pluggable (§ 5) au lieu du trousseau macOS en dur — condition de la portabilité VPS/Windows. La skill globale `blue-cli` (myagent) reste en l'état pendant les Phases 1-2, puis est migrée vers une instance de `blue-app` une fois la Phase 2 validée (tranché, D4).
- **Table de couverture (§ 2.2 du plan d'origine) à compléter** : domaine « Templates de workspace » (queries `templates`/`template`, mutations `convertWorkspaceToTemplate`, `removeWorkspaceFromTemplates` — vérifiés par introspection le 2026-07-12), absent de la CLI hors `workspaces create --template <ID>`.
- **Piège doc à consigner** : la documentation Blue nomme `convertProjectToTemplate` ; le schéma réel expose `convertWorkspaceToTemplate`. L'introspection (`__schema`) fait foi.
- Les phases 1 à 4 et les critères d'acceptation du plan d'origine restent valables tels quels (dont la validation de bout en bout de l'upload presigned PUT avant documentation).

### 4.2 Plan T-PLAN-3 (workspace modèle) — deux points refermés

- **§ 5.4 refermé** : l'ID d'un template s'obtient par la query GraphQL `templates { items { id name } }` (validée en live, liste vide aujourd'hui — cohérent, aucun modèle encore créé).
- **§ 3.2 automatisable** : la conversion en template n'est plus nécessairement un geste UI de l'utilisateur — `convertWorkspaceToTemplate` la rend pilotable par agent via `blue-gql.sh` (mutation à tester prudemment au premier essai, D2). Restent côté humain : les réglages visuels du workspace modèle.
- La recette complète « créer le workspace d'un nouveau projet depuis le template d'organisation » entre dans le `SKILL.md` portable (et dans `GOUVERNANCE_BLUE.md` § création, comme prévu au § 4 du plan d'origine).

## 5. Couche secrets : `blue-secrets.sh`

Un seul script POSIX, sourcé par `blue-cli.sh` et `blue-gql.sh`, qui exporte `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` selon l'ordre de résolution :

1. **Variables d'environnement déjà posées** → ne rien faire (universel : CI, Windows via SecretManagement qui exporte avant de lancer l'agent, tout backend non prévu).
2. **`BLUE_SECRET_BACKEND=keychain`** (défaut si `security` existe) → trousseau macOS, service `blue-cli`, comptes `client_id`/`auth_token` (compatible avec l'existant).
3. **`BLUE_SECRET_BACKEND=bws`** → `bws secret get "$BLUE_BWS_TOKEN_ID_UUID" | jq -r .value` (idem secret) ; exige `BWS_ACCESS_TOKEN` dans l'environnement.
4. **`BLUE_SECRET_BACKEND=file`** → `~/.config/blue/secrets.env`, refusé si permissions ≠ 600 ou s'il est dans un dossier synchronisé. Cas nominal VPS headless (Hermès).

Garanties reprises de l'existant et de T-PLAN-2 : jamais d'écho des secrets ; `config.env` de la CLI régénéré puis supprimé par `trap EXIT` (fenêtre d'exécution seulement) ; GraphQL n'écrit rien du tout sur disque ; `--check` (smoke test `workspaceList`) avec message clair et exit non nul si le backend est vide ou mal configuré. Windows : pas de script dédié — `INSTALL.md` documente SecretManagement/SecretStore (`Get-Secret -AsPlainText`) pour poser les variables d'environnement (voie 1) ; un `blue-secrets.ps1` ne sera écrit que si un usage Windows réel apparaît (tranché, D5).

## 6. Workflow commentaires : pilotage humain → agent (nouvelle demande)

Constat : les cartes Blue acceptent des commentaires (CLI `blue comments`, GraphQL `comments`), consultables et rédigeables depuis le téléphone. Demande de l'utilisateur : pouvoir écrire une demande en commentaire d'une carte (« modifie cette carte », « réactive-la avec telle nouvelle tâche »...), que l'agent la lise, l'exécute, et confirme.

Protocole proposé (à intégrer au `SKILL.md` portable et à `GOUVERNANCE_BLUE.md`) :

1. **Convention** : tout commentaire écrit par l'utilisateur sur une carte du workspace miroir est une demande actionnable adressée au prochain agent qui ouvre une session sur le projet.
2. **Relevé** : quand la brique Blue est active, le rituel de reprise (début de session) inclut un relevé des commentaires non traités, comme pour `ECHEANCES.md` et le handoff. Relevé aussi à la demande (« relève Blue »).
3. **Détection du non-traité, sans état séparé** : un commentaire humain est « non traité » tant qu'il n'a pas de commentaire de réponse agent posté après lui sur la même carte. Pas de tag ni de fichier d'état à maintenir.
4. **Exécution dans le bon ordre** : appliquer la demande d'abord dans `TASKS.md` (source de vérité du miroir), puis resynchroniser la carte (list, titre, description, checklist, custom field `ID` si nouvelle tâche), selon le workflow existant de la gouvernance.
5. **Feedback systématique** : l'agent poste un commentaire de confirmation sur la carte — `✅ Pris en compte par <agent> le <YYYY-MM-DD HH:MM> : <action réalisée ou en cours>`. Si la demande touche une action sensible (suppression massive, engagement externe...), le commentaire dit explicitement « en attente de validation » et la demande remonte dans la session / `PROGRESS.md`.
6. **Limite assumée** (même nature que le handoff) : aucune notification push ; la latence est « à la prochaine session ». Pistes futures hors périmètre : polling planifié côté Hermès (VPS, toujours allumé), subscriptions WebSocket GraphQL (déjà notées hors périmètre dans T-PLAN-2).

## 7. Handoff : mise en cohérence inter-agents

1. **Noms d'agents canoniques** dans `docs/NAMING-CONVENTIONS.md` : `CLAUDECODE`, `HERMES`, `CODEX` (et la règle de formation pour un agent futur). Résout la divergence `HANDOFF_CLAUDE_HERMES.md` / `HANDOFF_CLAUDECODE_HERMES.md` (§ 2.5) — les fichiers existants ne sont pas renommés d'office, la convention vaut pour les créations futures (renommage proposé projet par projet, geste validé par l'humain).
2. **Gabarit `HANDOFF_INTERAGENT.md` enrichi** de deux éléments :
   - un renvoi d'en-tête vers le tableau « Accès technique / équipement » de la gouvernance (l'état de l'équipage vit dans la gouvernance, le handoff ne porte que les demandes — une information, un seul endroit) ;
   - un **modèle d'entrée pré-rédigé « Équiper un agent »** (généralisation du précédent MySecretaire § 2.4) : demande d'installation d'une skill avec chemin source dans le projet, procédure (`INSTALL.md`), critère de vérification, et consigne de mise à jour du tableau d'équipement + passage du statut à FAIT.
3. **Rituel de session** (dans `GOUVERNANCE_BLUE.md` et le `SKILL.md` portable) : à l'ouverture d'un projet où `98_configuration/` existe, relever handoff + commentaires Blue non traités, dans cet ordre.

## 8. Impacts sur les artefacts méthode (si acté)

| Artefact | Changement |
|---|---|
| `templates/skills/blue-app/` | **Nouveau** : SKILL.md portable + INSTALL.md + 3 scripts (§ 3.1, § 5) |
| `templates/configuration/GOUVERNANCE_BLUE.md` | Section « Accès technique » → tableau d'équipement ; section « Créer le workspace d'un nouveau projet » (template d'organisation, T-PLAN-3 § 4) ; workflow commentaires (§ 6) ; pièges GraphQL (dont `convertWorkspaceToTemplate` vs doc) |
| `templates/configuration/HANDOFF_INTERAGENT.md` | Renvoi équipement + modèle d'entrée « Équiper un agent » (§ 7.2) |
| `skills/my-project-os/SKILL.md` | Modes 5/6, étape Blue : après la pose de la gouvernance, proposer la pose de `98_configuration/skills/blue-app/` + le choix du backend de secrets + l'inscription au tableau d'équipement. Correction de la ligne obsolète « Codex : pas de skills » et des chemins Hermès (§ 2.2) |
| `docs/NAMING-CONVENTIONS.md` | Noms d'agents canoniques (§ 7.1) |
| `agents/hermes.md` | Chemins skills à jour (`~/.hermes/skills/`, `skills.external_dirs`), mention du standard agentskills.io supporté (la section « Portabilité des garde-fous » reste, ce plan en réalise une partie pour la brique Blue) |
| `structures/core-tree.md` | `98_configuration/skills/` mentionné comme sous-dossier optionnel |
| Gate habituel | `DEC-` (architecture de la brique) + `CHG-` + bump **v0.11.0** ; aucun wiring `init-project.sh`/`check-project.sh` (cohérent DEC-0027/0028 : geste de session) ; skills `add-extension` et `validate` à dérouler |

## 9. Phases d'implémentation et critères d'acceptation

### Phase 1 — Scripts et secrets (Mac d'abord) — **faite le 2026-07-12**
Écrire `blue-secrets.sh`, `blue-cli.sh`, `blue-gql.sh` dans `templates/skills/blue-app/scripts/`. Tester en réel sur le Mac les backends `env`, `keychain`, `file`.
- [x] `blue-gql.sh --check` : OK + exit 0 avec chaque backend ; message clair + exit ≠ 0 si secret absent/invalide (testé : keychain OK 7 workspaces, env OK, file 644 refusé, file 600 avec fausses clés → erreur API propre exit 1).
- [x] Aucun secret écrit sur disque hors fenêtre d'exécution CLI ; jamais dans un dossier synchronisé ; jamais échoé (`config.env` régénéré/supprimé par trap, vérifié absent après exécution).
- [x] `errors[]` GraphQL → exit ≠ 0 (pas de faux succès) (testé sur query invalide, messages remontés sur stderr, exit 1).

Note Phase 1 : `SKILL.md` (138 lignes) et `INSTALL.md` (91 lignes) rédigés le même jour (anticipation de la Phase 2) ; syntaxe validée `sh -n` + `dash`. Point de vigilance pour durcissement ultérieur : les headers d'authentification passent en arguments de `curl`, brièvement visibles dans `ps` sur un système multi-utilisateur (acceptable en usage mono-utilisateur Mac/VPS ; piste : `curl --config` ou header file).

### Phase 2 — Skill portable et installation multi-agents — **faite le 2026-07-12** (banc d'essai MySecretaire)
Écrire `SKILL.md` + `INSTALL.md`. Dogfood sur un projet réel (MySecretaire ou LaCIOTAT) : pose de `98_configuration/skills/blue-app/`, installation Claude Code, entrée de handoff « Équiper un agent » vers Hermès, installation côté VPS (backend `file`), tableau d'équipement rempli par les deux agents.
- [x] La même skill fonctionne depuis Claude Code (Mac) et Hermès (VPS) sans modification, secrets résolus par des backends différents (Mac : `keychain`, `--check` OK 7 workspaces + `records list` 9 records ; VPS : backend `file` posé en SSH direct — `/root/.config/blue/secrets.env`, 600, jamais échoé — `--check` et `records list` OK, aucun `config.env` résiduel).
- [x] Chemin skills réel d'Hermès vérifié sur le VPS : les deux niveaux existent (`/root/.hermes/skills/` global et `/root/.hermes/profiles/<profil>/skills/`) ; copie globale retenue (D3), dossier plat `blue-app/` découvert et activé (`hermes skills list` : « local, enabled »). `INSTALL.md` figé et propagé aux 4 instances (canonique projet, `.claude`, `.codex`, VPS).
- [x] Codex : installé en réel (`.codex/skills/blue-app/`, Codex CLI 0.144.1), skill découverte (`codex exec` la liste) et `--check` OK depuis son chemin.

Constats Phase 2 à retenir : (a) les sessions Hermès reçoivent déjà `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` par leur couche Bitwarden Secrets Manager → la voie env (priorité 1) couvre Hermès sans configuration, le backend `file` devient un repli (documenté dans `INSTALL.md`) ; (b) aucun profil Hermès `MySecretaire` n'existe sur le VPS — l'entrée de handoff radar-projets du 2026-07-12 (toujours EN_ATTENTE) vise un profil inexistant, la copie globale D3 esquive le problème ; (c) tableau d'équipement rempli (Claude Code, Codex vérifiés ; ligne Hermès « en attente », vérification en session demandée par l'entrée de handoff « Équiper un agent » du 2026-07-12-1335).

### Phase 3 — Recettes GraphQL par domaine (reprise T-PLAN-2, Phases 2-3) — **faite le 2026-07-12**
Exécuter puis figer dans le `SKILL.md` : documents/wiki, formulaires, discussions/chat, fichiers (**upload presigned PUT validé de bout en bout**), status updates, + domaine templates (§ 4.1). Table de routage CLI/GraphQL complète.
- [x] Critères d'acceptation de T-PLAN-2 § 4 repris tels quels — tous satisfaits (« fichier visible dans l'UI » vérifié par la query `files` ; contrôle visuel UI possible par l'utilisateur).

Notes Phase 3 (exécution réelle sur le banc d'essai MySecretaire, objets `TEST-P3` créés puis supprimés, workspace revenu à l'état initial) :
- L'upload GraphQL (`uploadFile`, scalar `Upload` multipart) est inutilisable via `blue-gql.sh` : la voie fiable est REST `GET /uploads` → PUT presigné (900 s) → mutation `createFile` (`uid` = champ `X-Key`). Nouveau script `scripts/blue-files.sh` (upload/download encapsulés), testé de bout en bout (upload → listing → download → diff identique → suppression).
- `submitForm` : `formToken` = `uid` du formulaire ; une soumission devient un **record** du workspace (pas d'objet « submission » ; sans `todoListId`, première liste). `upsertFormField` : `formFieldId` obligatoire même en création.
- Message de discussion = `createComment` (`category: DISCUSSION`). Status updates immuables confirmé (create + delete seulement). Piège : `deleteStatusUpdate` aboutit côté serveur mais peut dépasser le timeout 30 s du wrapper → relister avant de réessayer.
- `companyId` des mutations (`createFolder`, `createFile`) = ID d'organisation, le slug est refusé (les filtres de query l'acceptent).
- Skill portée à `1.1.0`, propagée aux 4 instances. Détail : CHG-20260712-1658.

### Phase 4 — Workspace modèle et workflow commentaires
Dérouler T-PLAN-3 amendé : structure du modèle posée par agent (CLI), conversion testée via `convertWorkspaceToTemplate` (GraphQL), réglages visuels par l'utilisateur, création d'un workspace fils et relevé des nouveaux IDs. Implémenter et tester le workflow commentaires (§ 6) sur une carte réelle : commentaire de l'utilisateur → action agent → mise à jour `TASKS.md` → resynchro carte → commentaire de confirmation.
- [ ] Points 5.1 à 5.3 de T-PLAN-3 vérifiés au premier essai.
- [ ] Un commentaire posté depuis le téléphone est détecté, exécuté et confirmé à la session suivante.

### Phase 5 — Wiring méthode et propagation
Appliquer le § 8 (gate DEC/CHG, v0.11.0), dérouler la skill `validate`, propager par `--update-method` aux projets structurés, mettre à jour les gouvernances Blue instanciées (LaCIOTAT, MySecretaire) sans écraser leur vécu. Migrer `~/.claude/skills/blue-cli` (myagent) vers une instance de `blue-app` (D4) et consigner la migration dans la section Provenance de la skill.

## 10. Décisions (tranchées par l'utilisateur le 2026-07-12)

- **D1 — Nom : `blue-app`**, sous `templates/skills/blue-app/`. Minuscules et tirets uniquement (compatibilité entre les implémentations du standard : `blue.app` et `blue_app` écartés pour cette raison). Variante suffixée `blue-app-<projet>` possible sur le modèle du précédent `blue-cli-unjque`, réservée au cas où un projet exige un *comportement* différent — la *configuration* spécifique (organisation, workspace, règles de nommage ou de gestion propres au projet) vit déjà dans le `GOUVERNANCE_BLUE.md` du projet, que la skill lit en premier.
- **D2 — Conversion en template exécutée par l'agent**, après accord explicite de l'humain dans la session (action nouvelle au niveau de l'organisation ; réversible via `removeWorkspaceFromTemplates`). Si aucun workspace modèle n'existe encore (premier usage, ou autre utilisateur de la méthode), l'agent construit d'abord le modèle via la CLI, puis propose la conversion. Les réglages visuels du modèle restent un geste humain.
- **D3 — Hermès par copie unique globale** dans son dossier skills (`~/.hermes/skills/` ou par profil : chemin réel à vérifier au premier essai VPS, puis figé dans `INSTALL.md`). Mise à jour occasionnelle via l'entrée handoff « Équiper un agent ». `skills.external_dirs` écarté : skill modifiable par n'importe quelle session touchant le dossier projet, et vulnérable aux conflits Syncthing.
- **D4 — Migration de `~/.claude/skills/blue-cli`** (myagent) vers une instance de `blue-app` une fois la Phase 2 validée en réel ; ses spécificités myagent (organisation par défaut, table des workspaces connus, garde-fou `COMPANY_ID`) sont reprises dans l'instance ou les gouvernances projet. `blue-cli-unjque` n'est pas concernée (company `unjque`, hors périmètre).
- **D5 — Windows : documentation seule** dans `INSTALL.md` (coffre PowerShell SecretManagement/SecretStore → variables d'environnement, sourcée et datée). Aucun script `.ps1` tant qu'aucune machine Windows réelle ne permet de le tester (règle « aucune recette théorique »).

## 11. Articulation

- Englobe `2026-07-12-blue-cli-extension-graphql.md` (T-PLAN-2, amendé § 4.1) et `2026-07-12-blue-workspace-template.md` (T-PLAN-3, amendé § 4.2) : valider ce plan vaut arbitrage des trois, les critères d'acceptation des plans d'origine restant dus.
- S'appuie sur : DEC-0026 (`98_configuration/`), DEC-0027 (gabarit gouvernance), DEC-0028 (proposition active Modes 5/6), RETEX MySecretaire (précédent d'équipement Hermès § 2.4).
- Prépare la ROADMAP Phase 7 (portabilité des garde-fous vers Hermès) : la brique Blue devient le premier cas concret de skill partagée entre les trois agents.
