# Plan — Extension GraphQL de la skill globale `blue-cli`

> Statut : **proposition, non appliquée**. Zone PLAN/ = plan de travail isolé avant intégration.
> Date : 2026-07-12. Auteur de l'analyse : Claude Code (session Mac), à la demande de l'utilisateur.
> Périmètre principal : la skill globale `~/.claude/skills/blue-cli` (hors dépôt méthode).
> Impact méthode : enrichissement du gabarit `templates/configuration/GOUVERNANCE_BLUE.md` une fois le plan appliqué (voir § Impacts sur la méthode).

## 1. Contexte

La skill globale `blue-cli` pilote Blue (blue.cc) via la CLI `blue` (Homebrew, v0.6.6), scopée à l'organisation `myagent`, avec un wrapper `blue-kc.sh` qui régénère les credentials depuis le trousseau macOS à chaque appel (aucun secret au repos sur disque).

Constat du 2026-07-12 : la CLI ne couvre qu'une partie des fonctionnalités visibles dans l'interface Blue. Le wiki, le chat, les documents, les formulaires et la gestion fine des fichiers (upload, dossiers) sont absents du binaire. Or l'API GraphQL de Blue (`https://api.blue.app/graphql`, documentée sur `https://blue.app/api/graphql/start-guide/introduction`) expose la totalité du produit : « anything you can do in the UI you can drive programmatically ».

## 2. Constat vérifié (tests réels du 2026-07-12)

Tous les points ci-dessous ont été **testés en live** depuis le Mac, pas seulement lus dans la doc.

### 2.1 Authentification : aucun nouveau secret nécessaire

Les identifiants déjà stockés dans le trousseau macOS (service `blue-cli`, comptes `client_id` et `auth_token`) sont acceptés tels quels par l'API GraphQL comme headers `blue-token-id` / `blue-token-secret`. Testé avec succès sur `workspaceList` (les 7 workspaces `myagent` retournés). Les headers legacy `X-Bloo-Token-ID` / `X-Bloo-Token-Secret` fonctionnent aussi.

Headers d'une requête type :

```
POST https://api.blue.app/graphql
Content-Type: application/json
blue-token-id: <client_id du trousseau>
blue-token-secret: <auth_token du trousseau>
blue-org-id: myagent
blue-workspace-id: <ws_id>        # requis pour les opérations scopées workspace
```

### 2.2 Étendue de l'API

Introspection exécutée le 2026-07-12 : **128 queries, 304 mutations**. Couverture comparée :

| Domaine | CLI `blue` v0.6.6 | API GraphQL (vérifié) |
|---|---|---|
| Workspaces, lists, records, tags, custom fields, users, checklists, comments, automations, dashboards, charts, dependencies | ✅ | ✅ |
| Documents et wiki | ❌ | ✅ `documents`, `document`, `createDocument`, `updateDocument`, `deleteDocument` (une page wiki = `Document` avec `wiki: true`) |
| Formulaires | ❌ | ✅ `forms`, `form`, `formFields`, `createForm`, `updateForm`, `upsertFormField`, `copyForm`, `deleteForm`, `submitForm` (public) |
| Discussions | ❌ | ✅ `discussions`, `discussion`, `discussionList`, `createDiscussion`, `updateDiscussion`, `deleteDiscussion` |
| Chat | ❌ | ✅ `chats`, `createChat`, `updateChat`, `deleteChat`, `createChatMessage` |
| Fichiers (upload, liste, organisation) | ⚠️ `files download` seulement (zip global) | ✅ `files`, `uploadFile`, `uploadFiles`, `updateFile`, `deleteFile(s)`, `folders`, `createFolder`, `editFolder`, `setFileFolder`, `setParentFolder` |
| PDF templates (« Portable Documents ») | ❌ | ✅ `portableDocuments`, `createPortableDocument`, `createPortableDocumentField`, `printPortableDocument` |
| Status updates (santé projet vert/orange/rouge) | ❌ | ✅ `createStatusUpdate`, `deleteStatusUpdate`, `statusUpdateList` (immuables : pas d'édition, supprimer puis reposter) |
| Temps réel | ❌ | ✅ subscriptions WebSocket `wss://api.blue.app/graphql` (hors périmètre de ce plan) |

### 2.3 Signatures réelles validées (pièges confirmés)

Les signatures varient d'un domaine à l'autre ; celles-ci ont été exécutées avec succès :

```graphql
# Documents (wiki inclus) — filter.projectId (singulier)
query { documents(filter: { projectId: "<ws_id>" }) { items { id title wiki } } }

# Discussions — filter.projectId (singulier)
query { discussions(filter: { projectId: "<ws_id>" }) { items { id title } } }

# Folders — companyId ET type obligatoires ; champ titre = title (pas name)
query { folders(filter: { companyId: "myagent", projectId: "<ws_id>", type: FILE }) { items { id title } } }

# Files — projectIds (pluriel), contrairement à documents/discussions
query { files(filter: { projectIds: ["<ws_id>"] }) { items { id name } } }

# Forms — filter.projectId
query { forms(filter: { projectId: "<ws_id>" }) { items { id title isActive } } }
```

Pièges transverses constatés :
- les résultats paginés sont sous `items { }` (types `XxxPagination`) ;
- `discussionList` (curseur) et `discussions` (offset) coexistent avec des signatures différentes ;
- les messages d'erreur GraphQL suggèrent les bons noms de champs (`Did you mean...`), ce qui rend le débogage quasi auto-correctif ;
- l'introspection du schéma est ouverte (`__schema`), utilisable comme documentation de secours.

### 2.4 Limites connues

- Le token a des droits restreints : `workspaces update/delete` refusés côté CLI (« not authorized »), les mêmes restrictions s'appliquent en GraphQL.
- L'upload de fichiers passe par un flux presigned PUT en deux temps (obtenir l'URL, puis PUT du binaire) : c'est le morceau le plus délicat, à valider soigneusement avant de le documenter comme fiable.
- Rate limits selon le plan Blue (headers de quota dans les réponses, cf. doc « Rate Limits »).

