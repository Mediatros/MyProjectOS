---
name: blue-app
description: Piloter Blue (blue.cc) sur un projet MyProjectOS — tâches, records, wiki, documents, formulaires, fichiers, commentaires. Active cette skill pour toute opération Blue sur le workspace d'un projet : synchronisation TASKS.md, création/mise à jour de records, lecture ou dépôt de commentaires, wiki/documents, discussions, fichiers. Générique : aucune organisation, aucun workspace, aucun ID en dur — tout le spécifique projet se lit dans 98_configuration/GOUVERNANCE_BLUE.md.
version: "1.2.0"
required_environment_variables:
  - BLUE_TOKEN_ID
  - BLUE_TOKEN_SECRET
metadata:
  source: MyProjectOS templates/skills/blue-app
  standard: agentskills.io
---

# Skill — Blue App (générique MyProjectOS)

Skill portable, agent-agnostique (Claude Code, Codex, Hermès), pour piloter Blue (blue.cc) sur n'importe quel projet MyProjectOS ayant activé la brique Blue. Elle ne contient aucune organisation, aucun workspace ni aucun ID : tout cela vit dans la gouvernance du projet.

## Règle d'or

**Avant toute opération Blue, lire `98_configuration/GOUVERNANCE_BLUE.md` du projet courant.** Ce fichier porte l'organisation, le workspace, les IDs (lists, tags, custom fields), les conventions de nommage et le workflow miroir `TASKS.md` ↔ Blue. Cette skill ne fait que fournir les outils (CLI, GraphQL, secrets) et le routage ; toute règle de contenu spécifique au projet fait foi dans la gouvernance, pas ici.

Si `98_configuration/GOUVERNANCE_BLUE.md` n'existe pas encore sur le projet : le proposer à partir du gabarit `templates/configuration/GOUVERNANCE_BLUE.md` de MyProjectOS. Ne jamais improviser une organisation, un workspace ou des IDs en son absence.

## Secrets et connexion

Les scripts (`scripts/blue-secrets.sh`, `scripts/blue-cli.sh`, `scripts/blue-gql.sh`) résolvent les identifiants `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` selon trois backends, sélectionnables par `BLUE_SECRET_BACKEND` :

| Backend | Plateforme | Détail |
|---|---|---|
| `keychain` | macOS (défaut si `security` existe) | trousseau, service `blue-cli`, comptes `client_id`/`auth_token` |
| `bws` | toutes | Bitwarden Secrets Manager, `BWS_ACCESS_TOKEN` + `BLUE_BWS_TOKEN_ID_UUID`/`BLUE_BWS_TOKEN_SECRET_UUID` |
| `file` | toutes (défaut sinon), nominal VPS headless | `~/.config/blue/secrets.env`, `chmod 600` obligatoire, surchargeable par `BLUE_SECRETS_FILE` |

Priorité absolue : des variables d'environnement déjà posées dans la session (voie universelle, y compris Windows) court-circuitent tout backend.

Procédure d'installation et de configuration détaillée : voir `INSTALL.md` à côté de ce fichier.

**Règle absolue** : jamais de secret dans le dossier projet (il est synchronisé par Syncthing), jamais en clair dans une sortie de commande ou un commentaire. `blue-cli.sh` régénère `~/.config/blue/config.env` puis le supprime en sortie (`trap EXIT`) ; `blue-gql.sh` n'écrit rien sur disque.

## Scripts fournis

Interface fixe, à ne pas contourner par des appels directs à `blue` ou `curl` :

