# Plan — Workspace Blue modèle : uniformiser les cartes d'un projet à l'autre

> **Statut :** proposé, en attente de décision humaine (T-PLAN-3).
> **Date :** 2026-07-12
> **Zone :** `PLAN/plans/`
> **Origine :** RETEX MySecretaire du 2026-07-12, lors de la mise en conformité du workspace Blue avec `GOUVERNANCE_BLUE.md` : constat qu'à chaque nouveau workspace il faut recréer à la main toute la structure (lists, tags, custom field `ID`, réglages visuels), et que les champs d'une carte apparaissent repliés par défaut à l'ouverture. Demande explicite de l'utilisateur : documenter la solution ici, l'implémentation sera décidée ensuite.

## 1. Problème

Deux irritants distincts, constatés sur le workspace `MySecretaire` (organisation `myagent`) :

1. **Création répétitive.** La brique Blue de la méthode (DEC-0027, DEC-0028) suppose pour chaque projet un workspace structuré à l'identique : lists `À faire / En cours / Terminé / Abandonné`, tag `Urgent`, custom field `ID` (TEXT_SINGLE, clé de correspondance avec `TASKS.md`), plus les réglages d'affichage. Aujourd'hui tout est recréé à la main (ou à la CLI) projet par projet, avec risque de dérive (tags en doublon, field manquant, listes nommées différemment).
2. **Champs repliés à l'ouverture d'une carte.** L'interface Blue replie les champs vides ; seuls les champs porteurs d'une valeur (ex. le custom field `ID`) sont visibles d'emblée. Il n'existe pas de réglage documenté « toujours déplier tel champ » par carte.

## 2. Faits sourcés (documentation Blue consultée le 2026-07-12)

| Fait | Détail | Source |
|---|---|---|
| Les templates de workspace existent | Un workspace se convertit en modèle : **Workspace Settings > Convert to Template**. Un nouveau projet peut être créé depuis ce template ; la copie préserve lists, todos, custom fields, automatisations et settings (asynchrone, limite 250 000 todos). API GraphQL : mutations `convertProjectToTemplate` et `createProject` avec `templateId`. | blue.cc/en/api/projects/templates |
| La duplication de workspace existe | Icône settings du workspace > **Copy** : recopie custom fields, vues, automatisations, settings, avec option d'inclure records et fichiers. Réservé aux administrateurs du projet. UI uniquement (pas d'API dédiée documentée). | blue.cc/docs/projects/copying-projects |
| La visibilité des champs se règle par rôles, pas par affichage | **Settings > User Roles > Custom Field Visibility** : contrôle quel rôle peut voir/éditer quel champ. C'est de la gestion de droits ; aucun réglage documenté ne force le dépliage par défaut des champs vides d'une carte. | blue.cc/en/docs/user-management/roles/custom-user-roles |
| CLI `blue` 0.6.6 | `blue workspaces create --name "<Nom>" --template <ID>` crée un workspace depuis un template. La CLI ne sait ni lister les templates ni convertir un workspace en template (gestes UI/API). `blue fields groups manage` gère des groupes de champs, sans réglage de visibilité. | `blue workspaces create --help`, `blue fields groups manage --help` |

**Conséquence honnête sur l'irritant 2 :** le repli des champs vides est un comportement d'interface, aucun mécanisme documenté ne le supprime. Le template n'y change rien directement ; il garantit en revanche que la structure et les réglages copiés sont identiques partout, et la discipline de la gouvernance (description toujours renseignée, field `ID` toujours rempli) fait que les champs utiles portent une valeur, donc restent visibles.

## 3. Solution proposée

1. **Créer une fois un workspace modèle** dans l'organisation, nom proposé : `_Modele_MyProjectOS` (le préfixe `_` le trie en tête et le distingue des vrais projets). Contenu : les 4 lists canoniques, le tag `Urgent`, le custom field `ID` avec sa description, aucun record. La structure peut être posée par un agent via la CLI ; les réglages visuels se font une fois dans l'UI.
2. **Le convertir en template** : Workspace Settings > Convert to Template (geste UI, à faire par l'utilisateur).
3. **À chaque nouveau projet** : créer le workspace depuis le template (UI, ou `blue workspaces create --name "<Projet>" --template <ID>`), puis :
   - créer les tags de domaine propres au projet (un par sujet/phase de `TASKS.md`) ;
   - relever les IDs réels du nouveau workspace (lists, tags, custom field — la copie génère de nouveaux IDs) via `lists list` / `tags list` / `fields list` ;
   - instancier `98_configuration/GOUVERNANCE_BLUE.md` avec ces IDs, comme aujourd'hui.

## 4. Impacts sur les artefacts méthode (si acté)

- `templates/configuration/GOUVERNANCE_BLUE.md` : nouvelle section courte « Créer le workspace d'un nouveau projet » (partir du template d'organisation, ne jamais construire à la main ; relever les IDs après création).
- `skills/my-project-os/SKILL.md` (Modes 5 et 6, proposition Blue active depuis v0.10.0 / DEC-0028) : quand l'utilisateur accepte Blue, proposer la création depuis le template d'organisation s'il existe, sinon proposer de le créer d'abord.
- Passage par le gate habituel : entrée `DEC-` (décision) + `CHG-` (application) + bump de version mineure.

## 5. Points à vérifier au premier essai (avant d'intégrer aux docs stables)

1. « Convert to Template » est-il disponible dans le plan Blue actuel de l'organisation `myagent` ?
2. La création depuis template copie-t-elle bien le custom field `ID` (avec quel nouvel ID) et les 4 lists ?
3. Les réglages d'affichage des vues font-ils partie des « settings » copiés, et le rendu des cartes est-il identique dans le workspace fils ?
4. `blue workspaces create --template <ID>` : où trouver l'ID du template (URL de l'interface web ? API `templates` ?) — la CLI ne les liste pas.

## 6. Décisions à trancher (humain)

- **D1** : valider le principe (un template d'organisation par structure canonique) et le nom du workspace modèle.
- **D2** : qui fait quoi — agent CLI pour la structure du modèle, l'utilisateur pour les réglages visuels et la conversion en template.
- **D3** : après essai concluant, intégrer aux artefacts méthode (section gabarit + skill, voir §4) ou garder comme pratique locale MyAgent.

## 7. Articulation

- Complémentaire du plan `2026-07-12-blue-cli-extension-graphql.md` (T-PLAN-2) : si l'extension GraphQL aboutit, `convertProjectToTemplate` et la liste des templates deviendraient pilotables par agent, ce qui refermerait le point 5.4 et automatiserait le §3 de bout en bout.
- S'appuie sur l'existant : gabarit `GOUVERNANCE_BLUE.md` (v0.9.0, DEC-0027) et proposition active de Blue par la skill (v0.10.0, DEC-0028).