## 3. Plan d'évolution proposé

### Phase 1 — Wrapper `blue-gql.sh`

Nouveau script à côté de `blue-kc.sh` dans `~/.claude/skills/blue-cli/` :

- lit `client_id` / `auth_token` depuis le trousseau macOS (comme `blue-kc.sh`) ;
- envoie la requête en `curl` avec les headers `blue-token-id` / `blue-token-secret` / `blue-org-id` ;
- **aucun fichier de secrets créé**, même transitoire (supériorité sur le wrapper CLI, qui doit régénérer `config.env`) ;
- org `myagent` par défaut, option pour surcharger ;
- option `-w <ws_id>` pour poser le header `blue-workspace-id` ;
- requête passée en argument, via fichier ou stdin (mutations complexes multi-lignes) ;
- variables GraphQL passées en JSON séparé (évite l'échappement fragile dans la query) ;
- fiabilité : timeout curl, détection du tableau `errors` dans la réponse → exit code non nul avec le message ;
- commande `--check` : smoke test sur `workspaceList`, diagnostic en 2 secondes ;
- jamais d'écho des secrets.

### Phase 2 — Recettes validées par domaine

Pour chaque domaine non couvert par la CLI, exécuter la vraie requête en conditions réelles puis figer la recette dans le SKILL.md (comme les IDs de lists/tags déjà cartographiés) :

1. Documents / wiki : liste, lecture, création, mise à jour (`wiki: true` pour une page wiki).
2. Formulaires : création, champs (`upsertFormField`), activation, lecture des soumissions.
3. Discussions et chat : création, message, liste.
4. Fichiers : liste, dossiers, déplacement ; **upload presigned PUT validé de bout en bout** avant documentation.
5. Status updates : poster, lister (noter l'immuabilité).
6. Portable Documents : seulement si un besoin concret apparaît (complexité élevée, pas de cas d'usage identifié à ce jour).

### Phase 3 — Règle de routage dans le SKILL.md

Principe : **CLI d'abord** pour tout ce qu'elle couvre (moins verbeuse, moins d'erreurs possibles), **GraphQL uniquement pour le reste**. Tableau de décision explicite dans la skill pour que chaque session sache immédiatement quel outil prendre, sans réexplorer.

### Phase 4 — Validation et déploiement

- Test de bout en bout sur un workspace réel : créer une page wiki, un dossier, uploader un fichier, poster une discussion.
- Rien à copier par projet : la skill est globale, tous les projets MyProjects en bénéficient dès la mise à jour.
- La skill projet `blue-cli-unjque` n'est pas touchée (company `unjque`, hors périmètre).

## 4. Critères d'acceptation (fiabilité exigée)

- [ ] `blue-gql.sh --check` retourne OK et exit 0 ; un token invalide retourne un message clair et exit non nul.
- [ ] Aucun secret écrit sur disque à aucun moment ; aucun secret affiché dans les sorties.
- [ ] Toute recette documentée dans le SKILL.md a été exécutée avec succès au moins une fois (pas de recette « théorique »).
- [ ] L'upload de fichier fonctionne de bout en bout (fichier visible dans l'UI Blue après upload).
- [ ] Une erreur GraphQL (`errors[]`) est détectée et remonte en exit code non nul (pas de faux succès).
- [ ] Le tableau de routage CLI vs GraphQL couvre tous les domaines listés au § 2.2.

## 5. Impacts sur la méthode MyProjectOS

Ce plan vit hors du dépôt méthode (skill globale), mais une fois appliqué :

- **`templates/configuration/GOUVERNANCE_BLUE.md`** (v0.9.0, DEC-0027) : ajouter une section sur les capacités étendues (wiki, documents, formulaires, fichiers) et le routage CLI/GraphQL, pour que les projets qui activent la brique Blue sachent ce qui est pilotable au-delà du miroir `TASKS.md`.
- Les pièges CLI déjà consignés dans le gabarit restent valables ; les pièges GraphQL du § 2.3 pourraient les rejoindre.
- Aucune modification de `init-project.sh`, `check-project.sh` ni des hooks : conformément à DEC-0028, Blue reste un geste de session, pas un flag d'installation.

## 6. Décision attendue

Valider (ou amender) ce plan, puis lancer l'implémentation Phase 1 → 4. L'application sera consignée dans le CHANGELOG de la skill globale (section Provenance du SKILL.md) et, pour le volet méthode, via le gate DEC/CHG habituel du dépôt.