- **`scripts/blue-secrets.sh`** — sourcé (jamais exécuté seul), exporte `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` selon le backend actif. Utilisé par les deux scripts suivants, pas d'usage direct par l'agent.
- **`scripts/blue-cli.sh <args blue...>`** — wrapper de la CLI `blue`. Exige `BLUE_ORG` (organisation, lue dans la gouvernance du projet). Transmet ses arguments tels quels à `blue`, à une exception près : sur `tags add`, il lit d'abord les tags existants du record et fusionne les tag-ids, car la CLI **remplace** la liste au lieu de la compléter (bug tracé dans l'issue MyProjectOS#2 ; si la lecture préalable échoue, l'appel est annulé plutôt que de laisser écraser les tags) :
  ```sh
  BLUE_ORG=<org> scripts/blue-cli.sh records list -w <ws_id> --simple
  BLUE_ORG=<org> scripts/blue-cli.sh records update -r <record_id> -w <ws_id> -t "Nouveau titre"
  ```
- **`scripts/blue-gql.sh [-w <ws_id>] [-o <org>] [-v '<json>'] [-f <fichier>] [--check] [<query>|stdin]`** — client GraphQL vers `api.blue.app/graphql`. Organisation via `-o` ou `BLUE_ORG`. `--check` lance un smoke test (`workspaceList`). Toute réponse contenant `errors[]` fait sortir le script en échec (exit ≠ 0), jamais de faux succès. Dépendance : `jq`.
  ```sh
  BLUE_ORG=<org> scripts/blue-gql.sh -w <ws_id> 'query { documents(filter: { projectId: "'"$ws_id"'" }) { items { id title wiki } } }'
  BLUE_ORG=<org> scripts/blue-gql.sh --check
  ```
- **`scripts/blue-files.sh upload <fichier> -w <ws_id>` / `download <uid> -w <ws_id> [-O <sortie>]`** — upload et download de fichiers via le flux presigné REST (`GET /uploads` → PUT du binaire → mutation `createFile`), seule voie fiable : les mutations GraphQL `uploadFile`/`uploadFiles` exigent un multipart (scalar `Upload`) inutilisable via `blue-gql.sh`. Organisation via `-o` ou `BLUE_ORG` ; poser `BLUE_COMPANY_ID` (ID d'organisation) évite une query de résolution à chaque upload.
  ```sh
  BLUE_ORG=<org> scripts/blue-files.sh upload rapport.pdf -w <ws_id>
  BLUE_ORG=<org> scripts/blue-files.sh download <uid> -w <ws_id> -O rapport.pdf
  ```

## Table de routage : CLI d'abord, GraphQL pour le reste

Principe : la CLI `blue` est moins verbeuse et moins sujette à erreur — l'utiliser dès qu'elle couvre le besoin. GraphQL (`scripts/blue-gql.sh`) uniquement pour ce que la CLI ne fait pas.

| Domaine | Outil |
|---|---|
| Workspaces, lists, records, tags, custom fields, users, checklists, comments, automations, dashboards | CLI `blue` (`scripts/blue-cli.sh`) |
| Documents et wiki | GraphQL |
| Formulaires | GraphQL |
| Discussions, chat | GraphQL |
| Fichiers (upload, download, dossiers) | `scripts/blue-files.sh` pour upload/download (flux presigné REST) ; GraphQL pour lister, déplacer, renommer, supprimer |
| Status updates | GraphQL |
| Templates de workspace | GraphQL (`workspaces create --template <ID>` existe côté CLI pour instancier, mais lister/convertir est GraphQL) |
| Portable Documents (PDF templates) | GraphQL — domaine non validé à ce jour, ne pas improviser (voir plus bas) |
| Temps réel (subscriptions WebSocket) | Hors périmètre de la skill |

## Recettes GraphQL vérifiées (exécutées en réel le 2026-07-12)

Toutes les requêtes ci-dessous ont été exécutées avec succès en conditions réelles, création, relecture et suppression comprises. `-w <ws_id>` pose le header `blue-workspace-id` sur `blue-gql.sh` ; `-o <org>` ou `BLUE_ORG` sélectionne l'organisation ; `-v '<json>'` passe les variables séparément (voie à préférer pour toute mutation).

### Pièges transverses (tous domaines)

- Trois enveloppes de pagination coexistent : la plupart des listes sous `items { }` ; `statusUpdateList` retourne `{ statusUpdates, totalCount }` ; `records` exige le filtre `TodosFilter!` avec `companyIds: []` obligatoire même vide.
- Trois types de retour de suppression : Boolean nu, sans bloc de sélection (`deleteDocument`, `deleteForm`, `deleteChat`, `deleteFile`) ; `MutationResult { success }` (`deleteDiscussion`, `deleteStatusUpdate`, `deleteRecord`) ; l'introspection tranche.
- Types d'ID incohérents : les queries et suppressions prennent souvent `id: String!` en argument direct, mais les `UpdateXxxInput.id` sont `ID!`. Un mauvais type dans la déclaration de variable fait échouer l'appel.
- Dans les mutations (`createFolder`, `createFile`...), `companyId` = l'**ID** de l'organisation, pas son slug (le slug est refusé), alors que les filtres de query acceptent le slug. Résolution : `query { organizations { items { id slug } } }`.
- `discussionList` (curseur) et `discussions` (offset) coexistent avec des signatures différentes.
- Les messages d'erreur suggèrent les bons noms de champs (« Did you mean... ») ; l'introspection `__schema` fait foi en cas de doute, pas la doc publique.
- `deleteStatusUpdate` aboutit côté serveur mais sa réponse peut dépasser le timeout de 30 s du wrapper (exit ≠ 0 à tort) : après un timeout sur cette mutation, **toujours relister avant de réessayer**.
- **`todoCustomFields` est cassé côté serveur** (confirmé le 2026-07-12, issue MyProjectOS#3) : il retourne `null` aussi bien dans la liste `records(filter:)` que dans la query unitaire `record(id:)`, quels que soient les arguments. Pour lire les custom fields, sélectionner **`customFields { id name value }`** sur `Record` (`value` est un scalaire JSON portant la valeur réelle ; c'est la sélection qu'utilise la CLI elle-même). La query racine unitaire s'appelle `record(id: String!)`, pas `todo(id:)`.

### Queries de base

```graphql
# Workspaces d'une organisation — filter.companyIds obligatoire
query { workspaceList(filter: { companyIds: ["<org>"] }) { items { id name } } }

# Documents (wiki inclus) / Discussions / Forms — filter.projectId (singulier)
query { documents(filter: { projectId: "<ws_id>" }) { items { id title wiki } } }
query { discussions(filter: { projectId: "<ws_id>" }) { items { id title } } }
query { forms(filter: { projectId: "<ws_id>" }) { items { id title isActive } } }

# Files — projectIds (pluriel) ; Folders — companyId ET type obligatoires, titre = title
query { files(filter: { projectIds: ["<ws_id>"] }) { items { id name size status folder { id title } } } }
query { folders(filter: { companyId: "<org>", projectId: "<ws_id>", type: FILE }) { items { id title } } }

# Chats / Status updates (argument projectId direct, sans filter)
query { chats(filter: { projectId: "<ws_id>" }) { items { id title type } } }
query { statusUpdateList(projectId: "<ws_id>") { statusUpdates { id text category date } totalCount } }

# Templates de workspace de l'organisation
query { templates { items { id name } } }

# Records avec custom fields en masse (ex. clé de correspondance TASKS.md ↔ Blue) —
# customFields, PAS todoCustomFields (cassé, voir pièges transverses)
query R($filter: TodosFilter!) { records(filter: $filter) { items { id title customFields { id name value } } } }
# -v '{"filter":{"companyIds":[],"projectIds":["<ws_id>"]}}'
```

### Documents et wiki

Une page wiki = un `Document` avec `wiki: true`, même mutation pour les deux. `CreateDocumentInput` : seul `projectId` est obligatoire.

```graphql
mutation CreateDoc($input: CreateDocumentInput!) { createDocument(input: $input) { id title content wiki } }
# -v '{"input":{"projectId":"<ws_id>","title":"...","content":"...","wiki":true}}'

query GetDoc($id: String!) { document(id: $id) { id title content wiki } }

mutation UpdateDoc($input: UpdateDocumentInput!) { updateDocument(input: $input) { id title content wiki } }
# -v '{"input":{"id":"<doc_id>","title":"..."}}' — mise à jour partielle ; id typé ID! ;
# wiki modifiable (conversion document ↔ wiki possible)

mutation DeleteDoc($id: String!) { deleteDocument(id: $id) }   # Boolean nu
```

### Formulaires

Un formulaire naît `isActive: true` ; son `uid` sert de token de soumission. Pas de query de soumissions : **une soumission devient un record** du workspace (sans `todoListId` posé sur le formulaire, dans sa première liste).

```graphql
mutation CreateForm($input: CreateFormInput!) { createForm(input: $input) { id title isActive uid } }
# -v '{"input":{"projectId":"<ws_id>","title":"..."}}'

mutation UpsertFF($input: UpsertFormFieldInput!) { upsertFormField(input: $input) { id field name required position } }
# -v '{"input":{"formId":"<form_id>","formFieldId":"<id unique>","field":"title","name":"...","required":true,"position":1}}'
# formFieldId OBLIGATOIRE même en création (devient l'id réel du champ) ;
# field = enum : title | description | tags | assignees | startedAt | duedAt | custom (+ customFieldId)

query FF($filter: FormFieldFilterInput) { formFields(filter: $filter) { id field name required position } }
# -v '{"filter":{"formId":"<form_id>"}}'

mutation UpdF($input: UpdateFormInput!) { updateForm(input: $input) { id isActive } }
# -v '{"input":{"id":"<form_id>","isActive":false}}'

mutation Submit($input: SubmitFormInput!) { submitForm(input: $input) }   # Boolean nu
# -v '{"input":{"formToken":"<form_uid>","formId":"<form_id>","formFieldInput":[{"formFieldId":"<field_id>","value":"..."}]}}'
# formToken = le uid du formulaire, pas son id ; fonctionne avec le token API normal

# Relire les soumissions = query records (companyIds: [] obligatoire même vide)
query R($filter: TodosFilter!) { records(filter: $filter) { items { id title todoList { id title } createdAt } } }
# -v '{"filter":{"companyIds":[],"projectIds":["<ws_id>"],"q":"<titre>"}}'

mutation DelF($id: String!) { deleteForm(id: $id) }   # Boolean nu
```

### Discussions

`CreateDiscussionInput` : `title`, `html`, `text`, `projectId` tous obligatoires. Pas de mutation « message de discussion » : c'est `createComment` avec `category: DISCUSSION`. `UpdateDiscussionInput` ne permet de changer que le titre.

```graphql
mutation($input: CreateDiscussionInput!) { createDiscussion(input: $input) { id title } }
# -v '{"input":{"title":"...","html":"<p>...</p>","text":"...","projectId":"<ws_id>"}}'

mutation($input: CreateCommentInput!) { createComment(input: $input) { id text category } }
# -v '{"input":{"html":"<p>...</p>","text":"...","category":"DISCUSSION","categoryId":"<discussion_id>"}}'
# enum CommentCategory : DISCUSSION, STATUS_UPDATE, TODO

mutation($input: UpdateDiscussionInput!) { updateDiscussion(input: $input) { id title } }
mutation($id: String!) { deleteDiscussion(id: $id) { success } }   # MutationResult
```

### Chat

```graphql
mutation($input: CreateChatInput!) { createChat(input: $input) { id title type } }
# -v '{"input":{"projectId":"<ws_id>","title":"..."}}' — type optionnel (GENERAL, FILE_QA, PROJECT_ASSISTANT)

mutation($input: CreateChatMessageInput!) { createChatMessage(input: $input) { id text } }
# -v '{"input":{"chatId":"<chat_id>","text":"..."}}'

# Relire les messages : champ imbriqué du chat, pas de query dédiée
query { chats(filter: { projectId: "<ws_id>" }) { items { id title messages { id text } } } }

mutation($id: String!) { deleteChat(id: $id) }   # Boolean nu
```

### Status updates (immuables)

`updateStatusUpdate` n'existe pas (confirmé par introspection) : un status update se remplace (create puis delete de l'ancien). Les 5 champs de `CreateStatusUpdateInput` sont obligatoires ; `category` = enum `GREEN | ORANGE | RED`.

```graphql
mutation($input: CreateStatusUpdateInput!) { createStatusUpdate(input: $input) { id text category date } }
# -v '{"input":{"projectId":"<ws_id>","html":"<p>...</p>","text":"...","date":"<ISO 8601>","category":"GREEN"}}'

mutation($id: String!) { deleteStatusUpdate(id: $id) { success } }   # MutationResult — voir le piège timeout ci-dessus
```

### Fichiers et dossiers

Upload et download : **passer par `scripts/blue-files.sh`**, qui encapsule le flux presigné complet (`GET /uploads?filename=` → PUT du binaire vers l'URL presignée, expiration 900 s → `createFile` avec `uid` = champ `X-Key` de la réponse et la taille réelle en octets ; download : `GET /uploads/<uid>` → 302 vers une URL presignée de lecture). Sans la mutation `createFile`, un binaire uploadé reste invisible dans Blue.

```graphql
mutation CreateFolder($input: CreateFolderInput!) { createFolder(input: $input) { id title type } }
# -v '{"input":{"type":"FILE","title":"...","companyId":"<ID d organisation, pas le slug>","projectId":"<ws_id>"}}'

mutation SetFileFolder($input: SetFileFolderInput!) { setFileFolder(input: $input) }   # Boolean nu — fileIds au pluriel
# -v '{"input":{"fileIds":["<file_id>"],"folderId":"<folder_id>"}}'

mutation UpdateFile($input: UpdateFileInput!) { updateFile(input: $input) { id name } }
# -v '{"input":{"id":"<file_id>","name":"..."}}' — champs modifiables : name, shared, status

mutation { deleteFile(id: "<file_id>") }   # Boolean nu ; deleteFiles(ids: [...]) pour le lot
mutation DeleteFolder($input: DeleteFolderInput!) { deleteFolder(input: $input) }
# -v '{"input":{"id":"<folder_id>"}}'
```

### Domaine non encore validé

Portable Documents (PDF templates : `portableDocuments`, `createPortableDocument`, `printPortableDocument`) : **à valider avant usage réel** (complexité élevée, aucun cas d'usage identifié à ce jour). Ne pas improviser de recette non testée sur ce domaine.

### Piège documentation vs schéma réel : conversion en template

La documentation Blue nomme la mutation `convertProjectToTemplate` ; **le schéma réel expose `convertWorkspaceToTemplate`** (confirmé par introspection le 2026-07-12), avec aussi `removeWorkspaceFromTemplates` et `instantiateTemplateFolder`. En cas de doute sur une signature, l'introspection `__schema` fait foi, pas la doc publique.

**La conversion d'un workspace en template est une action au niveau de l'organisation** (elle affecte tous les projets qui pourraient s'en servir comme modèle). Ne jamais l'exécuter sans accord humain explicite dans la session, même si elle est techniquement réversible via `removeWorkspaceFromTemplates`.

Pour les pièges CLI (paramètres obligatoires, échappement de description, checklists en deux temps...), voir la section « Pièges CLI connus » de `98_configuration/GOUVERNANCE_BLUE.md` du projet — ils ne sont pas dupliqués ici.

## Créer le workspace d'un nouveau projet

Si un workspace modèle existe dans l'organisation (structure canonique : 4 lists, tag `Urgent`, custom field `ID`), partir de lui plutôt que de construire à la main :

1. Trouver son ID : `query { templates { items { id name } } }`.
2. Créer le workspace fils : `BLUE_ORG=<org> scripts/blue-cli.sh workspaces create --name "<Projet>" --template <template_id>`. Piège : la sortie de cette commande revient vide (ID/Name/Slug/Category non peuplés, la copie est asynchrone) — retrouver le workspace fils par `workspaceList` (recherche par nom), pas par la sortie de la commande.
3. **Inviter l'utilisateur humain sur ce workspace** (`blue users invite --email <email> --access-level <niveau> --workspace <id>`) : un workspace créé par API n'est pas automatiquement visible dans l'UI de l'humain propriétaire du compte, même s'il est admin de l'organisation. Sans cette étape, l'humain ne verra pas le workspace qu'il vient de faire créer.
4. La copie génère de nouveaux IDs pour les lists, tags et custom fields : les relever (`lists list`, `tags list`, `fields list`) et créer les tags de domaine propres au projet.
5. Instancier `98_configuration/GOUVERNANCE_BLUE.md` du projet avec ces IDs.

Si aucun workspace modèle n'existe encore : le signaler, construire d'abord sa structure via la CLI, proposer la conversion en template (voir piège ci-dessus, accord humain obligatoire), avant de créer le workspace du projet.

## Workflow commentaires : pilotage humain → agent

Les cartes Blue acceptent des commentaires, consultables et rédigeables depuis le téléphone. Convention :

1. **Tout commentaire humain sur une carte du workspace miroir est une demande actionnable** adressée au prochain agent qui ouvre une session sur le projet.
2. **Relevé en début de session** : quand la brique Blue est active, le rituel de reprise inclut un relevé des commentaires non traités (comme pour `ECHEANCES.md` et le handoff). Relevé aussi à la demande (« relève Blue »).
3. **Détection du non-traité, sans état séparé** : un commentaire humain est non traité tant qu'aucun commentaire de réponse agent n'a été posté après lui sur la même carte. Pas de tag ni de fichier d'état à maintenir.
4. **Ordre d'exécution** : appliquer la demande d'abord dans `TASKS.md` (source de vérité du miroir), puis resynchroniser la carte (list, titre, description, checklist, custom field `ID`), selon le workflow de `GOUVERNANCE_BLUE.md`.
5. **Confirmation systématique** : poster un commentaire de confirmation sur la carte : `✅ Pris en compte par <agent> le <YYYY-MM-DD HH:MM> : <action réalisée ou en cours>`. Pour une action sensible (suppression massive, engagement externe...), le commentaire dit explicitement « en attente de validation » et la demande remonte dans la session / `PROGRESS.md`.
6. **Limite assumée** : aucune notification push, la latence est « à la prochaine session ».

## Registre d'équipement

Tenir à jour le tableau « Accès technique » de `98_configuration/GOUVERNANCE_BLUE.md` du projet : agent, chemin d'installation de la skill, backend de secrets utilisé, date de dernière vérification. Un agent qui s'équipe (voir `INSTALL.md`) ajoute ou met à jour sa ligne. Un agent qui ne peut pas s'équiper seul (secrets à fournir par l'humain) le demande via une entrée de handoff « Équiper un agent ».

## Provenance

Skill générique du dépôt méthode MyProjectOS (`templates/skills/blue-app/`), instanciée dans chaque projet sous `98_configuration/skills/blue-app/` puis installée par agent selon `INSTALL.md`. Généralise la skill globale personnelle `~/.claude/skills/blue-cli` (organisation `myagent`) une fois cette dernière migrée (voir décision D4 du plan d'origine).

**D4 réalisée le 2026-07-12** : instance personnelle `~/.claude/skills/blue-app-myagent/` créée (copie des scripts + `SKILL.md` adapté : `BLUE_ORG=myagent`, table de routage projet → workspace et détails de workspace repris de l'ancienne skill), vérifiée en réel (`--check` OK, 7/8 workspaces retrouvés à l'identique). `~/.claude/skills/blue-cli/` laissée en place intacte, à titre de filet, non appelée par la nouvelle instance — bascule complète (suppression de l'ancienne) laissée à la discrétion de l'utilisateur après un usage réel de `blue-app-myagent`.
